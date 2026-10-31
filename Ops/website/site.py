"""
JawnTide public website (jawntide.com).

Every INTERVAL_SECONDS it reads the game databases with its own SELECT-only user ("web"), which can only see
character names, levels, XP, allegiance links, the PK kill log and the arena tables (never accounts, IPs or
login history), and keeps the result in memory. Pages are rendered from that copy, so visitors never touch
the game databases. Admin characters (accessLevel > 0) are left off every page.

Pages: /  home (server info, how to connect, rules), /pk  open-world PK kills, /arena  arena standings and
matches, /levels  player levels, /allegiances  monarch trees, /health.

Preview without a database:  python site.py --sample out.html  writes every page into one file.
"""
import html
import os
import sys
import threading
import time
import traceback
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

import wiki

DB = dict(host=os.environ.get("DB_HOST", "ace-db"), port=int(os.environ.get("DB_PORT", "3306")),
          user=os.environ.get("DB_USER", "web"), password=os.environ.get("DB_PASSWORD", ""),
          charset="utf8mb4", connect_timeout=10, read_timeout=60)
INTERVAL = max(60, int(os.environ.get("INTERVAL_SECONDS", "300")))
PORT = int(os.environ.get("PORT", "8080"))
HOME_FILE = os.environ.get("HOME_FILE", os.path.join(os.path.dirname(os.path.abspath(__file__)), "home.html"))
TANKS_URL = os.environ.get("TANKS_URL", "http://play.jawntide.com:8088/")  # the JawnTanks browser game
EMBLEM_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "emblem.webp")

PROP_INT_LEVEL = 25
PROP_INT_AGE = 125          # seconds played
PROP_INT64_ALLEG_XP_RECEIVED = 9002   # pass-up XP a patron has received from vassals (stock ACE)
PROP_INT64_TOTAL_XP = 1
PROP_IID_PATRON = 25
PROP_IID_MONARCH = 26
ARENA_DONE = 6

e = lambda v: html.escape("" if v is None else str(v))
snapshot = None
snapshot_lock = threading.Lock()


# ---------------------------------------------------------------- data

def take_snapshot():
    import pymysql
    conn = pymysql.connect(**DB)
    try:
        cur = conn.cursor()

        def q(sql, args=None):
            cur.execute(sql, args)
            return cur.fetchall()

        now = q("SELECT NOW()")[0][0]
        admin_accounts = {r[0] for r in q("SELECT accountId FROM ace_auth.account WHERE accessLevel > 0")}

        chars, admins = {}, set()
        for cid, aid, name, deleted, level, xp, age, passup in q("""
                SELECT c.id, c.account_Id, c.name, c.is_Deleted, COALESCE(l.value, 1), COALESCE(x.value, 0), COALESCE(a.value, 0),
                       COALESCE(r.value, 0)
                FROM ace_shard.`character` c
                LEFT JOIN ace_shard.biota_properties_int l ON l.object_Id = c.id AND l.type = %s
                LEFT JOIN ace_shard.biota_properties_int64 x ON x.object_Id = c.id AND x.type = %s
                LEFT JOIN ace_shard.biota_properties_int a ON a.object_Id = c.id AND a.type = %s
                LEFT JOIN ace_shard.biota_properties_int64 r ON r.object_Id = c.id AND r.type = %s""",
                (PROP_INT_LEVEL, PROP_INT64_TOTAL_XP, PROP_INT_AGE, PROP_INT64_ALLEG_XP_RECEIVED)):
            if aid in admin_accounts:
                admins.add(int(cid))
                continue
            chars[int(cid)] = dict(id=int(cid), name=name, level=int(level), xp=int(xp), age=int(age), passup=int(passup),
                                   deleted=bool(deleted and deleted not in (b"\x00", 0)))

        # when each character reached its current level (ace_log.character_level_log: written by the game server,
        # older ones estimated from backups). Times are converted to server time. Missing table or grant = no times.
        try:
            for cid, level, at, est in q("""
                    SELECT characterId, level, reachedAtUtc + INTERVAL TIMESTAMPDIFF(MINUTE, UTC_TIMESTAMP(), NOW()) MINUTE, estimated
                    FROM ace_log.character_level_log"""):
                c = chars.get(int(cid))
                if c and int(level) == c["level"]:
                    c["reached"], c["reached_est"] = at, bool(est)
        except Exception as ex:
            print(f"level times unavailable: {ex}", flush=True)

        for cid, ptype, value in q("""
                SELECT p.object_Id, p.type, p.value FROM ace_shard.biota_properties_i_i_d p
                JOIN ace_shard.`character` c ON c.id = p.object_Id WHERE p.type IN (%s, %s)""",
                (PROP_IID_PATRON, PROP_IID_MONARCH)):
            ch = chars.get(int(cid))
            if ch is not None:
                ch["patron" if ptype == PROP_IID_PATRON else "monarch"] = int(value)

        # Town Control whitelist, through a one-row view (the web user can't read the rest of the server settings)
        whitelist = set()
        try:
            for (value,) in q("SELECT value FROM ace_web.town_control_whitelist"):
                whitelist |= {int(x) for x in (value or "").split(",") if x.strip().isdigit()}
        except Exception as ex:
            print(f"town control whitelist not readable: {ex}", flush=True)

        kills = []
        for killer, victim, km, vm, when in q("""
                SELECT killer_id, victim_id, killer_monarch_id, victim_monarch_id, kill_datetime
                FROM ace_log.pk_kills_log WHERE killer_arena_player_id IS NULL ORDER BY kill_datetime"""):
            if killer in admins or victim in admins:
                continue
            kills.append(dict(killer=int(killer), victim=int(victim), km=km, vm=vm, when=when))

        arena_stats = []
        for cid, name, etype, matches, wins, losses, draws, dq, deaths, ks, dealt, recv, points in q("""
                SELECT character_id, character_name, event_type, total_matches, total_wins, total_losses,
                       total_draws, total_disqualified, total_deaths, total_kills, total_dmg_dealt,
                       total_dmg_received, rank_points FROM ace_log.arena_character_stats"""):
            if cid in admins:
                continue
            arena_stats.append(dict(id=cid, name=name, type=etype, matches=matches or 0, wins=wins or 0,
                                    losses=losses or 0, draws=draws or 0, dq=dq or 0, deaths=deaths or 0,
                                    kills=ks or 0, dealt=dealt or 0, received=recv or 0, points=points or 0))

        events = {}
        for eid, etype, ended, winner in q("""
                SELECT id, event_type, end_datetime, winning_team_guid FROM ace_log.arena_event
                WHERE status = %s AND end_datetime IS NOT NULL ORDER BY end_datetime DESC LIMIT 25""", (ARENA_DONE,)):
            events[eid] = dict(id=eid, type=etype, ended=ended, winner=winner, players=[])
        if events:
            marks = ",".join(["%s"] * len(events))
            for eid, cid, name, team, ks, deaths in q(f"""
                    SELECT event_id, character_id, character_name, team_guid, total_kills, total_deaths
                    FROM ace_log.arena_player WHERE event_id IN ({marks})""", tuple(events)):
                if cid not in admins:
                    events[eid]["players"].append(dict(id=cid, name=name, team=team, kills=ks or 0, deaths=deaths or 0))

        # Town Control: towns and recent battles (times there are UTC)
        utc = q("SELECT UTC_TIMESTAMP()")[0][0]
        towns = [dict(id=tid, name=name, owner=owner, conflict=bit(conf), length=int(length or 0), respite=int(resp or 0))
                 for tid, name, owner, conf, length, resp in q("""
                     SELECT town_id, town_name, owner_Id, is_in_conflict, conflict_length, conflict_respite_length
                     FROM ace_town_control.town ORDER BY town_name""")]
        battles = [dict(id=eid, town=tid, start=start, end=end, attacker=att, attacker_name=an, defender=dfn,
                        defender_name=dn, won=None if won is None else bit(won))
                   for eid, tid, start, end, att, an, dfn, dn, won in q("""
                       SELECT event_id, town_id, event_start_time, event_end_time, attacker_id, attacker_clan_name,
                              defender_id, defender_clan_name, is_attack_success
                       FROM ace_town_control.town_control_event ORDER BY event_start_time DESC LIMIT 500""")]

        patrons = {c["patron"] for c in chars.values() if c.get("patron")}
        return dict(taken=now, chars=chars, kills=kills, arena_stats=arena_stats, patrons=patrons, whitelist=whitelist,
                    utc=utc, towns=towns, battles=battles,
                    arena_events=sorted(events.values(), key=lambda v: v["ended"], reverse=True))
    finally:
        conn.close()


