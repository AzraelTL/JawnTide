"""
JawnTide Marketplace: players list items from their mule and buy with their bank (MMDs or PK Trophies). No fees.

The site never moves items or money: every action is a row in ace_shard.market_request, carried out by the game server
(MarketManager) within a few seconds; the result shows on /market/mine. Listings run 30 days, then wait (hidden) for the
seller to relist or cancel. Sign-in is the wiki login (one login per game account).

Pages: /market (search and filters), /market/item/ID, /market/mine (your mule, house chest keys, listings, history),
/market/icon/ID.png (icons the game server exported from portal.dat).
Database access (see market-setup.sh): read market_listing, market_request, market_icon and the ace_web.market_mule_item
view (mule contents, no other item data); insert into market_request. Nothing else.
"""
import html
import json
import os
import re
import threading
import time
import traceback
from datetime import datetime, timedelta
from urllib.parse import parse_qs, quote, urlencode, urlparse

import wiki

e = lambda v: html.escape("" if v is None else str(v))
SHARD_DB = os.environ.get("SHARD_DB", "ace_shard")
VIEW_DB = os.environ.get("WEB_VIEW_DB", "ace_web")
PYREALS_PER_MMD = 250000
MAX_MMD = 1_000_000
MAX_TROPHIES = 100_000_000
LISTING_DAYS = 30
DAY_OPTIONS = "".join(f'<option value="{d}"{" selected" if d == 7 else ""}>{d} day{"s" if d != 1 else ""}</option>' for d in (1, 2, 3, 5, 7, 10, 14))
CACHE_SECONDS = 15
PAGE_SIZE = 60

_db_args = None
_layout = None
_cache = {"at": 0.0, "rows": []}
_cache_lock = threading.Lock()
_icons = {}
_icons_lock = threading.Lock()

# 1x1 transparent PNG, for icons the server couldn't export (or hasn't yet)
BLANK_PNG = bytes.fromhex("89504e470d0a1a0a0000000d4948445200000001000000010806000000"
                          "1f15c4890000000d49444154789c6360000002000154a24f5d0000000049454e44ae426082")

CATEGORIES = [
    ("melee", "Melee weapons", 0x1), ("missile", "Missile weapons", 0x100), ("caster", "Casters", 0x8000),
    ("armor", "Armor", 0x2), ("clothing", "Clothing", 0x4), ("jewelry", "Jewelry", 0x8),
    ("salvage", "Salvage", 0x40000000), ("gem", "Gems", 0x800), ("food", "Food and potions", 0x20),
    ("key", "Keys", 0x4000), ("note", "Trade notes", 0x40000),
]
UI_EFFECTS = [(0x20, "fire"), (0x40, "lightning"), (0x80, "frost"), (0x100, "acid"), (0x1000, "nether"),
              (0x200, "blunt"), (0x400, "slash"), (0x800, "pierce"), (0x2, "poison"), (0x1, "magic")]
ATTRIBUTES = {1: "Strength", 2: "Endurance", 3: "Quickness", 4: "Coordination", 5: "Focus", 6: "Self"}
VITALS = {1: "Max Health", 3: "Max Stamina", 5: "Max Mana"}


def init(db_args, layout):
    """Called once by site.py with its database settings and page layout function."""
    global _db_args, _layout
    _db_args = dict(db_args, database=SHARD_DB, autocommit=True)
    _layout = layout


def _conn():
    import pymysql
    return pymysql.connect(**_db_args)


def _q(sql, args=None, one=False):
    conn = _conn()
    try:
        cur = conn.cursor()
        cur.execute(sql, args)
        rows = cur.fetchall()
        return (rows[0] if rows else None) if one else rows
    finally:
        conn.close()


def _x(sql, args=None):
    conn = _conn()
    try:
        cur = conn.cursor()
        cur.execute(sql, args)
        return cur.lastrowid
    finally:
        conn.close()


# ---------------------------------------------------------------- data

def pretty(name):
    """CamelCase enum name -> words ("WhiteSapphire" -> "White Sapphire", "CriticalStrike, ArmorRending" -> "Critical Strike, Armor Rending")."""
    if name is None:
        return ""
    return re.sub(r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])", " ", str(name))


def _category(item_type):
    for key, _, bit in CATEGORIES:
        if item_type & bit:
            return key
    return "other"


def _wield_level(d):
    ints, names = d.get("int", {}), d.get("names", {})
    for n in ("", "2", "3", "4"):
        if names.get(f"WieldRequirements{n}") == "Level":
            return ints.get(f"WieldDifficulty{n}")
    return None


def _prepare(row):
    (lid, seller, wcid, name, stack, itype, icon, ov, ov2, under, ui, details, search, pmmd, ptro, listed, expires,
     kind, acur, ahours, start, bin_, high, high_name, bids) = row
    auction = kind == "auction"
    if auction:
        # an auction's "price" (for filters and sorting) is its current bid, or the starting bid, in its own currency
        now_price = high or start
        pmmd, ptro = (now_price, None) if acur == "mmd" else (None, now_price)
    try:
        d = json.loads(details) if details else {}
    except ValueError:
        d = {}
    names = d.get("names", {})
    return dict(id=lid, seller=seller or "?", wcid=wcid, name=name, stack=stack, item_type=itype, icons=(under, icon, ov, ov2), ui=ui,
                details=d, search=(search or name or "").lower(), mmd=pmmd, trophies=ptro, listed=listed, expires=expires,
                auction=auction, acur=acur, hours=ahours, start=start, bin=bin_, high=high, high_name=high_name, bids=bids or 0,
                category=_category(itype), level=_wield_level(d), set=names.get("EquipmentSetId"),
                imbue=names.get("ImbuedEffect") if names.get("ImbuedEffect") not in (None, "Undef") else None)


LISTING_COLUMNS = ("id, seller_Name, wcid, name, stack_Size, item_Type, icon_Id, icon_Overlay_Id, icon_Overlay2_Id, icon_Underlay_Id, "
                   "ui_Effects, details, search_Text, price_Mmd, price_Trophies, listed_At, expires_At, "
                   "kind, auction_Currency, auction_Hours, start_Bid, buy_Now, high_Bid, high_Bidder_Name, bid_Count")
LISTING_WIDTH = 25


def active_listings():
    """Every listing on the market now (cached for a few seconds)."""
    with _cache_lock:
        if time.time() - _cache["at"] < CACHE_SECONDS:
            return _cache["rows"]
    rows = [_prepare(r) for r in _q(f"SELECT {LISTING_COLUMNS} FROM market_listing WHERE status = 'active' AND expires_At > UTC_TIMESTAMP() ORDER BY id DESC")]
    with _cache_lock:
        _cache.update(at=time.time(), rows=rows)
    return rows


def _forget_cache():
    with _cache_lock:
        _cache["at"] = 0.0


def _account(user):
    """The game account behind a wiki login."""
    row = wiki._q("SELECT account_id FROM wiki_user WHERE id = %s", (user["id"],), one=True)
    return row[0] if row else None


# Darkbeat, Hera and Shimmering Skeleton keys: can't go in the mule, so they're listed from (and go back to) a house storage chest
KEY_WCIDS = (480608, 490364, 30258)


def _chest_keys(account_id):
    """Keys in the account's house storage chests (same columns as _mule_items). Empty until market-setup.sh has made the view."""
    cols = "item_Guid, name, material, stack_Size, item_Type, icon_Id, icon_Overlay_Id, icon_Overlay2_Id, icon_Underlay_Id, ui_Effects, attuned, bonded, details"
    try:
        return _q(f"SELECT {cols} FROM {VIEW_DB}.market_chest_key WHERE account_Id = %s ORDER BY name LIMIT 500", (account_id,))
    except Exception:
        return []


