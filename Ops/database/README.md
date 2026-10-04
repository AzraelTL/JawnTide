# ZaiusTide database setup (MariaDB)

Creates every database the ZaiusTide server uses, with all tables the code expects.

| Script | Database | Contents |
|---|---|---|
| `00_create_databases.sql` | all | Creates the 5 databases (optional `ace` user block, commented out) |
| `01_ace_auth.sql` | `ace_auth` | Accounts, access levels, account IP binding tables |
| `02_ace_shard.sql` | `ace_shard` | Characters, biotas, quest registry, server properties (schema) |
| `03_ace_world.sql` | `ace_world` | Weenies, recipes, landblocks, quests, spells (**schema only, no game data**) |
| `04_ace_world_dungeon_info.sql` | `ace_world` | `dungeon_info` table and data |
| `05_ace_log.sql` | `ace_log` | Logins, tinkers, PK kills, arenas, rare log, stuck characters, season leaderboard |
| `06_ace_town_control.sql` | `ace_town_control` | Towns (Holtburg 72, Shoushi 91, Yaraq 102), events, archive, reward columns |

## Install (fresh server)

From this folder:

    mysql -u root -p < install_all.sql

The scripts are **safe to re-run**: they use `CREATE TABLE IF NOT EXISTS` and `INSERT IGNORE`, and contain no `DROP`. They do not change tables that already exist, except `06` which adds the four town reward columns if they are missing.

## What is NOT included

- **Stock world data.** Let the server download it (`AutoUpdateWorldDatabase` in `Config.js`), or import the release from `ACEmulator/ACE-World-16PY-Patches`.
- **Your custom world content** (custom weenies, quests, recipes, landblock edits). Run `export_live_data.sh` on the live server, then import `export/ace_world_full.sql` instead of step 03 and the stock download.
- **Server settings** (`config_properties_*` in `ace_shard`: `content_folder`, `town_control_alleglist`, arena settings...). `export_live_data.sh` dumps them too.
- **Accounts and characters.** Create a test admin at the server prompt: `accountcreate testaccount testpassword 5`.
- `ace_pk_kills`: legacy; the code logs PK kills to `ace_log.pk_kills_log`.

## Notes

- Written for **MariaDB**. `ADD COLUMN IF NOT EXISTS` and `CREATE INDEX IF NOT EXISTS` are MariaDB syntax.
- MySQL-8-only `ENCRYPTION='N'` clauses from the original dumps were removed.
- Source of these scripts: the `DatabaseSetupScripts` folder in your build output, checked against the entity mappings in `ACE.Database/Models/*`. Compare against the repo's own `Database/` folder before replacing anything there.
- Reward amounts on `town` default to 0 (no trophies). See the commented `UPDATE` at the end of `06`.
- Always back up before running anything on a live database: `mysqldump -u root -p --databases ace_auth ace_shard ace_world ace_log ace_town_control > backup.sql`
