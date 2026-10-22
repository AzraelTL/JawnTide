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
| Darkbeat's Storage Locker (480607): Stage 1 keeps only Black Market Gem of Dispelling x5 (15%), Trade Note 250,000 x1 (50%), PK Trophy x20 (18%), Darkbeat's Drawing x1 (7%), Hera's Vault Key (5%), Phial of Bloody Tears x1 (5%). Held back: all 14 Foolproof rows, Promissory Note, Infused Amber Shard, Corrupted Amber Shard, Gauntlet Coin, A Box, Essence of Power, Luminance Exchange Token, Duped Gem of Greater Luminance, Viridian Rise Deru Portal Sending Gem, Experience Certificate, Water of Enlightenment | Pick list cut and re-weighted (on `loot-stage1`) | Full pre-launch list: `stage2/weenies/Arena Patch/480607 Darkbeat's Storage Locker.sql`. Copying it over Content restores the original chances and stacks too (Trade Note x25 at 5%, PK Trophy 13%, Black Market Gem 4%, and so on), so adjust in the Loot Editor first if Stage 2 should differ | Stage 2 |
| Random loot above Tier 6 (Epics, Legendaries, armor ratings, custom T9) | Server settings `loot_max_tier 6`, `loot_disable_ratings false` | Settings, not files | Stages 2 to 4 and later (see README) |

## Systems switched off by setting

| What | Setting now | Bring back by |
|---|---|---|
| Arena rewards (XP, luminance, items for wins, losses, draws) | `arenas_disable_rewards true` | Loot Editor [Arena] tab first, then `modifybool arenas_disable_rewards false` |
| Dungeon Control (Shreth Caverns, Ancient Temple, Mite Hole, Halls of Metos, Black Spawn Den) and its reward chest, the Empyrean Cache (514108532) | Switched off in code by the previous dev, not by a setting: `OwnableDungeonMap` in `Source/ACE.Server/Entity/DungeonControl/DungeonControl.cs` and `IsOwnableDungeon` in `Source/ACE.Server/Entity/Landblock.cs` return early | Planned to return after a redesign, not just switched back on (see "Dungeon Control: why it needs a redesign" below). Turning it on is a code change removing both early returns, tested on JawnTest; captures also need the allegiance on the Town Control whitelist. Review the Empyrean Cache contents in the Loot Editor before it returns |

## Dungeon Control: why it needs a redesign

What players found wrong with the old version: an allegiance would capture a dungeon and nobody
challenged it, and allegiances ended up taking turns capturing to collect the rewards (the Empyrean
Cache every few minutes for 8 hours, plus the XP and luminance bonus). There was no real contest,
and players found it boring. A redesign has to make holding a dungeon contested rather than a
rotation of free rewards.

## Open decisions

- Shimmering Skeleton Key (30258) has no use while the Empyrean Storage Vault is closed. Its Empyrean Cache source (0.1%) is already off with Dungeon Control; it still comes from the Rare/Mythic Mystery Boxes. Hold it back there or leave it?

## Brought back

(nothing yet)