def bit(v):
    return bool(v) and v not in (b"\x00", 0, "0")


def collector():
    global snapshot
    while True:
        try:
            snap = take_snapshot()
            with snapshot_lock:
                snapshot = snap
        except Exception:
            traceback.print_exc()
        time.sleep(INTERVAL)


def get_snapshot():
    with snapshot_lock:
        return snapshot


# ---------------------------------------------------------------- formatting

def n(v):
    return f"{v:,}"


def ago(when, now):
    s = max(0, int((now - when).total_seconds()))
    if s < 60:
        return "just now"
    if s < 3600:
        return f"{s // 60} min ago"
    if s < 86400:
        return f"{s // 3600} h ago"
    d = s // 86400
    return f"{d} day{'s' if d != 1 else ''} ago"


def name_of(snap, cid):
    c = snap["chars"].get(cid)
    return c["name"] if c else "Unknown"


def allegiance_name(snap, cid):
    """Monarch's name for a character's allegiance; a monarch with vassals counts as their own allegiance"""
    c = snap["chars"].get(cid)
    if not c:
        return ""
    mid = c.get("monarch")
    if mid is None and "patrons" in snap and cid in snap["patrons"]:
        mid = cid
    m = snap["chars"].get(mid)
    return m["name"] if m else ""


SHOW = [("25", 25), ("50", 50), ("100", 100), ("250", 250), ("all", None)]


def parse_show(query, default):
    v = query.get("show", [""])[0]
    return next((s for s in SHOW if s[0] == v), next(s for s in SHOW if s[0] == default))


def show_links(path, keep, current):
    """'Show 25 50 100 250 All' links that keep the page's other choices (window, type)"""
    extra = "".join(f"&amp;{k}={e(v)}" for k, v in keep.items() if v)
    links = "".join(f'<a href="{path}?show={k}{extra}"{" aria-current=page" if k == current else ""}>{"All" if k == "all" else k}</a>'
                    for k, _ in SHOW)
    return f'<div class="show"><span class="muted">Show</span>{links}</div>'


def tc_badge(snap, monarch_id):
    return ' <span class="badge">Town Control</span>' if monarch_id in snap.get("whitelist", set()) else ""


def span_text(seconds):
    s = max(0, int(seconds))
    d, h, m = s // 86400, s % 86400 // 3600, s % 3600 // 60
    if d:
        return f"{d}d {h}h" if h else f"{d}d"
    if h:
        return f"{h}h {m}m" if m else f"{h}h"
    return f"{max(m, 1)}m" if s else "0m"


def played(seconds):
    """In-game played time in hours and minutes"""
    s = max(0, int(seconds or 0))
    return f"{s // 3600:,}h {s % 3600 // 60}m"


def countdown(end, utc):
    """Time left until end (UTC); the page's script keeps it ticking between refreshes"""
    return f'<span class="cd" data-end="{end.strftime("%Y-%m-%dT%H:%M:%SZ")}">{span_text((end - utc).total_seconds())}</span>'


def rank_cell(i):
    cls = " top" if i <= 3 else ""
    return f'<td class="rank{cls}">{i}</td>'


# ---------------------------------------------------------------- layout

FONTS = ('<link rel="preconnect" href="https://fonts.googleapis.com">'
         '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
         '<link href="https://fonts.googleapis.com/css2?family=Pirata+One&family=Alegreya+Sans:ital,wght@0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">')

