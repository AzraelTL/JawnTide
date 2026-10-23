"""
JawnTide resource monitor (read-only).

Every INTERVAL_SECONDS it reads the game databases with a SELECT-only user and keeps a snapshot of:
  - every account: last login, last IP, every IP it logged in from (from ace_log.character_login_log)
  - every character: played time (Age) and how much of each tracked currency it holds
    (main pack and side packs; anything not on a character counts as "elsewhere")
It stores per-account currency totals in a small SQLite file for history, and serves web pages on PORT.
It never writes to the game databases.
"""
import html
import json
import os
import sqlite3
import threading
import time
import traceback
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, quote, urlparse

import pymysql

DB = dict(host=os.environ.get("DB_HOST", "ace-db"), port=int(os.environ.get("DB_PORT", "3306")),
          user=os.environ.get("DB_USER", "monitor"), password=os.environ.get("DB_PASSWORD", ""),
          charset="utf8mb4", connect_timeout=10, read_timeout=60)
INTERVAL = max(60, int(os.environ.get("INTERVAL_SECONDS", "600")))
PORT = int(os.environ.get("PORT", "8080"))
DATA = os.environ.get("DATA_FILE", "/data/monitor.sqlite")
HISTORY_DAYS = int(os.environ.get("HISTORY_DAYS", "30"))

# Tracked items: these first (WCID:label), then every alternate currency any vendor uses (read from ace_world on
# each snapshot, so a vendor given a new currency is picked up automatically). Columns nobody holds are hidden.
EXTRA_ITEMS = ("273:Pyreals,20630:MMD (Trade Note 250k),1000002:PK Trophy,1000003:Phial of Bloody Tears,"
               "480608:Darkbeat Key,490364:Hera Key,52968:Infused Amber Shard,52969:Corrupted Amber Shard,"
               "490321:Lum Exchange Token,510000:A Box")
EXTRA = []
for part in os.environ.get("EXTRA_ITEMS", EXTRA_ITEMS).split(","):
    if ":" in part:
        w, label = part.split(":", 1)
        EXTRA.append((int(w.strip()), label.strip()))

PROP_INT_STACKSIZE = 12
PROP_INT_AGE = 125
PROP_IID_CONTAINER = 2

state = {"snapshot": None, "error": None, "taken": None, "duration": None}
lock = threading.Lock()


# ---------------------------------------------------------------- collecting

def query(cur, sql, args=None):
    cur.execute(sql, args)
    return cur.fetchall()


