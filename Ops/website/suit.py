"""
JawnTide Suit Builder (/suit): finds the best suit of armor, underclothes and jewelry in a player's mule for the slots and
spells they choose. The search runs in the browser (SUIT_JS); the site only hands over the account's wearable mule items
(from the ace_web.market_mule_item view the market already uses) and saves finished suits to ace_shard.suit_plan, so in
game "/mule suit CODE" can filter the mule window to them. Sign-in is the wiki login.

Database access (see market-setup.sh): read ace_web.market_mule_item and the account's characters' names and levels;
read and insert ace_shard.suit_plan. Nothing else.
"""
import json
import re
import secrets
import traceback
from urllib.parse import urlparse

import market
import wiki

e = market.e

# EquipMask bits that mean "worn": clothing and armor (0x1-0x7FFF), jewelry (neck, wrists, rings), trinket, cloak
WEARABLE = 0x7FFF | 0x8000 | 0x10000 | 0x20000 | 0x40000 | 0x80000 | 0x4000000 | 0x8000000
RATINGS = [("GearDamage", "Damage"), ("GearDamageResist", "Damage resist"), ("GearCrit", "Crit"), ("GearCritResist", "Crit resist"),
           ("GearCritDamage", "Crit damage"), ("GearCritDamageResist", "Crit damage resist"), ("GearHealingBoost", "Healing boost"),
           ("GearMaxHealth", "Max health"), ("GearPKDamageRating", "PK damage"), ("GearPKDamageResistRating", "PK damage resist")]
MAX_PLAN_ITEMS = 500
KEEP_PLANS = 50


def _spell_names(d):
    """The item's spells as shown on the page: its own spells, plus a cloak's surge ("Surge: ...", including the damage
    reduction surge, which has no spell) or a weapon's cast on strike."""
    I = d.get("int", {})
    cloak = int(I.get("ValidLocations") or 0) & 0x8000000
    out = [x["name"] for x in d.get("spells", []) if x.get("name") and not x.get("proc") and not x.get("use")]
    # a cloak's skill (its set, e.g. CloakTwoHandedCombat -> "Two Handed Combat Cloak") comes first
    set_name = str(d.get("names", {}).get("EquipmentSetId") or "")
    if cloak and set_name.startswith("Cloak") and len(set_name) > 5:
        out.insert(0, market.pretty(set_name[5:]) + " Cloak")
    for x in d.get("spells", []):
        if x.get("name") and x.get("proc"):
            n = x["name"]
            out.append((n if n.lower().startswith("surge") else "Surge: " + n) if cloak else "Cast on strike: " + n)
    if cloak and int(I.get("CloakWeaveProc") or 0) == 2:
        out.append("Surge: Damage Reduction (reduces a hit by up to 200)")
    return out


def _item(row, src="me"):
    (guid, name, material, stack, itype, icon, ov, ov2, under, ui, attuned, bonded, details) = row
    if not details:
        return None
    try:
        d = json.loads(details)
    except ValueError:
        return None
    full = f"{material} {name}" if material and not str(name).startswith(str(material)) else name
    return _wearable(d, int(guid), full, (under, icon, ov, ov2), ui, itype, attuned, src)


def _wearable(d, guid, full, icons, ui, itype, attuned, src):
    """The Suit Builder's view of one item (None if it isn't worn armor, clothing or jewelry). src: "me", "g:<account>" or "m"."""
    I, N = d.get("int", {}), d.get("names", {})
    vl, cov = int(I.get("ValidLocations") or 0), int(I.get("ClothingPriority") or 0)
    if not vl & WEARABLE or vl & 0x00F00000:   # not worn, or a weapon/shield
        return None
    reqs = []
    for n in ("", "2", "3", "4"):
        r = N.get(f"WieldRequirements{n}")
        if r and r != "Invalid":
            reqs.append([r, market.pretty(N.get(f"WieldSkillType{n}") or ""), I.get(f"WieldDifficulty{n}") or 0])
    spells = _spell_names(d)
    ratings = {k: I[k] for k, _ in RATINGS if I.get(k)}
    return dict(g=int(guid), src=src, n=full, ic=[i for i in icons if i], ui=int(ui or 0), t=int(itype or 0), vl=vl, cov=cov,
                al=int(I.get("ArmorLevel") or 0), set=market.pretty(N.get("EquipmentSetId")) if N.get("EquipmentSetId") not in (None, "Invalid") else "",
                sp=spells, rq=reqs, lv=market._wield_level(d) or 0, lore=int(I.get("ItemDifficulty") or 0),
                rt=ratings, att=bool(attuned and attuned >= 1), wk=int(I.get("ItemWorkmanship") or 0), mt=int(I.get("MaterialType") or 0))


def _row(d, guid, full, icons, ui, itype, attuned, src, stack=1):
    """One row of the Item search table (every item, not just wearable ones)."""
    I, N, F = d.get("int", {}), d.get("names", {}), d.get("float", {})
    nmat = I.get("NumItemsInMaterial") or 1
    work = round(I["ItemWorkmanship"] / nmat, 2) if I.get("ItemWorkmanship") else 0
    imbue = N.get("ImbuedEffect")
    return dict(g=int(guid), src=src, n=full, ic=[i for i in icons if i], ui=int(ui or 0), cat=market._category(int(itype or 0)),
                vl=int(I.get("ValidLocations") or 0), set=market.pretty(N.get("EquipmentSetId")) if N.get("EquipmentSetId") not in (None, "Invalid") else "",
                al=int(I.get("ArmorLevel") or 0), lv=market._wield_level(d) or 0, lore=int(I.get("ItemDifficulty") or 0), wk=work,
                val=int(I.get("Value") or 0), dmg=int(I.get("Damage") or 0), dv=round(F.get("DamageVariance") or 0, 2),
                ws=market.pretty(N.get("WeaponSkill") or N.get("WieldSkillType") or ""), imb=market.pretty(imbue) if imbue and imbue != "Undef" else "",
                sp=_spell_names(d),
                rt={k: I[k] for k, _ in RATINGS if I.get(k)}, st=int(stack or 1), att=bool(attuned and attuned >= 1), mt=int(I.get("MaterialType") or 0))


def _rows_for(rows, src, inv, items, locs=None):
    """Adds a mule's items to the Item search rows (inv) and the wearable ones to the suit search items. Returns how many lack details.
    locs: where each row is ("on Az (worn)"), for characters and house chests."""
    missing = 0
    for n_, r in enumerate(rows):
        (guid, name, material, stack, itype, icon, ov, ov2, under, ui, attuned, bonded, details) = r
        if not details:
            missing += 1
            continue
        try:
            d = json.loads(details)
            full = f"{material} {name}" if material and not str(name).startswith(str(material)) else name
            row = _row(d, guid, full, (under, icon, ov, ov2), ui, itype, attuned, src, stack)
            it = _wearable(d, int(guid), full, (under, icon, ov, ov2), ui, itype, attuned, src)
            if locs:
                row["loc"] = locs[n_]
                if it:
                    it["loc"] = locs[n_]
            inv.append(row)
            if it:
                items.append(it)
        except Exception:
            continue
    return missing


def _carried(account):
    """(character rows, their locations, chest rows, their locations) from ace_web.suit_char_item; empty until market-setup.sh made it."""
    cols = "char_Name, loc, item_Guid, name, material, stack_Size, item_Type, icon_Id, icon_Overlay_Id, icon_Overlay2_Id, icon_Underlay_Id, ui_Effects, attuned, bonded, details"
    try:
        rows = market._q(f"SELECT {cols} FROM {market.VIEW_DB}.suit_char_item WHERE account_Id = %s LIMIT 10000", (account,))
    except Exception:
        return [], [], [], []
    ch, chl, hs, hsl = [], [], [], []
    for r in rows:
        if r[1] == "house chest":
            hs.append(r[2:]); hsl.append(f"{r[0]}'s house chest")
        else:
            ch.append(r[2:]); chl.append(f"on {r[0]} ({r[1]})")
    return ch, chl, hs, hsl


def _characters(account):
    try:
        rows = market._q("SELECT c.name, COALESCE(l.value, 1) FROM `character` c LEFT JOIN biota_properties_int l ON l.object_Id = c.id AND l.type = 25 "
                         "WHERE c.account_Id = %s AND c.is_Deleted = 0 ORDER BY c.name", (account,))
        return [dict(n=r[0], lv=int(r[1])) for r in rows]
    except Exception:
        return []


def _guest_mules(account):
    """Mules this account's characters were added to as guests: [(owner account, name to show)]."""
    try:
        rows = market._q("SELECT g.account_Id, MIN(g.added_By), MIN(c.name) FROM mule_guest g JOIN `character` c ON c.id = g.guest_Id "
                         "WHERE c.account_Id = %s AND c.is_Deleted = 0 AND g.account_Id <> %s GROUP BY g.account_Id", (account, account))
        return [(int(r[0]), f"{r[1] or 'another player'}'s mule (guest as {r[2]})") for r in rows]
    except Exception:
        return []


def _market_items():
    """(wearable items for the suit search, every listing for the Item search), both from the Market's active listings."""
    out, rows = [], []
    try:
        for r in market.active_listings():
            price = []
            if r["mmd"]:
                price.append(f'{r["mmd"]:,} MMD')
            if r["trophies"]:
                price.append(f'{r["trophies"]:,} PK Trophies')
            extra = dict(price=(" or ".join(price) or "?") + (" (auction)" if r["auction"] else ""), seller=r["seller"])
            d = r["details"] or {}
            row = _row(d, int(r["id"]), r["name"], r["icons"], r["ui"], r["item_type"], 0, "m", r["stack"])
            row.update(extra)
            rows.append(row)
            it = _wearable(d, int(r["id"]), r["name"], r["icons"], r["ui"], r["item_type"], 0, "m")
            if it:
                it.update(extra)
                out.append(it)
    except Exception:
        traceback.print_exc()
    return out, rows