CSS = """
:root{
  /* palette taken from the Asheron's Call emblem painting: night-blue sky, cloud white, sky cyan, orchid, sun-gold grass */
  --night:#0F1430;--deep:#0A0E24;--panel:#18204A;--line:#2C3570;
  --bone:#F3EEF6;--dim:#A8B3D9;--portal:#65B8FB;--blood:#C885F6;--gold:#DFCC7C;--royal:#324DF7;--on-accent:#0A0E24;
  --display:"Pirata One","UnifrakturMaguntia",Georgia,serif;
  --body:"Alegreya Sans","Segoe UI",system-ui,sans-serif;
  color-scheme:dark;box-sizing:border-box;
  padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px);
}
@media (prefers-color-scheme:light){
  :root:not([data-theme="dark"]){--night:#EEF3FF;--deep:#DDE6FB;--panel:#FFFFFF;--line:#C6D0EE;
    --bone:#141A3A;--dim:#4E5A86;--portal:#2440D8;--blood:#8A3FC2;--gold:#7A6620;--royal:#2440D8;--on-accent:#FFFFFF;color-scheme:light}
}
*,*::before,*::after{box-sizing:inherit}
html{scroll-padding-top:env(safe-area-inset-top,0px);overflow-x:clip}
body{margin:0;overflow-x:clip;background:var(--night);color:var(--bone);font:400 1.0625rem/1.55 var(--body);
  font-variant-numeric:lining-nums tabular-nums}
a{color:var(--portal)}
a:focus-visible,button:focus-visible,summary:focus-visible{outline:2px solid var(--portal);outline-offset:3px;border-radius:2px}
header.bar{position:sticky;top:env(safe-area-inset-top,0px);z-index:5;background:var(--deep);border-bottom:1px solid var(--line)}
body::before{content:"";position:fixed;inset:0 0 auto;height:env(safe-area-inset-top,0px);z-index:10;background:var(--deep)}
.bar-in{max-width:68rem;margin:0 auto;padding:.55rem 1.25rem;display:flex;gap:1.5rem;align-items:baseline;flex-wrap:wrap}
.mark{font:400 1.7rem/1 var(--display);color:var(--bone);text-decoration:none}
nav{display:flex;gap:.25rem 1.1rem;flex-wrap:wrap}
nav a{color:var(--dim);text-decoration:none;padding:.2rem 0;border-bottom:2px solid transparent}
nav a:hover{color:var(--bone)}
nav a[aria-current]{color:var(--bone);border-bottom-color:var(--blood)}
nav a.play{color:var(--portal);font-weight:700}
.tanks{display:flex;flex-wrap:wrap;align-items:center;gap:.8rem 1.4rem;margin-top:.4rem}
main{max-width:68rem;margin:0 auto;padding:2rem 1.25rem 4rem}
h1{font:400 clamp(2.2rem,5vw,3.2rem)/1.05 var(--display);margin:0 0 .4rem;letter-spacing:.01em}
h2{font:400 1.9rem/1.1 var(--display);margin:2.6rem 0 .8rem}
h3{font:700 1.1rem/1.3 var(--body);margin:1.4rem 0 .5rem}
p{max-width:40rem}
.lede{color:var(--dim);margin:0 0 1.6rem;max-width:40rem}
.muted{color:var(--dim)}
.wrap{overflow-x:auto;margin:0 -.25rem}
table{border-collapse:collapse;width:100%;min-width:32rem}
th,td{text-align:left;padding:.45rem .6rem;border-bottom:1px solid var(--line);white-space:nowrap}
th{font-weight:500;color:var(--dim)}
td.n,th.n{text-align:right}
td.rank{color:var(--dim);width:2.5rem}
td.rank.top{color:var(--gold);font-weight:700}
td.k{color:var(--blood);font-weight:700}
.tabs{display:flex;gap:.5rem;flex-wrap:wrap;margin:0 0 1.2rem}
.tabs a{padding:.3rem .8rem;border:1px solid var(--line);border-radius:999px;color:var(--dim);text-decoration:none}
.tabs a[aria-current]{background:var(--panel);color:var(--bone);border-color:var(--portal)}
.show{display:flex;gap:.2rem .75rem;flex-wrap:wrap;align-items:baseline;margin:.8rem 0 0;font-size:.95rem}
.show a{color:var(--dim);text-decoration:none;padding:0 .1rem;border-bottom:2px solid transparent}
.show a:hover{color:var(--bone)}
.show a[aria-current]{color:var(--bone);border-bottom-color:var(--portal)}
.war{color:var(--blood);font-weight:700}
.calm{color:var(--dim)}
.resp{display:block;color:var(--dim);font-size:.95rem}
td.wrapcell{white-space:normal;min-width:12rem}
.feed{list-style:none;padding:0;margin:0;max-width:40rem}
.feed li{display:flex;justify-content:space-between;gap:1rem;padding:.45rem 0;border-bottom:1px solid var(--line)}
.feed b{font-weight:700}
.feed li>span:last-child{white-space:nowrap}
.feed .x{color:var(--blood)}
.cols{display:grid;gap:0 2.5rem;grid-template-columns:repeat(auto-fit,minmax(min(100%,26rem),1fr))}
.empty{padding:1.2rem 0;color:var(--dim)}
.stamp{color:var(--dim);font-size:.9rem;margin-top:3rem}
/* home */
.hero{position:relative;padding:3.5rem 0 2.5rem}
.hero::before{content:"";position:absolute;width:min(34rem,90vw);height:min(34rem,90vw);right:-9rem;top:-7rem;border-radius:50%;
  background:conic-gradient(from 0deg,transparent 0 12%,var(--royal) 22%,transparent 34% 48%,var(--blood) 60%,transparent 72% 84%,var(--portal) 94%,transparent);
  filter:blur(46px);opacity:.38;animation:turn 90s linear infinite;pointer-events:none}
@keyframes turn{to{transform:rotate(360deg)}}
@media (prefers-reduced-motion:reduce){.hero::before{animation:none}}
.hero h1{position:relative;font-size:clamp(4rem,14vw,8.5rem);line-height:.9;margin:0;display:flex;align-items:center;gap:.18em}
.hero h1 .emblem{width:1.05em;height:1.05em;flex:none;border-radius:50%;filter:drop-shadow(0 .06em .12em rgba(0,0,0,.45))}
.hero p{position:relative;font-size:1.3rem;margin:.9rem 0 0;max-width:34rem}
.connect{position:relative;margin-top:2rem;display:inline-flex;flex-wrap:wrap;align-items:center;gap:.6rem 1.2rem;
  padding:1rem 1.2rem;background:var(--panel);border:1px solid var(--line);border-left:4px solid var(--blood);border-radius:6px}
.connect code{font:700 1.35rem/1.2 var(--body);color:var(--bone)}
.connect .port{color:var(--dim);font-size:1.05rem}
button.copy{font:500 .95rem var(--body);color:var(--bone);background:transparent;border:1px solid var(--line);
  border-radius:4px;padding:.3rem .8rem;cursor:pointer}
button.copy:hover{border-color:var(--portal)}
ol.steps{padding-left:1.4rem;max-width:42rem}
ol.steps li{margin:.0 0 .9rem;padding-left:.3rem}
ol.steps li::marker{font:400 1.3rem var(--display);color:var(--blood)}
dl.facts{display:grid;grid-template-columns:max-content 1fr;gap:.5rem 1.4rem;max-width:44rem;margin:0}
dl.facts dt{color:var(--dim)}
dl.facts dd{margin:0}
.rules{max-width:42rem}
.discord{display:inline-block;margin-top:.4rem;padding:.55rem 1.1rem;border-radius:4px;background:var(--portal);
  color:var(--on-accent);text-decoration:none;font-weight:700}
/* levels */
.bars{max-width:40rem;display:grid;grid-template-columns:auto 1fr auto;gap:.35rem .8rem;align-items:center}
.bars .bar{height:.75rem;background:var(--portal);border-radius:2px;min-width:2px}
/* allegiances */
details{border-bottom:1px solid var(--line);padding:.55rem 0}
summary{cursor:pointer;display:flex;gap:1rem;flex-wrap:wrap;align-items:baseline}
summary b{font:400 1.35rem/1.2 var(--display)}
.badge{font-size:.85rem;font-weight:500;color:var(--gold);border:1px solid var(--gold);border-radius:999px;padding:.05rem .55rem;white-space:nowrap}
ul.tree{list-style:none;margin:.4rem 0 .2rem;padding-left:1.1rem;border-left:1px solid var(--line)}
ul.tree li{padding:.12rem 0}
/* wiki */
.wikibar{display:flex;flex-wrap:wrap;gap:.5rem 1.1rem;align-items:center;padding:.6rem 0 1rem;margin-bottom:1.2rem;border-bottom:1px solid var(--line);font-size:.95rem}
.wikibar>a{color:var(--dim);text-decoration:none}.wikibar>a:hover{color:var(--bone)}
.wsearch input{font:inherit;color:var(--bone);background:var(--panel);border:1px solid var(--line);border-radius:4px;padding:.25rem .6rem;width:12rem}
.who{margin-left:auto;color:var(--dim);display:flex;gap:.6rem;align-items:center;flex-wrap:wrap}
.who form,form.inline{display:inline}
button.link{font:inherit;color:var(--portal);background:none;border:0;padding:0;cursor:pointer;text-decoration:underline}
.btn{display:inline-block;font:700 1rem var(--body);color:var(--on-accent);background:var(--portal);border:0;border-radius:4px;padding:.5rem 1.1rem;cursor:pointer;text-decoration:none}
.btn.quiet{background:transparent;color:var(--bone);border:1px solid var(--line);font-weight:500}
.wlist{list-style:none;padding:0;margin:0;max-width:44rem}
.wlist li{display:flex;justify-content:space-between;gap:1rem;padding:.5rem 0;border-bottom:1px solid var(--line);flex-wrap:wrap}
.wtools{display:flex;gap:.6rem 1rem;flex-wrap:wrap;align-items:center;margin:.2rem 0 1rem;font-size:.95rem}
.wmeta{color:var(--dim);font-size:.9rem}
.toc{display:block;float:right;margin:0 0 1rem 1.5rem;padding:.8rem 1.1rem;background:var(--panel);border:1px solid var(--line);border-radius:6px;max-width:16rem;font-size:.95rem}
.toc b{display:block;margin-bottom:.3rem}.toc a{display:block;padding:.1rem 0;border:0;color:var(--portal)}
@media (max-width:40rem){.toc{float:none;margin:0 0 1rem}}
.wiki{max-width:46rem}.wiki h2{clear:none}.wiki table{min-width:0;width:auto}.wiki td,.wiki th{white-space:normal}
.wiki li{margin:.2rem 0}.wiki code{background:var(--panel);padding:.05rem .3rem;border-radius:3px}
.wiki a.missing{color:var(--blood)}
.note{border-left:4px solid var(--gold);background:var(--panel);padding:.6rem 1rem;margin:1rem 0;max-width:42rem}
.codebox{background:var(--deep);border:1px solid var(--line);border-radius:4px;padding:.7rem 1rem;overflow-x:auto}
.wedit{max-width:46rem;display:grid;gap:.9rem}
.wedit label{display:grid;gap:.3rem;color:var(--dim)}
.wedit input,.wedit textarea{font:inherit;color:var(--bone);background:var(--panel);border:1px solid var(--line);border-radius:4px;padding:.45rem .6rem;width:100%}
.wedit textarea{min-height:24rem;font:.95rem/1.5 ui-monospace,Consolas,monospace}
.row{display:flex;gap:.8rem;flex-wrap:wrap;align-items:center}
.err{color:var(--blood);font-weight:700}
.help{color:var(--dim);font-size:.92rem;max-width:46rem}
.linkcode{font:700 clamp(1.4rem,5vw,2.2rem)/1.2 ui-monospace,Consolas,monospace;letter-spacing:.08em;color:var(--gold);margin:.6rem 0 1rem}
"""

