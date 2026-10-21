# Live server on Docker (Linux "Asheron")

The live server runs JawnTide and MariaDB 11.8 in Docker. This replaces `Ops/deploy.sh` and the
native MariaDB install on Linux. The workflow rule is unchanged: code is edited on Windows, merged
into `master` on GitHub, and Linux only pulls and builds.

## Layout on Linux

| Path | What |
|---|---|
| `~/JawnTide` | git clone of `master` (never edited by hand) |
| `~/jawntide-server/compose.yml` | copy of `Ops/docker/compose.yml` |
| `~/jawntide-server/.env` | `DB_ROOT_PASSWORD`, `DB_ACE_PASSWORD` (generated with `openssl rand -hex 16`, mode 600, never committed) |
| `~/jawntide-server/Config/` | `Config.js` and `log4net.config` for the container (never committed) |
| `~/jawntide-server/Dats/` | the four client `.dat` files |
| `~/jawntide-server/Logs/` | server logs |
| `~/jawntide-server/db-data/` | MariaDB data files |

Containers: `ace-db` (MariaDB, port 3306 on 127.0.0.1 only) and `ace-server` (UDP 9000-9001).
Both restart automatically after a reboot unless they were stopped by hand.
The game database user is `ace`.

## Everyday commands (run from `~/jawntide-server`)

| Task | Command |
|---|---|
| Status | `docker ps` |
| Live log (Ctrl+C to leave) | `docker compose logs -f ace-server` |
| Server console (Ctrl+C to detach, server keeps running) | `docker attach --sig-proxy=false ace-server` |
| Stop / start the game server | `docker compose stop ace-server` / `docker compose start ace-server` |
| SQL prompt | `docker compose exec ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD"'` |

## Deploy a new master

    cd ~/JawnTide && git pull --ff-only origin master && cd ~/jawntide-server && docker compose build ace-server && docker compose up -d && git -C ~/JawnTide log -1 --oneline

`docker compose up -d` replaces the running server with the new image (players are disconnected).
New `Database/Updates` scripts are applied automatically at startup.

## Import Content/sql by hand

The server only imports `Content/sql` after a world database update. To import the current
content into the running world database (for example after advancing a loot stage):

    cd ~/JawnTide && LC_ALL=C find Content -name '*.sql' | LC_ALL=C sort | while IFS= read -r f; do cat "$f"; echo; done | docker compose -f ~/jawntide-server/compose.yml exec -T ace-db sh -c 'mariadb --force -uroot -p"$MARIADB_ROOT_PASSWORD" ace_world' 2> ~/jawntide-server/content-import-errors.txt; wc -l ~/jawntide-server/content-import-errors.txt

Then `@clearcache weenie` in game, or restart the server.

## log4net.config

Make it from the repo copy, which already has the async appender removed:

    cp ~/JawnTide/Source/ACE.Server/log4net.config.docker ~/jawntide-server/Config/log4net.config

The INFO lines are white, so use a dark terminal theme.

## Backups

Install `Ops/backup/jawntide-backup-docker.sh` as `/usr/local/bin/jawntide-backup.sh`; the cron file
is the same as for the native install. See `Ops/backup/README.md`.

## Docker and ufw

Ports published by Docker bypass ufw. That is why MariaDB is published on 127.0.0.1 only. The game
ports are reachable from anything that can reach the machine; the router decides what the internet sees.
