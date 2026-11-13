/* JawnTide Target Drudge: every session also saves, for each weapon or spell used, its stats (skill, weapon type,
   attack type, imbue, damage, variance, speed, mods, crit, slayer, cantrips, buffs on it, ammo or caster, the attacker's
   skill) and its results (attacks, hits, misses, crits, damage, min, max, average, damage types), as JSON.
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

ALTER TABLE `training_dummy_session` ADD COLUMN IF NOT EXISTS `sources_json` MEDIUMTEXT NULL;