def take_snapshot():
    started = time.time()
    conn = pymysql.connect(**DB)
    try:
        cur = conn.cursor()
        cur.execute("SET SESSION TRANSACTION READ ONLY")
        currencies = list(EXTRA)
        known = {w for w, _ in currencies}
        for (wcid, name) in query(cur, """
                SELECT d.value, MAX(s.value)
                FROM ace_world.weenie_properties_d_i_d d
                LEFT JOIN ace_world.weenie_properties_string s ON s.object_Id = d.value AND s.type = 1
                WHERE d.type = 57 AND d.value <> 0
                GROUP BY d.value"""):
            if wcid not in known:
                currencies.append((int(wcid), name or f"WCID {wcid}"))
                known.add(wcid)
        currencies = currencies[:len(EXTRA)] + sorted(currencies[len(EXTRA):], key=lambda c: c[1].lower())
        WCIDS = [w for w, _ in currencies]

        accounts = {}
        for (aid, name, level, last_time, last_ip, created, created_ip, logins, banned) in query(cur, """
                SELECT accountId, accountName, accessLevel, last_Login_Time, inet6_ntoa(last_Login_I_P),
                       create_Time, inet6_ntoa(create_I_P), total_Times_Logged_In, banned_Time
                FROM ace_auth.account"""):
            accounts[aid] = dict(id=aid, name=name, level=level, last_login=last_time, last_ip=last_ip or "",
                                 created=created, created_ip=created_ip or "", logins=logins, banned=banned,
                                 characters=[], ips={}, totals={w: 0 for w in WCIDS})

        chars = {}
        for (cid, aid, name, deleted, age) in query(cur, """
                SELECT c.id, c.account_Id, c.name, c.is_Deleted, COALESCE(a.value, 0)
                FROM ace_shard.`character` c
                LEFT JOIN ace_shard.biota_properties_int a ON a.object_Id = c.id AND a.type = %s""", (PROP_INT_AGE,)):
            ch = dict(id=cid, account=aid, name=name, deleted=bool(deleted and deleted != b"\x00"), age=int(age or 0),
                      holdings={w: 0 for w in WCIDS})
            chars[cid] = ch
            if aid in accounts:
                accounts[aid]["characters"].append(ch)

        elsewhere = {w: 0 for w in WCIDS}
        if WCIDS:
            marks = ",".join(["%s"] * len(WCIDS))
            for (wcid, stack, c1, c2) in query(cur, f"""
                    SELECT b.weenie_Class_Id, COALESCE(s.value, 1), c1.value, c2.value
                    FROM ace_shard.biota b
                    LEFT JOIN ace_shard.biota_properties_int s ON s.object_Id = b.id AND s.type = %s
                    LEFT JOIN ace_shard.biota_properties_i_i_d c1 ON c1.object_Id = b.id AND c1.type = %s
                    LEFT JOIN ace_shard.biota_properties_i_i_d c2 ON c2.object_Id = c1.value AND c2.type = %s
                    WHERE b.weenie_Class_Id IN ({marks})""", (PROP_INT_STACKSIZE, PROP_IID_CONTAINER, PROP_IID_CONTAINER, *WCIDS)):
                owner = chars.get(c1) or chars.get(c2)
                amount = int(stack or 1)
                if owner:
                    owner["holdings"][wcid] += amount
                else:
                    elsewhere[wcid] += amount

        by_name = {a["name"]: a for a in accounts.values()}
        for (account_name, ip, first, last, n) in query(cur, """
                SELECT accountName, sessionIP, MIN(loginDateTime), MAX(loginDateTime), COUNT(*)
                FROM ace_log.character_login_log
                GROUP BY accountName, sessionIP"""):
            a = by_name.get(account_name)
            if a is not None:
                a["ips"][ip or ""] = dict(first=first, last=last, logins=n)
        conn.commit()
    finally:
        conn.close()

    ip_accounts = {}
    for a in accounts.values():
        for ip in set(list(a["ips"].keys()) + ([a["last_ip"]] if a["last_ip"] else [])):
            if ip:
                ip_accounts.setdefault(ip, set()).add(a["name"])
        for ch in a["characters"]:
            for w in WCIDS:
                a["totals"][w] += ch["holdings"][w]
        live = [c for c in a["characters"] if not c["deleted"]] or a["characters"]
        a["top_character"] = max(live, key=lambda c: c["age"], default=None)
        a["holders"] = {}
        for w in WCIDS:
            best = max(a["characters"], key=lambda c: c["holdings"][w], default=None)
            a["holders"][w] = best if best and best["holdings"][w] > 0 else None

    held = {w for w in WCIDS if elsewhere[w] or any(a["totals"][w] for a in accounts.values())}
    snap = dict(taken=datetime.now(), accounts=accounts, characters=chars, elsewhere=elsewhere,
                ip_accounts={k: sorted(v) for k, v in ip_accounts.items()},
                currencies=currencies, held=held, wcids=WCIDS)
    save_history(snap)
    return snap, time.time() - started


def history_db():
    os.makedirs(os.path.dirname(DATA) or ".", exist_ok=True)
    db = sqlite3.connect(DATA)
    db.execute("CREATE TABLE IF NOT EXISTS history (ts TEXT, account TEXT, wcid INTEGER, amount INTEGER)")
    db.execute("CREATE INDEX IF NOT EXISTS history_account ON history (account, ts)")
    return db


def save_history(snap):
    db = history_db()
    try:
        ts = snap["taken"].strftime("%Y-%m-%d %H:%M")
        rows = [(ts, a["name"], w, a["totals"][w]) for a in snap["accounts"].values() for w in snap["wcids"] if a["totals"][w]]
        db.executemany("INSERT INTO history VALUES (?, ?, ?, ?)", rows)
        db.execute("DELETE FROM history WHERE ts < ?", ((datetime.now() - timedelta(days=HISTORY_DAYS)).strftime("%Y-%m-%d %H:%M"),))
        db.commit()
    finally:
        db.close()


