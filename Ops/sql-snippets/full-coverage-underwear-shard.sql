-- JawnTide: full-coverage underwear for items that already exist (players' inventories, storage, vendors' stock).
-- Same rules as Content/sql/zz-jawntide-patches/03-full-coverage-underwear.sql, on ace_shard.biota_properties_int.
-- Run with the game server STOPPED (a running server would save its cached copies back over it). Safe to run repeatedly.


-- ClothingPriority first, while ValidLocations still identifies the item

UPDATE `biota_properties_int` cp
JOIN `biota_properties_int` vl ON vl.`object_Id` = cp.`object_Id` AND vl.`type` = 9
JOIN `biota_properties_int` it ON it.`object_Id` = cp.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET cp.`value` = cp.`value` | 0x60
WHERE cp.`type` = 4
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x02) <> 0 AND (vl.`value` & 0xC0) = 0;

UPDATE `biota_properties_int` cp
JOIN `biota_properties_int` vl ON vl.`object_Id` = cp.`object_Id` AND vl.`type` = 9
JOIN `biota_properties_int` it ON it.`object_Id` = cp.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET cp.`value` = cp.`value` | 0x06
WHERE cp.`type` = 4
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x40) <> 0 AND (vl.`value` & 0x02) = 0;

-- then ValidLocations

UPDATE `biota_properties_int` vl
JOIN `biota_properties_int` it ON it.`object_Id` = vl.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET vl.`value` = vl.`value` | 0x18
WHERE vl.`type` = 9
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x02) <> 0 AND (vl.`value` & 0xC0) = 0;

UPDATE `biota_properties_int` vl
JOIN `biota_properties_int` it ON it.`object_Id` = vl.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET vl.`value` = vl.`value` | 0x80
WHERE vl.`type` = 9
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x40) <> 0 AND (vl.`value` & 0x02) = 0;
