-- JawnTide patch: every undershirt covers chest, upper arms and lower arms, and every pair of
-- underpants covers abdomen, upper legs and lower legs (shirts without the wrist/bracer part and
-- pants without the lower legs, such as tunics, short-sleeve shirts and breeches, get the missing parts).
--
-- Applies to every clothing or armor weenie (ItemType 2 or 4) whose ValidLocations are underwear slots only:
--   undershirt = has ChestWear (0x2) and no leg slots      -> ValidLocations |= UpperArmWear|LowerArmWear (0x18)
--                                                            ClothingPriority |= UnderwearUpperArms|UnderwearLowerArms (0x60)
--   underpants = has UpperLegWear (0x40) and no ChestWear  -> ValidLocations |= LowerLegWear (0x80)
--                                                            ClothingPriority |= UnderwearUpperLegs|UnderwearLowerLegs (0x06)
-- One-piece underwear that covers both chest and legs (a Toga) is left alone.
-- Only the coverage changes; the look (ClothingBase) does not, so a short-sleeve shirt still looks short-sleeved.
--
-- Safe to run repeatedly (it only sets bits). Items already in players' hands keep their own copy of these
-- values: Ops/sql-snippets/full-coverage-underwear-shard.sql updates those (run it with the game server stopped).

-- ClothingPriority first, while ValidLocations still identifies the item

UPDATE `weenie_properties_int` cp
JOIN `weenie_properties_int` vl ON vl.`object_Id` = cp.`object_Id` AND vl.`type` = 9
JOIN `weenie_properties_int` it ON it.`object_Id` = cp.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET cp.`value` = cp.`value` | 0x60
WHERE cp.`type` = 4
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x02) <> 0 AND (vl.`value` & 0xC0) = 0;

UPDATE `weenie_properties_int` cp
JOIN `weenie_properties_int` vl ON vl.`object_Id` = cp.`object_Id` AND vl.`type` = 9
JOIN `weenie_properties_int` it ON it.`object_Id` = cp.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET cp.`value` = cp.`value` | 0x06
WHERE cp.`type` = 4
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x40) <> 0 AND (vl.`value` & 0x02) = 0;

-- then ValidLocations

UPDATE `weenie_properties_int` vl
JOIN `weenie_properties_int` it ON it.`object_Id` = vl.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET vl.`value` = vl.`value` | 0x18
WHERE vl.`type` = 9
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x02) <> 0 AND (vl.`value` & 0xC0) = 0;

UPDATE `weenie_properties_int` vl
JOIN `weenie_properties_int` it ON it.`object_Id` = vl.`object_Id` AND it.`type` = 1 AND (it.`value` & 6) <> 0
SET vl.`value` = vl.`value` | 0x80
WHERE vl.`type` = 9
  AND vl.`value` <> 0 AND (vl.`value` & ~0xDE) = 0 AND (vl.`value` & 0x40) <> 0 AND (vl.`value` & 0x02) = 0;
