# Archived content (never imported)

Files moved out of `Content/sql` because importing them again would undo a JawnTide change. Nothing in this folder is imported.

| File | Why it was removed |
|---|---|
| `ChangeHousingRentToPkTrophies.sql` | Zaiustide patch that rewrites every placed slumlord's buy and rent lists in **ace_shard** to PK Trophies. JawnTide uses stock ACE housing costs (`Content/sql/weenies/Housing/`, Oct 25), but because this file writes straight to ace_shard, every full Content import (deploy, Oct 27) put PK Trophy costs back on all houses. Moved here on Oct 27, 2026; `Ops/sql-snippets/housing-costs-stock-shard.sql` copies the stock costs back onto the placed slumlords. |
| `Green Society Band.sql` | Zaiustide one-time migration that adds Legendary Two Handed Combat Aptitude (6073) to every Green Society Band in **ace_shard**. Already applied, and the weenie (`Content/sql/weenies/Green Society Band/`) creates new bands with the spell, so it only re-ran a player-data write on every import. Moved here on Oct 27, 2026. |
| `Legendary Seed of the Morning.sql` | Zaiustide one-time migration that sets the casting animation of every Legendary Seed of Mornings in **ace_shard**. Already applied, and the weenie has the same animation. Moved here on Oct 27, 2026. |

**Rule:** nothing under `Content/sql` may write to `ace_shard`, `ace_auth`, `ace_log` or any database other than the world database. Content is re-imported on every deploy, so a player-data write there runs again each time and can undo later changes. One-time player-data fixes go in `Ops/hotfix/` or `Ops/sql-snippets/` and are run once, by hand, with the game server stopped. Check with: `grep -rliE --include=*.sql "ace_shard|ace_auth|ace_log|ace_town_control|config_properties" Content` (should print nothing).
