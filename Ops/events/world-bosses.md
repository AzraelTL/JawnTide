# World bosses

The world bosses are in two groups, each with its own switch (a live setting, no restart):

* `disable_world_bosses` (default true) covers Bael'Zharon, Martine, the Olthoi King, Aerbax and the Tusker Queen. Turn them on with `@modifybool disable_world_bosses false`.
* `disable_low_level_world_bosses` (default true) covers Moloch, Khaz' and Death. Turn them on with `@modifybool disable_low_level_world_bosses false`.

While either group is on, the manager spawns one boss at a time, every 3 to 11 hours, picked only from the groups that are on. 60% of picks are an indoor boss with a statue and 40% a roaming town boss; when the groups that are on have only one kind (for example only the low-level group, which is all town bosses), it always picks that kind.
`@worldbossspawn <wcid>` spawns that boss right away, even when its group is switched off; with no wcid it picks from the groups that are on, or from every boss when both are off. `@worldbossinfo` shows the active boss.

| Boss | WCID | Kind | Balanced for | Token (9 drop) | Loot generator | Turn-in timer |
|---|---|---|---|---|---|---|
| Bael'Zharon | 490011 | Town | Level cap | Blood of the Hopeslayer 490029 | 490073 | WorldBossCompleted |
| Martine | 490039 | Town | Level cap | Martine's Tattered Cloak 490028 | 490072 | WorldBossCompleted2 |
| Olthoi King | 490010 | Town | Level cap | Olthoi King Claw 490030 | 490074 | WorldBossCompleted3 |
| Moloch (Drudge Warlord) | 520200 | Town | Levels 100-120 | Moloch's Fang 520201 | 520202 | WorldBossCompleted4 |
| Khaz' (Lugian Titan) | 520210 | Town | Levels 100-120 | Khaz's Knucklebone 520211 | 520212 | WorldBossCompleted5 |
| Death (Umbris Shadow) | 520220 | Town | Levels 100-120 | Death's Shroud 520221 | 520222 | WorldBossCompleted6 |
| Aerbax | 49009000 | Indoor | | | | |
| Tusker Queen | 49009300 | Indoor | | | | |

The town bosses all work the same way:

* Only red (PK) players and their own attacks can hurt them.
* There's no corpse. The loot generator scatters 9 tokens, 9 Darkbeat's Lost Storage Keys and 10 piles of treasure (profile 10025).
* Every player in the landblock gets 5 PK Trophies. XpOverride is 400,000,000.
* Only PKs can pick up tokens, and each pickup has a 3-minute timer per character. On top of that, one IP address can pick up at most `world_boss_tokens_per_ip` tokens (default 2, 0 = no limit) per world boss kill; the count resets when the next world boss dies. Admins are exempt, and re-picking a token already counted does not count again.
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