PAGES = [("/", "Home"), ("/pk", "PK kills"), ("/towns", "Town Control"), ("/arena", "Arena"), ("/levels", "Levels"), ("/allegiances", "Allegiances")]


def layout(path, title, body, snap):
    nav = "".join(f'<a href="{p}"{" aria-current=page" if p == path else ""}>{t}</a>' for p, t in PAGES)
    nav += f'<a href="/wiki"{" aria-current=page" if path == "/wiki" else ""}>Wiki</a>'
    nav += f'<a class="play" href="{e(TANKS_URL)}">JawnTanks</a>'
    stamp = f'<p class="stamp">Updated {e(snap["taken"].strftime("%b %d, %I:%M %p"))} server time. Refreshes every {INTERVAL // 60} minutes.</p>' if snap else ""
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8">'
            f'<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">'
            f'<title>{e(title)} | JawnTide</title><meta name="description" content="JawnTide, a red Asheron\'s Call server. Everyone is a player killer.">'
            f'{FONTS}<style>{CSS}</style></head><body>'
            f'<header class="bar"><div class="bar-in"><a class="mark" href="/">JawnTide</a><nav>{nav}</nav></div></header>'
            f'<main>{body}{stamp}</main>'
            '<script>function tick(){const now=Date.now();document.querySelectorAll(".cd").forEach(el=>{'
            'let s=Math.max(0,Math.floor((Date.parse(el.dataset.end)-now)/1000));const d=Math.floor(s/86400),h=Math.floor(s%86400/3600),m=Math.floor(s%3600/60),x=s%60;'
            'el.textContent=d?(h?`${d}d ${h}h`:`${d}d`):h?(m?`${h}h ${m}m`:`${h}h`):s?`${m}m ${x}s`:"ending"})}tick();setInterval(tick,1000);'
            'document.querySelectorAll("button.copy").forEach(b=>b.addEventListener("click",()=>{'
            'navigator.clipboard.writeText(b.dataset.copy).then(()=>{b.textContent="Copied";setTimeout(()=>b.textContent="Copy address",1600)})}))</script>'
            f'</body></html>')