def collector():
    while True:
        try:
            snap, took = take_snapshot()
            with lock:
                state.update(snapshot=snap, error=None, taken=snap["taken"], duration=took)
            print(f"{datetime.now():%Y-%m-%d %H:%M:%S} snapshot: {len(snap['accounts'])} accounts, "
                  f"{len(snap['characters'])} characters, {len(snap['currencies'])} currencies tracked "
                  f"({len(snap['held'])} held by someone), {took:.2f}s", flush=True)
        except Exception as ex:
            with lock:
                state["error"] = f"{datetime.now():%Y-%m-%d %H:%M:%S}: {ex}"
            traceback.print_exc()
        time.sleep(INTERVAL)


# ---------------------------------------------------------------- pages

e = lambda v: html.escape("" if v is None else str(v))


def fmt_age(seconds):
    seconds = int(seconds or 0)
    d, rem = divmod(seconds, 86400)
    h, rem = divmod(rem, 3600)
    return f"{d}d {h}h" if d else f"{h}h {rem // 60}m"


def fmt_n(n):
    return f"{n:,}" if n else ""


def fmt_t(t):
    return t.strftime("%Y-%m-%d %H:%M") if hasattr(t, "strftime") else ("" if t is None else str(t))


def account_link(name):
    return f'<a href="/account?name={quote(name)}">{e(name)}</a>'


def ip_link(ip):
    return f'<a href="/ip?addr={quote(ip)}">{e(ip)}</a>' if ip else ""


STYLE = """
:root { color-scheme: light dark; --bg:#f6f7f9; --fg:#1d2330; --muted:#667085; --line:#d7dbe2; --card:#fff; --hl:#fff4cc; --acc:#2563eb; }
@media (prefers-color-scheme: dark) { :root { --bg:#14171c; --fg:#e6e8eb; --muted:#9aa3b2; --line:#2c323c; --card:#1b1f26; --hl:#3a3218; --acc:#7aa2ff; } }
body { font: 14px/1.4 system-ui, sans-serif; margin: 0; background: var(--bg); color: var(--fg); }
header { padding: 12px 20px; border-bottom: 1px solid var(--line); background: var(--card); display:flex; gap:20px; align-items:baseline; flex-wrap:wrap; }
header b { font-size: 17px; } header a { margin-right: 12px; }
main { padding: 16px 20px; } a { color: var(--acc); text-decoration: none; } a:hover { text-decoration: underline; }
.wrap { overflow-x: auto; background: var(--card); border: 1px solid var(--line); border-radius: 6px; margin-bottom: 18px; }
table { border-collapse: collapse; width: 100%; } th, td { padding: 5px 9px; border-bottom: 1px solid var(--line); text-align: left; white-space: nowrap; }
th { position: sticky; top: 0; background: var(--card); font-weight: 600; } td.n, th.n { text-align: right; font-variant-numeric: tabular-nums; }
tr.shared td { background: var(--hl); } .muted { color: var(--muted); } .err { color: #c0392b; } h2 { font-size: 16px; margin: 18px 0 8px; }
"""


def page(title, body):
    with lock:
        taken, err, took = state["taken"], state["error"], state["duration"]
    status = f"Snapshot {fmt_t(taken)} ({took:.1f}s), every {INTERVAL // 60} min" if taken else "No snapshot yet"
    if err:
        status += f' <span class="err">Last error: {e(err)}</span>'
    return f"""<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="300"><title>{e(title)} - JawnTide monitor</title><style>{STYLE}</style></head><body>
<header><b>JawnTide monitor</b><nav><a href="/">Accounts</a><a href="/top">Top holders</a><a href="/ips">Shared IPs</a></nav>
<span class="muted">{status}</span></header><main>{body}</main></body></html>"""


def snapshot_or_wait():
    with lock:
        return state["snapshot"]


def shown(snap):
    """Currencies at least one character (or 'elsewhere') holds, in tracking order."""
    return [(w, label) for w, label in snap["currencies"] if w in snap["held"]]


