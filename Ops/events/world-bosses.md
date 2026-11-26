# World bosses

The world bosses are in three groups, each with its own switch (a live setting, no restart):

* `disable_world_bosses` (default true) covers Bael'Zharon, Martine, the Olthoi King, Goop Scoop, Aerbax and the Tusker Queen. Turn them on with `@modifybool disable_world_bosses false`.
* `disable_low_level_world_bosses` (default true) covers Moloch, Khaz' and Death. Turn them on with `@modifybool disable_low_level_world_bosses false`.
* `disable_mid_level_world_bosses` (default true) covers Xa'thrix, Carbonek and Gorgluuk. Turn them on with `@modifybool disable_mid_level_world_bosses false`.

While either group is on, the manager spawns one boss at a time, every 3 to 11 hours, picked only from the groups that are on. 60% of picks are an indoor boss with a statue and 40% a roaming town boss; when the groups that are on have only one kind (for example only the low-level group, which is all town bosses), it always picks that kind.
`@worldbossspawn <wcid>` spawns that boss right away, even when its group is switched off; with no wcid it picks from the groups that are on, or from every boss when both are off. `@worldbossinfo` shows the active boss.

| Boss | WCID | Kind | Balanced for | Token (9 drop) | Loot generator | Turn-in timer |
|---|---|---|---|---|---|---|
| Bael'Zharon | 490011 | Town | Level cap | Blood of the Hopeslayer 490029 | 490073 | WorldBossCompleted |
| Martine | 490039 | Town | Level cap | Martine's Tattered Cloak 490028 | 490072 | WorldBossCompleted2 |
| Olthoi King | 490010 | Town | Level cap | Olthoi King Claw 490030 | 490074 | WorldBossCompleted3 |
| Goop Scoop (giant Olthoi Larvae) | 520230 | Town | Level cap | Goop Scoop's Ichor 520231 | 520232 | WorldBossCompleted7 |
| Moloch (Drudge Warlord) | 520200 | Town | Levels 100-120 | Moloch's Fang 520201 | 520202 | WorldBossCompleted4 |
| Khaz' (Lugian Titan) | 520210 | Town | Levels 100-120 | Khaz's Knucklebone 520211 | 520212 | WorldBossCompleted5 |
| Death (Umbris Shadow) | 520220 | Town | Levels 100-120 | Death's Shroud 520221 | 520222 | WorldBossCompleted6 |
| Xa'thrix (K'nath Brood Empress) | 520250 | Town | Level 250 | Xa'thrix's Core 520251 | 520252 | WorldBossCompleted8 |
| Carbonek (Diamond Colossus) | 520270 | Town | Level 250 | Carbonek's Heart 520271 | 520272 | WorldBossCompleted9 |
| Gorgluuk (Burun Warking) | 520290 | Town | Level 250 | Gorgluuk's Idol 520291 | 520292 | WorldBossCompleted10 |
| Aerbax | 49009000 | Indoor | | | | |
| Tusker Queen | 49009300 | Indoor | | | | |

The town bosses all work the same way:

* Only red (PK) players and their own attacks can hurt them.
* There's no corpse. The loot generator scatters 9 tokens, 9 Darkbeat's Lost Storage Keys and 10 piles of treasure (profile 10025).
* Every player in the landblock gets 5 PK Trophies. XpOverride is 400,000,000.
* Only PKs can pick up tokens, and each pickup has a 3-minute timer per character. On top of that, one IP address can pick up at most `world_boss_tokens_per_ip` tokens (default 2, 0 = no limit) per world boss kill; the count resets when the next world boss dies. Admins are exempt, and re-picking a token already counted does not count again.
* Right after the spawn message of a town boss (not Aerbax or the Tusker Queen), a second line (in game and in the world boss Discord) hints at the kind of town it spawned at, grouped by Town Network wing: north = Aluvian (Holtburg, Arwic, Cragstone, Glenden Wood, Eastham, Rithwic, Lytelthorpe, Dryreach, Stonehold, Fort Tethena), east = Sho (Shoushi, Yanshi, Sawato, Tou-Tou, Hebian-to, Baishi, Nanto, Lin, Mayoi, Kara, Kryst), west = Gharu'ndim (Zaikhal, Al-Jalima, Samsur, Yaraq, Uziz, Al-Arqas, Xarabydun, Khayyaban, Qalabar); everything else (the south wing, plus Bobo, Bandit Castle, Ayan, Candeth, Fiun) gets "the beast's trail leads to a town accessible from the southern doors of the Town Network". The list is `TownRegions` in `Source/ACE.Server/Entity/WorldBoss/WorldBoss.cs`.
* Once a boss is below 90% health its position is announced every 2 minutes. A town boss dragged into a building or dungeon (no map coordinates) is announced as "near <town> (<town coords>)" for the town it spawned at, instead of "NULL".
* Aidoneus (490076) takes one token of each kind per 20 hours. He gives luminance, level-proportional XP (up to 5 billion), 2 Darkbeat keys, 40 Trade Notes, 100 PK Trophies and 5 Phials of Bloody Tears, plus one roll on `WorldBoss_random_reward`.