# ---------------------------------------------------------------- pages

def home_page(snap):
    try:
        with open(HOME_FILE, encoding="utf-8") as f:
            return f.read().replace("{{TANKS_URL}}", e(TANKS_URL))
    except OSError:
        return "<h1>JawnTide</h1><p>play.jawntide.com, port 9000</p>"


WINDOWS = [("24h", "Last 24 hours", timedelta(hours=24)), ("7d", "Last 7 days", timedelta(days=7)),
           ("30d", "Last 30 days", timedelta(days=30)), ("all", "All time", None)]


def pk_page(snap, window, query):
    key, label, span = next((w for w in WINDOWS if w[0] == window), WINDOWS[1])
    show_key, limit = parse_show(query, "50")
    now = snap["taken"]
    kills = [k for k in snap["kills"] if span is None or k["when"] >= now - span]
    tabs = "".join(f'<a href="/pk?window={k}&amp;show={show_key}"{" aria-current=page" if k == key else ""}>{t}</a>' for k, t, _ in WINDOWS)

    tally = {}
    for k in kills:
        tally.setdefault(k["killer"], [0, 0])[0] += 1
        tally.setdefault(k["victim"], [0, 0])[1] += 1
    board = sorted(((cid, kd) for cid, kd in tally.items() if kd[0] > 0),
                   key=lambda r: (-r[1][0], -(r[1][0] / max(r[1][1], 1)), name_of(snap, r[0])))[:limit]
    rows = []
    for i, (cid, (k, d)) in enumerate(board, 1):
        rows.append(f'<tr>{rank_cell(i)}<td>{e(name_of(snap, cid))}</td><td class="muted">{e(allegiance_name(snap, cid))}</td>'
                    f'<td class="n k">{n(k)}</td><td class="n">{n(d)}</td><td class="n">{k / max(d, 1):.2f}</td></tr>')
    killers = (f'<div class="wrap"><table><tr><th></th><th>Character</th><th>Allegiance</th><th class="n">Kills</th>'
               f'<th class="n">Deaths</th><th class="n">K/D</th></tr>{"".join(rows)}</table></div>' if rows
               else '<p class="empty">No kills in this window yet.</p>') + show_links("/pk", {"window": key}, show_key)

    alleg = {}
    for k in kills:
        if k["km"]:
            alleg.setdefault(k["km"], [0, 0])[0] += 1
        if k["vm"]:
            alleg.setdefault(k["vm"], [0, 0])[1] += 1
    arows = []
    for i, (mid, (k, d)) in enumerate(sorted(((m, v) for m, v in alleg.items() if v[0] > 0), key=lambda r: -r[1][0])[:15], 1):
        arows.append(f'<tr>{rank_cell(i)}<td>{e(name_of(snap, mid))}{tc_badge(snap, mid)}</td><td class="n k">{n(k)}</td><td class="n">{n(d)}</td></tr>')
    allegs = (f'<div class="wrap"><table style="min-width:20rem"><tr><th></th><th>Monarch</th><th class="n">Kills</th><th class="n">Deaths</th></tr>'
              f'{"".join(arows)}</table></div>' if arows else '<p class="empty">No allegiance kills in this window yet.</p>')

    recent = "".join(f'<li><span><b>{e(name_of(snap, k["killer"]))}</b> <span class="x">killed</span> {e(name_of(snap, k["victim"]))}</span>'
                     f'<span class="muted">{ago(k["when"], now)}</span></li>' for k in reversed(snap["kills"][-25:]))

    return (f'<h1>PK kills</h1><p class="lede">Player kills out in the world. Arena fights are on the Arena page. '
            f'{n(len(kills))} kills {label.lower()}.</p><div class="tabs">{tabs}</div>{killers}'
            f'<div class="cols"><section><h2>Allegiances</h2>{allegs}</section>'
            f'<section><h2>Latest kills</h2><ul class="feed">{recent or "<li class=muted>No kills yet.</li>"}</ul></section></div>')


def towns_page(snap):
    utc = snap["utc"]
    towns, battles = snap["towns"], snap["battles"]
    if not towns:
        return '<h1>Town Control</h1><p class="empty">No towns are set up for Town Control yet.</p>'
    allegiance = lambda mid, fallback=None: e(name_of(snap, mid)) if mid in snap["chars"] else e(fallback or "Unknown")

    rows = []
    for t in towns:
        active = next((b for b in battles if b["town"] == t["id"] and b["end"] is None), None) if t["conflict"] else None
        holder = allegiance(t["owner"]) if t["owner"] else '<span class="calm">Nobody</span>'
        if active:
            status = (f'<span class="war">Under attack</span><span class="resp">{e(active["attacker_name"])} challenging '
                      f'{e(active["defender_name"]) if active["defender_name"] else "an empty town"}</span>')
            timer = countdown(active["start"] + timedelta(seconds=t["length"]), utc)
        else:
            status, timer = '<span class="calm">Peaceful</span>', '<span class="calm">No battle</span>'
        # respite: an allegiance that started an attack here can't kill the governor again until respite has passed
        latest = {}
        for b in battles:
            if b["town"] == t["id"] and b["attacker"] not in latest:
                latest[b["attacker"]] = b
        waiting = sorted(((b["attacker_name"], b["start"] + timedelta(seconds=t["respite"])) for b in latest.values()
                          if b["start"] + timedelta(seconds=t["respite"]) > utc), key=lambda w: w[1])
        resp = "".join(f'<span class="resp">{e(nm)} {countdown(until, utc)}</span>' for nm, until in waiting)
        rows.append(f'<tr><td><b>{e(t["name"])}</b></td><td>{holder}{tc_badge(snap, t["owner"]) if t["owner"] else ""}</td>'
                    f'<td class="wrapcell">{status}</td><td>{timer}<span class="resp">lasts {span_text(t["length"])}</span></td>'
                    f'<td class="wrapcell">{span_text(t["respite"])} per allegiance{resp or "<span class=resp>Nobody waiting</span>"}</td></tr>')
    table = (f'<div class="wrap"><table><tr><th>Town</th><th>Held by</th><th>Status</th><th>Battle timer</th>'
             f'<th>Governor respite</th></tr>{"".join(rows)}</table></div>')

    held = {}
    for t in towns:
        if t["owner"]:
            held.setdefault(t["owner"], []).append(t["name"])
    hrows = "".join(f'<tr>{rank_cell(i)}<td>{allegiance(mid)}{tc_badge(snap, mid)}</td><td class="n k">{len(ns)}</td>'
                    f'<td class="muted wrapcell">{e(", ".join(sorted(ns)))}</td></tr>'
                    for i, (mid, ns) in enumerate(sorted(held.items(), key=lambda h: (-len(h[1]), name_of(snap, h[0]))), 1))
    holders = (f'<div class="wrap"><table style="min-width:24rem"><tr><th></th><th>Allegiance</th><th class="n">Towns</th><th>Which</th></tr>'
               f'{hrows}</table></div>' if hrows else '<p class="empty">No town is held yet.</p>')

    names = {t["id"]: t["name"] for t in towns}
    feed = []
    for b in battles[:20]:
        town = e(names.get(b["town"], "a town"))
        vs = f' held by {e(b["defender_name"])}' if b["defender_name"] else ""
        if b["end"] is None:
            result = '<span class="war">battle on</span>'
        elif b["won"]:
            result = "taken"
        else:
            result = "held"
        feed.append(f'<li><span><b>{e(b["attacker_name"])}</b> attacked {town}{vs}: {result}</span>'
                    f'<span class="muted">{ago(b["start"], utc)}</span></li>')
    return (f'<h1>Town Control</h1><p class="lede">Kill a town’s governor to start a battle for it. The battle runs for the '
            f'battle timer; hold the town to the end and it’s yours. An allegiance that starts a battle must wait out the '
            f'respite before it can kill that town’s governor again. Only whitelisted allegiances can take part.</p>'
            f'{table}<div class="cols"><section><h2>Towns held</h2>{holders}</section>'
            f'<section><h2>Recent battles</h2><ul class="feed">{"".join(feed) or "<li class=muted>No battles yet.</li>"}</ul></section></div>')


