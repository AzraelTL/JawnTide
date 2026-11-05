-- JawnTide: remove the Banderling Mace Shaft generator and shaft from the ground at the Banderling Conquest Dungeon portal (BE5B).
-- The stock portal (0x7BE5B002, added by 2026-11-09-00-Instanced-Tusker-Queen.sql) stays.
DELETE FROM `landblock_instance_link` WHERE `parent_GUID` = 0x7BE5B000;
DELETE FROM `landblock_instance` WHERE `guid` IN (0x7BE5B000, 0x7BE5B001) AND `landblock` = 0xBE5B;
