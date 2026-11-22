# Loot stages

Prepared chest files for future loot stages. **The full list of everything disabled for launch,
and how to bring each back, is in [DISABLED.md](DISABLED.md).**

One folder per stage (stage2, stage3, ...),
with the same layout as `Content/sql` (for example `stage2/weenies/Arena Patch/480607 Darkbeat's Storage Locker.sql`).

These folders are **not** imported by the server. `Content/sql` always holds the current stage.

| Stage | loot_max_tier | loot_disable_ratings | Random loot |
|---|---|---|---|
| 1 (launch) | 6 | false | Tier 6, Majors at most |
| 2 (live 2026-11-22) | 7 | false | Epics, armor sets, ratings on armor only (`loot_ratings_min_tier 7`, `loot_ratings_armor_only true`), all turned down with `loot_epic_rate`, `loot_set_rate`, `loot_rating_rate`, and `loot_quality_edge 0.5` so chests are only a little better than monsters. Level cap off (275) |
| 3 | 8 | true | Legendaries, no ratings |
| 4 | 8 | false | Legendaries with ratings |
| later | 0 | false | no cap (custom Tier 9) |

## Turning top results down

`loot_epic_rate`, `loot_legendary_rate`, `loot_set_rate` and `loot_rating_rate` are the share of already-rolled
Epics, Legendaries, sets and ratings that is kept (1 = all, 0.2 = one in five). They apply to every profile, including
high quality chests whose quality modifier otherwise makes the result certain. `loot_ratings_min_tier` is the lowest
tier that rolls ratings (retail 8). All of them take effect as soon as they are changed, with no restart.

`loot_quality_edge` decides how much a profile's quality modifier helps with those top results. Below 0 (default) is
stock: a quality above about 0.75 (top chests, rare bosses) makes Epics, sets and ratings certain before the rates
apply. At 0 or more every profile rolls them at the same table chance, and the kept share is multiplied by
(1 + edge x quality), so 0.5 makes the best chests about 1.5 times a quality 0 monster and slightly better than the
best monsters. It also stops quality forcing several cantrips per item from Tier 7.

## Advancing to the next stage

1. On a branch, copy the stage folder's files over the matching files in `Content/sql` (same relative paths), commit, merge, push, deploy.
2. Import the changed files on the live server (or restart once with AutoApplyWorldCustomizations true), then `@clearcache weenie`.
3. In game: `@modifylong loot_max_tier <n>` and, if needed, `@modifybool loot_disable_ratings <true|false>`.

## Originals (world closures)

`originals/` holds the unchanged pre-launch copies of `Content/sql` files that were edited to close
content for launch. Like the stage folders it is never imported; copy a file back (or into the stage
folder that reopens it) when that content returns.

| File | Closed for launch |
|---|---|
| `originals/landblocks/01C9.sql` | Fargon (600000), Empyrean Storage Vault (600036), Bounty Collector (3000381) and Artemis (490530, mercenary vendor) placements |
| `originals/weenies/Arena Patch/480480 Darkbeat.sql` | Darkbeat's shop: Bounty Purchase Token (60000213) and Writ of Pursuit (60000215) |
| `originals/weenies/Peddler's Outpost/490150 Outpost Flying Machine.sql` | Hot Air Balloon at Peddler's Outpost (took an Energy Infused Rock and flew to the island); now only says it is grounded |
| `originals/weenies/LootBoxes/510003 RareMysteryBox.sql`, `originals/weenies/LootBoxes/510004 MythicMysteryBox.sql` | Shimmering Skeleton Key removed from both boxes (permanent: it is a loot-system rare only) |

If only some of the 01C9 placements return in a stage, copy just its INSERT/VALUES lines back
instead of the whole file.