def _plans(account):
    try:
        return market._q("SELECT code, name, items, created_At FROM suit_plan WHERE account_Id = %s ORDER BY id DESC LIMIT 20", (account,))
    except Exception:
        return []


def page(h, user, query):
    if not user:
        return market._page(h, "Suit Builder", '<h1>Suit Builder</h1><p>The Suit Builder searches your mule (and, if you like, your characters, '
                             'house chests, mules you\'re a guest of and the Market) for the best suit for the slots and spells you pick.</p>'
                             '<p>It needs your game account, so sign in first. It\'s the same sign-in as the wiki and the Market.</p>'
                             '<p><a class="btn" href="/wiki/login?next=/suit">Sign in</a> <a class="btn" href="/wiki/link">Register (first time)</a></p>'
                             '<p class="muted">First time? Registering takes a minute: get a code on the website, type <code>/wiki CODE</code> in game, '
                             'then pick a password. See <a href="/wiki/website-account">Website account</a>.</p>', None, nav="/suit")
    account = market._account(user)
    if account is None:
        return market._page(h, "Suit Builder", '<h1>Suit Builder</h1><p>Your wiki login isn\'t linked to a game account. '
                            '<a href="/wiki/link">Link it</a> first.</p>', user, nav="/suit")
    items, inv = [], []
    missing = _rows_for(market._mule_items(account), "me", inv, items)
    sources = [dict(k="me", n="My mule", on=True)]
    ch, chl, hs, hsl = _carried(account)
    missing += _rows_for(ch, "c", inv, items, chl)
    missing += _rows_for(hs, "h", inv, items, hsl)
    sources += [dict(k="c", n="My characters (worn and in packs)", on=False), dict(k="h", n="My house storage chests", on=False)]
    for owner, label in _guest_mules(account):
        _rows_for(market._mule_items(owner), f"g:{owner}", inv, items)
        sources.append(dict(k=f"g:{owner}", n=label, on=False))
    market_items, market_rows = _market_items()
    items.extend(market_items)
    inv.extend(market_rows)
    sources.append(dict(k="m", n=f"Items for sale on the Market ({len(market_rows)})", on=False))
    data = dict(items=items, inv=inv, sources=sources, chars=_characters(account), ratings=RATINGS, csrf=user["csrf"],
                plans=[dict(code=p[0], name=p[1], n=len([x for x in (p[2] or "").split(",") if x]), at=p[3].strftime("%b %d")) for p in _plans(account)])
    note = (f'<p class="muted">{missing} item{"s" if missing != 1 else ""} can\'t be used yet: the game server hasn\'t read '
            f'{"their" if missing != 1 else "its"} details. Summon your mule, log the character in and out, or open and close the house chest once, then reload this page.</p>' if missing else "")
    blob = json.dumps(data, default=str).replace("</", "<\\/")
    body = (f'<h1>Suit Builder</h1><p><b>Suit search</b> finds the best suit in your mule (and, if you like, the mules you\'re a guest of and the Market) for the slots and spells you pick; <b>Item search</b> lists every item in a sortable table with filters. '
            f'Save a suit, then in game open your mule and type <code>/mule suit CODE</code> to show just those items. '
            f'See <a href="/wiki/suit-builder">Suit Builder</a> on the wiki.</p>{note}'
            f'<div id="suitapp"><p class="muted">Loading…</p></div>'
            f'<script id="suitdata" type="application/json">{blob}</script>'
            f'<style>{SUIT_CSS}</style><script>{SUIT_JS}</script>')
    market._page(h, "Suit Builder", body, user, nav="/suit")


def save(h, user):
    f = wiki._form(h)
    out = lambda status, obj: wiki._send(h, status, json.dumps(obj), "application/json")
    if not user:
        return out(401, {"error": "Sign in first."})
    if not wiki._csrf_ok(h, f, user):
        return out(403, {"error": "That page expired. Reload it and try again."})
    account = market._account(user)
    if account is None:
        return out(403, {"error": "Your wiki login isn't linked to a game account."})
    if wiki._limited(f"suit:{account}", 20, 60):
        return out(429, {"error": "Too many saves. Wait a minute."})
    name = re.sub(r"\s+", " ", (f.get("name") or "").strip())[:64] or "Suit"
    try:
        guids = sorted({int(x) for x in (f.get("items") or "").split(",") if x.strip()})
    except ValueError:
        return out(400, {"error": "Bad item list."})
    if not guids or len(guids) > MAX_PLAN_ITEMS:
        return out(400, {"error": f"Pick between 1 and {MAX_PLAN_ITEMS} items."})
    mine = {int(r[0]) for r in market._mule_items(account)}
    for owner, _ in _guest_mules(account):
        mine |= {int(r[0]) for r in market._mule_items(owner)}
    if any(g not in mine for g in guids):
        return out(400, {"error": "Some of those items aren't in your mule anymore. Reload the page and search again."})
    code = None
    for _ in range(10):
        c = "".join(secrets.choice("ABCDEFGHJKLMNPQRSTUVWXYZ23456789") for _ in range(5))
        if not market._q("SELECT 1 FROM suit_plan WHERE account_Id = %s AND code = %s", (account, c), one=True):
            code = c
            break
    if not code:
        return out(503, {"error": "Try again."})
    market._x("INSERT INTO suit_plan (account_Id, code, name, items, created_At) VALUES (%s, %s, %s, %s, UTC_TIMESTAMP())",
              (account, code, name, ",".join(map(str, guids))))
    try:
        market._x("DELETE FROM suit_plan WHERE account_Id = %s AND id NOT IN (SELECT id FROM (SELECT id FROM suit_plan WHERE account_Id = %s "
                  "ORDER BY id DESC LIMIT %s) k)", (account, account, KEEP_PLANS))
    except Exception:
        pass   # no DELETE grant: old suits just stay
    return out(200, {"code": code, "name": name})


def handle(h, method):
    """Serves /suit and /suit/save. Returns True when it handled the request."""
    path = urlparse(h.path).path.rstrip("/") or "/"
    if path not in ("/suit", "/suit/save"):
        return False
    try:
        user = wiki._current_user(h)
        if path == "/suit/save" and method == "POST":
            save(h, user)
        elif path == "/suit" and method == "GET":
            page(h, user, None)
        else:
            wiki._send(h, 405, "Method not allowed", "text/plain")
    except Exception:
        traceback.print_exc()
        try:
            wiki._send(h, 503, "<h1>The Suit Builder is unavailable</h1><p>Try again in a minute.</p>")
        except Exception:
            pass
    return True


SUIT_CSS = """
#suitapp .sbox{background:var(--panel);border:1px solid var(--line);border-radius:6px;padding:.7rem .85rem;margin:.6rem 0}
#suitapp h2{font-size:1.1rem;margin:.1rem 0 .5rem}
#suitapp select,#suitapp input[type=text],#suitapp input[type=number]{font:inherit;color:var(--bone);background:var(--deep);border:1px solid var(--line);border-radius:4px;padding:.3rem .45rem}
#suitapp input[type=number]{width:4.5rem}
#suitapp .row{display:flex;flex-wrap:wrap;gap:.5rem .9rem;align-items:center;margin:.3rem 0}
#suitapp .slots{display:grid;grid-template-columns:repeat(auto-fill,minmax(9.5rem,1fr));gap:.25rem .6rem}
#suitapp label{cursor:pointer}
#suitapp .want{display:flex;flex-wrap:wrap;gap:.4rem;align-items:center;margin:.25rem 0;padding:.25rem 0;border-bottom:1px solid var(--line)}
#suitapp .want .fam{min-width:14rem;font-weight:700}
#suitapp .want .cnt{color:var(--dim);font-size:.85rem}
#suitapp .want.setall{background:var(--deep);border-radius:4px;padding:.35rem .45rem}
#suitapp button{font:inherit;cursor:pointer;color:var(--bone);background:var(--deep);border:1px solid var(--line);border-radius:4px;padding:.3rem .6rem}
#suitapp button.go{background:var(--portal);color:#111;border-color:var(--portal);font-weight:700;padding:.45rem 1rem}
#suitapp button.x{padding:.1rem .45rem}
#suitapp .muted{color:var(--dim)}
#suitapp .ok{color:#7fd17f}#suitapp .no{color:var(--blood)}#suitapp .part{color:var(--gold)}
#suitapp .res{background:var(--panel);border:1px solid var(--line);border-radius:6px;padding:.7rem .85rem;margin:.7rem 0}
#suitapp .res table{width:100%;border-collapse:collapse;font-size:.92rem}
#suitapp .res td,#suitapp .res th{padding:.25rem .35rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
#suitapp .tags span{display:inline-block;margin:.1rem .25rem .1rem 0;padding:0 .35rem;border-radius:3px;background:var(--deep);font-size:.85rem}
#suitapp .tags span.hit{background:#26442a;color:#bff0bf}
#suitapp .chips span{display:inline-block;margin:.1rem .3rem .1rem 0;padding:.05rem .4rem;border-radius:3px;font-size:.88rem;background:var(--deep)}
#suitapp code.cmd{font-size:1.05rem;padding:.2rem .45rem;background:var(--deep);border-radius:4px}
#suitapp .sm{font-size:.85rem}
#suitapp details.sbox summary{cursor:pointer}
#suitapp .tabs button{font-weight:700;padding:.45rem 1rem}#suitapp .tabs button.on{background:var(--portal);color:#111;border-color:var(--portal)}
#suitapp table.inv{font-size:.88rem;min-width:900px}#suitapp table.inv th{position:sticky;top:0;background:var(--panel)}
#suitapp table.inv td,#suitapp table.inv th{padding:.25rem .35rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
#suitapp .doll{display:grid;gap:.35rem;grid-template-columns:repeat(3,minmax(0,1fr));
 grid-template-areas:"neck head trinket" "uarms chest cloak" "larms abdomen shirt" "hands ulegs pants" "lwrist llegs rwrist" "lring feet rring"}
#suitapp .dslot{background:var(--deep);border:1px solid var(--line);border-radius:5px;padding:.3rem .4rem;min-width:0;overflow-wrap:anywhere}
#suitapp .dslot .sl{display:block;font-size:.75rem;color:var(--dim);text-transform:uppercase;letter-spacing:.03em}
#suitapp label.dslot{display:flex;gap:.35rem;align-items:center;opacity:.55}
#suitapp label.dslot:has(input:checked){opacity:1;border-color:var(--portal)}
#suitapp .res .dslot{font-size:.85rem}
#suitapp .dslot.filled{border-color:var(--portal)}
#suitapp .dslot.empty .sl+span{color:var(--blood)}
#suitapp .dslot.off{opacity:.45}
#suitapp .dslot.cont{border-style:dashed}
#suitapp .dslot .tags span{font-size:.75rem}
#suitapp .dslot .micon img{width:24px;height:24px;vertical-align:middle}
@media (max-width:640px){#suitapp .want .fam{min-width:0;width:100%}#suitapp .res .doll{grid-template-columns:1fr;grid-template-areas:none}
 #suitapp .res .dslot{grid-area:auto!important}}
"""