## Moloch, Khaz' and Death (Oct 27, 2026)

Same rewards as the three level-cap town bosses. The Aidoneus turn-ins were added to `Content/sql/weenies/World Bosses/490076 Aidoneus.sql` and to its Stage 2 copy in `Ops/loot-stages/stage2/`.
Stats are a first pass, to tune on JawnTest. Effective skill = the init value in the file + the attribute bonus.

| | Moloch | Khaz' | Death |
|---|---|---|---|
| Look | Kerthump the Ear Taker (drudge), scale 4.0 | Lord Kresovus (lugian), scale 3.2 | Umbris Shadow, scale 3.0 |
| Level shown | 150 | 150 | 150 |
| Creature type | Target (76) | EnchantedArms (87) | Apparition (95) |
| Health | 120,000 | 160,000 | 100,000 |
| Attack (effective) | ~457 melee | ~480 melee | ~403 melee, ~445 war/void |
| Melee / magic defense (effective) | ~407 / ~380 | ~370 / ~351 | ~400 / ~420 |
| Element | Blade (slashing) | Bludgeon | Nether, plus fire |
| Melee damage | 75 hand, 60 foot (slashing) | 85 / 70 (bludgeon) | 50 / 40 (nether) |
| Spells | Blade Volley VII, Whirling Blade VII, Blade Arc VII, Blade Vuln VII, Imperil VII | Shock Wave VII, Bludgeoning Volley VII, Bludgeon Vuln VII, Slowness VII | Nether Bolt VII, Nether Arc VII, Curse of Festering VII, Impious Curse (2814), Flame Chain (4096), Fire Vuln VII, Drain Health VII, Harm VII, Fester VII |
| Specials (per boss attack) | Call the Horde 4% (refills dead minions), Squall of Swords 3% (1833, warned 2 s ahead), Blade Ring 5% (warned 2 s ahead) | Shield shifts like the Olthoi King, 3% each: Stone Hide (+900 melee defense), Boulder Wall (+900 missile defense), War Chant (+900 magic defense), Fury (drops all three); Stone Fists 4% (1838, warned 2 s ahead); Shockwave Ring 6% (warned 2 s ahead) | Hellfire 3% (Fire Vuln VII then Flame Chain on its target), Call the Shades 4% (refills dead minions), Nether Ring 6% (warned 2 s ahead) |
| Minions | 6 Ascendant Drudge, 3 Drudge Mystic | 6 Tiatus Lugian, 3 Bokrok Lugian | 5 Shadow Phantom (melee, Flaming Tachi), 4 Shadow Spectre (archers, Deadly Fire Arrows): Death's own copies 520223/520224 that cast only Flame Chain and Impious Curse, all hits fire |

Their creature types are ones no slayer weapon targets, so Drudge, Lugian and Shadow slayers do nothing extra to them (the look comes from the model, not the type). Every special announces itself in local chat. Khaz' shields reuse Aerbax's shield spells (4240-4245), the same ones the Olthoi King uses.
World bosses never dispel players (Death's Unravel special was removed Oct 27). The only dispel left in world boss content is the Aerbax and Tusker Queen entry idols removing rare-item buffs when a player enters.
Like the other town bosses, they ignore players' magic armor and magic resistance buffs (IgnoreMagicArmor and IgnoreMagicResist) and have Overpower 10.
Token looks: Moloch's Fang uses the Ivory Gromnie Tooth (3675) model and icon, Khaz's Knucklebone the Undead Thighbone (7041), and Death's Shroud the Martine's Cloak icon. Each also has its own colored glow (UiEffects): Fang Fire (red), Knucklebone Frost (blue), Shroud Nether (purple). The older tokens have no glow.
When assessed, the bosses show a title under their name (PropertyString Template): Moloch Drudge Lord, Khaz' Lugian Patriarch, Death Shadow Emperor.

## Goop Scoop (Nov 19, 2026)

A level-cap town boss: a copy of the Olthoi King (490010) with the Olthoi Larvae look (35147) at scale 4.0, Aqua palette, title Brood Glutton.
Same stats, armor, resists, spells (Corrosive Strike, Acid Spit Arc 2, Acid Vuln VIII), shield shifts (4240-4245), Heavy Acid Ring special, rewards and loot generator as the Olthoi King.
Token: Goop Scoop's Ichor 520231 (Progenitor's Ichor model, Acid glow), quest GoopScoopsIchor (3 minutes), turn-in timer WorldBossCompleted7, added to both Aidoneus files.

