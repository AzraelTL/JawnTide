-- =====================================================================
-- Flag a character as having completed Nalicana's Test
-- (turning in Battle Lord Gregor's Mnemosyne), for MariaDB / ACE.
--
-- Quest names and rewards below come from Nalicana's emotes in your ace_world:
--   OracleLuminanceRewardsQuestStart_1110
--   OracleLuminanceRewardsAccess_1110
--   OraclePortalEntry
--   MaximumLuminance (stat 7) = 1500000
--
-- STOP THE SERVER, or make sure the character is OFFLINE, before running.
-- An online character's in-memory data will overwrite these changes.
-- Back up first:  mysqldump -u root -p ace_shard > ace_shard_backup.sql
-- =====================================================================
USE ace_shard;

SET @char_name = 'CharacterNameHere';   -- exact character name
SET @max_lum   = 1500000;               -- use 15000000 if you raised the cap
SET @start_lum = 0;                     -- optional: set to 15000 to include the turn-in's luminance reward

SET @char_id = (SELECT id FROM `character` WHERE name = @char_name AND is_Deleted = 0 LIMIT 1);

-- Sanity check: this must show your character's id (not NULL) before you continue.
SELECT @char_id AS character_id, @char_name AS character_name;

-- 1. The three quest stamps
INSERT INTO character_properties_quest_registry
    (character_Id, quest_Name, last_Time_Completed, num_Times_Completed)
VALUES
    (@char_id, 'OracleLuminanceRewardsQuestStart_1110', UNIX_TIMESTAMP(), 1),
    (@char_id, 'OracleLuminanceRewardsAccess_1110',     UNIX_TIMESTAMP(), 1),
    (@char_id, 'OraclePortalEntry',                     UNIX_TIMESTAMP(), 1)
ON DUPLICATE KEY UPDATE
    last_Time_Completed = UNIX_TIMESTAMP(),
    num_Times_Completed = GREATEST(num_Times_Completed, 1);

-- 2. Unlock luminance (MaximumLuminance is property 7, AvailableLuminance is 6)
INSERT INTO biota_properties_int64 (object_Id, type, value)
VALUES (@char_id, 7, @max_lum)
ON DUPLICATE KEY UPDATE value = @max_lum;

INSERT IGNORE INTO biota_properties_int64 (object_Id, type, value)
VALUES (@char_id, 6, @start_lum);

-- 3. Check the result
SELECT * FROM character_properties_quest_registry
WHERE character_Id = @char_id
  AND quest_Name IN ('OracleLuminanceRewardsQuestStart_1110', 'OracleLuminanceRewardsAccess_1110', 'OraclePortalEntry');

SELECT * FROM biota_properties_int64 WHERE object_Id = @char_id AND type IN (6, 7);
