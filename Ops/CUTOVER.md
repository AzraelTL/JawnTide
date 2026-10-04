# Fresh live server: cutover plan

Proven on JawnTest (old PC): a world built from the repo + the stock release + the two patches
starts cleanly and contains no test content.

Machines: **new PC** = development, **old PC** = JawnTest, **Linux** = live.

## How the fresh world is built
1. `Ops/database/install_all.sql` creates the five empty databases, and seeds the world `version` row (0.0.0).
2. On first start the server sees version 0.0.0, downloads the latest stock world release from GitHub
   and imports it (slow, several minutes, needs internet).
3. Then it runs every `.sql` under `Content/` (sorted by full path): the previous developer's content,
   our three locker placements, and `Content/sql/zz-jawntide-patches/` last.

## Config.js settings the live server needs (in `~/ace-config/Config.js`)
- `"AutoUpdateWorldDatabase": true`, `"AutoApplyWorldCustomizations": true`, `"AutoApplyDatabaseUpdates": true`
- `"WorldCustomizationAddedPaths": [ "/home/kyleivanblake123/JawnTide/Content" ]`
- `"DatFilesDirectory"` pointing at a folder that is NOT inside the old ZaiusTide clone
- the five `MySql` sections with the right passwords

## Order of work (live)
1. Backup exists in two places (done: `~/backup-live-before-fresh-start.sql`, `C:\Users\kylei\backups\`).
2. Pull this repo on Linux: `cd ~/JawnTide && git pull --ff-only origin master`.
3. Copy the dat files to `~/ace-data/Dats` and update `DatFilesDirectory`.
4. Edit `~/ace-config/Config.js` (the settings above).
5. Stop the live server (`shutdown` at the ACE >> prompt).
6. Drop the five live databases and recreate them with `install_all.sql`.
7. `Ops/deploy.sh`, then start the server from `~/ace-live`.
8. Create the admin account (first account is promoted to admin automatically).
9. Re-enter real settings on purpose: whitelist (`@addwhitelist`), new Discord webhooks, anything else you want.

## Things that are deliberately NOT carried over
Test characters and accounts, Moe, the Mnemosyne copy, the Dueling Armor files, the Outpost Sewer change,
and all live Discord webhooks (rotate them before putting new ones in).
