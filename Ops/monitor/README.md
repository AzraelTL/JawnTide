# JawnTide resource monitor

A small web page for the LAN that shows, per account:

- last login, last IP, and the full IP history (from `ace_log.character_login_log`, which the server writes on
  every character login), with the other accounts that used the same IP (shared IPs are highlighted)
- the most played character (by in-game played time) and its level; each account page lists every character's
  level, total XP and played time
- how much of each tracked currency the account holds, summed over its characters (main pack and side packs),
  and which character holds it; anything not on a character is shown as "Elsewhere" (house storage, ground).
  Tracked: pyreals, MMDs (Trade Note 250k), PK Trophies, Phials, Darkbeat and Hera keys, Amber Shards,
  Luminance Exchange Tokens, A Boxes, plus **every alternate currency any vendor uses** (read from the world
  database on each snapshot, so new ones appear by themselves). Currencies nobody holds are hidden.
- per-account totals over time (kept 30 days)
- **Levels** (`/levels`): every character on the server with level, total XP, played time, XP gained and time
  played in a chosen window (1h, 6h, 24h, 72h, 7 days), XP per hour played, and the landblock where it was last
  saved; sort by level, XP gained, XP per hour played or played time. Below it, the landblocks where the most XP
  was earned in that window and who earned it. A character with a far higher XP per hour than others at its level
  is worth a look (exploit, or a spot whose XP needs turning down). XP history starts when this version first runs.

Pages: `/` accounts (click a currency header to sort), `/account?name=...`, `/levels`, `/top` top 15 holders per
currency, `/ips` IPs shared by several accounts. Open it from any machine on the LAN: **http://192.168.0.190:8080**

## How it works

`ace-monitor` is its own container (`Ops/monitor/compose.yml`), separate from the game server. Every 10 minutes
(`INTERVAL_SECONDS`) it runs a few indexed SELECT queries as the MariaDB user `monitor`, which can only read
`ace_auth.account`, `ace_shard`, `ace_log.character_login_log` and the two `ace_world` tables that list vendor
currencies and item names. It never writes to the game databases and
does not need the game server. ACE saves characters to the database every few minutes and on logout, so the
numbers lag the game by up to that much.

The extra items tracked besides vendor currencies are `EXTRA_ITEMS` in `monitor.py` (WCID:label pairs); an
`EXTRA_ITEMS` environment variable in compose.yml overrides them.

The port is published on 192.168.0.190 only, and the router only forwards UDP 9000-9001, so the page is not
reachable from the internet.

## Setup (Linux, once)

1. Make a password for the `monitor` user (stored in `.env`, never shown):

       cd ~/jawntide-server && grep -q '^MONITOR_DB_PASSWORD=' .env || echo "MONITOR_DB_PASSWORD=$(openssl rand -hex 16)" >> .env

2. Create the read-only database user:

       cd ~/jawntide-server && MP=$(grep '^MONITOR_DB_PASSWORD=' .env | cut -d= -f2) && docker compose exec -T -e MP="$MP" ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS monitor@\"%\" IDENTIFIED BY \"$MP\"; ALTER USER monitor@\"%\" IDENTIFIED BY \"$MP\"; GRANT SELECT ON ace_auth.account TO monitor@\"%\"; GRANT SELECT ON ace_shard.* TO monitor@\"%\"; GRANT SELECT ON ace_log.character_login_log TO monitor@\"%\"; GRANT SELECT ON ace_world.weenie_properties_d_i_d TO monitor@\"%\"; GRANT SELECT ON ace_world.weenie_properties_string TO monitor@\"%\"; FLUSH PRIVILEGES;"'

3. Build and start it:

       docker compose -f ~/JawnTide/Ops/monitor/compose.yml --env-file ~/jawntide-server/.env up -d --build && sleep 15 && docker logs --tail 5 ace-monitor

The log should say `snapshot: N accounts, N characters`. It restarts by itself after a reboot.

## Updating and stopping

After pulling a new master: `docker compose -f ~/JawnTide/Ops/monitor/compose.yml --env-file ~/jawntide-server/.env up -d --build`.
Stop it: `docker compose -f ~/JawnTide/Ops/monitor/compose.yml stop`.
