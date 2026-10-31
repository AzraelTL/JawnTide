# Level backfill (one time)

`ace_log.character_level_log` records level ups from the moment the server has it. `level_backfill.py` fills in
**estimated** times for everything before that, from the nightly backups and the monitor's 10-minute history
(rows get `estimated = 1` and `windowMinutes` = how wide the gap was that the time was placed in; 10 = good, 1440 = a
day between backups). It only inserts rows that don't exist yet, so it never changes a real (server-written) time.

Run on Linux (backups are root-only, so it runs with sudo; standard library Python only):

    docker cp ace-monitor:/data/monitor.sqlite /tmp/monitor.sqlite
    sudo python3 ~/JawnTide/Ops/tools/level-backfill/level_backfill.py /var/backups/jawntide /tmp/monitor.sqlite > /tmp/level-backfill.sql
    docker compose -f ~/jawntide-server/compose.yml exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD"' < /tmp/level-backfill.sql

Backup file names and monitor times are read as America/New_York (third argument changes it).

Current levels in order (highest first, earliest to get there first):

    SELECT l.characterName, l.level, l.reachedAtUtc, l.estimated, l.windowMinutes FROM ace_log.character_level_log l
    JOIN (SELECT characterId, MAX(level) lvl FROM ace_log.character_level_log GROUP BY characterId) m
      ON m.characterId = l.characterId AND m.lvl = l.level
    ORDER BY l.level DESC, l.reachedAtUtc;