def _mule_items(account_id):
    """The account's mule items. The last column is the item's details (None until the game server has saved them)."""
    cols = "item_Guid, name, material, stack_Size, item_Type, icon_Id, icon_Overlay_Id, icon_Overlay2_Id, icon_Underlay_Id, ui_Effects, attuned, bonded"
    try:
        return _q(f"SELECT {cols}, details FROM {VIEW_DB}.market_mule_item WHERE account_Id = %s ORDER BY name LIMIT 3000", (account_id,))
    except Exception:   # the view from before market-setup.sh was run again: no details column
        return [r + (None,) for r in _q(f"SELECT {cols} FROM {VIEW_DB}.market_mule_item WHERE account_Id = %s ORDER BY name LIMIT 3000", (account_id,))]


# ---------------------------------------------------------------- formatting

def price_html(mmd, trophies):
    parts = []
    if mmd:
        parts.append(f'<span class="pm">{mmd:,} MMD{"s" if mmd != 1 else ""}</span>')
    if trophies:
        parts.append(f'<span class="pt">{trophies:,} PK Troph{"ies" if trophies != 1 else "y"}</span>')
    return ' <span class="muted">or</span> '.join(parts)


def unit(cur, n=2):
    return ("PK Troph" + ("y" if n == 1 else "ies")) if cur == "trophies" else ("MMD" + ("" if n == 1 else "s"))


def amount_html(n, cur):
    return f'<span class="{"pt" if cur == "trophies" else "pm"}">{n:,} {unit(cur, n)}</span>'


def ends_html(when):
    """A live countdown (the site's ticking script fills it in)."""
    return f'<span class="cd" data-end="{when.strftime("%Y-%m-%dT%H:%M:%SZ")}">{when.strftime("%b %d %H:%M")} UTC</span>'