def overview(sort):
    snap = snapshot_or_wait()
    if not snap:
        return page("Accounts", "<p>Waiting for the first snapshot.</p>")
    CURRENCIES = shown(snap)
    WCIDS = [w for w, _ in CURRENCIES]
    accounts = list(snap["accounts"].values())
    key = int(sort) if sort and sort.isdigit() and int(sort) in WCIDS else (20630 if 20630 in WCIDS else (WCIDS[0] if WCIDS else None))
    accounts.sort(key=lambda a: (-(a["totals"].get(key, 0) if key else 0), a["name"].lower()))
    shared = {ip for ip, names in snap["ip_accounts"].items() if len(names) > 1}
    head = "".join(f'<th class="n"><a href="/?sort={w}">{e(label)}</a></th>' for w, label in CURRENCIES)
    rows = []
    for a in accounts:
        top = a["top_character"]
        ips = set(a["ips"].keys()) | ({a["last_ip"]} if a["last_ip"] else set())
        is_shared = bool(ips & shared)
        cells = "".join(f'<td class="n">{fmt_n(a["totals"][w])}</td>' for w in WCIDS)
        rows.append(f'<tr class="{"shared" if is_shared else ""}"><td>{account_link(a["name"])}</td>'
                    f'<td>{fmt_t(a["last_login"])}</td><td>{ip_link(a["last_ip"])}</td><td class="n">{len(ips)}</td>'
                    f'<td>{e(top["name"]) + " <span class=muted>(" + fmt_age(top["age"]) + ")</span>" if top else ""}</td>{cells}</tr>')
    total_cells = "".join(f'<td class="n"><b>{fmt_n(sum(a["totals"][w] for a in accounts))}</b></td>' for w in WCIDS)
    else_cells = "".join(f'<td class="n">{fmt_n(snap["elsewhere"][w])}</td>' for w in WCIDS)
    hidden = len(snap["currencies"]) - len(CURRENCIES)
    body = (f'<p class="muted">{len(accounts)} accounts. Highlighted rows share an IP with another account. '
            f'Click a currency to sort by it. "Elsewhere" is everything not on a character (house storage, ground, vendors). '
            f'Tracking {len(snap["currencies"])} currencies (every vendor alternate currency plus pyreals, MMDs and keys); '
            f'{hidden} nobody holds yet are hidden.</p>'
            f'<div class="wrap"><table><tr><th>Account</th><th>Last login</th><th>Last IP</th><th class="n">IPs</th>'
            f'<th>Most played character</th>{head}</tr>{"".join(rows)}'
            f'<tr><td><b>All accounts</b></td><td></td><td></td><td></td><td></td>{total_cells}</tr>'
            f'<tr><td class="muted">Elsewhere</td><td></td><td></td><td></td><td></td>{else_cells}</tr></table></div>')
    return page("Accounts", body)


def account_page(name):
    snap = snapshot_or_wait()
    a = next((x for x in snap["accounts"].values() if x["name"] == name), None) if snap else None
    if not a:
        return page("Account", f"<p>No account named {e(name)} in the last snapshot.</p>")
    CURRENCIES = [(w, label) for w, label in snap["currencies"] if a["totals"][w]]
    WCIDS = [w for w, _ in CURRENCIES]
    info = (f'<p>Access level {e(a["level"])}. Created {fmt_t(a["created"])} from {ip_link(a["created_ip"])}. '
            f'Logins: {e(a["logins"])}. Last login {fmt_t(a["last_login"])} from {ip_link(a["last_ip"])}.'
            f'{" <b class=err>Banned " + fmt_t(a["banned"]) + "</b>" if a["banned"] else ""}</p>')
    head = "".join(f'<th class="n">{e(label)}</th>' for _, label in CURRENCIES)
    crow = []
    for c in sorted(a["characters"], key=lambda c: -c["age"]):
        cells = "".join(f'<td class="n">{fmt_n(c["holdings"][w])}</td>' for w in WCIDS)
        crow.append(f'<tr><td>{e(c["name"])}{" <span class=muted>(deleted)</span>" if c["deleted"] else ""}</td>'
                    f'<td class="n">{fmt_age(c["age"])}</td>{cells}</tr>')
    total = "".join(f'<td class="n"><b>{fmt_n(a["totals"][w])}</b></td>' for w in WCIDS)
    chars = (f'<h2>Characters (by played time)</h2><div class="wrap"><table><tr><th>Character</th><th class="n">Played</th>{head}</tr>'
             f'{"".join(crow)}<tr><td><b>Total</b></td><td></td>{total}</tr></table></div>')
    irow = []
    for ip, d in sorted(a["ips"].items(), key=lambda kv: str(kv[1]["last"]), reverse=True):
        others = [n for n in snap["ip_accounts"].get(ip, []) if n != a["name"]]
        irow.append(f'<tr class="{"shared" if others else ""}"><td>{ip_link(ip)}</td><td>{fmt_t(d["first"])}</td>'
                    f'<td>{fmt_t(d["last"])}</td><td class="n">{d["logins"]}</td>'
                    f'<td>{", ".join(account_link(n) for n in others)}</td></tr>')
    ips = (f'<h2>IP history (character logins)</h2><div class="wrap"><table><tr><th>IP</th><th>First seen</th><th>Last seen</th>'
           f'<th class="n">Logins</th><th>Other accounts on this IP</th></tr>{"".join(irow) or "<tr><td colspan=5 class=muted>No logins logged yet</td></tr>"}</table></div>')
    db = history_db()
    try:
        hist = db.execute("SELECT ts, wcid, amount FROM history WHERE account = ? ORDER BY ts DESC LIMIT 2000", (a["name"],)).fetchall()
    finally:
        db.close()
    by_ts = {}
    for ts, w, amt in hist:
        by_ts.setdefault(ts, {})[w] = amt
    hrow = "".join(f'<tr><td>{e(ts)}</td>' + "".join(f'<td class="n">{fmt_n(v.get(w, 0))}</td>' for w in WCIDS) + "</tr>"
                   for ts, v in list(by_ts.items())[:200])
    history = (f'<h2>Totals over time (last {HISTORY_DAYS} days, newest first)</h2><div class="wrap"><table><tr><th>Snapshot</th>{head}</tr>'
               f'{hrow or "<tr><td class=muted>No history yet</td></tr>"}</table></div>')
    return page(a["name"], f'<h2>Account {e(a["name"])}</h2>{info}{chars}{ips}{history}')


