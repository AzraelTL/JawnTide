# Ops: where everything is

This folder holds the operations files for the JawnTide server. It lives in the repo so every machine
(new PC, old PC test server, Linux server) always has the same copy after `git pull`.

| What | Where |
|---|---|
| How code moves between machines (Windows -> GitHub -> Linux) | `WORKFLOW.md` |
| Build and swap on the Linux server | `deploy.sh` |
| Create all 5 databases from scratch (MariaDB) | `database/` (start with `database/README.md`, run `install_all.sql`) |
| Capture live data (world, server settings) from the Linux server | `database/export_live_data.sh` |
| One-off admin SQL scripts | `sql-snippets/` |

## Where things live on each machine

| Item | New PC (development) | Old PC (test server) | Linux server (live) |
|---|---|---|---|
| Code (git clone) | `C:\Users\kylei\source\repos\JawnTide` | `C:\Users\kylei\source\repos\JawnTide` | `~/JawnTide` |
| Edit code here? | **yes** | no (pull only) | no (pull only) |
| Real `Config.js` | not needed | next to the built `ACE.Server.dll` | `~/ace-config/Config.js` |
| Databases | none | MariaDB 11.8 (`C:\MariaDB118`, port 3306) | MariaDB 11.8 |

## Never commit
`Config.js`, `*.dat`, `*.zip`, logs, database dumps, the Moe test vendor, and test weenies.
Content under `Content/` is committed **by file name** (`git add "path"`), never with `git add -A`.
