#!/usr/bin/env python3
"""
Estimates when each character reached each level, from the data we already have, and writes SQL that fills
ace_log.character_level_log with those estimates (estimated = 1). Standard library only; run once on the Linux server.

Sources (merged into one timeline per character, times converted to UTC):
  - every nightly backup (/var/backups/jawntide/jawntide-YYYY-MM-DD_HHMM.sql.gz): level, total XP and played time
    of every character at backup time
  - the monitor's history (char_history in monitor.sqlite): the same every 10 minutes, since the Levels page started
  - each character's creation time (level 1, 0 XP)

For a level L, the estimate falls between the last sample below L and the first sample at L or above, placed by how
far the XP had to go to reach L (the XP needed for each level is inferred from all samples; level 126 is the cap XP).
For the cap (126), where XP stops growing, it uses the XP per minute played from the sample before and assumes they
kept playing; with no such rate it takes the middle of the gap.
windowMinutes is the gap between those two samples: how rough the estimate is. Rows the server writes later
(estimated = 0) are never touched: INSERT IGNORE keeps whatever is there first.

Usage: python3 level_backfill.py BACKUP_DIR MONITOR_SQLITE [TIMEZONE] > level-backfill.sql
"""
import glob
import gzip
import os
import re
import sqlite3
import sys
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

PROP_INT_LEVEL, PROP_INT_CREATED, PROP_INT_AGE, PROP_INT64_XP = 25, 98, 125, 1

# same as Database/Updates/Log/AddCharacterLevelLogFeature.sql (the server creates it too; whichever runs first wins)
TABLE = """CREATE TABLE IF NOT EXISTS `character_level_log` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `characterId` INT UNSIGNED NOT NULL,
  `characterName` VARCHAR(255) NOT NULL,
  `accountId` INT UNSIGNED NOT NULL,
  `level` INT NOT NULL,
  `totalExperience` BIGINT NOT NULL DEFAULT 0 COMMENT 'total XP right after the level up',
  `ageSeconds` INT NOT NULL DEFAULT 0 COMMENT 'played time (seconds) at the level up',
  `reachedAtUtc` DATETIME NOT NULL,
  `estimated` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = filled in afterwards from backups and monitor history',
  `windowMinutes` INT NULL COMMENT 'estimated rows: minutes between the two samples the time falls between',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uidx_character_level` (`characterId`, `level`),
  KEY `idx_level_time` (`level`, `reachedAtUtc`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;"""


def parse_values(s, i):
    """Parses '(a,b,'c'),(...)' from position i; yields lists of Python values (None, int, float, str, bytes)."""
    n = len(s)
    while i < n:
        while i < n and s[i] in " ,\n\r":
            i += 1
        if i >= n or s[i] != "(":
            return
        i += 1
        row, cur = [], None
        while True:
            c = s[i]
            if c == "'" or (c in "_b" and s.startswith(("_binary '", "b'"), i)):
                binary = c != "'"
                i = s.index("'", i) + 1
                buf = []
                while True:
                    c = s[i]
                    if c == "\\":
                        nxt = s[i + 1]
                        buf.append({"0": "\0", "n": "\n", "r": "\r", "t": "\t", "Z": "\x1a"}.get(nxt, nxt)); i += 2
                    elif c == "'":
                        if s[i + 1] == "'":
                            buf.append("'"); i += 2
                        else:
                            i += 1; break
                    else:
                        buf.append(c); i += 1
                val = "".join(buf)
                cur = val.encode("latin-1", "replace") if binary else val
            elif c in ",)":
                row.append(cur); cur = None; i += 1
                if c == ")":
                    yield row
                    break
            else:
                j = i
                while s[j] not in ",)":
                    j += 1
                tok = s[i:j].strip(); i = j
                if tok == "NULL":
                    cur = None
                elif tok.startswith("0x"):
                    cur = int(tok, 16)
                else:
                    try:
                        cur = int(tok)
                    except ValueError:
                        try:
                            cur = float(tok)
                        except ValueError:
                            cur = tok


