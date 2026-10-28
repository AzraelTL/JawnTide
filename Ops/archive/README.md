# Archived content (never imported)

Files moved out of `Content/sql` because importing them again would undo a JawnTide change. Nothing in this folder is imported.

| File | Why it was removed |
|---|---|
| `ChangeHousingRentToPkTrophies.sql` | Zaiustide patch that rewrites every placed slumlord's buy and rent lists in **ace_shard** to PK Trophies. JawnTide uses stock ACE housing costs (`Content/sql/weenies/Housing/`, Oct 25), but because this file writes straight to ace_shard, every full Content import (deploy, Oct 27) put PK Trophy costs back on all houses. Moved here on Oct 27, 2026; `Ops/sql-snippets/housing-costs-stock-shard.sql` copies the stock costs back onto the placed slumlords. |