Helpers (21, regenerate on death like the Olthoi King's): each is the stock creature's look with the Royal Olthoi helpers' stats
(level 265, 15,000 health, the Royal Olthoi Ranger's armor, resists, attributes and skills, plus 430 in every magic school, loot 2111).

| WCID | Helper | Look from | Count | Health | Spells |
|---|---|---|---|---|---|
| 520233 | Slimed Maniacal Fiun | 29345 | 3 | 15,000 | Flame Bolt, Whirling Blade, Frost Streak, Lightning Streak, Imperil, Blade Vuln (VIII) |
| 520234 | Slimed Cannibal Fiun | 29507 | 3 | 15,000 | Frost Bolt, Lightning Bolt, Acid Streak, Flame Streak, Imperil, Pierce Vuln (VIII) |
| 520235-520237 | Slimed K'nath N'da, R'ajed, Y'nda | 38009-38011 | 2 each | 15,000 | stock: Shock Wave Streak, Shock Blast, Imperil, Bludgeon Vuln (VIII) |
| 520238-520241 | Slimed Shivering, Corroding, Voltaic, Incalescent Wisp | 40127, 40128, 40129, 40131 | 1 each | 10,000 | their element's Bolt (or Acid Stream), Arc and Vuln (VIII); volleys were swapped for arcs Nov 19 (client crashes reported) |
| 520242 | Slimed Sentient Crystal Shard | 35118 | 1 | 25,000 | stock: heals, debuffs and Vitality Siphon |
| 520243 | Slimed Fire Crystal | 45747 | 2 | 15,000 | Flame Bolt, Flame Streak (VIII) |
| 520244 | Slimed Ice Crystal | 45748 | 2 | 15,000 | Frost Bolt, Frost Streak (VIII) |

All seven town boss tokens use the gift box model the original three always had (Setup 0x02000E74, scale 0.33) since Nov 19; each keeps its own icon, name and glow. Moloch's Fang, Khaz's Knucklebone and Goop Scoop's Ichor used other models before. Tokens already in players' packs keep their old look.

## Xa'thrix, Carbonek and Gorgluuk (Nov 26, 2026)

Mid-level town bosses tuned for level 250, between Moloch's group and the level-cap bosses. Same rewards, loot generator layout, token rules and town spawning as the other town bosses; the Aidoneus turn-ins (WorldBossCompleted8-10) are in both Aidoneus files. Their own switch is `disable_mid_level_world_bosses` (default true). Stats are a first pass, to tune on JawnTest.
Effective skill = the init value in the file + the attribute bonus.

| | Xa'thrix | Carbonek | Gorgluuk |
|---|---|---|---|
| Look | K'nath Mother (38012), scale 4.5 | Diamond Golem Suzerain (19543), scale 3.0 | Morgluuk (27661), scale 3.0 |
| Title | K'nath Brood Empress | Diamond Colossus | Burun Warking |
| Level shown | 250 | 250 | 250 |
| Creature type | Energy (94) | Statue (63) | Harvest (93) |
| Health | 300,000 | 400,000 | 350,000 |
| Attributes | Str/End 520, Quick 440, Coord 500, Focus/Self 460 | same | same |
| Attack (effective) | ~820 melee, ~670 war | same | same |
| Melee / missile / magic defense (effective) | ~533 / ~573 / ~607 | same | same |
| Armor | 550 base | 550 base | 550 base |
| Element | Lightning (melee 110 / 95) | Frost (melee 110 / 95) | Acid (melee 110 / 95) |
| Weak to | Acid (resist 0.85) | Bludgeon (0.8) | Fire (0.85) |
| Spells (Incantation, no volleys) | Lightning Bolt, Arc, Streak, Lightning Vuln, Imperil | Frost Bolt, Arc, Streak, Cold Vuln, Weakness | Acid Stream, Arc, Streak, Acid Vuln, Fester |
| Specials (per boss attack) | Call the Brood 4% (refills minions), Lightning Barrage 3% (1837), Storm Ring 5% (Eye of the Storm 1788) | Shield shifts like Khaz', 3% each: Diamond Hide (melee), Crystal Wall (missile), Prismatic Ward (magic), Fracture (drops all); Call the Constructs 4%; Avalanche 3% (1836); Frost Ring 5% (Halo of Frost 1787) | Call the Warband 4%; Torrential Acid 3% (1832); Acid Ring 5% (3805) |
| Minions (9) | 3 each Brood K'nath B'orret, C'ire, Y'bot (520253-520255) | 2 each Diamondbound Magma, Aqueous, Crystal Golem, 1 each Mud, Sandstone, Platinum (520273-520278) | 3 Warband Burun Savage, 2 each Shaman, Soothsayer, Fiend (520293-520296) |

Minions are the stock creatures (look, creature type, armor shape, attacks) at level 250 strength: 10,000 health (golems 12,000), attributes 360-380, about 700 effective attack, 500 base armor keeping the stock creature's armor ratios, hardest hit 110, stock spells upgraded to their Incantation versions (volleys swapped for arcs), XpOverride 2,000,000 and the Royal Olthoi helpers' loot (2111). They regenerate while the boss lives.
Token looks: the gift box like the other town tokens, with icons from the K'nath Core, the Glacial Golem Heart and the Burun Idol, and glows Lightning, Frost and Acid.
