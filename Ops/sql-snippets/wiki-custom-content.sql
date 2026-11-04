-- Writes the JawnTide custom-content wiki articles straight into ace_wiki (adds or replaces the current version; old versions stay in history).
USE ace_wiki;
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('jawntide', 'JawnTide', 'JawnTide is a red Asheron''s Call server running on ACEmulator, forked from DocTide. Everyone is a player killer.

## Connecting
1. Install Asheron''s Call (the end-of-retail client). The guide at [emulator.ac](https://emulator.ac) covers the installer and patch.
2. Install ThwargLauncher from [thwargle.com](https://thwargle.com).
3. Add a server: name **JawnTide**, address `play.jawntide.com`, port `9000`, emulator type ACE.
4. Pick an account name and password. The account is made the first time you log in.

## The basics
| Topic | How it works |
|---|---|
| PvP | Everyone is red. Die to another player and you turn white for a few minutes (the PK respite timer), then you''re red again. |
| Accounts | Up to 2 accounts logged in at a time per person. |
| Connections | No VPNs or proxies. |
| Loot | Loot comes in stages. See [[Loot stages]]. |

## Custom content
- [[World bosses]]: roaming town bosses that drop tokens for [[Aidoneus]].
- [[Event boss]]: live events where an admin plays the boss.
- [[Town Control]]: allegiances fight to own towns.
- [[Arena]]: queued 1v1, 2v2 and free-for-all matches.
- [[JawnTanks]]: the browser tank game.
- [[Bounties]]: hunt marked players, or post a reward on someone.
- [[PK quests]]: daily PvP tasks from Thorsten.
- [[Peddler''s Outpost]]: the custom island outpost.
- [[Mercenaries]]: summonable fighters from Artemis.
- [[Tinker characters]]: one crafting-only character per account.
- [[Allegiance limits]]: caps on allegiance size in some areas.
- [[Bank]] and [[My Mule]]: account-wide storage.
- [[Player commands]]: every custom command.

> New to the wiki? See [[Editing the wiki]].
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('jawntide', 'JawnTide', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('bounties', 'Bounties', 'Hunt marked players for the Bounty Collector, or put a price on someone''s head yourself.

## Who can be a target
A player can only be picked as a bounty target if they are:
- level 150 or higher,
- in an allegiance that''s enabled for [[Town Control]],
- red (not on PK respite), and
- on the Mountain Retreat or the Peddler''s Outpost island, dungeons included.

Players on a kill streak above 4, or with a Writ of Pursuit posted on them, are more likely to be picked.

## Getting a contract
Give the Bounty Collector a **Bounty Purchase Token** and he hands you a Bounty Contract for a target. You must be in an enabled allegiance yourself.

| Rule | Value |
|---|---|
| Contracts you can hold | 3 |
| Time to finish a contract | 60 minutes |
| Target''s protection after being collected on | 30 minutes |

## Finding your target
Use the contract to see where the target was last seen. Each use costs **25 PK Trophies**, and you have to wait 30 seconds between uses.

## Turning in
Kill your target, then hand the completed contract back to the Bounty Collector. If someone posted a Writ of Pursuit on the target, you also get its phials and the whole server is told. Contracts that run out of time can be handed back for 1 Phial of Bloody Tears.

## Writ of Pursuit
Post your own reward on a player:
1. Inscribe a Writ of Pursuit with `name:amount`, where the amount is in Phials of Bloody Tears. Example: `Ra''s Al Ghul:10`.
2. Give the writ to the Bounty Collector with that many phials in your pack.

You can''t target yourself or someone in your own allegiance. That player becomes a **high priority** target, and whoever turns in a bounty on them gets the phials.

Bounty kills also count toward [[PK quests]].
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('bounties', 'Bounties', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('pk-quests', 'PK quests', 'Daily PvP tasks with luminance, XP and item rewards. Talk to **Thorsten** on the Mountain Retreat to get them.

## How it works
- Using Thorsten shows your active quests and progress, pays out anything you''ve finished, and gives you any quests you don''t have yet.
- Once a quest is finished and paid out, Thorsten gives it to you again the next day.
- Kill quests only count kills on members of **other allegiances that are enabled for [[Town Control]]**.

## Quest types
| Kind | Examples |
|---|---|
| [[Arena]] | Take part in or win 1v1, 2v2, FFA, Tugak War and Group matches; place top 3; deal damage or heal during matches |
| PvP kills | Kill enemy allegiance members anywhere, or 3 at a time in Town Network, Subway, the Peddler''s Outpost lifestone and the island dungeons |
| [[Town Control]] | Kill 1, 5 or 30 enemies during a Town Control conflict |
| [[Bounties]] | Turn in bounty contracts |

## Rewards
Rewards scale with how hard the quest is and can include luminance, a percentage of the XP to your next level, Darkbeat Keys, Phials of Bloody Tears, PK Trophies, boxes, Hera''s Vault Keys and Radiant Amber Crystals. Thorsten tells you each quest''s reward when he gives it to you.
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('pk-quests', 'PK quests', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('player-commands', 'Player commands', 'Commands added on JawnTide on top of the normal ACE ones.

| Command | What it does |
|---|---|
| `/bank` | Your account bank. See [[Bank]] |
| `/mule` | Your account mule. See [[My Mule]] |
| `/arena` | Arena queues and stats. See [[Arena]] |
| `/town-owners` | Who owns each town. See [[Town Control]] |
| `/town-control-respite TOWN` | When your allegiance can attack a town again |
| `/buyrename NAME` | Rename your character. The first rename is free, the second costs 200 PK Trophies, and after that the price keeps rising, up to 20,000 |
| `/buytitle TITLE` | Give your character a custom title for 200 PK Trophies (32 characters max) |
| `/spendallxp` | Spend all your unspent XP on attributes, vitals and skills |
| `/flagtinker` | Make a level 1 character a Tinker. See [[Tinker characters]] |
| `/OfflineSwear NAME` | Swear allegiance to an offline character on your own account |
| `/ForceLogoffStuckCharacter NAME` | Log off a stuck character on your own account |
| `/fixinvisible` or `/fi` | Resend nearby monsters and NPCs if some are invisible |
| `/objsend` | Resend everything you can see, for rare invisible-object bugs |
| `/wiki CODE` | Link your account to the wiki (the code is shown on the wiki) |
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('player-commands', 'Player commands', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('tinker-characters', 'Tinker characters', 'Each account can have one dedicated Tinker: a crafting-only character.

## Making one
Log in a **level 1** character and type `/flagtinker`. Your account can''t already have a Tinker. **This can''t be undone.**

## What changes
- All crafting skills are specialized and maxed.
- All offensive combat skills are removed.
- Strength, Endurance, Coordination and Focus are raised to 100 innate, and all attributes are maxed.
- The character stays level 1: it earns no XP and can''t train or specialize new skills.
- No vitae penalty on death.

Using `/flagtinker` again on your Tinker refreshes it and upgrades its Tinkering Trinket.
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('tinker-characters', 'Tinker characters', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('allegiance-limits', 'Allegiance limits', 'Some areas cap how many players from one allegiance can be inside at the same time, so big groups can''t zerg them.

| Area | Max per allegiance |
|---|---|
| [[Town Control]] towns (Holtburg, Yaraq, Shoushi) | 9 |
| Drudge Stronghold, Dragon''s Den | 9 |
| Ancient Temple, Mite Hole, Shreth Caverns | 14 |
| Halls of Metos, Black Spawn Den | 9 |
| Mountain Citadel | 14 |
| Aerbax [[World bosses|world boss]] | 7 |
| Tusker Queen [[World bosses|world boss]] | 5 |
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('allegiance-limits', 'Allegiance limits', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('mercenaries', 'Mercenaries', 'Artemis sells mercenary essences for Promissory Notes. Shiyama the Currency Exchanger at [[Peddler''s Outpost]] trades other currencies for Promissory Notes. Use an essence to summon your mercenary, and use it again to send the mercenary away.

## Mercenaries for sale
- Virindi
- Void Lord
- Acid
- Fire
- Lightning
- Frost
- Tusker
- Olthoi
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('mercenaries', 'Mercenaries', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
INSERT INTO revision (slug, title, body, summary, user_id) VALUES ('peddler-s-outpost', 'Peddler''s Outpost', 'A custom island outpost with its own town, hunters, collectors, shops and dungeons. The whole island counts as a [[Bounties|bounty]] area, and kills there count toward [[PK quests]].

## Kill tasks
Ask the hunter for the task, kill the creatures, then talk to them again. Each task can be done **once every 20 hours**.

| NPC | Task | Where |
|---|---|---|
| Xing the Wasp Hunter | Kill 100 Mythic Wasps | Around the island |
| Mao the Mite Hunter | Kill 100 Rabid Mites | Mite Hole |
| Aria the Shreth Slayer | Kill 100 Maniacal Shreths | Shreth Caverns |
| Lee the Sleech Hunter | Kill 15 Colossal Sleeches | Around the island |

**Reward:** 1 billion XP, 50,000 luminance and an Outpost Supply Crate (see below).

## Trophy turn-ins
Each turn-in can be done **once every 20 hours**. Unless the table says otherwise, the reward is **50,000 luminance, 50% of the XP to your next level (up to 5 billion) and an Outpost Supply Crate**.

| NPC | Bring |
|---|---|
| General Titus | Drudge Commander''s head |
| General Titus | 10 Drudge Maurader Guts |
| General Titus | 10 Drudge Aviator Compasses |
| General Titus | Drudge Battle Plans (found in the Drudge Stronghold) |
| Xang Shou the Rat Collector | 10 Ravenous Rat Tails (from the Rat Nest) |
| Xang Shou the Rat Collector | Razor Tooth''s Fang |
| Helios | An Island Dragon Hide |
| Helios | 10 Island Dragon Eggs |
| Helios | 10 Island Dragon Wings |

## Collectors (no timer)
| NPC | Takes | Pays |
|---|---|---|
| Xing the Wasp Hunter | Phyntos wasp wings (red, green, blue, mire, gold, jungle, white) | XP plus pyreals, or a 10,000 trade note for white wings |
| Xing the Wasp Hunter | Gromnie wings (rust, azure, ivory, ash) | A matching piece of winged armor plus XP |
| Xing the Wasp Hunter | Mythic Wasp Wing | 2,000 to 20,000 luminance, depending on its quality |
| Mao the Mite Hunter | Rabid Mite Head | 2,000 to 20,000 luminance, depending on its size |
| Aria the Shreth Slayer | Maniacal Shreth Hide | 2,000 to 20,000 luminance, depending on its size |

## Outpost Supply Crate
Open it for one of these:
- Outpost Trade Token
- Darkbeat''s Storage Locker key
- Ancient Empyrean Tool (your next tinker can''t fail; breaks after one use)
- Empyrean Jeweler''s Sawblade (chance to let a ring, bracelet or necklace go in a different slot)
- Pet Island Dragon egg (summons a pet dragon; hand it a PK Trophy to clear your vitae)
- Infinite Black Luster Pearl
- Infinite Platinum Spirit

## Shops and exchangers
| NPC | Takes | Sells / does |
|---|---|---|
| General Store | Outpost Trade Tokens | Crates of salvage, spell components, Dragon Scale arrows, quarrels and darts, Black Luster Pearls, potions, spirits, salted meats, Black Market Gems of Dispelling, healing supplies and Black Pages of Salt and Ash |
| Master Ulenor the Archmage | Pyreals | Spell components, mana charges, mage robes and tinkering supplies |
| Outpost Fletcher | Pyreals | Bows, crossbows, atlatls and ammo |
| Jalam the Salvager | Pyreals | Trade notes |
| Shiyama the Currency Exchanger | Colosseum Coins (5 each), Small Olthoi Venom Sacs (2), Ornate Gear Markers (2), Ancient Mhoire Coins (1), A''nekshay Tokens (½) | Promissory Notes. Hand over 10 or 100 at a time |
| Foolproof Exchanger | 2 PK Trophies, then a bag of foolproof salvage | A random new bag of foolproof salvage |

## The sewers
Use the Outpost Sewer to drop down to **Adrian the Smuggler**, who sells boxed Darkbeat''s Lost Storage Keys and rare quest trophies for Phials of Bloody Tears. You need at least 4 enlightenments to enter.

## Island dungeons
| Dungeon | Notes |
|---|---|
| Drudge Stronghold | Opens for everyone when someone kills the Drudge Commander. A Drudge Slave inside can lead you out a secret exit |
| Dragon''s Den | Home of the Island Dragons. A loose rock inside opens a short-lived exit |
| Mite Hole | Rabid Mites for Mao''s task |
| Shreth Caverns | Maniacal Shreths for Aria''s task |
| Rat Nest | Ravenous Rats and Razor Tooth |
| Ancient Temple | Ancient Golems |

Several of these have [[Allegiance limits]]. The Mythic Wasp Queen also roams the island.
', 'Custom content update', NULL);
INSERT INTO page (slug, title, current_rev) VALUES ('peddler-s-outpost', 'Peddler''s Outpost', LAST_INSERT_ID()) ON DUPLICATE KEY UPDATE title=VALUES(title), current_rev=VALUES(current_rev), updated_at=UTC_TIMESTAMP();
SELECT slug, current_rev FROM page ORDER BY slug;
