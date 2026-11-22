/* JawnTide Stage 2: Blazing Heart (spell 3204) is back to +50 maximum health (world update 2026-11-22-00-Blazing-Heart-50-Health.sql).
   Raises the Blazing Heart already active on players and items from the Stage 1 amount, since an active spell keeps the
   amount it was cast with. Runs at server start, before anyone logs in. Safe to re-run. */
UPDATE `biota_properties_enchantment_registry` SET `stat_Mod_Value` = 50 WHERE `spell_Id` = 3204 AND `stat_Mod_Value` = 30;
