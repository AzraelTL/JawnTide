# Loot stages

Prepared chest files for future loot stages. One folder per stage (stage2, stage3, ...),
with the same layout as `Content/sql` (for example `stage2/weenies/Arena Patch/480607 Darkbeat's Storage Locker.sql`).

These folders are **not** imported by the server. `Content/sql` always holds the current stage.

| Stage | loot_max_tier | loot_disable_ratings | Random loot |
|---|---|---|---|
| 1 (launch) | 6 | false | Tier 6, Majors at most |
| 2 | 7 | false | Epics, no ratings |
| 3 | 8 | true | Legendaries, no ratings |
| 4 | 8 | false | Legendaries with ratings |
| later | 0 | false | no cap (custom Tier 9) |

## Advancing to the next stage

1. On a branch, copy the stage folder's files over the matching files in `Content/sql` (same relative paths), commit, merge, push, deploy.
2. Import the changed files on the live server (or restart once with AutoApplyWorldCustomizations true), then `@clearcache weenie`.
3. In game: `@modifylong loot_max_tier <n>` and, if needed, `@modifybool loot_disable_ratings <true|false>`.
