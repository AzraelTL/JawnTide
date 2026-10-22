# Disabled for launch: what to bring back later

One list of everything closed, held back or switched off for launch (Oct 23, 2026), with where the
original lives and how to bring it back. **Update this file in the same commit as every new closure,
and tick an item off (move it to "Brought back") in the commit that reopens it.**

Remember: deleting or moving a file out of `Content/sql` does not remove what it already put in the
database, and copying a file back does nothing until it is imported (then `clearcache weenie`).

## World content closed

| What | WCID | How it is closed | Original | Planned return |
|---|---|---|---|---|
| Fargon (Void/Rending imbue vendor) | 600000 | Placement removed from Marketplace landblock | `originals/landblocks/01C9.sql` | Undecided |
| Empyrean Storage Vault | 600036 | Placement removed from Marketplace landblock | `originals/landblocks/01C9.sql` | Stage 3 or 4 (undecided) |
| Bounty Collector | 3000381 | Placement removed from Marketplace landblock | `originals/landblocks/01C9.sql` | Undecided |
| Artemis (mercenary vendor: 7 Mercenary Essences for 250 Promissory Notes a week) | 490530 | Placement removed from Marketplace landblock | `originals/landblocks/01C9.sql` | Undecided |
| Bounty Purchase Token | 60000213 | Removed from Darkbeat's shop | `originals/weenies/Arena Patch/480480 Darkbeat.sql` | With the Bounty Collector |
| Writ of Pursuit | 60000215 | Removed from Darkbeat's shop | `originals/weenies/Arena Patch/480480 Darkbeat.sql` | With the Bounty Collector |
| Hot Air Balloon at Peddler's Outpost (Energy Infused Rock → island) | 490150 | Says it is grounded; no longer takes the rock or flies | `originals/weenies/Peddler's Outpost/490150 Outpost Flying Machine.sql` | Undecided |

To reopen a Marketplace placement, copy just its three lines (INSERT, VALUES, @teleloc comment)
from `originals/landblocks/01C9.sql` back into `Content/sql/landblocks/01C9.sql`, or the stage
folder that reopens it, rather than the whole file.

## Loot held back

| What | Where | Original | Planned return |
|---|---|---|---|
| Darkbeat's Storage Locker (480607) non-currency picks: all 14 Foolproof rows, Essence of Power, Luminance Exchange Token, Duped Gem of Greater Luminance, Viridian Rise Deru Portal Sending Gem, Hera's Vault Key, Experience Certificate, Water of Enlightenment, Darkbeat's Drawing | Removed from the locker's pick list (in progress on `loot-stage1`) | Full list: `stage2/weenies/Arena Patch/480607 Darkbeat's Storage Locker.sql` | Stage 2 |
| Random loot above Tier 6 (Epics, Legendaries, armor ratings, custom T9) | Server settings `loot_max_tier 6`, `loot_disable_ratings false` | Settings, not files | Stages 2 to 4 and later (see README) |

## Systems switched off by setting

| What | Setting now | Bring back by |
|---|---|---|
| Arena rewards (XP, luminance, items for wins, losses, draws) | `arenas_disable_rewards true` | Loot Editor [Arena] tab first, then `modifybool arenas_disable_rewards false` |

## Open decisions

- Shimmering Skeleton Key (30258) still drops from the Empyrean Cache (0.1%) and the Rare/Mythic Mystery Boxes, but has no use while the Empyrean Storage Vault is closed. Hold it back or leave it?

## Brought back

(nothing yet)