def read_backup(path):
    """{char_id: (level, xp, age)}, {char_id: (name, account_id, deleted, created_unix)} from one dump."""
    db, cols, table = None, {}, None
    chars, ints, int64 = {}, {}, {}
    with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
        for line in f:
            if line.startswith("INSERT INTO `") and not line.rstrip().endswith(";"):
                # newer mariadb-dump writes "INSERT INTO `t` VALUES" and then one row per line until the ';'
                parts = [line]
                for more in f:
                    parts.append(more)
                    if more.rstrip().endswith(";"):
                        break
                line = "".join(parts)
            if line.startswith("USE `"):
                db = line[5:line.index("`", 5)]
            elif db == "ace_shard" and line.startswith("CREATE TABLE `"):
                table = line[14:line.index("`", 14)]; cols[table] = []
            elif table and line.startswith("  `"):
                cols[table].append(line[3:line.index("`", 3)])
            elif table and line.startswith(")"):
                table = None
            elif db == "ace_shard" and line.startswith("INSERT INTO `"):
                t = line[13:line.index("`", 13)]
                if t not in ("character", "biota_properties_int", "biota_properties_int64"):
                    continue
                c = cols.get(t) or (["object_Id", "type", "value"] if t != "character" else [])
                start = line.index("VALUES") + 6
                for row in parse_values(line, start):
                    r = dict(zip(c, row))
                    if t == "character":
                        deleted = r.get("is_Deleted")
                        deleted = bool(deleted and deleted not in (b"\0", "\0", 0, "0"))
                        chars[r["id"]] = [r["name"], r["account_Id"], deleted, None]
                    elif t == "biota_properties_int" and r["type"] in (PROP_INT_LEVEL, PROP_INT_CREATED, PROP_INT_AGE):
                        ints[(r["object_Id"], r["type"])] = r["value"]
                    elif t == "biota_properties_int64" and r["type"] == PROP_INT64_XP:
                        int64[r["object_Id"]] = r["value"]
    samples = {}
    for cid, info in chars.items():
        info[3] = ints.get((cid, PROP_INT_CREATED))
        samples[cid] = (ints.get((cid, PROP_INT_LEVEL), 1), int64.get(cid, 0), ints.get((cid, PROP_INT_AGE), 0))
    return samples, chars


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    backup_dir, monitor_db = sys.argv[1], sys.argv[2]
    tz = ZoneInfo(sys.argv[3] if len(sys.argv) > 3 else "America/New_York")
    utc = lambda local: local.replace(tzinfo=tz).astimezone(timezone.utc).replace(tzinfo=None)

    timeline, names = {}, {}
    files = sorted(glob.glob(os.path.join(backup_dir, "jawntide-*.sql.gz")))
    for path in files:
        m = re.search(r"jawntide-(\d{4}-\d{2}-\d{2})_(\d{4})\.sql\.gz$", path)
        if not m:
            continue
        when = utc(datetime.strptime(m.group(1) + m.group(2), "%Y-%m-%d%H%M"))
        samples, chars = read_backup(path)
        for cid, (lvl, xp, age) in samples.items():
            timeline.setdefault(cid, []).append((when, xp, lvl, age or 0))
        names.update(chars)            # newest backup wins (files are in date order)
        print(f"-- backup {os.path.basename(path)}: {len(samples)} characters", file=sys.stderr)

    if os.path.exists(monitor_db):
        con = sqlite3.connect(monitor_db)
        n = 0
        for ts, cid, xp, lvl, age in con.execute("SELECT ts, cid, xp, level, age FROM char_history"):
            timeline.setdefault(cid, []).append((utc(datetime.strptime(ts, "%Y-%m-%d %H:%M")), xp or 0, lvl or 1, age or 0)); n += 1
        print(f"-- monitor history: {n} samples", file=sys.stderr)

    for cid, info in names.items():
        if info[3]:
            timeline.setdefault(cid, []).append((datetime.fromtimestamp(info[3], timezone.utc).replace(tzinfo=None), 0, 1, 0))

    # XP needed for each level, from every sample: above the most XP seen below it, at most the least XP seen at or above it
    below, at = {}, {}
    for pts in timeline.values():
        for _, xp, lvl, _a in pts:
            for L in range(2, 127):
                if lvl >= L:
                    at[L] = min(at.get(L, xp), xp)
                else:
                    below[L] = max(below.get(L, xp), xp)
                    break
    need = {}
    for L in at:
        need[L] = (below[L] + at[L]) / 2 if L in below else at[L]
    if 126 in at:
        need[126] = at[126]           # the cap: everyone at 126 sits exactly on the cap XP

    print("USE `ace_log`;")
    print(TABLE)
    rows = 0
    for cid, pts in timeline.items():
        pts.sort()
        clean, top = [], (-1, 0)
        for t, xp, lvl, age in pts:   # ignore anything that goes backwards (admin level changes)
            if (lvl, xp) >= top:
                clean.append((t, xp, lvl, age)); top = (lvl, xp)
        current = clean[-1][2]
        for L in range(2, current + 1):
            i = next(k for k, p in enumerate(clean) if p[2] >= L)
            if i == 0:
                continue              # already past L in the first thing we know about: no estimate possible
            (t0, x0, _, a0), (t1, x1, _, a1) = clean[i - 1], clean[i]
            if L == 126 and i >= 2:
                # XP stops at the cap, so the later sample can't say how far into the gap they capped. Use how fast they
                # were earning per minute played just before (the previous sample) and assume they kept playing.
                tp, xp_, _, ap = clean[i - 2]
                rate = (x0 - xp_) / (a0 - ap) if a0 > ap and x0 > xp_ else 0
                if rate > 0:
                    secs = (need[L] - x0) / rate
                    when = min(t1, t0 + timedelta(seconds=secs))
                else:
                    when = t0 + (t1 - t0) / 2
            else:
                frac = 0.5 if L not in need or x1 <= x0 else min(1.0, max(0.0, (need[L] - x0) / (x1 - x0)))
                when = t0 + (t1 - t0) * frac
            window = int((t1 - t0).total_seconds() // 60)
            # name and account come from the live character table; deleted characters are skipped there
            print(f"INSERT IGNORE INTO character_level_log (characterId, characterName, accountId, level, totalExperience, ageSeconds, "
                  f"reachedAtUtc, estimated, windowMinutes) SELECT id, name, account_Id, {L}, {int(need.get(L, x1))}, 0, "
                  f"'{when:%Y-%m-%d %H:%M:%S}', 1, {window} FROM ace_shard.`character` WHERE id = {int(cid)} AND is_Deleted = 0;")
            rows += 1
    print(f"-- {rows} estimated level times for {len(timeline)} characters from {len(files)} backups", file=sys.stderr)


if __name__ == "__main__":
    main()