def arena_page(snap, etype, query):
    show_key, limit = parse_show(query, "50")
    types = sorted({s["type"] for s in snap["arena_stats"] if s["type"]}, key=lambda t: (t != "1v1", t != "2v2", t))
    now = snap["taken"]
    if not types:
        return ('<h1>Arena</h1><p class="lede">Arena standings and recent matches.</p>'
                '<p class="empty">No arena matches yet. Join the queue in game with /arena join.</p>')
    etype = etype if etype in types else types[0]
    tabs = "".join(f'<a href="/arena?type={e(t)}&amp;show={show_key}"{" aria-current=page" if t == etype else ""}>{e(t)}</a>' for t in types)
    stats = sorted((s for s in snap["arena_stats"] if s["type"] == etype and s["matches"] > 0),
                   key=lambda s: (-s["points"], -s["wins"], s["name"] or ""))[:limit]
    rows = "".join(
        f'<tr>{rank_cell(i)}<td>{e(s["name"])}</td><td class="n k">{n(s["points"])}</td><td class="n">{n(s["matches"])}</td>'
        f'<td class="n">{n(s["wins"])}</td><td class="n">{n(s["losses"])}</td><td class="n">{n(s["draws"])}</td>'
        f'<td class="n">{n(s["kills"])}</td><td class="n">{n(s["deaths"])}</td><td class="n">{n(s["dealt"])}</td></tr>'
        for i, s in enumerate(stats, 1))
    table = (f'<div class="wrap"><table><tr><th></th><th>Character</th><th class="n">Rank points</th><th class="n">Matches</th>'
             f'<th class="n">Wins</th><th class="n">Losses</th><th class="n">Draws</th><th class="n">Kills</th>'
             f'<th class="n">Deaths</th><th class="n">Damage dealt</th></tr>{rows}</table></div>' if rows
             else '<p class="empty">No matches of this type yet.</p>') + show_links("/arena", {"type": etype}, show_key)

    all_matches = sum(s["matches"] for s in snap["arena_stats"])
    matches = []
    for ev in snap["arena_events"][:15]:
        winners = [p for p in ev["players"] if ev["winner"] and p["team"] == ev["winner"]]
        others = [p for p in ev["players"] if p not in winners]
        names = lambda ps: ", ".join(e(p["name"]) for p in ps) or "nobody"
        result = (f'<b>{names(winners)}</b> beat {names(others)}' if winners else f'Draw between {names(ev["players"])}')
        matches.append(f'<li><span><span class="muted">{e(ev["type"])}</span>&ensp;{result}</span>'
                       f'<span class="muted">{ago(ev["ended"], now)}</span></li>')
    return (f'<h1>Arena</h1><p class="lede">Standings by rank points. Join the queue in game with /arena join.</p>'
            f'<div class="tabs">{tabs}</div>{table}'
            f'<h2>Recent matches</h2><ul class="feed">{"".join(matches) or "<li class=muted>No finished matches yet.</li>"}</ul>')


LEVEL_SORTS = [("total", "By level, first to reach it first"), ("earned", "By earned XP (no pass-up)")]
NEVER = datetime(9999, 1, 1)


def reached(c):
    at = c.get("reached")
    if not at:
        return ""
    text = at.strftime("%b %d, %I:%M %p").replace(" 0", " ")
    return f'<span title="Estimated from backups">~{e(text)}</span>' if c.get("reached_est") else e(text)


