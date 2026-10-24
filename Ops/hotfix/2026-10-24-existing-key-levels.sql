/* Existing Darkbeat's Lost Storage Keys (480608) and Hera's Vault Keys (490364) keep the level requirement they
   were created with (150 / 180). Content now creates them at level 40; this brings keys already in the world down to 40.
   Run against ace_shard with the game server STOPPED (online characters would save their old copies back). */
UPDATE ace_shard.biota_properties_int p
JOIN ace_shard.biota b ON b.id = p.object_Id
SET p.value = 40
WHERE p.type = 369 AND b.weenie_Class_Id IN (480608, 490364);
SELECT ROW_COUNT() AS keys_updated;
