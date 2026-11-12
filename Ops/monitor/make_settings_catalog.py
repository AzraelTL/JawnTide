"""
Builds settings_catalog.json for the monitor's Settings page from the server's list of settings
(Source/ACE.Server/Managers/PropertyManager.cs): name, type, default, description and an area for grouping.

Run it from the repo root after adding or changing a setting in PropertyManager.cs, then commit the JSON:
    python Ops/monitor/make_settings_catalog.py
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SOURCE = os.path.join(HERE, "..", "..", "Source", "ACE.Server", "Managers", "PropertyManager.cs")
OUT = os.path.join(HERE, "settings_catalog.json")

# One setting: ("key", new Property<type>(default, "description")), where the description may be several "..." + "..." parts
# split over lines.
ENTRY = re.compile(r'\("([a-z0-9_]+)",\s*new Property<(bool|long|double|string)>\(((?:"(?:[^"\\]|\\.)*"|[^,"])*?),\s*((?:"(?:[^"\\]|\\.)*"\s*\+?\s*)+)\)\)', re.S)
PART = re.compile(r'"((?:[^"\\]|\\.)*)"')

# first match wins; order matters
AREAS = [
    ("World bosses & events", r"world_boss|event_boss|world_bosses"),
    ("Arena", r"arena"),
    ("Town Control", r"town_control|dungeon"),
    ("Bounties", r"^bounty_|^pk_bounty_timer$|^writ_of_pursuit"),
    ("PvP damage tuning", r"^pvp_(dmg_mod|ratings_mod|void_hybrid|cs_critrate|damage_cap|cloak_max)|^ignore_magic_"),
    ("PvP & player killers", r"(^|_)pk|pvp|respite|cleave|zerg"),
    ("XP, levels & luminance", r"xp|level|rolling|luminance|lum_|aug"),
    ("Loot & salvage", r"loot|rare|salvage|tier|mutat|treasure|equipmentset|rating|burning_coals"),
    ("Bank, audit & economy", r"^transfer_audit|^economy_stats|^bank_|^market_|^mule_"),
    ("Housing", r"house|housing|slumlord|mansion"),
    ("Allegiance & fellowship", r"alleg|fellow|monarch|patron"),
    ("Vendors & economy", r"vendor|pyreal|trade|coin|currency|price|value|stipend"),
    ("Chat, Discord & messages", r"chat|webhook|discord|motd|popup|broadcast|global|message|welcome"),
    ("Accounts, logins & security", r"vpn|ip_|account|login|proxycheck|session|ban|whitelist|logoff|logout"),
    ("Combat & magic", r"spell|magic|comp|damage|dmg|combat|melee|missile|attack|defense|armor|resist|heal|vitae|death|corpse|cloak|dispel|stuck_state"),
]
OTHER = "Server & everything else"


def area(key):
    for name, rx in AREAS:
        if re.search(rx, key):
            return name
    return OTHER


def build(text):
    """The catalog ({"areas": [...], "settings": [...]}) for the text of PropertyManager.cs."""
    rows = []
    seen = set()
    for m in ENTRY.finditer(text):
            key, typ, default, desc_parts = m.groups()
            if key in seen:
                continue
            seen.add(key)
            desc = "".join(PART.findall(desc_parts))
            default = default.strip()
            if typ == "string":
                default = default.strip('"')
            default = re.sub(r"(?<=\d)[fFdDmM]$", "", default)
            rows.append({"key": key, "type": typ, "default": default,
                         "jawntide": "JawnTide" in desc,
                         "desc": desc.replace('\\"', '"').replace("JawnTide live events: ", "").replace("JawnTide: ", ""),
                         "area": area(key)})
    order = [a for a, _ in AREAS] + [OTHER]
    rows.sort(key=lambda r: (order.index(r["area"]), r["key"]))
    return {"areas": order, "settings": rows}


def main():
    with open(SOURCE, encoding="utf-8") as f:
        catalog = build(f.read())
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(catalog, f, indent=1)
    print(f"{len(catalog['settings'])} settings written to {OUT}")


if __name__ == "__main__":
    main()
