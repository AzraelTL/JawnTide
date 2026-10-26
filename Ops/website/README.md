# JawnTide public website

The site for jawntide.com: `site.py` (one small Python web server) and `home.html` (the home page text).

Pages: `/` home (server info, how to connect, Discord), `/pk` open-world PK kills (24 hours, 7 days, 30 days,
all time; top killers, allegiances, latest kills), `/arena` standings per arena type by rank points and recent
matches, `/towns` Town Control (who holds each town, live battles with attacker and defender, battle and
governor respite timers, recent battles), `/levels` the top 100 characters and everyone by level, `/allegiances` monarch trees with kills this week.

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
- `ace_town_control.town`, `ace_town_control.town_control_event` (the Town Control page)
- `ace_web.town_control_whitelist`: a view showing only the `town_control_alleglist` setting (for the Town Control flag on
  the Allegiances page); the web user cannot read any other server setting

It cannot see account names, passwords, IP addresses or login history. The container runs read-only as `nobody`.

## Going public: Cloudflare Tunnel

jawntide.com's DNS is on Cloudflare (nameservers archer/jasmine.ns.cloudflare.com, set at IONOS). `play.jawntide.com`
is an A record to 24.154.20.35 with the proxy **off** (grey cloud), because the game's UDP can't go through Cloudflare.

`ace-tunnel` (cloudflared) connects out to Cloudflare and brings visitors to `ace-web`. No router port is forwarded for the
site and the home IP is hidden behind Cloudflare. It sits on its own Docker network (`jawntide-public`) with `ace-web`
only, so it cannot reach the database or the game server. Its token is `CLOUDFLARE_TUNNEL_TOKEN` in
`~/jawntide-server/.env` (a secret; never paste it anywhere). The tunnel (`jawntide-web`, Cloudflare Zero Trust >
Networks > Tunnels) has public hostnames `jawntide.com` and `www.jawntide.com`, both to `HTTP ace-web:8080`.

## Setup (Linux, once)

1. Create the `web` user with a random password saved in `~/jawntide-server/.env` as `WEB_DB_PASSWORD`
   (the command is in the Oct 26 handoff; it never prints the password).
2. Start it: `docker compose -f ~/JawnTide/Ops/website/compose.yml --env-file ~/jawntide-server/.env up -d --build`
3. Open http://192.168.0.190:8081 on the LAN.

To change the home page, edit `home.html`; after a pull, run the start command again (it rebuilds the image).

Preview without a database: `python site.py --sample preview.html` writes every page, with made-up data, into one file.