def levels_page(snap, query):
    show_key, limit = parse_show(query, "100")
    sort = query.get("sort", ["total"])[0]
    sort = sort if sort in dict(LEVEL_SORTS) else "total"
    live = [c for c in snap["chars"].values() if not c["deleted"]]
    earned = lambda c: max(0, c["xp"] - c.get("passup", 0))
    if sort == "earned":
        top = sorted(live, key=lambda c: (-earned(c), -c["level"], c["name"]))[:limit]
    else:
        # same level: whoever got there first ranks higher; no recorded time yet goes after, by total XP
        top = sorted(live, key=lambda c: (-c["level"], c.get("reached") or NEVER, -c["xp"], c["name"]))[:limit]
    tabs = "".join(f'<a href="/levels?sort={k}&amp;show={show_key}"{" aria-current=page" if k == sort else ""}>{t}</a>'
                   for k, t in LEVEL_SORTS)
    rows = "".join(
        f'<tr>{rank_cell(i)}<td>{e(c["name"])}</td><td class="n k">{c["level"]}</td><td class="n">{n(c["xp"])}</td>'
        f'<td class="n">{n(earned(c))}</td><td class="n">{n(c.get("passup", 0))}</td>'
        f'<td class="n">{played(c.get("age", 0))}</td><td class="n muted">{reached(c)}</td><td class="muted">{e(allegiance_name(snap, c["id"]))}</td></tr>'
        for i, c in enumerate(top, 1))
    brackets = {}
    for c in live:
        b = min(c["level"] // 25 * 25, 275)
        brackets[b] = brackets.get(b, 0) + 1
    most = max(brackets.values()) if brackets else 1
    bars = "".join(f'<span>{b}–{b + 24}</span><span class="bar" style="width:{100 * v / most:.1f}%"></span><span class="n">{n(v)}</span>'
                   for b, v in sorted(brackets.items()))
    shown = f"The {n(len(top))} highest characters" if len(top) < len(live) else "Every character"
    return (f'<h1>Levels</h1><p class="lede">{shown} on the server, out of {n(len(live))}. Pass-up XP is what a '
            f'character has received from its vassals; earned XP is the rest of its total. Characters at the same level '
            f'are ordered by when they reached it; times marked ~ are estimated from backups (to within minutes for most).</p><div class="tabs">{tabs}</div>'
            f'<div class="wrap"><table><tr><th></th><th>Character</th><th class="n">Level</th><th class="n">Total XP</th>'
            f'<th class="n">Earned XP</th><th class="n">Pass-up XP</th><th class="n">Time played</th><th class="n">Reached level</th><th>Allegiance</th></tr>{rows}</table></div>{show_links("/levels", {"sort": sort}, show_key)}'
            f'<h2>Everyone by level</h2><div class="bars">{bars}</div>')


def allegiances_page(snap, query):
    show_key, limit = parse_show(query, "all")
    live = {cid: c for cid, c in snap["chars"].items() if not c["deleted"]}
    children = {}
    for c in live.values():
        if c.get("patron") in live:
            children.setdefault(c["patron"], []).append(c)
    roots = [c for c in live.values() if c.get("patron") not in live and c["id"] in children]
    week = snap["taken"] - timedelta(days=7)
    kills = {}
    for k in snap["kills"]:
        if k["when"] >= week and k["km"]:
            kills[k["km"]] = kills.get(k["km"], 0) + 1

    sizes = {}

    def size(c):
        if c["id"] not in sizes:
            sizes[c["id"]] = 1 + sum(size(k) for k in children.get(c["id"], []))
        return sizes[c["id"]]

    def members(c):
        out = [c]
        for k in children.get(c["id"], []):
            out += members(k)
        return out

    def tree(c):
        kids = sorted(children.get(c["id"], []), key=lambda k: (-size(k), -k["level"], k["name"]))
        inner = "".join(tree(k) for k in kids)
        return (f'<li>{e(c["name"])} <span class="muted">{c["level"]}</span>'
                + (f'<ul class="tree">{inner}</ul>' if inner else "") + "</li>")

    blocks = []
    for r in sorted(roots, key=lambda r: (-size(r), r["name"]))[:limit]:
        m = members(r)
        badge = '<span class="badge">Town Control</span>' if r["id"] in snap.get("whitelist", set()) else ""
        blocks.append(f'<details><summary><b>{e(r["name"])}</b>{badge}<span class="muted">{len(m)} members, highest level '
                      f'{max(x["level"] for x in m)}, {n(kills.get(r["id"], 0))} kills this week</span></summary>'
                      f'<ul class="tree">{"".join(tree(k) for k in sorted(children[r["id"]], key=lambda k: (-size(k), -k["level"], k["name"])))}</ul></details>')
    return (f'<h1>Allegiances</h1><p class="lede">Every allegiance with at least one vassal, largest first. '
            f'Open one to see its tree. Numbers next to names are levels. '
            f'<span class="badge">Town Control</span> marks allegiances whitelisted for Town Control.</p>'
            f'{"".join(blocks) or "<p class=empty>No allegiances yet.</p>"}{show_links("/allegiances", {}, show_key) if roots else ""}')


def render(path, query, snap):
    if snap is None:
        return layout(path, "JawnTide", "<h1>JawnTide</h1><p>Loading the latest numbers. Try again in a minute.</p>", None)
    if path == "/":
        return layout(path, "A red Asheron's Call server", home_page(snap), snap)
    if path == "/pk":
        return layout(path, "PK kills", pk_page(snap, query.get("window", ["7d"])[0], query), snap)
    if path == "/towns":
        return layout(path, "Town Control", towns_page(snap), snap)
    if path == "/arena":
        return layout(path, "Arena", arena_page(snap, query.get("type", [""])[0], query), snap)
    if path == "/levels":
        return layout(path, "Levels", levels_page(snap, query), snap)
    if path == "/allegiances":
        return layout(path, "Allegiances", allegiances_page(snap, query), snap)
    return None


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            if wiki.handle(self, "POST"):
                return
            self.send_error(405)
        except Exception:
            traceback.print_exc()
            self.send_error(500)

    def do_GET(self):
        url = urlparse(self.path)
        try:
            if wiki.handle(self, "GET"):
                return
            if url.path == "/emblem.webp":
                with open(EMBLEM_FILE, "rb") as f:
                    data = f.read()
                self.send_response(200)
                self.send_header("Content-Type", "image/webp")
                self.send_header("Content-Length", str(len(data)))
                self.send_header("Cache-Control", "public, max-age=86400")
                self.send_header("X-Content-Type-Options", "nosniff")
                self.end_headers()
                self.wfile.write(data)
                return
            if url.path == "/health":
                body, ctype = "ok", "text/plain"
            else:
                body = render(url.path, parse_qs(url.query), get_snapshot())
                ctype = "text/html; charset=utf-8"
                if body is None:
                    self.send_error(404)
                    return
            data = body.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "public, max-age=60")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Referrer-Policy", "strict-origin-when-cross-origin")
            self.send_header("X-Frame-Options", "DENY")
            self.end_headers()
            self.wfile.write(data)
        except Exception:
            traceback.print_exc()
            self.send_error(500)

    def log_message(self, fmt, *args):
        pass


# ---------------------------------------------------------------- preview with made-up data