def min_bid(r):
    if r["high"]:
        return r["high"] + max(1, -(-r["high"] * 5 // 100))
    return r["start"] or 1


def auction_html(r):
    """Current bid (or starting bid), Buy It Now and time left for an auction."""
    if r["bids"]:
        now = f'{amount_html(r["high"], r["acur"])} <span class="muted">({r["bids"]} bid{"s" if r["bids"] != 1 else ""})</span>'
    else:
        now = f'<span class="muted">Starting bid</span> {amount_html(r["start"], r["acur"])}'
    bin_ = f' <span class="muted">· Buy It Now</span> {amount_html(r["bin"], r["acur"])}' if r["bin"] else ""
    return f'{now}{bin_}'


def icon_html(icons, ui, big=False):
    layers = "".join(f'<img src="/market/icon/{i}.png" alt="" loading="lazy">' for i in icons if i)
    glow = next((cls for bit, cls in UI_EFFECTS if ui & bit), "")
    return f'<span class="micon{" big" if big else ""}{(" fx-" + glow) if glow else ""}">{layers}</span>'


def _pct(v, base=1.0):
    return f"{(v - base) * 100:+.0f}%"


def appraise(d):
    """The item's details as (label, value) rows, roughly like the in-game appraisal panel."""
    I, F, S, B, I64, N = (d.get(k, {}) for k in ("int", "float", "string", "bool", "int64", "names"))
    rows = []
    add = lambda label, value: rows.append((label, value))

    # wield requirements
    for n in ("", "2", "3", "4"):
        req, diff, what = N.get(f"WieldRequirements{n}"), I.get(f"WieldDifficulty{n}"), I.get(f"WieldSkillType{n}")
        if not req or req == "Invalid" or diff is None:
            continue
        skill = pretty(N.get(f"WieldSkillType{n}"))
        if req == "Level":
            add("Wield requires", f"Level {diff}")
        elif req in ("Skill", "RawSkill"):
            add("Wield requires", f"{'Base ' if req == 'RawSkill' else ''}{skill} {diff}")
        elif req == "Training":
            add("Wield requires", f"{'Specialized' if diff >= 3 else 'Trained'} {skill}")
        elif req in ("Attrib", "RawAttrib"):
            add("Wield requires", f"{'Base ' if req == 'RawAttrib' else ''}{ATTRIBUTES.get(what, 'Attribute')} {diff}")
        elif req in ("SecondaryAttrib", "RawSecondaryAttrib"):
            add("Wield requires", f"{VITALS.get(what, 'Vital')} {diff}")
        else:
            add("Wield requires", f"{pretty(req)} {diff}")
    if I.get("ItemAllegianceRankLimit"):
        add("Allegiance rank", I["ItemAllegianceRankLimit"])

    # weapon
    if "Damage" in I:
        top = I["Damage"]
        var = F.get("DamageVariance")
        low = top * (1 - var) if var is not None else None
        dtype = pretty(N.get("DamageType", "")).replace(", ", "/")
        add("Damage", (f"{low:.2f} - {top}" if low is not None else f"{top}") + (f" {dtype}" if dtype and dtype != "Undef" else ""))
    if "WeaponTime" in I:
        add("Speed", I["WeaponTime"])
    if N.get("WeaponSkill") and N["WeaponSkill"] not in ("None", "0"):
        add("Skill", pretty(N["WeaponSkill"]))
    if F.get("DamageMod") not in (None, 1.0):
        add("Damage modifier", _pct(F["DamageMod"]))
    if I.get("ElementalDamageBonus"):
        add("Elemental damage", f"+{I['ElementalDamageBonus']}")
    if F.get("ElementalDamageMod") not in (None, 1.0, 0.0):
        add("Elemental damage vs players", _pct(F["ElementalDamageMod"]))
    if F.get("ManaConversionMod"):
        add("Mana conversion", f"{F['ManaConversionMod'] * 100:+.0f}%")
    if F.get("WeaponOffense") not in (None, 1.0, 0.0):
        add("Attack", _pct(F["WeaponOffense"]))
    if F.get("WeaponDefense") not in (None, 1.0, 0.0):
        add("Melee defense", _pct(F["WeaponDefense"]))
    if F.get("WeaponMissileDefense") not in (None, 1.0, 0.0):
        add("Missile defense", _pct(F["WeaponMissileDefense"]))
    if F.get("WeaponMagicDefense") not in (None, 1.0, 0.0):
        add("Magic defense", _pct(F["WeaponMagicDefense"]))
    if I.get("Cleaving"):
        add("Cleave", f"{I['Cleaving']} targets")
    if F.get("CriticalFrequency"):
        add("Critical chance", f"{F['CriticalFrequency'] * 100:.0f}%")
    if F.get("CriticalMultiplier"):
        add("Critical damage", f"x{F['CriticalMultiplier']:.2f}")
    if F.get("IgnoreArmor"):
        add("Ignores armor", f"{F['IgnoreArmor'] * 100:.0f}%")
    if N.get("SlayerCreatureType") and N["SlayerCreatureType"] not in ("Invalid", "0"):
        add("Slayer", pretty(N["SlayerCreatureType"]) + (f" (x{F['SlayerDamageBonus']:.2f})" if F.get("SlayerDamageBonus") else ""))

    # armor
    if I.get("ArmorLevel"):
        add("Armor level", I["ArmorLevel"])
        prot = [(k, F[f"ArmorModVs{k}"]) for k in ("Slash", "Pierce", "Bludgeon", "Fire", "Cold", "Acid", "Electric", "Nether") if f"ArmorModVs{k}" in F]
        if prot:
            add("Protection", ", ".join(f"{k} {v:.2f}" for k, v in prot))

    # imbues, sets, ratings
    if N.get("ImbuedEffect") not in (None, "Undef"):
        add("Imbue", pretty(N["ImbuedEffect"]))
    if N.get("ImbuedEffect2") not in (None, "Undef"):
        add("Imbue", pretty(N["ImbuedEffect2"]))
    if N.get("EquipmentSetId") not in (None, "Invalid"):
        add("Set", pretty(N["EquipmentSetId"]))
    ratings = [(pretty(k.replace("Gear", "")), v) for k, v in sorted(I.items()) if v and (k.startswith("Gear") or k.endswith("Rating"))]
    if ratings:
        add("Ratings", ", ".join(f"{k} +{v}" for k, v in ratings))

    # magic
    if I.get("ItemSpellcraft"):
        add("Spellcraft", I["ItemSpellcraft"])
    if I.get("ItemDifficulty"):
        add("Arcane lore", I["ItemDifficulty"])
    if I.get("ItemMaxMana"):
        add("Mana", f"{I.get('ItemCurMana', 0):,} / {I['ItemMaxMana']:,}")
    if I.get("ItemMaxLevel"):
        add("Max item level", I["ItemMaxLevel"])

    # crafting
    if N.get("MaterialType") not in (None, "Unknown"):
        add("Material", pretty(N["MaterialType"]))
    if I.get("ItemWorkmanship"):
        add("Workmanship", I["ItemWorkmanship"])
    if I.get("NumTimesTinkered"):
        add("Tinkered", f"{I['NumTimesTinkered']} time{'s' if I['NumTimesTinkered'] != 1 else ''}")
    if S.get("ImbuerName"):
        add("Imbued by", S["ImbuerName"])
    if S.get("TinkerName"):
        add("Last tinkered by", S["TinkerName"])
    if S.get("CraftsmanName"):
        add("Made by", S["CraftsmanName"])
    if I.get("MaxStructure"):
        add("Uses", f"{I.get('Structure', 0)} / {I['MaxStructure']}")

    # general
    if "Value" in I:
        add("Value", f"{I['Value']:,} pyreals")
    if "EncumbranceVal" in I:
        add("Burden", f"{I['EncumbranceVal']:,}")
    flags = [label for key, label in (("Retained", "Retained"), ("Ivoryable", "Ivoryable"), ("Dyable", "Dyable")) if B.get(key)]
    if flags:
        add("Properties", ", ".join(flags))
    if S.get("Inscription"):
        add("Inscription", f'"{S["Inscription"]}"' + (f" (by {S['ScribeName']})" if S.get("ScribeName") else ""))
    return rows


# ---------------------------------------------------------------- pages

def _page(h, title, body, user, status=200, refresh=None):
    bar = (f'<div class="wikibar"><a href="/market">Market</a><a href="/market/mine">My market</a><a href="/suit">Suit Builder</a>'
           f'<form class="wsearch" action="/market" method="get"><input name="q" placeholder="Search the market" aria-label="Search the market"></form>'
           + (f'<span class="who">Signed in as <b>{e(user["name"])}</b></span>' if user
              else '<span class="who"><a href="/wiki/login?next=/market/mine">Sign in</a> or <a href="/wiki/link">link your game account</a></span>')
           + '</div>')
    page = _layout("/market", title, f"<style>{CSS}</style>" + bar + body, None)
    if refresh:
        page = page.replace("<head>", f'<head><meta http-equiv="refresh" content="{refresh}">', 1)
    wiki._send(h, status, page)


def _arg(query, key, default=""):
    return (query.get(key, [default])[0] or default).strip()


def _int_arg(query, key):
    v = _arg(query, key)
    return int(v) if v.isdigit() else None


def browse(h, user, query):
    q = _arg(query, "q")[:80].lower()
    cat, cur, sort = _arg(query, "cat"), _arg(query, "cur"), _arg(query, "sort", "new")
    kind = _arg(query, "kind")
    lo, hi, lvl = _int_arg(query, "min"), _int_arg(query, "max"), _int_arg(query, "lvl")
    set_, imbue = _arg(query, "set"), _arg(query, "imbue")
    page = max(1, _int_arg(query, "page") or 1)

    rows = active_listings()
    sets = sorted({r["set"] for r in rows if r["set"] and r["set"] != "Invalid"})
    imbues = sorted({p.strip() for r in rows if r["imbue"] for p in r["imbue"].split(",")})

    def price(r):
        return r["trophies"] if cur == "trophies" else r["mmd"]

    out = rows
    if q:
        words = q.split()
        out = [r for r in out if all(w in r["search"] for w in words)]
    if cat:
        out = [r for r in out if r["category"] == cat]
    if kind in ("fixed", "auction"):
        out = [r for r in out if r["auction"] == (kind == "auction")]
    if cur in ("mmd", "trophies"):
        out = [r for r in out if price(r)]
        if lo is not None:
            out = [r for r in out if price(r) >= lo]
        if hi is not None:
            out = [r for r in out if price(r) <= hi]
    if lvl is not None:
        out = [r for r in out if (r["level"] or 0) <= lvl]
    if set_:
        out = [r for r in out if r["set"] == set_]
    if imbue:
        out = [r for r in out if r["imbue"] and imbue in [p.strip() for p in r["imbue"].split(",")]]

    big = 10 ** 12
    if sort in ("cheap", "dear"):
        key = (lambda r: price(r) or big) if cur in ("mmd", "trophies") else (lambda r: r["mmd"] or (r["trophies"] or big) / 1000)
        out = sorted(out, key=key, reverse=(sort == "dear"))
    elif sort == "name":
        out = sorted(out, key=lambda r: r["name"].lower())
    elif sort == "ending":
        out = sorted(out, key=lambda r: r["expires"])

    total = len(out)
    shown = out[(page - 1) * PAGE_SIZE: page * PAGE_SIZE]

    def opt(value, label, current):
        return f'<option value="{e(value)}"{" selected" if value == current else ""}>{e(label)}</option>'

    form = (f'<form class="mfilter" method="get" action="/market">'
            f'<input name="q" value="{e(_arg(query, "q"))}" placeholder="Name, spell, set, material" aria-label="Search">'
            f'<select name="cat" aria-label="Type">{opt("", "All types", cat)}{"".join(opt(k, l, cat) for k, l, _ in CATEGORIES)}{opt("other", "Other", cat)}</select>'
            f'<select name="kind" aria-label="Listing type">{opt("", "Buy now and auctions", kind)}{opt("fixed", "Buy now only", kind)}{opt("auction", "Auctions only", kind)}</select>'
            f'<select name="cur" aria-label="Currency">{opt("", "MMDs or trophies", cur)}{opt("mmd", "MMDs", cur)}{opt("trophies", "PK Trophies", cur)}</select>'
            f'<input name="min" value="{e(lo if lo is not None else "")}" inputmode="numeric" placeholder="Min price" aria-label="Min price">'
            f'<input name="max" value="{e(hi if hi is not None else "")}" inputmode="numeric" placeholder="Max price" aria-label="Max price">'
            f'<input name="lvl" value="{e(lvl if lvl is not None else "")}" inputmode="numeric" placeholder="My level" aria-label="Wield level up to">'
            f'<select name="set" aria-label="Set">{opt("", "Any set", set_)}{"".join(opt(s, pretty(s), set_) for s in sets)}</select>'
            f'<select name="imbue" aria-label="Imbue">{opt("", "Any imbue", imbue)}{"".join(opt(s, pretty(s), imbue) for s in imbues)}</select>'
            f'<select name="sort" aria-label="Sort">{opt("new", "Newest", sort)}{opt("cheap", "Cheapest", sort)}{opt("dear", "Most expensive", sort)}'
            f'{opt("name", "Name", sort)}{opt("ending", "Ending soon", sort)}</select>'
            f'<button class="btn">Search</button> <a href="/market" class="muted">Clear</a></form>'
            '<p class="help">Price filters use the currency you pick. "My level" hides items that need a higher level to wield.</p>')

    cards = "".join(_card(r) for r in shown) or '<p class="empty">Nothing on the market matches that.</p>'
    pager = ""
    if total > PAGE_SIZE:
        base = {k: v[0] for k, v in query.items() if k != "page"}
        links = []
        if page > 1:
            links.append(f'<a href="/market?{e(urlencode(dict(base, page=page - 1)))}">Previous</a>')
        if page * PAGE_SIZE < total:
            links.append(f'<a href="/market?{e(urlencode(dict(base, page=page + 1)))}">Next</a>')
        pager = f'<p class="show">{" ".join(links)} <span class="muted">Page {page} of {(total + PAGE_SIZE - 1) // PAGE_SIZE}</span></p>'

    intro = ('<p class="lede">Buy from other players, or bid on their auctions, with the MMDs and PK Trophies in your <a href="/wiki/bank">bank</a>. '
             'Purchases land in your mule. To sell, open <a href="/market/mine">My market</a> and list or auction something from your mule. No fees.</p>')
    _page(h, "Market", f'<h1>Market</h1>{intro}{form}<p class="muted">{total:,} item{"s" if total != 1 else ""}</p>'
                       f'<div class="mgrid">{cards}</div>{pager}{FLIP}', user)


def id_panel(r):
    """The hover panel for a listing."""
    return id_panel_for(r["name"], r["stack"], r["details"], f'Seller: {r["seller"]} · ends {r["expires"].strftime("%b %d")}')


def _details(text):
    try:
        return json.loads(text) if text else None
    except ValueError:
        return None


def id_panel_for(name, stack, d, footer=None):
    """The hover panel: the item's details laid out like the in-game appraisal (right-click / ID) panel."""
    if not d:
        return ""
    rows = appraise(d)
    top = [(k, v) for k, v in rows if k in ("Value", "Burden")]
    rest = [(k, v) for k, v in rows if k not in ("Value", "Burden")]
    lines = "".join(f"<div><span>{e(k)}:</span> {e(v)}</div>" for k, v in top + rest)
    spells = [s.get("name") for s in d.get("spells", []) if s.get("name")]
    spell_html = f'<div class="idsp"><span>Spells:</span> {e(", ".join(spells))}</div>' if spells else ""
    strings = d.get("string", {})
    text = "".join(f'<p>{e(strings.get(k))}</p>' for k in ("Use", "LongDesc") if strings.get(k))
    count = f" ({stack:,})" if stack and stack > 1 else ""
    foot = f'<span class="idf">{e(footer)}</span>' if footer else ""
    return f'<span class="idp" role="tooltip"><b class="idn">{e(name)}{count}</b>{lines}{spell_html}{text}{foot}</span>'


def _hover(label_html, panel):
    """Wraps something (an item name) so hovering it shows the ID panel."""
    return f'<span class="hasid">{label_html}{panel}</span>' if panel else label_html


def _card(r):
    lvl = f'<span class="muted">Lvl {r["level"]}</span>' if r["level"] else ""
    extra = " · ".join(pretty(x) for x in (r["set"], r["imbue"]) if x)
    stack = f' <span class="muted">x{r["stack"]:,}</span>' if r["stack"] > 1 else ""
    auc = f'<span class="mauc">Auction · ends in {ends_html(r["expires"])}</span>' if r["auction"] else ""
    return (f'<a class="mcard hasid" href="/market/item/{r["id"]}">{icon_html(r["icons"], r["ui"])}<span class="mtext">'
            f'<span class="mname">{e(r["name"])}{stack}</span>'
            f'<span class="mprice">{auction_html(r) if r["auction"] else price_html(r["mmd"], r["trophies"])}</span>'
            f'{auc}'
            f'<span class="mmeta">{lvl}{" · " if lvl and extra else ""}{e(extra)}</span></span>{id_panel(r)}</a>')


def item_page(h, user, lid, query=None):
    err = _arg(query or {}, "err")[:200]
    row = _q(f"SELECT {LISTING_COLUMNS}, status, seller_Account_Id FROM market_listing WHERE id = %s", (lid,), one=True)
    if not row:
        return _page(h, "Not found", "<h1>That listing doesn't exist</h1>", user, 404)
    r = _prepare(row[:LISTING_WIDTH])
    status, seller_account = row[LISTING_WIDTH], row[LISTING_WIDTH + 1]
    d = r["details"]

    on_sale = status == "active" and r["expires"] > datetime.utcnow()
    account = _account(user) if user else None
    buy = ""
    if not on_sale:
        ended = ("sold" if status in ("sold", "owed") else "won, waiting for delivery" if status == "won" else
                 "the auction ended" if r["auction"] else "taken off the market")
        buy = f'<p class="note">This item is no longer for sale ({e(ended)}).</p>'
    elif not user:
        buy = f'<p><a class="btn" href="/wiki/login?next={quote("/market/item/" + str(lid))}">Sign in to {"bid" if r["auction"] else "buy"}</a></p>'
    elif account == seller_account:
        buy = '<p class="muted">This is your listing. Manage it on <a href="/market/mine">My market</a>.</p>'
    elif r["auction"]:
        low = min_bid(r)
        top = (r["bin"] - 1) if r["bin"] else (MAX_TROPHIES if r["acur"] == "trophies" else MAX_MMD)
        mine_high = r["bids"] and r["high_name"] and user and r["high_name"] == user["name"]
        form = (f'<form class="mlist" method="post" action="/market/bid">{wiki._hidden(user)}<input type="hidden" name="listing" value="{lid}">'
                f'<input name="amount" inputmode="numeric" value="{low}" aria-label="Your bid"> <span class="muted">{unit(r["acur"])}</span>'
                f'<button class="btn">Place bid</button></form>') if low <= top else ""
        bin_btn = (_post_button(user, "/market/buy", {"listing": lid, "pay": r["acur"]}, f'Buy It Now for {r["bin"]:,} {unit(r["acur"], r["bin"])}',
                                f'Buy {r["name"]} now for {r["bin"]:,} {unit(r["acur"], r["bin"])} from your bank?')) if r["bin"] else ""
        buy = (f'{"<p class=note>You are the highest bidder.</p>" if mine_high else ""}<div class="row">{form}{bin_btn}</div>'
               f'<p class="help">The lowest bid you can make is {low:,} {unit(r["acur"], low)}. Your bid is taken from your bank straight away '
               f'and given back if someone outbids you. A bid in the last 5 minutes adds 5 minutes. The winner gets the item in their mule.</p>')
    else:
        btns = []
        if r["mmd"]:
            btns.append(_post_button(user, "/market/buy", {"listing": lid, "pay": "mmd"}, f'Buy for {r["mmd"]:,} MMD{"s" if r["mmd"] != 1 else ""}',
                                     f'Buy {r["name"]} for {r["mmd"]:,} MMDs ({r["mmd"] * PYREALS_PER_MMD:,} pyreals) from your bank?'))
        if r["trophies"]:
            btns.append(_post_button(user, "/market/buy", {"listing": lid, "pay": "trophies"}, f'Buy for {r["trophies"]:,} PK Trophies',
                                     f'Buy {r["name"]} for {r["trophies"]:,} PK Trophies from your bank?'))
        buy = (f'<div class="row">{"".join(btns)}</div>'
               '<p class="help">Paid from your bank. The item goes into your mule within a few seconds. If your mule is full, you are not charged.</p>')

    facts = "".join(f"<dt>{e(k)}</dt><dd>{e(v)}</dd>" for k, v in appraise(d))
    spells = "".join(f'<li>{e(s.get("name"))}{" <span class=muted>(cast on hit)</span>" if s.get("proc") else ""}'
                     f'{" <span class=muted>(cast on use)</span>" if s.get("use") else ""}</li>' for s in d.get("spells", []))
    text = "".join(f'<p>{e(d.get("string", {}).get(k))}</p>' for k in ("Use", "LongDesc") if d.get("string", {}).get(k))

    raw = []
    for group in ("int", "int64", "float", "bool", "string", "did"):
        for k, v in sorted(d.get(group, {}).items()):
            raw.append(f"<tr><td>{e(k)}</td><td class=wrapcell>{e(v)}</td></tr>")
    raw_html = f'<details class="mraw"><summary>All properties</summary><div class="wrap"><table>{"".join(raw)}</table></div></details>' if raw else ""

    when = f'Listed by <b>{e(r["seller"])}</b> {wiki._ago(r["listed"])}'
    if on_sale:
        when += f' · ends in {ends_html(r["expires"])}' if r["auction"] else f' · ends {e(r["expires"].strftime("%b %d"))}'
    stack = f' <span class="muted">x{r["stack"]:,}</span>' if r["stack"] > 1 else ""
    history = ""
    if r["auction"]:
        bids = _q("SELECT character_Name, amount, placed_At FROM market_bid WHERE listing_Id = %s ORDER BY id DESC LIMIT 50", (lid,))
        items = "".join(f'<li><span><b>{e(n)}</b> bid {amount_html(a, r["acur"])}</span><span class="muted">{wiki._ago(t)}</span></li>' for n, a, t in bids)
        history = f'<h2>Bids</h2><ul class="feed">{items or "<li class=muted>No bids yet.</li>"}</ul>'
    _page(h, r["name"], f'<div class="mhead">{icon_html(r["icons"], r["ui"], big=True)}<div><h1>{e(r["name"])}{stack}</h1>'
                        f'<p class="mbig">{auction_html(r) if r["auction"] else price_html(r["mmd"], r["trophies"])}</p><p class="muted">{when}</p></div></div>'
                        f'{f"<p class=err>{e(err)}</p>" if err else ""}{buy}{history}'
                        f'<div class="cols"><section><h2>Details</h2><dl class="facts">{facts or "<dt>No details</dt><dd></dd>"}</dl>{text}</section>'
                        f'<section><h2>Spells</h2>{f"<ul class=wlist>{spells}</ul>" if spells else "<p class=muted>None.</p>"}</section></div>{raw_html}', user)


def _post_button(user, action, fields, label, confirm=None, quiet=False):
    hidden = "".join(f'<input type="hidden" name="{e(k)}" value="{e(v)}">' for k, v in fields.items())
    onsubmit = f' onsubmit="return confirm({e(json.dumps(confirm))})"' if confirm else ""
    return (f'<form class="inline" method="post" action="{action}"{onsubmit}>{wiki._hidden(user)}{hidden}'
            f'<button class="btn{" quiet" if quiet else ""}">{e(label)}</button></form>')


def mine(h, user, query):
    if not user:
        return wiki._redirect(h, "/wiki/login?next=/market/mine")
    account = _account(user)
    if account is None:
        return _page(h, "My market", "<h1>My market</h1><p>Your wiki login isn't linked to a game account.</p>", user)

    requests = _q("SELECT id, created_At, kind, status, result FROM market_request WHERE account_Id = %s ORDER BY id DESC LIMIT 8", (account,))
    waiting = any(s in ("pending", "working") for _, _, _, s, _ in requests)
    reqs = "".join(
        f'<li><span>{e(k.title())}: {e(res) if res else "<span class=muted>waiting for the game server...</span>"}</span>'
        f'<span class="{"x" if s == "failed" else "muted"}">{e("failed" if s == "failed" else "done" if s == "done" else "working")} · {wiki._ago(c)}</span></li>'
        for _, c, k, s, res in requests)
    notices = f'<h2>Latest requests</h2><ul class="feed">{reqs}</ul>' if reqs else ""
    if waiting:
        notices += '<p class="help">This page refreshes by itself until the game server has finished.</p>'

    mine_rows = [(_prepare(r[:LISTING_WIDTH]), r[LISTING_WIDTH]) for r in _q(
        f"SELECT {LISTING_COLUMNS}, status FROM market_listing WHERE seller_Account_Id = %s AND status IN ('active', 'expired', 'busy', 'won', 'owed', 'returning') ORDER BY id DESC",
        (account,))]
    now = datetime.utcnow()
    lrows = []
    for r, status in mine_rows:
        live = status == "active" and r["expires"] > now
        stack = f' x{r["stack"]:,}' if r["stack"] > 1 else ""
        link = f'<a href="/market/item/{r["id"]}">{e(r["name"])}</a>'
        home = "house chest" if r["wcid"] in KEY_WCIDS else "mule"
        back = _post_button(user, "/market/cancel", {"listing": r["id"]}, f"Back to {home}", f'Take {r["name"]} off the market and put it back in your {home}?', quiet=True)
        if status == "returning":
            state, actions = "Off the market, waiting for room in your house chest", ""
        elif status == "owed":
            state, actions = "Sold, waiting for room in the buyer's house chest", ""
        elif r["auction"]:
            days = max(1, (r["hours"] or 24) // 24)
            if status == "won":
                state, actions = f'Won by {e(r["high_name"])}, waiting for room in their {home}', ""
            elif live and r["bids"]:
                state, actions = f'Auction: high bid {r["high"]:,} by {e(r["high_name"])}', ""
            elif live:
                state, actions = "Auction: no bids yet", back
            elif status == "busy":
                state, actions = "busy", ""
            else:
                state = "auction ended with no bids"
                actions = _post_button(user, "/market/relist", {"listing": r["id"]}, f"Auction again ({days} day{'s' if days != 1 else ''})", quiet=True) + " " + back
            if live:
                state += f' · ends in {ends_html(r["expires"])}'
        else:
            state = (f'{max(0, (r["expires"] - now).days)} days left' if live else "busy" if status == "busy" else "ended, not on the market")
            actions = "" if status == "busy" else (
                _post_button(user, "/market/relist", {"listing": r["id"]}, "Relist 30 days", quiet=True) + " " + back)
        lrows.append(f'<tr><td>{icon_html(r["icons"], r["ui"])}</td><td class=wrapcell>'
                     f'{_hover(link, id_panel(r))}'
                     f'{stack}</td>'
                     f'<td>{auction_html(r) if r["auction"] else price_html(r["mmd"], r["trophies"])}</td>'
                     f'<td class="wrapcell {"" if live else "x"}">{state if r["auction"] and (live or status == "won") else e(state)}</td><td>{actions}</td></tr>')
    listings = (f'<div class="wrap"><table><tr><th></th><th>Item</th><th>Price</th><th>Status</th><th></th></tr>{"".join(lrows)}</table></div>'
                if lrows else '<p class="empty">You have nothing on the market.</p>')

    def sell_rows(items, where):
      rows = []
      for guid, name, material, stack, itype, icon, ov, ov2, under, ui, attuned, bonded, details in items:
        full = f"{pretty(material)} {name}" if material and material not in ("Unknown",) and pretty(material) not in name else name
        if attuned == 1:
            action = '<span class="muted">Attuned: can\'t be sold</span>'
        else:
            action = (f'<form class="mlist" method="post" action="/market/list">{wiki._hidden(user)}<input type="hidden" name="item" value="{guid}">'
                      f'<input name="mmd" inputmode="numeric" placeholder="MMDs" aria-label="Price in MMDs">'
                      f'<input name="trophies" inputmode="numeric" placeholder="PK Trophies" aria-label="Price in PK Trophies">'
                      f'<button class="btn quiet">List</button></form>'
                      f'<details class="mauction"><summary>or auction it</summary>'
                      f'<form class="mlist" method="post" action="/market/auction">{wiki._hidden(user)}<input type="hidden" name="item" value="{guid}">'
                      f'<select name="cur" aria-label="Auction currency"><option value="mmd">MMDs</option><option value="trophies">PK Trophies</option></select>'
                      f'<input name="start" inputmode="numeric" placeholder="Starting bid" aria-label="Starting bid" required>'
                      f'<input name="bin" inputmode="numeric" placeholder="Buy It Now (opt.)" aria-label="Buy It Now price (optional)">'
                      f'<select name="days" aria-label="Length">{DAY_OPTIONS}</select>'
                      f'<button class="btn quiet">Start auction</button></form></details>')
        rows.append(f'<tr data-n="{e(full.lower())}"><td>{icon_html((under, icon, ov, ov2), ui or 0)}</td>'
                    f'<td class=wrapcell>{_hover(e(full), id_panel_for(full, stack, _details(details), where))}'
                    f'{f" x{stack:,}" if stack and stack > 1 else ""}</td><td>{action}</td></tr>')
      return rows

    mule = sell_rows(_mule_items(account), "In your mule")
    chest = sell_rows(_chest_keys(account), "In your house chest")
    chest_html = (f'<h2>Keys in your house chest</h2><p class="help">Darkbeat, Hera and Shimmering Skeleton keys can\'t go in your mule, so they\'re '
                  f'listed straight from your house storage chest. While listed they wait in the market; taken back or bought, they go into a house '
                  f'chest (the buyer\'s, if sold). If that chest is full they wait in the market until there\'s room.</p>'
                  f'<div class="wrap"><table><tr><th></th><th>Item</th><th>Sell for (one or both)</th></tr>{"".join(chest)}</table></div>') if chest else ""
    mule_html = ((f'<input class="mfind" placeholder="Filter your mule" aria-label="Filter your mule" oninput="'
                  "const t=this.value.toLowerCase();document.querySelectorAll('#mule tr[data-n]').forEach(r=>r.hidden=!r.dataset.n.includes(t))\">"
                  f'<div class="wrap"><table id="mule"><tr><th></th><th>Item</th><th>Sell for (one or both)</th></tr>{"".join(mule)}</table></div>')
                 if mule else '<p class="empty">Your mule is empty (or you have never summoned it).</p>')

    bidding = _q("SELECT l.id, l.name, l.stack_Size, l.auction_Currency, l.high_Bid, l.high_Bidder_Account_Id = %s, l.expires_At, l.status, MAX(b.amount), l.wcid "
                 "FROM market_bid b JOIN market_listing l ON l.id = b.listing_Id WHERE b.account_Id = %s AND l.status IN ('active', 'busy', 'won') "
                 "GROUP BY l.id ORDER BY l.expires_At", (account, account))
    brows = []
    for lid, name, stack, cur, high, winning, ends, status, mine_max, wcid in bidding:
        if status == "won":
            where = f"You won! It goes to your {'house chest' if wcid in KEY_WCIDS else 'mule'} as soon as there's room." if winning else "Ended."
        elif winning:
            where = f'You\'re the highest bidder at {high:,} {unit(cur, high)} · ends in {ends_html(ends)}'
        else:
            where = f'Outbid: high bid {high:,} {unit(cur, high)} (yours was {mine_max:,}) · ends in {ends_html(ends)}'
        brows.append(f'<li><span><a href="/market/item/{lid}">{e(name)}</a>{f" x{stack:,}" if stack > 1 else ""}</span>'
                     f'<span class="{"" if winning else "x"}">{where}</span></li>')
    owed = _q("SELECT id, name, stack_Size FROM market_listing WHERE buyer_Account_Id = %s AND status = 'owed' ORDER BY id", (account,))
    if owed:
        notices += ('<h2>Waiting for room in your house chest</h2><ul class="feed">' + "".join(
            f'<li><span><a href="/market/item/{lid}">{e(name)}</a>{f" x{stack:,}" if stack > 1 else ""}</span>'
            f'<span class="muted">bought, goes in as soon as a house chest has room</span></li>' for lid, name, stack in owed) + '</ul>')
    bids_html = f'<h2>Your bids</h2><ul class="feed mbids">{"".join(brows)}</ul>' if brows else ""

    history = _q("SELECT id, name, stack_Size, status, paid_Currency, paid_Amount, closed_At, buyer_Account_Id = %s AS bought, buyer_Name, seller_Name, details, wcid "
                 "FROM market_listing WHERE (seller_Account_Id = %s OR buyer_Account_Id = %s) AND status IN ('sold', 'returned') ORDER BY closed_At DESC LIMIT 30",
                 (account, account, account))
    hrows = []
    for lid, name, stack, status, cur, amount, closed, bought, buyer, seller, details, wcid in history:
        paid = (f"{amount // PYREALS_PER_MMD:,} MMDs" if cur == "pyreals" else f"{amount:,} PK Trophies") if amount else ""
        what = (f"Bought from {seller} for {paid}" if bought else f"Sold to {buyer} for {paid}") if status == "sold" else f"Taken back to your {'house chest' if wcid in KEY_WCIDS else 'mule'}"
        link = _hover(f'<a href="/market/item/{lid}">{e(name)}</a>', id_panel_for(name, stack, _details(details)))
        hrows.append(f'<li><span>{link}{f" x{stack:,}" if stack > 1 else ""}: {e(what)}</span>'
                     f'<span class="muted">{wiki._ago(closed) if closed else ""}</span></li>')
    hist = f'<ul class="feed">{"".join(hrows)}</ul>' if hrows else '<p class="empty">No sales or purchases yet.</p>'

    sent = '<p class="note">Sent to the game server. It usually finishes within a few seconds.</p>' if _arg(query, "sent") else ""
    err = f'<p class="err">{e(_arg(query, "err")[:200])}</p>' if _arg(query, "err") else ""
    _page(h, "My market", f'<h1>My market</h1>{sent}{err}{notices}{bids_html}<h2>Your listings</h2>{listings}'
                          f'<h2>Your mule</h2><p class="help">Pick a price in MMDs, PK Trophies, or both (the buyer picks). Listings last {LISTING_DAYS} days, '
                          f'then wait here for you to relist or take back. Or auction it for 1 to 14 days with an optional Buy It Now price. No fees. Items appear here as they are in your mule; '
                          f'summon your mule in game once if pictures are missing.</p>{mule_html}{chest_html}'
                          f'<h2>History</h2>{hist}{FLIP}', user, refresh=4 if waiting else None)


# ---------------------------------------------------------------- actions

def _num(f, key, limit):
    v = (f.get(key) or "").replace(",", "").strip()
    if not v:
        return 0
    if not v.isdigit() or len(v) > 12:
        raise ValueError
    n = int(v)
    if n > limit:
        raise ValueError
    return n


def _chest_key(account, item):
    """(attuned, bonded) of a key in the account's house chest, or None"""
    try:
        return _q(f"SELECT attuned, bonded FROM {VIEW_DB}.market_chest_key WHERE account_Id = %s AND item_Guid = %s", (account, item), one=True)
    except Exception:
        return None


def act(h, user, kind):
    f = wiki._form(h)
    if not user:
        return wiki._redirect(h, "/wiki/login?next=/market/mine")
    if not wiki._csrf_ok(h, f, user):
        return wiki._redirect(h, "/market/mine?err=" + quote("That form expired. Try again."))
    account = _account(user)
    if account is None:
        return wiki._redirect(h, "/market/mine?err=" + quote("Your wiki login isn't linked to a game account."))
    fail = lambda msg, where="/market/mine": wiki._redirect(h, where + ("&" if "?" in where else "?") + "err=" + quote(msg))
    if wiki._limited(f"market:{account}", 20, 60):
        return fail("Too many requests. Wait a minute.")
    busy = _q("SELECT COUNT(*) FROM market_request WHERE account_Id = %s AND status IN ('pending', 'working')", (account,), one=True)[0]
    if busy >= 10:
        return fail("You have too many requests waiting. Give the game server a few seconds.")

    if kind == "auction":
        item = (f.get("item") or "").strip()
        cur = f.get("cur") if f.get("cur") in ("mmd", "trophies") else None
        days = (f.get("days") or "").strip()
        if not item.isdigit():
            return fail("Pick an item.")
        if not cur:
            return fail("Pick MMDs or PK Trophies for the auction.")
        if not days.isdigit() or not 1 <= int(days) <= 14:
            return fail("An auction lasts from 1 day to 2 weeks.")
        limit = MAX_TROPHIES if cur == "trophies" else MAX_MMD
        try:
            start, bin_ = _num(f, "start", limit), _num(f, "bin", limit)
        except ValueError:
            return fail(f"Bids are whole numbers, up to {limit:,}.")
        if not start:
            return fail("Set a starting bid.")
        if bin_ and bin_ <= start:
            return fail("Buy It Now has to be higher than the starting bid.")
        owned = _q(f"SELECT attuned FROM {VIEW_DB}.market_mule_item WHERE account_Id = %s AND item_Guid = %s", (account, int(item)), one=True) or _chest_key(account, int(item))
        if not owned:
            return fail("That item isn't in your mule or house chest.")
        if owned[0] == 1:
            return fail("Attuned items can't be sold.")
        _x("INSERT INTO market_request (created_At, account_Id, character_Name, kind, item_Guid, auction_Currency, start_Bid, buy_Now, auction_Hours) "
           "VALUES (UTC_TIMESTAMP(), %s, %s, 'auction', %s, %s, %s, %s, %s)", (account, user["name"], int(item), cur, start, bin_ or None, int(days) * 24))
    elif kind == "list":
        item = (f.get("item") or "").strip()
        if not item.isdigit():
            return fail("Pick an item.")
        try:
            mmd, trophies = _num(f, "mmd", MAX_MMD), _num(f, "trophies", MAX_TROPHIES)
        except ValueError:
            return fail(f"Prices are whole numbers, up to {MAX_MMD:,} MMDs or {MAX_TROPHIES:,} PK Trophies.")
        if not mmd and not trophies:
            return fail("Set a price in MMDs, PK Trophies, or both.")
        owned = _q(f"SELECT attuned, bonded FROM {VIEW_DB}.market_mule_item WHERE account_Id = %s AND item_Guid = %s", (account, int(item)), one=True) or _chest_key(account, int(item))
        if not owned:
            return fail("That item isn't in your mule or house chest.")
        if owned[0] == 1:
            return fail("Attuned items can't be sold.")
        _x("INSERT INTO market_request (created_At, account_Id, character_Name, kind, item_Guid, price_Mmd, price_Trophies) "
           "VALUES (UTC_TIMESTAMP(), %s, %s, 'list', %s, %s, %s)", (account, user["name"], int(item), mmd or None, trophies or None))
    else:
        lid = (f.get("listing") or "").strip()
        if not lid.isdigit():
            return fail("Pick a listing.")
        row = _q("SELECT seller_Account_Id, status, price_Mmd, price_Trophies, kind, auction_Currency, buy_Now, high_Bid, start_Bid, high_Bidder_Account_Id, "
                 "expires_At FROM market_listing WHERE id = %s", (int(lid),), one=True)
        if not row:
            return fail("That listing doesn't exist.")
        seller, status, pmmd, ptro, lkind, acur, bin_, high, start, high_acct, expires = row
        if lkind == "auction":
            # the auction's own currency and Buy It Now price count; the game server checks everything again
            pmmd, ptro = (bin_, None) if acur == "mmd" else (None, bin_)
        if kind == "bid":
            back = f"/market/item/{lid}"
            amount = (f.get("amount") or "").replace(",", "").strip()
            if lkind != "auction" or status != "active" or expires <= datetime.utcnow():
                return fail("That auction has ended.", back)
            if seller == account:
                return fail("You can't bid on your own auction.", back)
            if high_acct == account:
                return fail("You're already the highest bidder.", back)
            if not amount.isdigit() or len(amount) > 12:
                return fail("Type your bid as a whole number.", back)
            lowest = min_bid(dict(high=high, start=start))
            if int(amount) < lowest:
                return fail(f"The lowest bid you can make is {lowest:,}.", back)
            if bin_ and int(amount) >= bin_:
                return fail("That's at or above the Buy It Now price. Use Buy It Now instead.", back)
            _x("INSERT INTO market_request (created_At, account_Id, character_Name, kind, listing_Id, bid_Amount) VALUES (UTC_TIMESTAMP(), %s, %s, 'bid', %s, %s)",
               (account, user["name"], int(lid), int(amount)))
        elif kind == "buy":
            pay = "trophies" if f.get("pay") == "trophies" else "mmd"
            back = f"/market/item/{lid}"
            if seller == account:
                return fail("That's your own listing.", back)
            if status != "active":
                return fail("That item isn't for sale any more.", back)
            if (pay == "mmd" and not pmmd) or (pay == "trophies" and not ptro):
                return fail("That item can't be bought with that currency.", back)
            _x("INSERT INTO market_request (created_At, account_Id, character_Name, kind, listing_Id, pay_With) VALUES (UTC_TIMESTAMP(), %s, %s, 'buy', %s, %s)",
               (account, user["name"], int(lid), pay))
        else:
            if seller != account:
                return fail("That listing isn't yours.")
            if status not in ("active", "expired"):
                return fail("That listing is already closed.")
            _x("INSERT INTO market_request (created_At, account_Id, character_Name, kind, listing_Id) VALUES (UTC_TIMESTAMP(), %s, %s, %s, %s)",
               (account, user["name"], kind, int(lid)))
    _forget_cache()
    wiki._redirect(h, "/market/mine?sent=1")


def icon(h, icon_id):
    with _icons_lock:
        data = _icons.get(icon_id)
    if data is None:
        row = _q("SELECT png FROM market_icon WHERE icon_Id = %s", (icon_id,), one=True)
        data = bytes(row[0]) if row and row[0] else None
        if data is not None or row is not None:   # cache real icons and known-unreadable ones, not missing ones
            with _icons_lock:
                if len(_icons) < 20000:
                    _icons[icon_id] = data or BLANK_PNG
        data = data or BLANK_PNG
    h.send_response(200)
    h.send_header("Content-Type", "image/png")
    h.send_header("Content-Length", str(len(data)))
    h.send_header("Cache-Control", "public, max-age=86400" if data is not BLANK_PNG else "no-store")
    h.send_header("X-Content-Type-Options", "nosniff")
    h.end_headers()
    h.wfile.write(data)


def handle(h, method):
    """Serves /market and everything under it. Returns True when it handled the request."""
    url = urlparse(h.path)
    path = url.path.rstrip("/") or "/"
    if path != "/market" and not path.startswith("/market/"):
        return False
    query = parse_qs(url.query)
    try:
        m = re.fullmatch(r"/market/icon/(\d{1,10})\.png", path)
        if m and method == "GET":
            icon(h, int(m.group(1)))
            return True
        user = wiki._current_user(h)
        if method == "POST":
            if h.headers.get("Origin") and urlparse(h.headers["Origin"]).netloc != h.headers.get("Host", ""):
                _page(h, "Not allowed", "<h1>That request came from another site</h1>", user, 403)
            elif path in ("/market/list", "/market/buy", "/market/cancel", "/market/relist", "/market/auction", "/market/bid"):
                act(h, user, path.rsplit("/", 1)[1])
            else:
                wiki._send(h, 405, "Method not allowed", "text/plain")
            return True
        m = re.fullmatch(r"/market/item/(\d{1,18})", path)
        if path == "/market":
            browse(h, user, query)
        elif path == "/market/mine":
            mine(h, user, query)
        elif m:
            item_page(h, user, int(m.group(1)), query)
        else:
            _page(h, "Not found", "<h1>Not found</h1>", user, 404)
    except Exception:
        traceback.print_exc()
        try:
            wiki._send(h, 503, _layout("/market", "Market unavailable", "<h1>The market is unavailable</h1><p>Try again in a minute.</p>", None))
        except Exception:
            pass
    return True


# keeps the hover panel on screen: opens it to the left or upward when it would go past the window edge
FLIP = ('<script>(()=>{function place(c){const p=c.querySelector(".idp");if(!p)return;c.classList.add("on");'
        'const r=c.getBoundingClientRect(),w=p.offsetWidth,h=p.offsetHeight;let x=Math.max(8,Math.min(r.left,innerWidth-w-8)),y=r.bottom+6;'
        'if(y+h>innerHeight-8){if(r.top-h-6>=8)y=r.top-h-6;else{y=Math.max(8,Math.min(r.top,innerHeight-h-8));'
        'x=r.right+8+w<=innerWidth-8?r.right+8:Math.max(8,r.left-w-8)}}p.style.left=x+"px";p.style.top=y+"px"}'
        'document.querySelectorAll(".hasid").forEach(c=>{c.addEventListener("mouseenter",()=>place(c));'
        'c.addEventListener("mouseleave",()=>c.classList.remove("on"))});addEventListener("scroll",()=>document.querySelectorAll(".hasid.on").forEach(place),{passive:true})})()</script>')

CSS = """
.mfilter{display:flex;flex-wrap:wrap;gap:.5rem;align-items:center;margin:0 0 .4rem}
.mfilter input,.mfilter select,.mlist input,.mfind{font:inherit;color:var(--bone);background:var(--panel);border:1px solid var(--line);border-radius:4px;padding:.35rem .55rem}
.mfilter input{width:9rem}.mfilter input[name=q]{width:min(100%,18rem)}
.mgrid{display:grid;gap:.6rem;grid-template-columns:repeat(auto-fill,minmax(min(100%,15rem),1fr));margin-top:.6rem}
.mcard{display:flex;gap:.7rem;align-items:center;padding:.6rem .7rem;
  background:var(--panel);border:1px solid var(--line);border-radius:6px;color:var(--bone);text-decoration:none}
.mcard:hover{border-color:var(--portal)}
.mcard,.hasid{position:relative}
.hasid:not(.mcard){display:inline-block;cursor:help}
.idp{display:none;position:fixed;z-index:20;left:0;top:0;width:22rem;max-width:calc(100vw - 2rem);max-height:calc(100vh - 16px);overflow:hidden;padding:.7rem .85rem;
  background:var(--deep);color:var(--bone);border:1px solid var(--gold);border-radius:6px;box-shadow:0 8px 24px rgba(0,0,0,.45);
  font-size:.9rem;line-height:1.4;font-weight:400;pointer-events:none}
.idp .idn{display:block;font-size:1rem;margin-bottom:.35rem;color:var(--gold)}
.idp div span{color:var(--dim)}
.idp .idsp{margin-top:.35rem}
.idp p{margin:.4rem 0 0;max-width:none}
.idp .idf{display:block;margin-top:.45rem;color:var(--dim);font-size:.82rem}
@media (hover:hover){.hasid.on .idp{display:block}}
.mtext{display:flex;flex-direction:column;gap:.1rem;min-width:0}
.mname{font-weight:700;line-height:1.25}.mprice{font-size:.95rem}.mmeta{font-size:.85rem;color:var(--dim)}
.pm{color:var(--gold);font-weight:700}.pt{color:var(--blood);font-weight:700}
.micon{position:relative;display:inline-block;width:32px;height:32px;flex:none;background:var(--deep);border-radius:3px;vertical-align:middle}
.micon img{position:absolute;inset:0;width:100%;height:100%;image-rendering:pixelated}
.micon.big{width:64px;height:64px}
.fx-magic{box-shadow:0 0 0 1px #6fa8ff,0 0 8px #3b7bff}.fx-fire{box-shadow:0 0 0 1px #ff8a3d,0 0 8px #ff5a1f}
.fx-frost{box-shadow:0 0 0 1px #9fe7ff,0 0 8px #5ccfff}.fx-lightning{box-shadow:0 0 0 1px #ffe36b,0 0 8px #ffd21f}
.fx-acid{box-shadow:0 0 0 1px #8dff6b,0 0 8px #43d91f}.fx-nether{box-shadow:0 0 0 1px #c38bff,0 0 8px #8a3fc2}
.fx-poison{box-shadow:0 0 0 1px #8dff6b}.fx-blunt,.fx-slash,.fx-pierce{box-shadow:0 0 0 1px #d8d8d8,0 0 6px #aaa}
.mhead{display:flex;gap:1.1rem;align-items:center;margin-bottom:.6rem}.mhead h1{margin:0}
.mbig{font-size:1.25rem;margin:.2rem 0}
.mlist{display:flex;gap:.4rem;flex-wrap:wrap;align-items:center}.mlist input{width:7.5rem}
.mfind{width:min(100%,18rem);margin:.2rem 0 .6rem}
.mauction{margin-top:.35rem;font-size:.92rem}.mauction summary{display:inline;color:var(--portal);cursor:pointer}
.mauction form{margin-top:.4rem}.mauction select{font:inherit;color:var(--bone);background:var(--panel);border:1px solid var(--line);border-radius:4px;padding:.35rem .4rem}
.mauc{font-size:.85rem;color:var(--blood)}
.mbids li>span:last-child{white-space:normal;text-align:right}
.mraw{margin-top:2rem}.mraw table{min-width:0}
td .micon{margin:-.2rem 0}
"""
