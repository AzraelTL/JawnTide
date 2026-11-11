-- JawnTide: Blazing Heart (spell 3204: Burning Coals, the Blazing Heart Morph Gem, Salvaged Obsidian) adds 30 maximum health
-- instead of 50. Only the amount changes, so it still doesn't stack with Essence Glutton or other spells of its kind.
-- Blazing Heart already on players is lowered by 2026-11-19-00-Blazing-Heart-30-Health.sql (shard). Safe to re-run.
UPDATE `spell` SET `stat_Mod_Val` = 30 WHERE `id` = 3204;