SUIT_JS = r"""
(()=>{
const D=JSON.parse(document.getElementById('suitdata').textContent);
const app=document.getElementById('suitapp');
const esc=s=>String(s==null?'':s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

// ---- slots: one bit each, in search order
const SLOTS=[['head','Head'],['chest','Chest'],['abdomen','Abdomen'],['uarms','Upper arms'],['larms','Lower arms'],['hands','Hands'],
 ['ulegs','Upper legs'],['llegs','Lower legs'],['feet','Feet'],['shirt','Shirt'],['uabd','(underclothes abdomen)'],['pants','Pants'],
 ['neck','Necklace'],['lwrist','Left bracelet'],['rwrist','Right bracelet'],['lring','Left ring'],['rring','Right ring'],['trinket','Trinket'],['cloak','Cloak']];
const BIT={};SLOTS.forEach((s,i)=>BIT[s[0]]=1<<i);
const NB=SLOTS.length;
// the game decides what can be worn together by each item's ValidLocations (equip slots), not by what it covers
const EQ=[[0x1,'head'],[0x2,'shirt'],[0x4,'uabd'],[0x8,'shirt'],[0x10,'shirt'],[0x20,'hands'],[0x40,'pants'],[0x80,'pants'],[0x100,'feet'],
 [0x200,'chest'],[0x400,'abdomen'],[0x800,'uarms'],[0x1000,'larms'],[0x2000,'ulegs'],[0x4000,'llegs']];
const JEW=0x8000|0x10000|0x20000|0x40000|0x80000|0x4000000|0x8000000;
// tailoring: which single slots a multi-slot loot armor piece can be reduced to, by the server's own rules (Tailoring.TailorReduceArmor):
//   main reduction tool: chest if it has chest, else upper arms, else abdomen
//   lower tool (never for chest pieces): lower arms if it has upper arms, else lower legs if it has upper legs, else feet if it has lower legs and feet
//   middle tool: upper legs if it has upper legs
// Only loot armor (it has workmanship) can be reduced.
function slotNames(m){return SLOTS.filter((s,b)=>m&(1<<b)).map(s=>s[0])}
function reductions(it){if(!it.pl.length||!it.wk)return[];const v=it.vl;const has=b=>(v&b)===b;
  const C=0x200,AB=0x400,UA=0x800,UL=0x2000,LL=0x4000,FT=0x100;
  if(slotNames(it.pl[0]).length<2)return[];
  const out=new Set();
  if(has(C))out.add('chest');else if(has(UA))out.add('uarms');else if(has(AB))out.add('abdomen');
  if(!has(C)){if(has(UA))out.add('larms');else if(has(UL))out.add('llegs');else if(has(LL|FT))out.add('feet')}
  if(has(UL))out.add('ulegs');
  return[...out].map(n=>BIT[n])}
// each item -> one or more placements (a ring can go on either hand)
function placements(it){
  const vl=it.vl;let m=0;for(const[b,s]of EQ)if(vl&b)m|=BIT[s];if(m)return[m];
  const out=[];
  if(vl&0x8000)out.push(BIT.neck);if(vl&0x10000)out.push(BIT.lwrist);if(vl&0x20000)out.push(BIT.rwrist);
  if(vl&0x40000)out.push(BIT.lring);if(vl&0x80000)out.push(BIT.rring);if(vl&0x4000000)out.push(BIT.trinket);if(vl&0x8000000)out.push(BIT.cloak);
  return out;
}

// ---- spells: "Legendary Strength" -> family Strength, tier 4; "Strength Self VII" -> family "Strength Self", tier 7
const TW={minor:1,lesser:1,major:2,greater:2,epic:3,legendary:4};
const ROMAN={I:1,II:2,III:3,IV:4,V:5,VI:6,VII:7,VIII:8};
function parse(name){
  let m=name.match(/^(Minor|Lesser|Major|Greater|Epic|Legendary)\s+(.+)$/i);
  if(m)return{f:m[2],t:TW[m[1].toLowerCase()],c:1};
  m=name.match(/^(.+?)\s+(I|II|III|IV|V|VI|VII|VIII)$/);
  if(m)return{f:m[1],t:ROMAN[m[2]],c:0};
  m=name.match(/^Incantation of (.+)$/i);
  if(m)return{f:m[1],t:8,c:0};
  return{f:name,t:1,c:0};
}
const TIERN={1:'Minor',2:'Major',3:'Epic',4:'Legendary'};
const IMP='Impenetrability';
const ARMORVL=0x1|0x20|0x100|0x200|0x400|0x800|0x1000|0x2000|0x4000,UNDERVL=0x2|0x4|0x8|0x10|0x40|0x80,EXTVL=0x1|0x20|0x100;
// armor material groups (the item's material: Steel, Satin, Gromnie Hide, ...)
const MATS=[['metal','Metal'],['leather','Leather and hide'],['cloth','Cloth'],['other','Other']];
const matGroup=it=>{const m=it.mt||0;return m>=56&&m<=64?'metal':m>=52&&m<=55?'leather':m>=3&&m<=8?'cloth':'other'};
const isCov=it=>/\bcovenant\b/i.test(it.n);
const pieceKind=it=>it.vl&ARMORVL?'armor':(it.vl&UNDERVL?'under':null);
const impOn=it=>{const k=pieceKind(it);return k&&S.imp[k].m!=='off'};
const tierName=(f,t)=>FAMS[f]&&FAMS[f].c?(TIERN[t]||t):(t>1?'level '+t:'any');

// index the items
// i is the item's index in ITEMS (everything refers to items by it), so items that can't be worn anywhere are dropped first
const ITEMS=D.items.filter(it=>placements(it).length).map((it,i)=>{const sp={};for(const n of it.sp){const p=parse(n);if(!sp[p.f]||sp[p.f]<p.t)sp[p.f]=p.t}
  const o=Object.assign(it,{i,pl:placements(it),fams:sp});o.red=reductions(o);return o});
const FAMS={};
for(const it of ITEMS)for(const n of it.sp){const p=parse(n);const F=FAMS[p.f]||(FAMS[p.f]={c:p.c,max:0,n:0});F.max=Math.max(F.max,p.t);F.n++}
const FAMLIST=Object.keys(FAMS).sort((a,b)=>(FAMS[b].c-FAMS[a].c)||a.localeCompare(b));
const SETS={};for(const it of ITEMS)if(it.set)SETS[it.set]=(SETS[it.set]||0)+1;
const RATED={};for(const it of ITEMS)for(const k in it.rt)RATED[k]=1;

// ---- templates: keywords matched against the families your items actually have
const DEF=['Invulnerability','Impregnability','Magic Resistance'];
const ATTR=['Strength','Endurance','Coordination','Quickness','Focus','Willpower'];
const TEMPLATES={
 custom:{n:'Custom (keep my picks)'},
 heavy:{n:'Melee: Heavy Weapons',k:ATTR.concat(DEF,['Heavy Weapon','Healing'])},
 light:{n:'Melee: Light Weapons',k:ATTR.concat(DEF,['Light Weapon','Healing'])},
 finesse:{n:'Melee: Finesse Weapons',k:ATTR.concat(DEF,['Finesse Weapon','Healing'])},
 twohand:{n:'Melee: Two Handed',k:ATTR.concat(DEF,['Two Handed','Healing'])},
 missile:{n:'Missile',k:ATTR.concat(DEF,['Missile Weapon','Healing'])},
 war:{n:'Mage: War Magic',k:ATTR.concat(DEF,['War Magic','Mana Conversion','Arcane'])},
 void:{n:'Mage: Void Magic',k:ATTR.concat(DEF,['Void Magic','Mana Conversion','Arcane'])},
 life:{n:'Mage: Life Magic',k:ATTR.concat(DEF,['Life Magic','Mana Conversion','Arcane'])},
 dual:{n:'Melee: Dual Wield',k:ATTR.concat(DEF,['Dual Wield','Healing'])},
 tinker:{n:'Tinker (crafting)',k:['Strength','Endurance','Coordination','Focus','Item Tinkering','Armor Tinkering','Weapon Tinkering','Magic Item Tinkering']},
 wards:{n:'Add: the seven wards',k:['Acid Ward','Bludgeoning Ward','Flame Ward','Frost Ward','Piercing Ward','Slashing Ward','Storm Ward'],add:1},
};
function resolve(k){const kk=k.toLowerCase();
  // a cantrip family named exactly that, else one containing it, else the first non-cantrip containing it
  return FAMLIST.find(f=>FAMS[f].c&&f.toLowerCase()===kk)||FAMLIST.find(f=>FAMS[f].c&&f.toLowerCase().includes(kk))||FAMLIST.find(f=>f.toLowerCase().includes(kk))||null}

// ---- state
const S={slots:new Set(SLOTS.map(s=>s[0]).filter(s=>s!=='uabd')),want:[],set:'',setN:5,set2:'',setN2:4,onlySets:false,reduce:true,cov:'out',mats:new Set(['metal','leather','cloth','other']),
  F:{alBody:'',alExt:'',lvMin:'',lvMax:'',re:'',minLeg:'',minEpic:'',minOff:'',minDef:'',minTot:''},obs:null,al:1,rate:{},imp:{armor:{m:'off',t:4},under:{m:'off',t:4}},char:D.chars[0]?D.chars[0].n:'',noreq:false,
  noatt:false,locked:new Set(),excluded:new Set(),results:null,busy:false,msg:'',src:new Set((D.sources||[]).filter(x=>x.on).map(x=>x.k))};
// which spells to list: only cantrips (Minor/Major/Epic/Legendary), or every spell; remembered in this browser
try{S.allSpells=localStorage.getItem('suitAllSpells')==='1'}catch(e){S.allSpells=false}
try{S.view=localStorage.getItem('suitView')==='list'?'list':'doll'}catch(e){S.view='doll'}
const showSpell=n=>S.allSpells||parse(n).c||/^(Surge|Cast on strike)\b/i.test(n)||/ Cloak$/.test(n);
const SRCNAME={};(D.sources||[]).forEach(x=>SRCNAME[x.k]=x.n);
function applyTemplate(key){const T=TEMPLATES[key];if(!T||!T.k)return;
  if(!T.add){S.want=[];S.slots=new Set(SLOTS.map(s=>s[0]).filter(s=>s!=='uabd'))}
  const miss=[];
  for(const k of T.k){const f=resolve(k);if(!f){miss.push(k);continue}
    if(!S.want.find(w=>w.f===f))S.want.push({f,t:FAMS[f].c?4:FAMS[f].max,p:'need'})}
  S.msg=miss.length?'None of your items have: '+miss.join(', ')+'.':'';
}

// ---- Item search: every item in a sortable, filterable table (after Mag-SuitBuilder's inventory grid)
const CATS=[['armor','Armor'],['under','Underclothes'],['clothing','Other clothing'],['jewelry','Jewelry'],['melee','Melee'],['missile','Missile'],['caster','Casters'],['salvage','Salvage'],['gem','Gems'],['other','Other']];
const RSHORT={GearDamage:'D',GearDamageResist:'DR',GearCrit:'C',GearCritResist:'CR',GearCritDamage:'CD',GearCritDamageResist:'CDR',GearHealingBoost:'Heal',GearMaxHealth:'Vit',GearPKDamageRating:'PvP D',GearPKDamageResistRating:'PvP DR'};
const BYKEY={};for(const it of ITEMS)BYKEY[it.src+':'+it.g]=it;
const INV=(D.inv||[]).map(r=>{let leg=0,epic=0;for(const n of r.sp){const p=parse(n);if(p.c&&p.t>=4)leg++;if(p.c&&p.t>=3)epic++}
  const sl=r.vl?SLOTS.filter((s,b)=>{const m=placements({vl:r.vl});return m.some(x=>x&(1<<b))}).filter(s=>s[0]!=='uabd').map(s=>s[1]).join(', '):'';
  const rsum=ks=>ks.reduce((a,k)=>a+Math.max(0,r.rt[k]||0),0);
  return Object.assign(r,{leg,epic,sl,off:rsum(['GearDamage','GearCrit','GearCritDamage']),def:rsum(['GearDamageResist','GearCritResist','GearCritDamageResist']),tot:Object.values(r.rt).reduce((a,x)=>a+Math.max(0,x),0),
    cat:r.vl&&!(r.vl&~UNDERVL)?'under':CATS.some(c=>c[0]===r.cat)?r.cat:'other',where:r.src==='m'?'Market':r.src==='me'?'My mule':r.loc?r.loc:(SRCNAME[r.src]||'guest mule'),it:BYKEY[r.src+':'+r.g]})});
const IMBUES=[...new Set(INV.map(r=>r.imb).filter(Boolean))].sort();
const IS={q:'',cats:new Set(CATS.map(c=>c[0])),slot:'',set:'',imb:'',cov:'',mat:'',alMin:'',alMax:'',lvMin:'',lvMax:'',minLeg:'',minEpic:'',minOff:'',minDef:'',minTot:'',wkMax:'',sort:'n',dir:1};
const COLS=[['n','Item'],['cat','Type'],['sl','Slots'],['set','Set'],['al','AL'],['lv','Level'],['lore','Lore'],['wk','Work'],['leg','Leg'],['epic','Epic+'],
  ['tot','Ratings'],['dmg','Damage'],['imb','Imbue'],['val','Value'],['where','Where']];
function invRows(){let rx=null;if(IS.q){try{rx=new RegExp(IS.q,'i')}catch(e){rx=null}}
  const n=v=>v===''?null:+v;
  const out=INV.filter(r=>{if(!S.src.has(r.src)||!IS.cats.has(r.cat))return false;
    if(rx&&!rx.test(r.n)&&!rx.test(r.sp.join(', ')))return false;
    if(IS.slot&&!r.sl.split(', ').includes(IS.slot))return false;
    if(IS.set&&r.set!==IS.set)return false;
    if(IS.imb&&r.imb!==IS.imb)return false;
    if(IS.mat&&matGroup(r)!==IS.mat)return false;
    if(IS.cov==='out'&&isCov(r))return false;
    if(IS.cov==='only'&&!isCov(r))return false;
    const chk=(v,min,max)=>!((n(min)!=null&&v<n(min))||(n(max)!=null&&v>n(max)));
    return chk(r.al,IS.alMin,IS.alMax)&&chk(r.lv,IS.lvMin,IS.lvMax)&&chk(r.leg,IS.minLeg,'')&&chk(r.epic,IS.minEpic,'')&&chk(r.off,IS.minOff,'')
      &&chk(r.def,IS.minDef,'')&&chk(r.tot,IS.minTot,'')&&(IS.wkMax===''||!r.wk||r.wk<=+IS.wkMax)});
  const k=IS.sort,d=IS.dir;
  out.sort((a,b)=>{const x=a[k],y=b[k];return(typeof x==='number'&&typeof y==='number'?x-y:String(x).localeCompare(String(y)))*d||a.n.localeCompare(b.n)});
  return out}
function itemsView(){
  const rows=invRows(),shown=rows.slice(0,500);
  const fi=(k,l)=>`<label>${l} <input type=number data-if="${k}" value="${esc(IS[k])}"></label>`;
  const sel=(k,l,opts)=>`<label>${l} <select data-if="${k}"><option value="">(any)</option>${opts.map(o=>`<option${IS[k]===o?' selected':''}>${esc(o)}</option>`).join('')}</select></label>`;
  const head=COLS.map(([k,l])=>`<th data-sort="${k}" style="cursor:pointer;white-space:nowrap">${l}${IS.sort===k?(IS.dir>0?' ▲':' ▼'):''}</th>`).join('');
  const body=shown.map(r=>{const icon=`<span class=micon>${r.ic.map(x=>`<img src="/market/icon/${x}.png" alt="" loading=lazy>`).join('')}</span>`;
    const rts=Object.entries(r.rt).map(([k,v])=>(RSHORT[k]||k)+' '+v).join(' ');
    const where=r.src==='m'?`<a href="/market/item/${r.g}" target=_blank>${esc(r.price)}</a>`:esc(r.where);
    const acts=r.it?`<button class=x data-lock="${r.it.i}" title="Always use in Suit search">🔒</button><button class=x data-ex="${r.it.i}" title="Never use in Suit search">🚫</button>`:'';
    return `<tr><td>${icon} <b>${esc(r.n)}</b>${r.st>1?' ×'+r.st:''}<div class="sm muted">${esc(r.sp.filter(showSpell).join(', '))}</div></td><td>${esc(r.cat)}</td><td class=sm>${esc(r.sl)}</td><td class=sm>${esc(r.set)}</td>
      <td>${r.al||''}</td><td>${r.lv||''}</td><td>${r.lore||''}</td><td>${r.wk||''}</td><td>${r.leg||''}</td><td>${r.epic||''}</td><td class=sm>${esc(rts)}</td>
      <td>${r.dmg?r.dmg+(r.dv?' ('+Math.round(r.dv*100)+'%)':''):''}${r.ws?'<div class="sm muted">'+esc(r.ws)+'</div>':''}</td><td class=sm>${esc(r.imb)}</td><td>${r.val?r.val.toLocaleString():''}</td><td class=sm>${where} ${acts}</td></tr>`}).join('');
  return `<div class=sbox><h2>Item search</h2>
    <div class=row><input type=text data-if="q" value="${esc(IS.q)}" placeholder="Name or spell (regular expression, e.g. legendary.*legendary)" style="min-width:min(100%,24rem)"><button id=ifclear>Clear filters</button></div>
    <div class=row>${CATS.map(([k,l])=>`<label><input type=checkbox data-icat="${k}"${IS.cats.has(k)?' checked':''}> ${l}</label>`).join('')}</div>
    <div class=row>${sel('slot','Slot',SLOTS.filter(s=>s[0]!=='uabd').map(s=>s[1]))}${sel('set','Set',Object.keys(SETS).sort())}${sel('imb','Imbue',IMBUES)}<label>Material <select data-if="mat"><option value="">(any)</option>${MATS.map(([k,l])=>`<option value=${k}${IS.mat===k?' selected':''}>${l}</option>`).join('')}</select></label><label>Covenant armor <select data-if="cov"><option value=""${IS.cov===''?' selected':''}>show</option><option value=out${IS.cov==='out'?' selected':''}>hide</option><option value=only${IS.cov==='only'?' selected':''}>only</option></select></label></div>
    <div class=row>${fi('alMin','AL from')}${fi('alMax','to')}${fi('lvMin','Level from')}${fi('lvMax','to')}${fi('wkMax','Workmanship at most')}</div>
    <div class=row>${fi('minLeg','At least N Legendary')}${fi('minEpic','Epic or better')}${fi('minOff','Offensive ratings')}${fi('minDef','Defensive')}${fi('minTot','Total ratings')}</div>
    <div class=row><span class=muted>${rows.length.toLocaleString()} item${rows.length===1?'':'s'}${rows.length>500?', showing the first 500: narrow the filters':''}. Click a column to sort.</span><button id=ifcsv>Download as CSV (spreadsheet)</button></div></div>
  <div class="res" style="overflow-x:auto"><table class=inv><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>`}
function invCsv(){const rows=invRows();const q=v=>'"'+String(v==null?'':v).replace(/"/g,'""')+'"';
  const hdr=['Item','Stack','Type','Slots','Set','AL','Level','Lore','Workmanship','Legendary','Epic+','Ratings','Damage','Imbue','Value','Where','Price','Spells'];
  const lines=[hdr.map(q).join(',')].concat(rows.map(r=>[r.n,r.st,r.cat,r.sl,r.set,r.al,r.lv,r.lore,r.wk,r.leg,r.epic,Object.entries(r.rt).map(([k,v])=>(RSHORT[k]||k)+' '+v).join(' '),r.dmg,r.imb,r.val,r.where,r.price||'',r.sp.join('; ')].map(q).join(',')));
  const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([lines.join('\r\n')],{type:'text/csv'}));a.download='jawntide-items.csv';document.body.appendChild(a);a.click();a.remove()}

// ---- render
function srcBox(){return `<div class=sbox><h2>Where to look</h2><div class=row>${(D.sources||[]).map(x=>`<label><input type=checkbox data-src="${esc(x.k)}"${S.src.has(x.k)?' checked':''}> ${esc(x.n)} <span class=muted>(${INV.filter(r=>r.src===x.k).length})</span></label>`).join('')}</div>
    <p class="sm muted">In Suit search, your own items (mule, characters, house chests) are preferred when two items are otherwise equal, then guest mules, then the Market. Characters' items are as of their last login or logout; a house chest's as of the last time it was closed.</p></div>
  <div class="row tabs"><button data-tab=suit class="${S.tab!=='items'?'on':''}">Suit search</button><button data-tab=items class="${S.tab==='items'?'on':''}">Item search</button>
    <label class=sm>Show <select id=spshow><option value=c${S.allSpells?'':' selected'}>cantrips only</option><option value=all${S.allSpells?' selected':''}>cantrips and all spells</option></select></label></div>`}
function render(){
  if(S.tab==='items'){app.innerHTML=srcBox()+itemsView();return}
  const ch=D.chars.map(c=>`<option${c.n===S.char?' selected':''}>${esc(c.n)}</option>`).join('');
  const slots=SLOTS.filter(s=>s[0]!=='uabd').map(s=>`<label class=dslot style="grid-area:${s[0]}"><input type=checkbox data-slot="${s[0]}"${S.slots.has(s[0])?' checked':''}> ${s[1]}</label>`).join('');
  const wants=S.want.map((w,i)=>{const F=FAMS[w.f]||{c:0,max:0,n:0};
    const tiers=F.c?[1,2,3,4]:Array.from({length:Math.max(1,F.max)},(_,j)=>j+1);
    const opts=tiers.map(t=>`<option value="${t}"${t===w.t?' selected':''}>${esc(tierName(w.f,t))}${t===4&&F.c||(!F.c&&t===F.max)?'':' or better'}</option>`).join('');
    return `<div class=want><span class=fam>${esc(w.f)}</span><select data-wt="${i}">${opts}</select>
      <select data-wp="${i}"><option value=need${w.p==='need'?' selected':''}>Must have</option><option value=nice${w.p==='nice'?' selected':''}>Nice to have</option></select>
      <span class=cnt>${F.n} item${F.n===1?'':'s'}, best ${esc(tierName(w.f,F.max))}</span><button class=x data-wdel="${i}" title="Remove">✕</button></div>`}).join('')||'<p class=muted>No spells picked yet. Choose a template above or add spells below.</p>';
  const famOpts=FAMLIST.filter(f=>!S.want.find(w=>w.f===f)&&(S.allSpells||FAMS[f].c)).map(f=>`<option value="${esc(f)}">${esc(f)}${FAMS[f].c?'':' (spell)'} — ${FAMS[f].n}</option>`).join('');
  const sets=Object.keys(SETS).sort().map(s=>`<option${s===S.set?' selected':''} value="${esc(s)}">${esc(s)} (${SETS[s]})</option>`).join('');
  const sets2=Object.keys(SETS).sort().map(s=>`<option${s===S.set2?' selected':''} value="${esc(s)}">${esc(s)} (${SETS[s]})</option>`).join('');
  const fi=(k,label,w,ph)=>`<label>${label} <input type=${w||'number'} data-f="${k}" value="${esc(S.F[k])}"${ph?` placeholder="${ph}"`:''}></label>`;
  const rates=D.ratings.filter(r=>RATED[r[0]]).map(r=>`<label><input type=checkbox data-rate="${r[0]}"${S.rate[r[0]]?' checked':''}> ${esc(r[1])}</label>`).join('')||'<span class=muted>None of your items have ratings.</span>';
  const pinned=[...S.locked].map(i=>`<span>🔒 ${esc(ITEMS[i].n)} <button class=x data-unlock="${i}">✕</button></span>`).concat(
    [...S.excluded].map(i=>`<span>🚫 ${esc(ITEMS[i].n)} <button class=x data-unex="${i}">✕</button></span>`)).join('');
  const plans=D.plans.length?'<p class="sm muted">Saved suits: '+D.plans.map(p=>`<b>${esc(p.code)}</b> ${esc(p.name)} (${p.n} items, ${esc(p.at)})`).join(' · ')+'</p>':'';
  app.innerHTML=srcBox()+`
  <div class=sbox><h2>1. Start from a template</h2><div class=row>
    <select id=tpl>${Object.entries(TEMPLATES).map(([k,t])=>`<option value="${k}">${esc(t.n)}</option>`).join('')}</select>
    <button id=tplgo>Use template</button><span class=muted>${ITEMS.filter(it=>it.src==='me').length} wearable items in your mule.</span></div>
    ${S.msg?`<p class=part>${esc(S.msg)}</p>`:''}</div>
  <div class=sbox><h2>2. Slots to fill</h2><p class="sm muted">Only items that fit entirely in the ticked slots are used, so untick slots you already have covered.</p>
    <div class=doll>${slots}</div><div class=row><button id=sall>All</button><button id=snone>None</button>
    <button id=sarmor>Armor only</button><button id=sjew>Jewelry only</button></div></div>
  <div class=sbox><h2>3. Spells you need</h2>${S.want.length>1?`<div class="want setall"><span class=fam>Set all</span>
    <select id=allt><option value="">level…</option><option value=1>Minor or better</option><option value=2>Major or better</option><option value=3>Epic or better</option><option value=4>Legendary</option></select>
    <select id=allp><option value="">priority…</option><option value=need>Must have</option><option value=nice>Nice to have</option></select></div>`:''}${wants}
    <div class=row><select id=addf><option value="">Add a spell…</option>${famOpts}</select></div></div>
  <div class=sbox><h2>4. Extras</h2>
    <div class=row><label>Armor set <select id=set><option value="">(any)</option>${sets}</select></label>
      <label>pieces <input type=number id=setn min=2 max=9 value="${S.setN}"></label>
      <label>second set <select id=set2><option value="">(none)</option>${sets2}</select></label>
      <label>pieces <input type=number id=setn2 min=2 max=9 value="${S.setN2}"></label>
      <label><input type=checkbox id=onlysets${S.onlySets?' checked':''}> body armor only from these sets</label></div>
    <div class=row><label><input type=checkbox id=reduce${S.reduce?' checked':''}> allow tailoring reductions (a multi-slot loot piece can be used in any one slot it can be reduced to)</label></div>
    <div class=row><span>Armor made of:</span>${MATS.map(([k,l])=>`<label><input type=checkbox data-mat="${k}"${S.mats.has(k)?' checked':''}> ${l}</label>`).join('')}
      <span class="sm muted">applies to armor pieces only; "other" includes pieces with no material</span></div>
    <div class=row><label>Covenant armor <select id=cov><option value=out${S.cov==='out'?' selected':''}>leave out</option><option value=ok${S.cov==='ok'?' selected':''}>allow</option><option value=only${S.cov==='only'?' selected':''}>Covenant armor only</option></select></label>
      <span class="sm muted">"Covenant armor only" uses Covenant pieces for every armor slot; underclothes and jewelry are picked as usual.</span></div>
    ${['armor','under'].map(k=>{const o=S.imp[k];return `<div class=row><span>Impenetrability cantrip on each ${k==='armor'?'armor piece':'underclothes piece (shirt, pants)'}:</span>
      <select data-impm="${k}"><option value=off${o.m==='off'?' selected':''}>doesn't matter</option><option value=prefer${o.m==='prefer'?' selected':''}>prefer</option><option value=require${o.m==='require'?' selected':''}>require</option></select>
      <select data-impt="${k}">${[1,2,3,4].map(t=>`<option value=${t}${o.t===t?' selected':''}>${TIERN[t]}${t<4?' or better':''}</option>`).join('')}</select></div>`}).join('')}
    <div class=row><label>Armor level <select id=al><option value=0${S.al==0?' selected':''}>doesn't matter</option><option value=1${S.al==1?' selected':''}>tie-breaker</option><option value=5${S.al==5?' selected':''}>important</option></select></label></div>
    <div class=row><span>Ratings to collect:</span>${rates}</div>
    <div class=row><label>Character <select id=char>${ch}</select></label>
      <label><input type=checkbox id=noreq${S.noreq?' checked':''}> ignore level requirements</label>
      <label><input type=checkbox id=noatt${S.noatt?' checked':''}> skip attuned items</label></div>
    ${pinned?`<div class="row chips">${pinned}</div>`:''}</div>
  <details class=sbox${Object.values(S.F).some(v=>v!=='')?' open':''}><summary><b>5. Item filters</b> <span class="sm muted">(optional: items that fail these are never used)</span></summary>
    <div class=row>${fi('alBody','Min base armor level, body')}${fi('alExt','extremities (head, hands, feet)')}</div>
    <div class=row>${fi('lvMin','Wield level from')}${fi('lvMax','to')}</div>
    <div class=row>${fi('minLeg','At least this many Legendary spells per item')}${fi('minEpic','Epic or better')}</div>
    <div class=row>${fi('minOff','Min offensive rating (damage + crit + crit damage)')}${fi('minDef','defensive (the resists)')}${fi('minTot','total')}</div>
    <div class=row>${fi('re','Name or a spell matches','text','regular expression, e.g. legendary.*legendary')}</div></details>
  <div class=row><button id=obsb>Find items in my mule that another of my items beats</button></div>
  <div id=obsout>${obsolete()}</div>
  <div class=row><button class=go id=go${S.busy?' disabled':''}>${S.busy?'Searching…':'Find suits'}</button><span id=prog class=muted></span></div>
  <div id=results>${results()}</div>${plans}`;
}

function results(){
  if(!S.results)return'';
  if(!S.results.length)return'<p class=no>No suit found. Tick more slots, or make some spells "Nice to have".</p>';
  const view=`<div class=row><label class=sm>Show suits as <select id=view><option value=doll${S.view==='doll'?' selected':''}>paperdoll</option><option value=list${S.view==='list'?' selected':''}>list</option></select></label></div>`;
  return view+S.results.map((r,ri)=>{
    const met=S.want.map(w=>{const got=r.tiers[w.f]||0;const cls=got>=w.t?'ok':got?'part':'no';
      return `<span class=${cls}>${esc(w.f)}${got&&got<w.t?' ('+esc(tierName(w.f,got))+')':''}${got?'':' ✕'}</span>`}).join(' · ');
    const rows=r.picks.map(([i,occ])=>{const it=ITEMS[i];const where=SLOTS.filter((s,b)=>occ&(1<<b)&&s[0]!=='uabd').map(s=>s[1]).join(', ')+(it.pl.includes(occ)?'':' (tailor-reduce to this)');
      const tags=it.sp.filter(showSpell).map(n=>{const p=parse(n);const hit=S.want.find(w=>w.f===p.f)||(p.f===IMP&&impOn(it));return `<span${hit?' class=hit':''}>${esc(n)}</span>`}).join('');
      const icon=`<span class=micon>${it.ic.map(x=>`<img src="/market/icon/${x}.png" alt="" loading=lazy>`).join('')}</span>`;
      const meta=[it.al?'AL '+it.al:'',it.set,it.lv?'level '+it.lv:'',it.lore?'lore '+it.lore:'',...Object.entries(it.rt).map(([k,v])=>(D.ratings.find(x=>x[0]===k)||[k,k])[1]+' '+v)].filter(Boolean).join(' · ');
      const from=it.src==='m'?`<div class=sm><span class=part>Market:</span> <a href="/market/item/${it.g}" target=_blank>${esc(it.price)}</a> <span class=muted>from ${esc(it.seller)}</span></div>`
        :it.loc?`<div class="sm part">${esc(it.loc)}</div>`:it.src!=='me'?`<div class="sm part">${esc(SRCNAME[it.src]||'guest mule')}</div>`:'';
      return `<tr><td>${esc(where)}</td><td>${icon} <b>${esc(it.n)}</b>${from}<div class="sm muted">${esc(meta)}</div><div class=tags>${tags}</div></td>
        <td class=sm><button class=x data-lock="${i}" title="Always use this item">🔒</button> <button class=x data-ex="${i}" title="Never use this item">🚫</button></td></tr>`}).join('');
    const empty=SLOTS.filter((s,b)=>S.slots.has(s[0])&&!(r.occ&(1<<b))).map(s=>s[1]);
    const doll=S.view==='doll'?`<div class=doll>${SLOTS.map((s,b)=>{if(s[0]==='uabd')return'';const k=s[0];
      const pk=r.picks.find(([i,occ])=>occ&(1<<b));
      if(!pk)return `<div class="dslot ${S.slots.has(k)?'empty':'off'}" style="grid-area:${k}"><span class=sl>${esc(s[1])}</span><span>${S.slots.has(k)?'empty':'not searched'}</span></div>`;
      const [i,occ]=pk,it=ITEMS[i];const first=SLOTS.findIndex((x,bb)=>x[0]!=='uabd'&&occ&(1<<bb));
      if(first!==b)return `<div class="dslot filled cont" style="grid-area:${k}"><span class=sl>${esc(s[1])}</span><span class=muted>↳ ${esc(it.n)} (${esc(SLOTS[first][1])})</span></div>`;
      const tags=it.sp.filter(showSpell).map(n=>{const p=parse(n);const hit=S.want.find(w=>w.f===p.f)||(p.f===IMP&&impOn(it));return `<span${hit?' class=hit':''}>${esc(n)}</span>`}).join('');
      const meta=[it.al?'AL '+it.al:'',it.set,it.lv?'level '+it.lv:''].filter(Boolean).join(' · ');
      const from=it.src==='m'?`<div class=part>Market: <a href="/market/item/${it.g}" target=_blank>${esc(it.price)}</a></div>`:it.loc?`<div class=part>${esc(it.loc)}</div>`:it.src!=='me'?`<div class=part>${esc(SRCNAME[it.src]||'guest mule')}</div>`:'';
      return `<div class="dslot filled" style="grid-area:${k}"><span class=sl>${esc(s[1])}${it.pl.includes(occ)?'':' · tailor-reduce'}</span>
        <span class=micon>${it.ic.map(x=>`<img src="/market/icon/${x}.png" alt="" loading=lazy>`).join('')}</span> <b>${esc(it.n)}</b>
        <button class=x data-lock="${i}" title="Always use this item">🔒</button><button class=x data-ex="${i}" title="Never use this item">🚫</button>
        ${from}${meta?`<div class=muted>${esc(meta)}</div>`:''}<div class=tags>${tags}</div></div>`}).join('')}</div>`:`<table><tbody>${rows}</tbody></table>`;
    const rt=Object.entries(r.rt).map(([k,v])=>(D.ratings.find(x=>x[0]===k)||[k,k])[1]+' '+v).join(', ');
    const pcs=r.picks.map(([i])=>ITEMS[i]).filter(it=>pieceKind(it));
    const imp=pcs.length&&(S.imp.armor.m!=='off'||S.imp.under.m!=='off')?` · Impenetrability on ${pcs.filter(it=>(it.fams[IMP]||0)>=S.imp[pieceKind(it)].t).length} of ${pcs.length} pieces`:'';
    const cnt=[4,3,2].map(t=>[t,S.want.filter(w=>FAMS[w.f]&&FAMS[w.f].c&&(r.tiers[w.f]||0)===t).length]).filter(x=>x[1]).map(([t,n])=>n+' '+TIERN[t]).join(', ');
    return `<div class=res><div class=row><b>Suit ${ri+1}</b><span class=muted>armor level ${r.al}${r.set?' · '+esc(S.set)+' '+r.set+' pieces':''}${r.set2?' · '+esc(S.set2)+' '+r.set2+' pieces':''}${rt?' · '+esc(rt):''}${imp}${cnt?' · '+cnt:''}</span></div>
      <p>${met||'<span class=muted>no spells picked</span>'}</p>${empty.length?`<p class="sm muted">Left empty: ${esc(empty.join(', '))}</p>`:''}
      ${doll}
      <div class=row><input type=text id=sn${ri} value="Suit ${ri+1}" maxlength=64 aria-label="Suit name"><button data-save="${ri}">Save for /mule suit</button><button data-copy="${ri}">Copy as text</button><span id=sv${ri}></span></div></div>`}).join('');
}

// ---- item filters (Mag-SuitBuilder's filters)
const num=v=>v===''||v==null?null:+v;
const OFF=['GearDamage','GearCrit','GearCritDamage'],DEFR=['GearDamageResist','GearCritResist','GearCritDamageResist'];
function passesFilters(it){const F=S.F,k=pieceKind(it);
  if(k==='armor'){const ext=(it.vl&EXTVL)&&!(it.vl&0x7E00);const min=num(ext?F.alExt:F.alBody);if(min!=null&&it.al<min)return false}
  if(num(F.lvMin)!=null&&it.lv<num(F.lvMin))return false;
  if(num(F.lvMax)!=null&&it.lv>num(F.lvMax))return false;
  const tiers=Object.entries(it.fams).filter(([f])=>FAMS[f]&&FAMS[f].c).map(([,t])=>t);
  if(num(F.minLeg)!=null&&tiers.filter(t=>t>=4).length<num(F.minLeg))return false;
  if(num(F.minEpic)!=null&&tiers.filter(t=>t>=3).length<num(F.minEpic))return false;
  const sum=ks=>ks.reduce((a,x)=>a+Math.max(0,it.rt[x]||0),0);
  if(num(F.minOff)!=null&&sum(OFF)<num(F.minOff))return false;
  if(num(F.minDef)!=null&&sum(DEFR)<num(F.minDef))return false;
  if(num(F.minTot)!=null&&Object.values(it.rt).reduce((a,x)=>a+Math.max(0,x),0)<num(F.minTot))return false;
  if(F.re){let rx;try{rx=new RegExp(F.re,'i')}catch(e){return true}if(!rx.test(it.n)&&!rx.test(it.sp.join(', ')))return false}
  return true}

// ---- items another of your items beats (Mag-SuitBuilder's upgrades view, turned around): same equip slots, every spell
// at the same level or better, armor level and ratings at least as high, same armor set (or none), no higher level requirement
function beats(b,a){if(b===a||b.vl!==a.vl)return false;
  for(const f in a.fams)if((b.fams[f]||0)<a.fams[f])return false;
  if(b.al<a.al||b.lv>a.lv)return false;if(a.set&&b.set!==a.set)return false;
  for(const k in a.rt)if((b.rt[k]||0)<a.rt[k])return false;
  return true}
function findObsolete(){const mine=ITEMS.filter(it=>it.src==='me'&&pieceKind(it)||it.src==='me'&&(it.vl&JEW));const out=[];
  for(const a of mine){const b=mine.find(b=>beats(b,a)&&(!beats(a,b)||b.i<a.i));if(b)out.push([a.i,b.i])}
  return out}
function obsolete(){if(!S.obs)return'';if(!S.obs.length)return'<p class=muted>Nothing in your mule is beaten by another of your items.</p>';
  return `<div class=res><p><b>${S.obs.length}</b> item${S.obs.length===1?' is':'s are'} beaten by another item in your mule (same slots, every spell at least as good, armor level and ratings at least as high).</p>
    <table><tbody>${S.obs.map(([a,b])=>`<tr><td>${esc(ITEMS[a].n)}</td><td class="sm muted">beaten by ${esc(ITEMS[b].n)}</td></tr>`).join('')}</tbody></table>
    <div class=row><button id=obssave>Save this list for /mule suit and /mule purge</button><span id=obssv></span></div></div>`}

// ---- search (in a worker so the page stays responsive)
function buildProblem(){
  const allowed=SLOTS.reduce((m,s,b)=>S.slots.has(s[0])?m|(1<<b):m,0)|((S.slots.has('shirt')||S.slots.has('pants'))?BIT.uabd:0);
  const lvl=(D.chars.find(c=>c.n===S.char)||{lv:999}).lv;
  const fams=S.want.map(w=>w.f);
  const rkeys=Object.keys(S.rate).filter(k=>S.rate[k]);
  const cands=[];const locked=[];
  for(const it of ITEMS){
    if(S.excluded.has(it.i))continue;
    if(!S.src.has(it.src)&&!S.locked.has(it.i))continue;
    const isLocked=S.locked.has(it.i);
    if(!isLocked){if(S.noatt&&it.att)continue;if(!S.noreq&&it.lv>lvl)continue}
    // Impenetrability is per piece (it raises that piece's armor level), so it's a rule on each armor/underclothes piece
    const ik=pieceKind(it),io=ik?S.imp[ik]:null,itier=it.fams[IMP]||0;
    if(!isLocked&&io&&io.m==='require'&&itier<io.t)continue;
    if(!isLocked&&!passesFilters(it))continue;
    if(!isLocked&&S.cov!=='ok'&&pieceKind(it)==='armor'&&isCov(it)!==(S.cov==='only'))continue;
    if(!isLocked&&pieceKind(it)==='armor'&&!S.mats.has(matGroup(it)))continue;
    if(!isLocked&&S.onlySets&&(S.set||S.set2)&&(it.vl&0x7E00)&&it.set!==S.set&&it.set!==S.set2)continue;
    const tv=fams.map(f=>it.fams[f]||0);
    const bonus=(it.src==='m'?-0.6:it.src==='me'||it.src==='c'||it.src==='h'?0:-0.3)+S.al*it.al/1000+rkeys.reduce((a,k)=>a+(it.rt[k]||0),0)+(io&&io.m==='prefer'&&itier>=io.t?2:0);
    const spots=S.reduce||isLocked?it.pl.concat(it.red):it.pl;
    for(const occ of spots){
      if(!isLocked&&(occ&~allowed))continue;
      if(isLocked&&(occ&~allowed)&&spots.some(o=>!(o&~allowed)))continue;   // a locked piece goes where the ticked slots allow, when it can
      const c={i:it.i,occ,tv,set:S.set&&it.set===S.set?1:0,set2:S.set2&&it.set===S.set2?1:0,bonus};
      (isLocked?locked:cands).push(c);
    }
  }
  return{nb:NB,cands,locked,want:S.want.map(w=>({t:w.t,w:w.p==='need'?10:3})),setN:S.set?S.setN:0,setN2:S.set2?S.setN2:0,top:5,ms:8000,rkeys};
}

const WORKER=`
onmessage=ev=>{const P=ev.data;const NB=P.nb,W=P.want,NF=W.length;
const low=o=>{for(let b=0;b<NB;b++)if(o&(1<<b))return b;return NB};
function famVal(f,t){const w=W[f];if(t>=w.t)return w.w;return t?w.w*0.5*t/w.t:0}
// keep only items that aren't beaten in every way by another item in the same spot
const groups={};for(const c of P.cands)(groups[c.occ]=groups[c.occ]||[]).push(c);
const heur=c=>c.tv.reduce((a,t,f)=>a+famVal(f,t),0)+(c.set+c.set2)*5+c.bonus;
const kept=[];
for(const k in groups){const g=groups[k].sort((a,b)=>heur(b)-heur(a));const keep=[];
  for(const c of g){if(keep.some(o=>o.set>=c.set&&o.set2>=c.set2&&o.bonus>=c.bonus&&o.tv.every((t,f)=>t>=c.tv[f])))continue;keep.push(c);if(keep.length>=14)break}
  kept.push(...keep)}
const byLow=Array.from({length:NB+1},()=>[]);for(const c of kept)byLow[low(c.occ)].push(c);
for(const l of byLow)l.sort((a,b)=>heur(b)-heur(a));
// optimistic tables from each position onward
const remT=Array.from({length:NB+1},()=>new Array(NF).fill(0)),remSet=new Array(NB+1).fill(0),remSet2=new Array(NB+1).fill(0),remBonus=new Array(NB+1).fill(0);
for(let p=NB-1;p>=0;p--){for(let f=0;f<NF;f++)remT[p][f]=remT[p+1][f];remSet[p]=remSet[p+1];remSet2[p]=remSet2[p+1];remBonus[p]=remBonus[p+1];
  let mb=0,hs=0,hs2=0;for(const c of byLow[p]){for(let f=0;f<NF;f++)if(c.tv[f]>remT[p][f])remT[p][f]=c.tv[f];if(c.bonus>mb)mb=c.bonus;if(c.set)hs=1;if(c.set2)hs2=1}
  remSet[p]+=hs;remSet2[p]+=hs2;remBonus[p]+=mb}
const sv=(n,N)=>N?Math.min(n,N)*4+(n>=N?6:0):0;
const setVal=(n,n2)=>sv(n,P.setN)+sv(n2,P.setN2);
const tiers=new Array(NF).fill(0);let setCount=0,setCount2=0,bonus=0,occ=0;const used=new Set(),picks=[];
for(const c of P.locked){if(c.occ&occ||used.has(c.i))continue;occ|=c.occ;used.add(c.i);picks.push(c);c.tv.forEach((t,f)=>{if(t>tiers[f])tiers[f]=t});setCount+=c.set;setCount2+=c.set2;bonus+=c.bonus}
const best=[];let worst=-1,nodes=0,stop=false;const t0=Date.now();
function score(p){let s=0;for(let f=0;f<NF;f++)s+=famVal(f,Math.max(tiers[f],p<NB?remT[p][f]:0));
  return s+setVal(setCount+(p<NB?remSet[p]:0),setCount2+(p<NB?remSet2[p]:0))+bonus+(p<NB?remBonus[p]:0)}
function record(){const s=score(NB);if(best.length>=P.top&&s<=worst)return;
  const key=picks.map(c=>c.i).sort((a,b)=>a-b).join(',');if(best.some(b=>b.key===key))return;
  best.push({s,key,picks:picks.map(c=>[c.i,c.occ]),occ,tiers:tiers.slice(),set:setCount,set2:setCount2,bonus});best.sort((a,b)=>b.s-a.s);if(best.length>P.top)best.pop();
  worst=best.length>=P.top?best[best.length-1].s:-1}
function dfs(p){if(stop)return;if(++nodes%20000===0){if(Date.now()-t0>P.ms){stop=true;return}postMessage({prog:nodes})}
  while(p<NB&&(occ&(1<<p)))p++;
  if(best.length>=P.top&&score(p)<=worst+1e-9)return;
  if(p>=NB){record();return}
  for(const c of byLow[p]){if(c.occ&occ||used.has(c.i))continue;
    const saved=tiers.slice();occ|=c.occ;used.add(c.i);picks.push(c);for(let f=0;f<NF;f++)if(c.tv[f]>tiers[f])tiers[f]=c.tv[f];setCount+=c.set;setCount2+=c.set2;bonus+=c.bonus;
    dfs(p+1);
    for(let f=0;f<NF;f++)tiers[f]=saved[f];occ&=~c.occ;used.delete(c.i);picks.pop();setCount-=c.set;setCount2-=c.set2;bonus-=c.bonus;if(stop)return}
  const bit=1<<p;occ|=bit;dfs(p+1);occ&=~bit}
dfs(0);
postMessage({done:best,nodes,stopped:stop,kept:kept.length});};`;

let worker=null;
function search(){
  const P=buildProblem();
  if(!P.cands.length&&!P.locked.length){S.results=[];render();return}
  S.busy=true;S.results=null;render();
  if(worker)worker.terminate();
  worker=new Worker(URL.createObjectURL(new Blob([WORKER],{type:'text/javascript'})));
  worker.onerror=ev=>{S.busy=false;S.results=null;render();const pr=document.getElementById('prog');if(pr)pr.innerHTML='<span class=no>The search failed: '+esc(ev.message||'error')+'</span>'};
  worker.onmessage=ev=>{const m=ev.data;const pr=document.getElementById('prog');
    if(m.prog){if(pr)pr.textContent=`checked ${m.prog.toLocaleString()} combinations…`;return}
    S.busy=false;worker.terminate();worker=null;
    S.results=m.done.map(b=>{const t={};S.want.forEach((w,f)=>{if(b.tiers[f])t[w.f]=b.tiers[f]});
      const rt={};let al=0;for(const[i]of b.picks){const it=ITEMS[i];al+=it.al;for(const k in it.rt)if(S.rate[k])rt[k]=(rt[k]||0)+it.rt[k]}
      return{picks:b.picks.sort((x,y)=>low(x[1])-low(y[1])),occ:b.occ,tiers:t,set:b.set,set2:b.set2,al,rt}});
    render();const pr2=document.getElementById('prog');
    if(pr2)pr2.textContent=`${m.nodes.toLocaleString()} combinations of ${m.kept} useful items${m.stopped?' (stopped after 8 seconds: the best found so far)':''}.`};
  worker.postMessage(P);
}
const low=o=>{for(let b=0;b<NB;b++)if(o&(1<<b))return b;return NB};

function copySuit(ri){const r=S.results[ri];const out=document.getElementById('sv'+ri);
  const lines=r.picks.map(([i,occ])=>{const it=ITEMS[i];return `${slotNames(occ).filter(n=>n!=='uabd').map(n=>SLOTS.find(s=>s[0]===n)[1]).join(', ')}: ${it.n}${it.al?' (AL '+it.al+')':''} - ${it.sp.join(', ')}`});
  const text=`Suit ${ri+1}, armor level ${r.al}\n`+lines.join('\n');
  (navigator.clipboard?navigator.clipboard.writeText(text):Promise.reject()).then(()=>{out.textContent='Copied.'},()=>{out.innerHTML='<textarea rows=6 cols=60>'+esc(text)+'</textarea>'})}
async function saveObsolete(){const out=document.getElementById('obssv');
  const body=new URLSearchParams({csrf:D.csrf,name:'Beaten items',items:[...new Set(S.obs.map(([a])=>ITEMS[a].g))].join(',')});
  out.textContent='Saving…';
  try{const res=await fetch('/suit/save',{method:'POST',body,headers:{'Content-Type':'application/x-www-form-urlencoded'}});const j=await res.json();
    if(!res.ok)throw new Error(j.error||'Could not save');
    out.innerHTML=`Saved. In game, open your mule: <code class=cmd>/mule suit ${esc(j.code)}</code> shows them, <code class=cmd>/mule purge suit:${esc(j.code)}</code> removes them (with the usual warning and 7-day undo).`}
  catch(err){out.innerHTML=`<span class=no>${esc(err.message)}</span>`}}
async function saveSuit(ri){const r=S.results[ri];const out=document.getElementById('sv'+ri);
  const name=(document.getElementById('sn'+ri).value||'').trim()||'Suit';
  const mules=r.picks.map(([i])=>ITEMS[i]).filter(it=>it.src==='me'||it.src.startsWith('g:'));const buy=r.picks.filter(([i])=>ITEMS[i].src==='m').length;
  const carried=r.picks.length-mules.length-buy;
  if(!mules.length){out.innerHTML='<span class=no>None of this suit is in a mule: '+(buy?'buy the Market items first (links above)':'')+(buy&&carried?' and ':'')+(carried?'the rest is already on your characters or in your house chests':'')+'.</span>';return}
  const body=new URLSearchParams({csrf:D.csrf,name,items:[...new Set(mules.map(it=>it.g))].join(',')});
  out.textContent='Saving…';
  try{const res=await fetch('/suit/save',{method:'POST',body,headers:{'Content-Type':'application/x-www-form-urlencoded'}});const j=await res.json();
    if(!res.ok)throw new Error(j.error||'Could not save');
    D.plans.unshift({code:j.code,name:j.name,n:r.picks.length,at:'today'});
    out.innerHTML=`Saved. In game, open the mule and type <code class=cmd>/mule suit ${esc(j.code)}</code>`+
      (mules.some(it=>it.src!=='me')?' (it works on a mule you\'re a guest of too: open that mule and type the same).':'')+
      (buy?` <span class=part>${buy} Market item${buy===1?' isn\'t':'s aren\'t'} in the saved suit: buy ${buy===1?'it':'them'} first.</span>`:'')+
      (carried?` <span class=part>${carried} item${carried===1?' is':'s are'} on your characters or in your house chests, so ${carried===1?'it isn\'t':'they aren\'t'} in the saved suit (see where above).</span>`:'')}
  catch(err){out.innerHTML=`<span class=no>${esc(err.message)}</span>`}}

// ---- events
app.addEventListener('click',ev=>{const th=ev.target.closest('th[data-sort]');
  if(th){const k=th.dataset.sort;if(IS.sort===k)IS.dir=-IS.dir;else{IS.sort=k;IS.dir=['n','cat','sl','set','imb','where'].includes(k)?1:-1}render();return}
  const t=ev.target.closest('button');if(!t)return;const d=t.dataset;
  if(d.tab){S.tab=d.tab;render();return}
  if(t.id==='ifclear'){Object.assign(IS,{q:'',cats:new Set(CATS.map(c=>c[0])),slot:'',set:'',imb:'',cov:'',mat:'',alMin:'',alMax:'',lvMin:'',lvMax:'',minLeg:'',minEpic:'',minOff:'',minDef:'',minTot:'',wkMax:''});render();return}
  if(t.id==='ifcsv'){invCsv();return}
  if(t.id==='tplgo'){applyTemplate(document.getElementById('tpl').value);render();return}
  if(t.id==='sall'){S.slots=new Set(SLOTS.map(s=>s[0]).filter(s=>s!=='uabd'))}
  else if(t.id==='snone'){S.slots=new Set()}
  else if(t.id==='sarmor'){S.slots=new Set(['head','chest','abdomen','uarms','larms','hands','ulegs','llegs','feet','shirt','pants'])}
  else if(t.id==='sjew'){S.slots=new Set(['neck','lwrist','rwrist','lring','rring','trinket','cloak'])}
  else if(t.id==='go'){search();return}
  else if(d.wdel!=null){S.want.splice(+d.wdel,1)}
  else if(d.lock!=null){S.locked.add(+d.lock);S.excluded.delete(+d.lock)}
  else if(d.ex!=null){S.excluded.add(+d.ex);S.locked.delete(+d.ex)}
  else if(d.unlock!=null){S.locked.delete(+d.unlock)}
  else if(d.unex!=null){S.excluded.delete(+d.unex)}
  else if(d.save!=null){saveSuit(+d.save);return}
  else if(d.copy!=null){copySuit(+d.copy);return}
  else if(t.id==='obsb'){S.obs=findObsolete();render();return}
  else if(t.id==='obssave'){saveObsolete();return}
  else return;
  render()});
app.addEventListener('change',ev=>{const t=ev.target;const d=t.dataset;
  if(t.id==='view'){S.view=t.value==='list'?'list':'doll';try{localStorage.setItem('suitView',S.view)}catch(e){}render();return}
  if(t.id==='spshow'){S.allSpells=t.value==='all';try{localStorage.setItem('suitAllSpells',S.allSpells?'1':'0')}catch(e){}render();return}
  if(d.icat){t.checked?IS.cats.add(d.icat):IS.cats.delete(d.icat);render();return}
  if(d.if!=null&&t.tagName==='SELECT'){IS[d.if]=t.value;render();return}
  if(d.slot){t.checked?S.slots.add(d.slot):S.slots.delete(d.slot);return}
  if(d.rate){S.rate[d.rate]=t.checked;return}
  if(d.wt!=null){S.want[+d.wt].t=+t.value;return}
  if(d.wp!=null){S.want[+d.wp].p=t.value;return}
  if(t.id==='allt'&&t.value){const v=+t.value;
    // cantrips take the level as is; other spells (roman numeral levels) keep theirs
    S.want.forEach(w=>{if(FAMS[w.f]&&FAMS[w.f].c)w.t=v});render();return}
  if(t.id==='allp'&&t.value){S.want.forEach(w=>w.p=t.value);render();return}
  if(t.id==='addf'&&t.value){const f=t.value;S.want.push({f,t:FAMS[f].c?4:FAMS[f].max,p:'need'});render();return}
  if(t.id==='set'){S.set=t.value;return}
  if(t.id==='setn'){S.setN=Math.max(2,Math.min(9,+t.value||5));return}
  if(t.id==='set2'){S.set2=t.value;return}
  if(t.id==='setn2'){S.setN2=Math.max(2,Math.min(9,+t.value||4));return}
  if(t.id==='onlysets'){S.onlySets=t.checked;return}
  if(t.id==='reduce'){S.reduce=t.checked;return}
  if(t.id==='cov'){S.cov=t.value;return}
  if(d.mat){t.checked?S.mats.add(d.mat):S.mats.delete(d.mat);return}
  if(d.f){S.F[d.f]=t.value.trim();return}
  if(t.id==='al'){S.al=+t.value;return}
  if(d.impm){S.imp[d.impm].m=t.value;return}
  if(d.impt){S.imp[d.impt].t=+t.value;return}
  if(t.id==='char'){S.char=t.value;return}
  if(t.id==='noreq'){S.noreq=t.checked;return}
  if(t.id==='noatt'){S.noatt=t.checked;return}
  if(d.src){t.checked?S.src.add(d.src):S.src.delete(d.src);if(S.tab==='items')render();return}});
let itimer=null;
app.addEventListener('input',ev=>{const t=ev.target;if(t.dataset.if==null||t.tagName==='SELECT')return;IS[t.dataset.if]=t.value.trim();
  clearTimeout(itimer);itimer=setTimeout(()=>{const k=t.dataset.if,pos=t.selectionStart;render();const el=app.querySelector(`[data-if="${k}"]`);if(el){el.focus();try{el.setSelectionRange(pos,pos)}catch(e){}}},250)});
render();
})();
"""