def top_page():
    snap = snapshot_or_wait()
    if not snap:
        return page("Top holders", "<p>Waiting for the first snapshot.</p>")
    parts = []
    for w, label in shown(snap):
        holders = sorted((c for c in snap["characters"].values() if c["holdings"][w] > 0), key=lambda c: -c["holdings"][w])[:15]
        rows = "".join(f'<tr><td>{e(c["name"])}</td><td>{account_link(snap["accounts"][c["account"]]["name"]) if c["account"] in snap["accounts"] else ""}</td>'
                       f'<td class="n">{fmt_n(c["holdings"][w])}</td></tr>' for c in holders)
        parts.append(f'<h2>{e(label)}</h2><div class="wrap"><table><tr><th>Character</th><th>Account</th><th class="n">Holding</th></tr>'
                     f'{rows or "<tr><td colspan=3 class=muted>Nobody holds any</td></tr>"}</table></div>')
    return page("Top holders", "".join(parts))


def ips_page():
    snap = snapshot_or_wait()
    if not snap:
        return page("Shared IPs", "<p>Waiting for the first snapshot.</p>")
    shared = sorted(((ip, n) for ip, n in snap["ip_accounts"].items() if len(n) > 1), key=lambda x: -len(x[1]))
    rows = "".join(f'<tr><td>{ip_link(ip)}</td><td class="n">{len(n)}</td><td>{", ".join(account_link(x) for x in n)}</td></tr>' for ip, n in shared)
    return page("Shared IPs", f'<h2>IPs used by more than one account</h2><div class="wrap"><table><tr><th>IP</th><th class="n">Accounts</th><th>Accounts</th></tr>'
                f'{rows or "<tr><td colspan=3 class=muted>None</td></tr>"}</table></div>')


def ip_page(addr):
    snap = snapshot_or_wait()
    names = snap["ip_accounts"].get(addr, []) if snap else []
    rows = "".join(f"<li>{account_link(n)}</li>" for n in names)
    return page(addr, f"<h2>IP {e(addr)}</h2><p>Accounts that logged in from it:</p><ul>{rows or '<li class=muted>None</li>'}</ul>")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        q = parse_qs(url.query)
        try:
            if url.path == "/":
                body = overview(q.get("sort", [""])[0])
            elif url.path == "/account":
                body = account_page(q.get("name", [""])[0])
            elif url.path == "/top":
                body = top_page()
            elif url.path == "/ips":
                body = ips_page()
            elif url.path == "/ip":
                body = ip_page(q.get("addr", [""])[0])
            elif url.path == "/health":
                body = "ok"
            else:
                self.send_error(404)
                return
            data = body.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8" if body != "ok" else "text/plain")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception:
            traceback.print_exc()
            self.send_error(500)

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    threading.Thread(target=collector, daemon=True).start()
    print(f"JawnTide monitor on port {PORT}, snapshot every {INTERVAL}s, plus every vendor alternate currency", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
