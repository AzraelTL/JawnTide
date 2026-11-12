# JawnTide resource monitor

A small web page for the LAN that shows, per account:

- last login, last IP, and the full IP history (from `ace_log.character_login_log`, which the server writes on
  every character login), with the other accounts that used the same IP (shared IPs are highlighted)
- the most played character (by in-game played time) and its level; each account page lists every character's
  level, total XP and played time
- how much of each tracked currency the account owns: carried on its characters (main pack and side packs), in its
  **My Mule** storage and in its **bank** (`account_bank`; hover a number for the split), and which character carries
  the most; anything else is shown as "Elsewhere" (house storage, ground, vendors). Banked luminance has its own column.
  Tracked: pyreals, MMDs (Trade Note 250k), PK Trophies, Phials, Darkbeat, Hera and Shimmering Skeleton keys, Amber Shards,
  Luminance Exchange Tokens, A Boxes, plus **every alternate currency any vendor uses** (read from the world
  database on each snapshot, so new ones appear by themselves). Currencies nobody holds are hidden.
- per-account totals over time (kept 30 days)
- **Top holders** (`/top`): accounts ranked by carried + mule + bank for each currency.
- **Bank** (`/bank`): every account's bank balances, and the last 300 bank entries (sends, receives, admin changes and
  big changes highlighted). Each account page also shows its own bank history.
- **Allegiances** (`/allegiances`): every allegiance with at least one vassal (largest first) with its monarch, whether the
  monarch is on the Town Control whitelist (`town_control_alleglist`), member and account counts and levels; below it each
  allegiance's full patron/vassal tree. Whitelist IDs that no longer belong to a monarch are listed too.
- **Levels** (`/levels`): every character on the server with level, total XP, played time, XP gained and time
  played in a chosen window (1h, 6h, 24h, 72h, 7 days), XP per hour played, and the landblock where it was last
  saved; sort by level, XP gained, XP per hour played or played time. Below it, the landblocks where the most XP
  was earned in that window and who earned it. A character with a far higher XP per hour than others at its level
  is worth a look (exploit, or a spot whose XP needs turning down). XP history starts when this version first runs.
  The **Wiki** column picks wiki contributors. Players register a character on the wiki first ("registered, waiting"),
  then you tick it to let them edit (one per account; ticking another character on that account replaces it, unticking
  takes editing away). "same IP as" flags another contributor's account on the same IP. This is the monitor's only write (`ace_wiki.contributor`, granted by
  `Ops/website/wiki-setup.sh`).

- **Casting** (`/casting`): the live settings that change how spell casting reacts to moving, turning and position, with their
  current values, plus the rules fixed in the server code (6 m movement fizzle for red players, cast animation speed and so on).
  The list is `CASTING_SETTINGS` and `CASTING_FIXED` in `monitor.py`.
- **Settings** (`/settings`): every server setting an admin can change in game, grouped by area, with its **current live value**
  (read from `ace_shard.config_properties_*` each time the page loads), its default, what it does and the `@fetch`/`@modify`
  commands. Rows that differ from the default are highlighted; search, area and "changed only" filters. Secret values
  (webhooks, keys) show only as "set" or "(empty)". Names, defaults and descriptions come from `settings_catalog.json`,
  read live from `Source/ACE.Server/Managers/PropertyManager.cs` (mounted into the container by compose.yml), so every
  setting in the code pulled on Linux shows up with nothing to regenerate. `settings_catalog.json` is the fallback when that file
  isn't mounted; refresh it with `python Ops/monitor/make_settings_catalog.py` from the repo root.
  Below the settings, **Admin commands** lists every command above player level (name, aliases, level, description, usage,
  file), read live from `Source/ACE.Server/Command/Handlers/*.cs` (also mounted by compose.yml), with search and a level filter.

- **PvP damage** (`/pvp`): every setting about damage (the whole PvP damage tuning area plus any other setting whose name is about
  damage, crits, armor or resistance) with its live value, and **editable**: change values, enter the edit password and Save. The monitor
  only adds rows to `ace_shard.settings_request`; the game server (`SettingsRequests.cs`) applies them within about 5 seconds, the same as
  `@modifydouble` / `@modifylong` / `@modifybool`, and posts each change on the audit channel. String settings (webhooks, keys) can't be
  changed here. Recent changes and whether each was applied are listed below the table.
- **Target Drudge** (`/dummy`): every placed Target Drudge with its setup and a form to change it (armor for the body and for
  head/hands/feet, defenses, ratings, buff presets and extra buffs by name or id, taking worn items off, removing debuffs), saved with the
  edit password as `training_dummy_request` rows that the game server applies within about 5 seconds. Below that, every attack session on a Target Drudge (wcid 4290001, `TrainingDummy.cs`): DPS, damage, hit, crit,
  evade and resist rates, the dummy's setup, the per-weapon and per-spell breakdown, and which PvP settings were changed from default at
  the time. Place one in game with `@createinst 4290001` and set it up with `/dummy` (`/help dummy`). A player's hits on it take the
  PvP damage path, it never dies and gives no skill training.

Pages: `/` accounts (click a currency header to sort), `/account?name=...`, `/levels`, `/allegiances`, `/top` top 15 holders per
currency, `/ips` IPs shared by several accounts, `/settings` server settings, `/casting` casting and movement. Open it from any machine on the LAN: **http://192.168.0.190:8080**

## How it works

`ace-monitor` is its own container (`Ops/monitor/compose.yml`), separate from the game server. Every 10 minutes
(`INTERVAL_SECONDS`) it runs a few indexed SELECT queries as the MariaDB user `monitor`, which can only read
`ace_auth.account`, `ace_shard`, `ace_log.character_login_log` and the two `ace_world` tables that list vendor
currencies and item names. It never writes to the game databases and
does not need the game server (the one exception is the Wiki column above, which writes `ace_wiki.contributor`). ACE saves characters to the database every few minutes and on logout, so the
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

   For the PvP damage page (after the game server has started once with the PvP balance tools, which creates the table), let the
   monitor add setting change requests and set its edit password:

       cd ~/jawntide-server && grep -q '^MONITOR_EDIT_PASSWORD=' .env || echo "MONITOR_EDIT_PASSWORD=$(openssl rand -hex 6)" >> .env && docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "GRANT INSERT ON ace_shard.settings_request TO monitor@\"%\"; GRANT INSERT ON ace_shard.training_dummy_request TO monitor@\"%\"; FLUSH PRIVILEGES;"' && grep '^MONITOR_EDIT_PASSWORD=' .env

   The last part prints the edit password (keep it to yourself).

3. Build and start it:

       docker compose -f ~/JawnTide/Ops/monitor/compose.yml --env-file ~/jawntide-server/.env up -d --build && sleep 15 && docker logs --tail 5 ace-monitor

The log should say `snapshot: N accounts, N characters`. It restarts by itself after a reboot.

## Updating and stopping

After pulling a new master: `docker compose -f ~/JawnTide/Ops/monitor/compose.yml --env-file ~/jawntide-server/.env up -d --build`.
Stop it: `docker compose -f ~/JawnTide/Ops/monitor/compose.yml stop`.
