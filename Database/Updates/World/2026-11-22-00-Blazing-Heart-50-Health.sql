-- JawnTide Stage 2: Blazing Heart (spell 3204: Burning Coals, the Blazing Heart Morph Gem, Salvaged Obsidian) is back to
-- +50 maximum health (it was lowered to +30 for Stage 1 by 2026-11-19-01-Blazing-Heart-30-Health.sql).
-- Blazing Heart already on players and items is raised by 2026-11-22-00-Blazing-Heart-50-Health.sql (shard). Safe to re-run.
UPDATE `spell` SET `stat_Mod_Val` = 50 WHERE `id` = 3204;
