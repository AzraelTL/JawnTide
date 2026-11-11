/* JawnTide: Blazing Heart (spell 3204) is now +30 maximum health (world update 2026-11-19-01-Blazing-Heart-30-Health.sql).
   Lowers the Blazing Heart already active on players and items, which keep the amount they were cast with.
   Runs at server start, before anyone logs in. Safe to re-run. */
UPDATE `biota_properties_enchantment_registry` SET `stat_Mod_Value` = 30 WHERE `spell_Id` = 3204 AND `stat_Mod_Value` > 30;
