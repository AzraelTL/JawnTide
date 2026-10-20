#!/usr/bin/env bash
# Nightly backup of the JawnTide databases (Linux live server).
# Installed to /usr/local/bin/jawntide-backup.sh and run as root by /etc/cron.d/jawntide-backup.
# Root can dump without a password on Debian (MariaDB socket login), so no password is stored here.
set -euo pipefail

BACKUP_DIR=/var/backups/jawntide
KEEP_DAYS=14
DATABASES="ace_auth ace_shard ace_world ace_log ace_town_control"
STAMP=$(date +%Y-%m-%d_%H%M)

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# Only dump databases that exist (so the backup still works before/after a wipe)
existing=""
for db in $DATABASES; do
    if mariadb -N -e "SHOW DATABASES LIKE '$db'" | grep -qx "$db"; then
        existing="$existing $db"
    fi
done
if [ -z "$existing" ]; then
    echo "$(date -Is) ERROR: none of the JawnTide databases were found"
    exit 1
fi

OUT="$BACKUP_DIR/jawntide-$STAMP.sql.gz"
# --single-transaction: consistent snapshot without stopping the game server
mariadb-dump --single-transaction --routines --events --databases $existing | gzip > "$OUT.tmp"
mv "$OUT.tmp" "$OUT"
chmod 600 "$OUT"

# Keep the last KEEP_DAYS days of backups
find "$BACKUP_DIR" -name 'jawntide-*.sql.gz' -mtime +"$KEEP_DAYS" -delete

echo "$(date -Is) Backup written: $OUT ($(du -h "$OUT" | cut -f1)) databases:$existing"
