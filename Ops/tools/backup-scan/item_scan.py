#!/usr/bin/env python3
"""
JawnTide: count an item (default PK Trophies, wcid 1000002) per character in nightly backups, without loading them.

Reads each mariadb-dump .sql.gz as text (one pass, read-only) and reports, for the chosen accounts:
  - stacks carried by each character (main pack and side packs)
  - stacks stored in the account's My Mule (whole container chain)
  - the account's bank balance for that item (PK Trophies only)

Usage (backups are root-only):
  sudo python3 item_scan.py /var/backups/jawntide/jawntide-*.sql.gz --accounts livefit,evilways1
  sudo python3 item_scan.py BACKUP.sql.gz --accounts livefit --wcid 1000002 --bank-code pk_trophies
"""
import argparse
import gzip
import re
import sys

USE_RE = re.compile(r"^USE `([^`]+)`;")
INSERT_RE = re.compile(r"^INSERT INTO `([^`]+)` VALUES\s?")
NUM3 = re.compile(r"\((\d+),(\d+),(-?\d+)\)")          # (object_Id,type,value)
BIOTA = re.compile(r"\((\d+),(\d+),")                  # (id,weenie_Class_Id,...
ACCOUNT = re.compile(r"\((\d+),'((?:[^'\\]|\\.)*)'")   # (accountId,'accountName',...
CHAR = re.compile(r"\((\d+),(\d+),'((?:[^'\\]|\\.)*)'")  # (id,account_Id,'name',...
MULE = re.compile(r"\((\d+),(\d+),(-?\d+)\)")          # (account_Id,container_Id,visual_Variant)
BANK = re.compile(r"\((\d+),'((?:[^'\\]|\\.)*)',(-?\d+)\)")  # (account_Id,'currency',amount)


def scan(path, wcid, account_names, bank_code):
    db = None
    item_ids = set()
    stack = {}
    container = {}      # object -> container (PropertyInstanceId.Container = 2)
    next_mule = {}      # mule container -> next container (PropertyInstanceId.MuleNextContainerId = 20003)
    accounts = {}       # accountId -> name
    chars = {}          # character id -> (account_Id, name)
    mules = {}          # account_Id -> head container
    bank = {}           # account_Id -> amount

    def handle(table, body):
        if db == "ace_auth" and table == "account":
            for a in ACCOUNT.finditer(body):
                accounts[int(a.group(1))] = a.group(2)
        elif db != "ace_shard":
            return
        elif table == "biota":
            for b in BIOTA.finditer(body):
                if int(b.group(2)) == wcid:
                    item_ids.add(int(b.group(1)))
        elif table == "biota_properties_int":
            for p in NUM3.finditer(body):
                if p.group(2) == "12":
                    oid = int(p.group(1))
                    if oid in item_ids:
                        stack[oid] = int(p.group(3))
        elif table == "biota_properties_i_i_d":
            for p in NUM3.finditer(body):
                t = p.group(2)
                if t == "2":
                    container[int(p.group(1))] = int(p.group(3))
                elif t == "20003":
                    next_mule[int(p.group(1))] = int(p.group(3))
        elif table == "character":
            for c in CHAR.finditer(body):
                chars[int(c.group(1))] = (int(c.group(2)), c.group(3))
        elif table == "account_mule":
            for c in MULE.finditer(body):
                mules[int(c.group(1))] = int(c.group(2))
        elif table == "account_bank":
            for c in BANK.finditer(body):
                if c.group(2) == bank_code:
                    bank[int(c.group(1))] = int(c.group(3))

    # mariadb-dump 11 writes "INSERT INTO `t` VALUES" on its own line and each row on the following lines (ending
    # with ";"); older dumps put every row on the INSERT line. Both are handled: rows belong to the last INSERT
    # until a line ends with ";".
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

    wanted = {aid for aid, name in accounts.items() if name.lower() in account_names}

    # mule container -> account
    mule_of = {}
    for aid, head in mules.items():
        c, seen = head, set()
        while c and c not in seen:
            seen.add(c)
            mule_of[c] = aid
            c = next_mule.get(c)

    per_char, per_mule = {}, {}
    for oid in item_ids:
        n = stack.get(oid, 1)
        c = container.get(oid)
        if c in chars:
            per_char[c] = per_char.get(c, 0) + n
        elif c in mule_of:
            per_mule[mule_of[c]] = per_mule.get(mule_of[c], 0) + n
        else:
            parent = container.get(c)
            if parent in chars:
                per_char[parent] = per_char.get(parent, 0) + n

    print(f"=== {path}")
    total = 0
    for aid in sorted(wanted, key=lambda a: accounts[a]):
        lines = []
        for cid, n in sorted(per_char.items(), key=lambda kv: -kv[1]):
            if chars[cid][0] == aid:
                lines.append(f"    {chars[cid][1]}: {n:,} carried")
                total += n
        if aid in per_mule:
            lines.append(f"    (My Mule): {per_mule[aid]:,}")
            total += per_mule[aid]
        if bank.get(aid):
            lines.append(f"    (bank): {bank[aid]:,}")
            total += bank[aid]
        print(f"  {accounts[aid]} (account {aid})" + ("" if lines else ": none"))
        for l in lines:
            print(l)
    missing = account_names - {accounts[a].lower() for a in wanted}
    if missing:
        print(f"  (not in this backup: {', '.join(sorted(missing))})")
    print(f"  TOTAL: {total:,}")
    sys.stdout.flush()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("backups", nargs="+")
    ap.add_argument("--accounts", required=True, help="comma separated account (login) names")
    ap.add_argument("--wcid", type=int, default=1000002)
    ap.add_argument("--bank-code", default="pk_trophies")
    args = ap.parse_args()
    names = {n.strip().lower() for n in args.accounts.split(",") if n.strip()}
    for path in sorted(args.backups):
        scan(path, args.wcid, names, args.bank_code)


if __name__ == "__main__":
    main()
