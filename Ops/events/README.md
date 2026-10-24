# Live events: the event boss

An admin plays the boss. Everything is driven by two admin commands, `@eventboss` and `/minions`, plus settings.

## One-time setup

1. Make a **dedicated boss character** on the admin account (normal character creation; name it after the boss,
   e.g. "Sinister Shadow"). `@eventboss on` rewrites every skill and attribute on whatever character uses it, permanently.
   Strength is tuned with `event_boss_skill_ranks` and `event_boss_attribute_ranks` (100 each suits a level 100 boss
   that players around level 50-126 can hit; 226 and 190 is fully maxed). Change them, then `@eventboss on` again.
2. Dress it for the part (dark armor or robes). Players see your character scaled up while the event runs.
3. Place the **Shadow Warden** (520103), who opens the reward boxes, where players can reach him after the fight:
   `@create 520103` spawns him in front of you until the next restart. For a permanent spot, add him to a landblock file.

## Running an event

| Step | Command | What happens |
|---|---|---|
| Go to the arena of your choice | `@teleloc ...` | Outdoors works best (minions and boxes spawn in a ring) |
| Start | `@eventboss on` | Every skill specialized with `event_boss_skill_ranks` ranks, attributes 100 innate + `event_boss_attribute_ranks` ranks, health `event_boss_health`, stamina and mana `event_boss_mana`, every spell learned, no spell components, size `event_boss_scale`, full heal, server-wide announcement (and the world boss Discord webhook) |
| Call helpers | `/minions` | `event_boss_minion_count` Shadow Minions (520101, level 80, no XP, no loot) in a ring around you. They attack players and never you. Cooldown `event_boss_summon_cooldown_seconds`; they vanish after `event_boss_minion_lifespan_seconds` or when the event ends |
| Fight | | You melee and cast like any character |
| Boss dies | automatic | Announcement; every player in the landblock gets `event_boss_participation_trophies` PK Trophies; the top damager gets **Corpse of <boss>** filled from loot profile `event_boss_corpse_treasure` that only they (and their loot-sharing fellowship) can open for `event_boss_corpse_minutes`; `event_boss_reward_boxes` Shadow Spoils Boxes (520102) drop in a ring for anyone to grab; minions vanish; the boss goes to its lifestone with no vitae and loses nothing |
| Cancel without rewards | `@eventboss off` | Minions vanish, size back to normal |
| Check | `@eventboss status` | |

Players hand Shadow Spoils Boxes to the Shadow Warden for a roll on `EventBoss_random_reward` (copied from Aidoneus's
table at first). **Tune that table in the Loot Editor (Loot > NPC rewards) before the first live event**: nine boxes per kill.

## Settings (all live with @modifylong / @modifydouble, no restart)

| Setting | Default |
|---|---|
| event_boss_skill_ranks (every skill specialized; 226 = max) | 100 |
| event_boss_attribute_ranks (on top of 100 innate; 190 = max) | 100 |
| event_boss_health | 20000 |
| event_boss_mana (stamina and mana) | 10000 |
| event_boss_scale (double) | 2.0 |
| event_boss_participation_trophies | 5 |
| event_boss_corpse_treasure | 10001 (World Boss Loot Profile; random loot still capped by loot_max_tier) |
| event_boss_corpse_minutes | 30 |
| event_boss_reward_boxes | 9 |
| event_boss_reward_box_wcid | 520102 |
| event_boss_minion_wcid | 520101 |
| event_boss_minion_count | 9 |
| event_boss_minion_lifespan_seconds | 300 |
| event_boss_summon_cooldown_seconds | 120 |

## Notes

- Only one event boss at a time. The boss state is in memory: a server restart ends the event (no rewards).
- The boss counts as a player, so players need to be able to attack it (JawnTide is a red server; check PK status if not).
- More boss types later: a different look is a different dedicated character; different strength is different settings
  (health, minion creature and count, loot profile).
