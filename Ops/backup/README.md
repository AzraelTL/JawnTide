# Nightly database backups (Linux live server)

- Script: `jawntide-backup.sh` dumps ace_auth, ace_shard, ace_world, ace_log and ace_town_control
  into `/var/backups/jawntide/jawntide-YYYY-MM-DD_HHMM.sql.gz` and keeps 14 days.
- Schedule: `jawntide-backup.cron` runs it every night at 04:30 as root. Log: `/var/log/jawntide-backup.log`.

## Install (Linux, from the repo clone)

    cd ~/JawnTide && git pull --ff-only origin master
    sudo install -m 700 Ops/backup/jawntide-backup.sh /usr/local/bin/jawntide-backup.sh
    sudo install -m 644 Ops/backup/jawntide-backup.cron /etc/cron.d/jawntide-backup

The cron file must be installed WITHOUT a file extension: cron ignores files in /etc/cron.d whose names contain a dot.

## Run one by hand / check

    sudo /usr/local/bin/jawntide-backup.sh
    sudo ls -lh /var/backups/jawntide

## Restore (server stopped)

    gunzip -c /var/backups/jawntide/jawntide-DATE.sql.gz | sudo mariadb

Copy a backup off the machine now and then (for example to the new PC), so a disk failure can't take
the server and its backups together.
