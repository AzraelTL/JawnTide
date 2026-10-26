# JawnTide public website

The site for jawntide.com: `site.py` (one small Python web server) and `home.html` (the home page text).

Pages: `/` home (server info, how to connect, Discord), `/pk` open-world PK kills (24 hours, 7 days, 30 days,
all time; top killers, allegiances, latest kills), `/arena` standings per arena type by rank points and recent
matches, `/levels` the top 100 characters and everyone by level, `/allegiances` monarch trees with kills this week.

## How it works

`ace-web` is its own container (`compose.yml`). Every 5 minutes (`INTERVAL_SECONDS`) it reads the databases as the
MariaDB user `web` and keeps the result in memory; pages are built from that copy, so visitors never touch the game
databases. Admin characters (accounts with accessLevel above 0) are left off every page. Arena kills come only from
the arena tables; the PK page counts open-world kills (`pk_kills_log` rows with no arena player).

The `web` user can read only what the site shows:

- `ace_auth.account`: the columns `accountId` and `accessLevel` (to hide admin characters), nothing else
- `ace_shard.character`: `id`, `account_Id`, `name`, `is_Deleted`
- `ace_shard.biota_properties_int`, `biota_properties_int64`, `biota_properties_i_i_d` (level, XP, patron, monarch)
- `ace_log.pk_kills_log`, `ace_log.arena_event`, `ace_log.arena_character_stats`
- `ace_log.arena_player` without `player_ip`

It cannot see account names, passwords, IP addresses or login history. The container runs read-only as `nobody`.

## Setup (Linux, once)

1. Create the `web` user with a random password saved in `~/jawntide-server/.env` as `WEB_DB_PASSWORD`
   (the command is in the Oct 26 handoff; it never prints the password).
2. Start it: `docker compose -f ~/JawnTide/Ops/website/compose.yml --env-file ~/jawntide-server/.env up -d --build`
3. Open http://192.168.0.190:8081 on the LAN.

To change the home page, edit `home.html`; after a pull, run the start command again (it rebuilds the image).

Preview without a database: `python site.py --sample preview.html` writes every page, with made-up data, into one file.
