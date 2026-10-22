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
| Hot Air Balloon at Peddler's Outpost (Energy Infused Rock → island) | 490150 | Says it is grounded; no longer takes the rock or flies. The other way to the island, the Empyrean Compass (490322), is held back from Hera, its only source | `originals/weenies/Peddler's Outpost/490150 Outpost Flying Machine.sql` | Undecided |

To reopen a Marketplace placement, copy just its three lines (INSERT, VALUES, @teleloc comment)
from `originals/landblocks/01C9.sql` back into `Content/sql/landblocks/01C9.sql`, or the stage
folder that reopens it, rather than the whole file.

## Loot held back

| What | Where | Original | Planned return |
|---|---|---|---|
| Darkbeat's Storage Locker (480607): Stage 1 keeps only Trade Note 250,000 x1 (53.192%), PK Trophy x20 (19.149%), Black Market Gem of Dispelling x5 (15.957%), Hera's Vault Key (5.319%), Phial of Bloody Tears x1 (5.319%), Darkbeat's Drawing x1 (1.064%, lowered from 7% after JawnTest: Thorsten's PK quests hand out many locker keys, and each Drawing buys a box of augmentation gems from Anti Parazi). Held back: all 14 Foolproof rows, Promissory Note, Infused Amber Shard, Corrupted Amber Shard, Gauntlet Coin, A Box, Essence of Power, Luminance Exchange Token, Duped Gem of Greater Luminance, Viridian Rise Deru Portal Sending Gem, Experience Certificate, Water of Enlightenment | Pick list cut and re-weighted. Its random loot also uses its own Stage 1 profile, 10007 (`Content/sql/patches/10007 Darkbeats Storage Locker Stage 1 Loot Profile.sql`), instead of 10000, which the Exquisite Casino Chest keeps using; the stage2 file points back to 10000 | Full pre-launch list: `stage2/weenies/Arena Patch/480607 Darkbeat's Storage Locker.sql`. Copying it over Content restores the original chances and stacks too (Trade Note x25 at 5%, PK Trophy 13%, Black Market Gem 4%, and so on), so adjust in the Loot Editor first if Stage 2 should differ | Stage 2 |
| Hera (490320) `random_reward`: Stage 1 keeps Darkbeat's Lost Storage Key (47.245%), PK Trophy x5 (15.748%, was x50), Draught of Revitalization x5 (7.874%, was x25), Light Infused Healing Kit 43478 x5 (7.874%), Hera's Vault Key (7.087%) and the six stat Morph Gems (2.362% each). Held back: Empyrean Compass (490322, teleports to the Island Outpost, so it stays out while the island is closed), Balloon Instruction Manual, Water of Enlightenment, Quest Weapon Coin, Imbue Swap Coin, Light Infused Healing Kit 43479, Outpost Trade Token, Empyrean Jeweler's Sawblade, Ancient Empyrean Tool, Impenetrability Morph Gem | Reward table cut and re-weighted (on `loot-stage1`) | `stage2/weenies/lumcasinopatch/490320 Hera.sql` (original chances and stacks) | Stage 2; the Empyrean Compass and Balloon Instruction Manual only with the island |
| Aidoneus (490076) `WorldBoss_random_reward`: Stage 1 keeps Darkbeat's Lost Storage Key x5 (35.582%, was x10), PK Trophy x25 (35.587%, was x150), Phial of Bloody Tears x5 (28.467%, was x25), and Band of Thought, Oil of the Elements, Ring of the Heart, Bracelet of Dexterity, Potion of Resistance, Empyrean Tailoring Scissors, Ring of Protection (0.052% each). Held back: Ancient Bottle, Gem of Vitality, Gem of Damage Enhancement, Creature Slaying Enhancement Morph Gem, Creature Resistance Enhancement Morph Gem, Rare Gem of Critical Damage Reduction, Rare Gem of Critical Damage, Gem of Damage Protection, Durable Empyrean Forging Hammer, Gem of Overpower. His fixed reward per world boss (2 keys, 40 Trade Notes, 100 PK Trophies, 5 Phials) is unchanged | Reward table cut and re-weighted (on `loot-stage1`) | `stage2/weenies/World Bosses/490076 Aidoneus.sql` (original chances and stacks) | Stage 2 |
| Mystery Boxes (from A Box 510000, which gives Common 60%, Rare 25%, Mythic 5%, A Dick 10%): every item held back elsewhere for Stage 1 removed, the rest rescaled to keep their shares of each other. Common (510002) lost Water of Enlightenment x5, Duped Gem of Greater Luminance x20, Experience Certificate x5, Luminance Exchange Token (14% of the box). Rare (510003) lost Water of Enlightenment x15 and x25, Duped Gem x50, Luminance Exchange Token x20, Ancient Empyrean Tool, Empyrean Jeweler's Sawblade, Ancient Bottle, both Creature Enhancement Morph Gems, Gem of Vitality, both Rare Gems of Critical Damage (48% of the box). Mythic (510004) lost Water of Enlightenment x40, Gem of Overpower, Gem of Damage Enhancement, Gem of Damage Protection, Durable Empyrean Forging Hammer, both Rare Gems of Critical Damage, both Creature Enhancement Morph Gems, Gem of Vitality (43% of the box). Also removed from all three boxes after a JawnTest review: Luminous Crystal of Rare Armor Damage Boost V x25 and of Rare Damage Reduction V x25, Vial of Dragons Tears, Creature Resistance Morph Gem, Rare Damage Boost Morph Gem, Rare Damage Reduction Morph Gem, Gem of Overpower Resist, and Potion of Polishing (Epic to Legendary spells; the Mythic box was its only source, so it is now unobtainable until it returns). Empyrean Tuning Fork removed from the Rare box too (it rerolls and can add Legendary cantrips). Empyrean Forging Hammer removed from the Rare box too (in the Loot Editor). Side effect: the remaining rewards are more likely, including the box-in-box chances (Rare Mystery Box from a Common now 13.9%, was 10.5%; Mythic from a Rare now 9.4%, was 3.2%). Other sources not changed: the Luminous Crystals (Nalicana and the Boxed Rare Damage Boost/Reduction items), the Rare Damage Boost/Reduction Morph Gems (the T9 dungeon bosses Li Fanli, Itala the Knife, Torgrym the Magnificent, Adroth Salson, Den-Ru Chang). Luminance Exchange Tokens are still sold by the three Town Treasurers (Boxed Luminance Exchange Token) | Rewards removed from the boxes' Use scripts (editable in the Loot Editor as [Box] entries) | `stage2/weenies/LootBoxes/` (510003 and 510004 there are already without the Shimmering Skeleton Key, which is permanent; A Box 510000 and the Outpost Supply Crate are saved there and in `stage2/weenies/Peddler's Outpost/` unchanged) | Stage 2 |
| World-boss jewelry Band of Thought (490001), Ring of the Heart (490003), Bracelet of Dexterity (490048), from the Mythic Mystery Box and Aidoneus: their two Legendary cantrips each replaced with the Major version (Band: Legendary Focus/Willpower to Major; Ring: Legendary Strength/Endurance to Major; Bracelet: Legendary Quickness/Coordination to Major). Items made during Stage 1 keep their Majors | Spell book edited in place (same WCIDs) | `stage2/weenies/World Bosses/` (Legendary versions) | Stage 2 or later, with Legendaries in loot |
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

## Permanent changes (not coming back)

| What | Change | Original |
|---|---|---|
| Shimmering Skeleton Key (30258) | Only drops as a stock Tier 3 rare from the loot system (`LootGenerationFactory_Rare.cs`). Removed from the Rare Mystery Box (510003, was 5%) and the Mythic Mystery Box (510004, two entries, was 8%); their other rewards keep the same share of each other. Its Empyrean Cache source is off with Dungeon Control and should be removed before Dungeon Control returns | `originals/weenies/LootBoxes/510003 RareMysteryBox.sql`, `originals/weenies/LootBoxes/510004 MythicMysteryBox.sql` |

## Open decisions

(none)

## Brought back

(nothing yet)
