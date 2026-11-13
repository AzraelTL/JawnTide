#!/usr/bin/env python3
"""
JawnTide: looks for duplicated stackable items by comparing two nightly backups, server-wide. Read-only; reads each
mariadb-dump .sql.gz as text in one pass (same approach as item_scan.py), so the game server can keep running.

For every account it adds up each stackable item (anything with a stack size: gems, morph gems, keys, salvage, trade
goods, spell components, ...) held in the account's My Mule, carried by its characters (main pack and side packs) and
in the house storage chests its characters own. Then it lists the accounts whose amount of an item grew the most between
the two backups, biggest first. A big jump with no explanation (a market buy, a quest, a vendor) is worth a closer look.

Usage (backups are root-only):
  sudo python3 mule_diff.py OLDER.sql.gz NEWER.sql.gz
  sudo python3 mule_diff.py /var/backups/jawntide/jawntide-2026-11-10*.sql.gz /var/backups/jawntide/jawntide-2026-11-13*.sql.gz --min 50 --top 80
Options:
  --min N      only list increases of at least N units (default 100)
  --ratio R    ... that are also at least R times what the account had before (default 1.0, i.e. it at least doubled)
  --top N      how many lines to print (default 60)
  --skip WCIDS comma-separated weenie ids to leave out (default 273 pyreals)
  --skip-accounts NAMES  comma-separated account names to leave out too. Staff accounts (accessLevel > 0) are always
               left out, including from the whole-server totals.
"""
import argparse
import gzip
import re

USE_RE = re.compile(r"^USE `([^`]+)`;")
INSERT_RE = re.compile(r"^INSERT INTO `([^`]+)` VALUES\s?")
NUM3 = re.compile(r"\((\d+),(\d+),(-?\d+)\)")          # (object_Id,type,value)
BIOTA = re.compile(r"\((\d+),(\d+),")                  # (id,weenie_Class_Id,...
STR3 = re.compile(r"\((\d+),(\d+),'((?:[^'\\]|\\.)*)'\)")  # (object_Id,type,'value')
ACCOUNT = re.compile(r"\((\d+),'((?:[^'\\]|\\.)*)',(?:'(?:[^'\\]|\\.)*'|NULL),(?:'(?:[^'\\]|\\.)*'|NULL),(\d+)")
# (accountId,'accountName','passwordHash','passwordSalt',accessLevel,...
CHAR = re.compile(r"\((\d+),(\d+),'((?:[^'\\]|\\.)*)'")  # (id,account_Id,'name',...
MULE = re.compile(r"\((\d+),(\d+),(-?\d+)\)")          # (account_Id,container_Id,visual_Variant)


