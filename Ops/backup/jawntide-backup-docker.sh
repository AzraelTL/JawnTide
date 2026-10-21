#!/usr/bin/env bash
# Nightly backup of the JawnTide databases when MariaDB runs in Docker (container ace-db).
# Install to /usr/local/bin/jawntide-backup.sh (same path as the native script, so
# jawntide-backup.cron works unchanged). Runs as root. The root password is read inside
# the container from its own environment, so no password is stored here.
set -euo pipefail

BACKUP_DIR=/var/backups/jawntide
KEEP_DAYS=14
CONTAINER=ace-db
DATABASES="ace_auth ace_shard ace_world ace_log ace_town_control"
STAMP=$(date +%Y-%m-%d_%H%M)

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -qx true; then
    echo "$(date -Is) ERROR: container $CONTAINER is not running"
    exit 1
fi

# Only dump databases that exist (so the backup still works before/after a wipe)
existing=""
for db in $DATABASES; do
    if docker exec "$CONTAINER" sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "SHOW DATABASES"' | grep -qx "$db"; then
        existing="$existing $db"
    fi
done
if [ -z "$existing" ]; then
    echo "$(date -Is) ERROR: none of the JawnTide databases were found"
    exit 1
fi

OUT="$BACKUP_DIR/jawntide-$STAMP.sql.gz"
# --single-transaction: consistent snapshot without stopping the game server
docker exec "$CONTAINER" sh -c "mariadb-dump -uroot -p\"\$MARIADB_ROOT_PASSWORD\" --single-transaction --routines --events --databases $existing" | gzip > "$OUT.tmp"
mv "$OUT.tmp" "$OUT"
chmod 600 "$OUT"

# Keep the last KEEP_DAYS days of backups
find "$BACKUP_DIR" -name 'jawntide-*.sql.gz' -mtime +"$KEEP_DAYS" -delete

echo "$(date -Is) Backup written: $OUT ($(du -h "$OUT" | cut -f1)) databases:$existing"