def sample_snapshot():
    import random
    rnd = random.Random(7)
    now = datetime(2026, 10, 26, 20, 15)
    names = ["Grimvale", "Tusker Bait", "Ashkaro", "Vel Morrow", "Sythe", "Brannoc", "Lady Corva", "Jaxom",
             "Mirelock", "Quel Daan", "Hollowpoint", "Ostrava", "Rekk", "Faelin", "Bones McGee", "Thistle",
             "Drudge Slayer", "Kaelith", "Pyre", "Nox", "Ember Vane", "Gorrim", "Silk", "Wendigo Jim"]
    chars = {}
    for i, nm in enumerate(names):
        lvl = rnd.choice([126, 126, 126, 124, 119, 112, 98, 87, 75, 60, 44, 30])
        chars[1000 + i] = dict(id=1000 + i, name=nm, level=lvl, xp=lvl * lvl * 270000 + rnd.randint(0, 9_000_000), deleted=False,
                               age=lvl * 1100 + rnd.randint(0, 40000), passup=rnd.choice([0, 0, 0, 12_000_000, 250_000_000]))
    for k, c in enumerate(c for c in chars.values() if c["level"] == 126):
        c.update(reached=now - timedelta(days=5) + timedelta(hours=7 * k + rnd.randint(0, 5)), reached_est=k % 2 == 0)
    for cid in (1001, 1002, 1003, 1004, 1005):
        chars[cid].update(patron=1000, monarch=1000)
    for cid in (1006, 1007):
        chars[cid].update(patron=1001, monarch=1000)
    for cid in (1009, 1010, 1011):
        chars[cid].update(patron=1008, monarch=1008)
    chars[1012].update(patron=1009, monarch=1008)
    for cid in (1014, 1015):
        chars[cid].update(patron=1013, monarch=1013)
    ids = list(chars)
    kills = []
    for _ in range(325):
        a, b = rnd.sample(ids, 2)
        when = now - timedelta(minutes=rnd.randint(1, 60 * 24 * 3))
        kills.append(dict(killer=a, victim=b, km=chars[a].get("monarch"), vm=chars[b].get("monarch"), when=when))
    kills.sort(key=lambda k: k["when"])
    stats = [dict(id=1000, name="Grimvale", type="1v1", matches=2, wins=2, losses=0, draws=0, dq=0, deaths=0, kills=2,
                  dealt=4810, received=1220, points=1032),
             dict(id=1002, name="Ashkaro", type="1v1", matches=1, wins=0, losses=1, draws=0, dq=0, deaths=1, kills=0,
                  dealt=900, received=2410, points=984),
             dict(id=1004, name="Sythe", type="1v1", matches=1, wins=0, losses=1, draws=0, dq=0, deaths=1, kills=0,
                  dealt=1320, received=2400, points=990),
             dict(id=1008, name="Mirelock", type="2v2", matches=0, wins=0, losses=0, draws=0, dq=0, deaths=0, kills=0,
                  dealt=0, received=0, points=1000)]
    events = [dict(id=2, type="1v1", ended=now - timedelta(hours=5), winner="a",
                   players=[dict(id=1000, name="Grimvale", team="a", kills=1, deaths=0), dict(id=1002, name="Ashkaro", team="b", kills=0, deaths=1)]),
              dict(id=1, type="1v1", ended=now - timedelta(days=1, hours=2), winner="c",
                   players=[dict(id=1000, name="Grimvale", team="c", kills=1, deaths=0), dict(id=1004, name="Sythe", team="d", kills=0, deaths=1)])]
    towns = [dict(id=1, name="Arwic", owner=1000, conflict=True, length=3600, respite=86400),
             dict(id=2, name="Holtburg", owner=1008, conflict=False, length=3600, respite=86400),
             dict(id=3, name="Shoushi", owner=1000, conflict=False, length=3600, respite=86400),
             dict(id=4, name="Yaraq", owner=None, conflict=False, length=3600, respite=86400)]
    battles = [dict(id=5, town=1, start=now - timedelta(minutes=22), end=None, attacker=1013, attacker_name="Faelin",
                    defender=1000, defender_name="Grimvale", won=None),
               dict(id=4, town=2, start=now - timedelta(hours=6), end=now - timedelta(hours=5), attacker=1008,
                    attacker_name="Mirelock", defender=1013, defender_name="Faelin", won=True),
               dict(id=3, town=3, start=now - timedelta(hours=20), end=now - timedelta(hours=19), attacker=1013,
                    attacker_name="Faelin", defender=1000, defender_name="Grimvale", won=False)]
    patrons = {c["patron"] for c in chars.values() if c.get("patron")}
    return dict(taken=now, chars=chars, kills=kills, arena_stats=stats, arena_events=events, patrons=patrons,
                whitelist={1000, 1013}, utc=now, towns=towns, battles=battles)


def write_sample(out):
    """All pages in one file, switched with the nav (for previewing the design without a database)."""
    snap = sample_snapshot()
    sections = []
    for path, _ in PAGES:
        page = render(path, {}, snap)
        main = page[page.index("<main>") + 6:page.index("</main>")]
        sections.append(f'<section data-page="{path}" hidden>{main}</section>')
    shell = render("/", {}, snap)
    head, tail = shell[:shell.index("<main>") + 6], shell[shell.index("</main>"):]
    ids = ",".join(f'"#{"home" if p == "/" else p.strip("/")}":"{p}"' for p, _ in PAGES)
    switch = ('<script>const ids={' + ids + '};'
              'function show(p){document.querySelectorAll("section[data-page]").forEach(s=>s.hidden=s.dataset.page!==p);'
              'document.querySelectorAll("nav a").forEach(a=>{if(ids[a.getAttribute("href")]===p)a.setAttribute("aria-current","page");else a.removeAttribute("aria-current")})}'
              'function route(){show(ids[location.hash]||"/");scrollTo(0,0)}'
              'addEventListener("hashchange",route);route()</script>')
    doc = head + "".join(sections) + tail.replace("</body>", switch + "</body>")
    # in the preview, the menu uses #links so it works inside any viewer or straight from a downloaded file
    for path, _ in PAGES:
        tok = "home" if path == "/" else path.strip("/")
        doc = doc.replace(f'href="{path}"', f'href="#{tok}"')
    for path, _ in PAGES[1:]:
        doc = doc.replace(f'href="{path}?', f'href="#{path.strip("/")}" data-x="')
    with open(out, "w", encoding="utf-8") as f:
        f.write(doc)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--sample":
        write_sample(sys.argv[2])
        sys.exit(0)
    threading.Thread(target=collector, daemon=True).start()
    wiki.init(DB, layout)
    print(f"JawnTide website on port {PORT}, data refresh every {INTERVAL}s", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