def scan(path):
    db = None
    wcid_of = {}        # biota id -> weenie class id
    stack = {}          # object -> stack size (PropertyInt.StackSize = 12)
    container = {}      # object -> container (PropertyInstanceId.Container = 2)
    next_mule = {}      # mule container -> next container (PropertyInstanceId.MuleNextContainerId = 20003)
    house_owner = {}    # storage chest -> owning character (PropertyInstanceId.HouseOwner = 32)
    names = {}          # weenie class id -> an item name
    accounts, chars, mules, staff = {}, {}, {}, set()

    def handle(table, body):
        if db == "ace_auth" and table == "account":
            for a in ACCOUNT.finditer(body):
                accounts[int(a.group(1))] = a.group(2)
                if int(a.group(3)) > 0:
                    staff.add(int(a.group(1)))
        elif db != "ace_shard":
            return
        elif table == "biota":
            for b in BIOTA.finditer(body):
                wcid_of[int(b.group(1))] = int(b.group(2))
        elif table == "biota_properties_int":
            for p in NUM3.finditer(body):
                if p.group(2) == "12":
                    stack[int(p.group(1))] = int(p.group(3))
        elif table == "biota_properties_i_i_d":
            for p in NUM3.finditer(body):
                t = p.group(2)
                if t == "2":
                    container[int(p.group(1))] = int(p.group(3))
                elif t == "20003":
                    next_mule[int(p.group(1))] = int(p.group(3))
                elif t == "32":
                    house_owner[int(p.group(1))] = int(p.group(3))
        elif table == "biota_properties_string":
            for p in STR3.finditer(body):
                if p.group(2) == "1":
                    w = wcid_of.get(int(p.group(1)))
                    if w is not None and w not in names:
                        names[w] = p.group(3)
        elif table == "character":
            for c in CHAR.finditer(body):
                chars[int(c.group(1))] = (int(c.group(2)), c.group(3))
        elif table == "account_mule":
            for c in MULE.finditer(body):
                mules[int(c.group(1))] = int(c.group(2))

    table = None
    with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
        for line in f:
            if table is None:
                if line.startswith("USE "):
                    m = USE_RE.match(line)
                    if m:
                        db = m.group(1)
                    continue
                if not line.startswith("INSERT INTO"):
                    continue
                m = INSERT_RE.match(line)
                if not m:
                    m2 = re.match(r"^INSERT INTO `([^`]+)`", line)
                    if not m2:
                        continue
                    table = m2.group(1)
                    body = line[m2.end():]
                else:
                    table = m.group(1)
                    body = line[m.end():]
            else:
                body = line
            handle(table, body)
            if body.rstrip().endswith(";"):
                table = None

    # where a container belongs: a mule container, a character, a side pack on a character, or a house chest
    owner = {}
    for aid, head in mules.items():
        c, seen = head, set()
        while c and c not in seen:
            seen.add(c)
            owner[c] = aid
            c = next_mule.get(c)
    for cid, (aid, _) in chars.items():
        owner[cid] = aid
    for chest, cid in house_owner.items():
        if cid in chars:
            owner[chest] = chars[cid][0]

    totals = {}
    for oid, n in stack.items():
        w = wcid_of.get(oid)
        if w is None:
            continue
        c = container.get(oid)
        aid = owner.get(c)
        if aid is None and c is not None:
            aid = owner.get(container.get(c))   # inside a side pack
        if aid is None:
            continue
        key = (aid, w)
        totals[key] = totals.get(key, 0) + n
    return totals, names, accounts, staff


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("older")
    ap.add_argument("newer")
    ap.add_argument("--min", type=int, default=100)
    ap.add_argument("--ratio", type=float, default=1.0)
    ap.add_argument("--top", type=int, default=60)
    ap.add_argument("--skip", default="273")
    ap.add_argument("--skip-accounts", default="")
    a = ap.parse_args()
    skip = {int(x) for x in a.skip.split(",") if x.strip()}

    print(f"reading {a.older} ...", flush=True)
    old, names_old, acc_old, staff_old = scan(a.older)
    print(f"reading {a.newer} ...", flush=True)
    new, names, accounts, staff = scan(a.newer)
    names = {**names_old, **names}
    accounts = {**acc_old, **accounts}
    extra = {x.strip().lower() for x in a.skip_accounts.split(",") if x.strip()}
    staff |= staff_old | {aid for aid, n in accounts.items() if n.lower() in extra}
    if not accounts:
        print("warning: no accounts read from ace_auth, so staff accounts can't be left out")
    else:
        print(f"leaving out {len(staff)} staff account(s): {', '.join(sorted(accounts.get(i, str(i)) for i in staff)) or 'none'}")
    old = {k: v for k, v in old.items() if k[0] not in staff}
    new = {k: v for k, v in new.items() if k[0] not in staff}

    rows = []
    for (aid, w), n in new.items():
        if w in skip:
            continue
        before = old.get((aid, w), 0)
        gain = n - before
        if gain >= a.min and gain >= a.ratio * before:
            rows.append((gain, aid, w, before, n))
    rows.sort(reverse=True)

    print(f"\nAccounts whose stackable items grew by at least {a.min} and at least {a.ratio:g}x what they had (mule + characters + house chests):")
    print(f"{'account':<20} {'item':<40} {'wcid':>8} {'before':>10} {'after':>10} {'gain':>10}")
    for gain, aid, w, before, n in rows[:a.top]:
        print(f"{accounts.get(aid, str(aid))[:20]:<20} {names.get(w, '?')[:40]:<40} {w:>8} {before:>10,} {n:>10,} {gain:>+10,}")
    if not rows:
        print("  none")

    # the whole server, per item: helps tell a real dupe (one account jumps) from an item everyone got more of
    server_old, server_new = {}, {}
    for (aid, w), n in old.items():
        server_old[w] = server_old.get(w, 0) + n
    for (aid, w), n in new.items():
        server_new[w] = server_new.get(w, 0) + n
    grow = sorted(((server_new[w] - server_old.get(w, 0), w) for w in server_new if w not in skip), reverse=True)[:20]
    print("\nWhole server, the 20 items that grew the most:")
    for g, w in grow:
        print(f"  {names.get(w, '?')[:40]:<40} {w:>8} {server_old.get(w, 0):>12,} -> {server_new[w]:>12,} ({g:+,})")


if __name__ == "__main__":
    main()
