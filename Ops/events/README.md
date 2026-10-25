# Live events: the event boss

An admin plays the boss. Everything is driven by two admin commands, `@eventboss` and `/minions`, plus settings.

## One-time setup

1. Make a **dedicated boss character** on the admin account (normal character creation; name it after the boss,
   e.g. "Sinister Shadow"). `@eventboss on` rewrites every skill and attribute on whatever character uses it, permanently.
   Strength is tuned with `event_boss_skill_ranks` and `event_boss_attribute_ranks` (100 each suits a level 100 boss
   that players around level 50-126 can hit; 226 and 190 is fully maxed). Change them, then `@eventboss on` again.
2. Its look: `@eventboss on`/`make` gives the character a creature body from the `event_boss_look_*` settings (default:
   the Sinister Shadow), saved on the character; gear is not drawn over it while it is the boss. Use a **human male**
   character (it already has the body the Shadow uses). Other players see it right away; your own screen after a relog.
3. Reward boxes are opened by **Aidoneus** (490076), the same NPC who takes world boss drops, so nothing needs placing.

## Permanent boss characters

`@eventboss make` on a boss character makes it permanent. To run an event: log it in, get into position, and type
**`/startevent`** (stats re-applied, size, no +, Shadow look, announcement). **`/endevent`** stops it without rewards,
and logging out also ends it. `@eventboss unmake` turns it back into an ordinary character (its stats stay);
`@eventboss list` shows the permanent boss characters. Only one event boss can be active at a time.

When the boss dies it keeps all its buffs and gets no vitae; it wakes at its lifestone and the event is over (rewards
handed out). Type `/startevent` again to start the next fight.

## Boss weapons

Boss-only weapons with no wield requirements, attuned and bonded (never traded, dropped or sold; nothing sells or drops
them). Create them on the boss character with `@ci`:

| WCID | Weapon | Notes |
|---|---|---|
| 520110 | Shadow Reaver | Weeping Two Handed Spear +10% in a two-handed sword shape: 52 slash, offense 1.35, defense 1.30, Bael'Zharon's Hate (human slayer 3.74x), ignores armor and shields, Moderate Two Handed Aptitude |
| 520111 | Shadow Wand | Weeping Wand +10%: defense 1.1, mana conversion +2.2%, human slayer 1.54x, Slash Rending, Life and War Mastery Other VI, Focus and Willpower Self VI, Moderate Mana Conversion Prowess |
| 520112 | Shadow Longbow | Weeping Bow +10%: damage 29, modifier 2.40, offense 1.1, defense 1.30, human slayer 3.19x, ignores armor and shields, Slash Rending, Moderate Missile Aptitude; needs arrows (`@ci` any stock arrows) |

Bael'Zharon's Hate makes them human slayers: every player character counts as human, so they hit players very hard.

Tune them by editing their files in `Content/sql/weenies/Live Events/` (then import + restart).

## Running an event

| Step | Command | What happens |
|---|---|---|
| Go to the arena of your choice | `@teleloc ...` | Outdoors works best (minions and boxes spawn in a ring) |
| Start | `@eventboss on` | Every skill specialized with `event_boss_skill_ranks` ranks, attributes 100 innate + `event_boss_attribute_ranks` ranks, health `event_boss_health`, stamina and mana `event_boss_mana`, every spell learned, no spell components, size `event_boss_scale`, full heal, server-wide announcement (and the world boss Discord webhook); an admin boss shows without the + in its name and with a normal radar dot while the event runs |
| Relog | log out and back in | Right after `@eventboss on`: the client needs a fresh login to pick up thousands of new spells and the new skills; without it, wielding or moving items can get stuck |
| Call helpers | `/minions` | `event_boss_minion_count` Shadow Minions (520101, level 80, no XP; each drops one Shadow Essence) in a ring around you. They attack players and never you. Cooldown `event_boss_summon_cooldown_seconds`; they vanish after `event_boss_minion_lifespan_seconds` or when the event ends |
| Fight | | You melee and cast like any character |
| Boss dies | automatic | Announcement; every player in the landblock gets `event_boss_participation_trophies` PK Trophies; the top damager gets **Corpse of <boss>** filled from loot profile `event_boss_corpse_treasure` that only they (and their loot-sharing fellowship) can open for `event_boss_corpse_minutes`; `event_boss_reward_boxes` Shadow Spoils Boxes (520102) scatter at random around the body (2 to `event_boss_reward_box_radius` meters); each character can pick up **one box every 4 hours** (quest `EventBossBoxPickup`, `Content/sql/quests/Shadow Spoils Box.sql`); minions vanish; the boss goes to its lifestone with no vitae and loses nothing |
| Cancel without rewards | `@eventboss off` | Minions vanish, size back to normal |
| Check | `@eventboss status` | |

Shadow Essences (520120, stackable, attuned and bonded) drop from minions; Aidoneus trades **10 for a Hera's Vault Key**.

Players hand Shadow Spoils Boxes to Aidoneus for a roll on `EventBoss_random_reward` (its own table, copied from his
world boss table at first). **Tune that table in the Loot Editor (Loot > NPC rewards) before the first live event**: nine boxes per kill.

## Settings (all live with @modifylong / @modifydouble, no restart)

| Setting | Default |
|---|---|
| event_boss_level (shown on appraisal; strength comes from the ranks) | 100 |
| event_boss_look_setup / _clothing_base / _palette_base / _palette_template / _shade (double) | the Sinister Shadow: 0x02000001 / 0x100000B0 / 0x0400007E / 39 / 0.5 (clothing_base 0 = own look) |
| event_boss_skill_ranks (every skill specialized; 226 = max) | 100 |
| event_boss_attribute_ranks (on top of 100 innate; 190 = max) | 100 |
| event_boss_health | 20000 |
| event_boss_mana (stamina and mana) | 10000 |
| event_boss_scale (double) | 2.0 |
| event_boss_participation_trophies | 5 |
| event_boss_corpse_treasure | 10001 (World Boss Loot Profile; random loot still capped by loot_max_tier) |
| event_boss_corpse_minutes | 30 |
| event_boss_reward_boxes | 9 |
| event_boss_reward_box_radius (meters) | 8 |
| event_boss_reward_box_wcid | 520102 |
| event_boss_minion_wcid | 520101 |
| event_boss_minion_count | 9 |
| event_boss_minion_lifespan_seconds | 300 |
| event_boss_summon_cooldown_seconds | 120 |

## Notes

- Only one event boss at a time. The boss state is in memory: a server restart ends the event (no rewards), so run
  `@eventboss on` again after a restart. The skills, attributes and level it sets are saved on the character like any
  other change (every few minutes and on logout), so stop the server only after the boss has logged out.
- The boss counts as a player, so players need to be able to attack it (JawnTide is a red server; check PK status if not).
- More boss types later: each can drop its own box weenie, with its own `Refuse` emote and random table on Aidoneus.
- Boss looks: a different look is a different dedicated character; different strength is different settings
  (health, minion creature and count, loot profile).
