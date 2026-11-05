-- JawnTide instancing: arenas move into private instances, and the arena dungeons get their normal content back.
--
-- 1) landblock_instance gets a variation_id column. NULL = normal world content (everything that exists today).
--    A value = content that only spawns inside instanced copies (variation 1 = arena content).
-- 2) Today's content in the arena dungeons that DocTide changed (Binding Realm 007F, Bone Lair 0145,
--    Yaraq PK Arena 02E3, One Ten 039D) is kept as the arena version (variation 1).
--    Guids move up by 0x800 so they don't clash with the stock guids.
--    Galley Tower (01AD) and Fowl Basement (596A) are empty arenas today, and their arena copies stay empty.
-- 3) The normal world copy of those 6 dungeons gets the stock ACE content back (ACE-World-16PY + 16PY-Patches).
-- PKL Arena (0067) has no content in stock or today, so nothing changes there.
--
-- Safe to re-run: step 2 runs once (recorded in jt_world_migration), and step 3 replaces only the NULL (normal world) rows.

ALTER TABLE `landblock_instance` ADD COLUMN IF NOT EXISTS `variation_id` INT NULL DEFAULT NULL COMMENT 'JawnTide instancing: NULL = normal world, otherwise content for instanced copies';
ALTER TABLE `landblock_instance` ADD INDEX IF NOT EXISTS `instance_variation_idx` (`variation_id`);

CREATE TABLE IF NOT EXISTS `jt_world_migration` (
  `name` VARCHAR(100) NOT NULL PRIMARY KEY,
  `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='JawnTide: one-time world data migrations that have run';

START TRANSACTION;

-- which arena landblocks still need their arena content copied (none on a re-run)
DROP TEMPORARY TABLE IF EXISTS `jt_arena_todo`;
CREATE TEMPORARY TABLE `jt_arena_todo` (`landblock` INT NOT NULL PRIMARY KEY);
INSERT INTO `jt_arena_todo` (`landblock`)
SELECT lb.landblock FROM (SELECT 127 AS landblock UNION ALL SELECT 325 AS landblock UNION ALL SELECT 739 AS landblock UNION ALL SELECT 925 AS landblock) lb
WHERE NOT EXISTS (SELECT 1 FROM `jt_world_migration` m WHERE m.`name` = 'instanced-arenas')
  AND NOT EXISTS (SELECT 1 FROM `landblock_instance` v WHERE v.`landblock` = lb.landblock AND v.`variation_id` = 1);

-- 2) today's content becomes the arena version (variation 1)
DROP TEMPORARY TABLE IF EXISTS `jt_arena_inst`;
CREATE TEMPORARY TABLE `jt_arena_inst` AS
SELECT i.`guid`, i.`weenie_Class_Id`, i.`obj_Cell_Id`, i.`origin_X`, i.`origin_Y`, i.`origin_Z`, i.`angles_W`, i.`angles_X`, i.`angles_Y`, i.`angles_Z`, i.`is_Link_Child`, i.`last_Modified`
FROM `landblock_instance` i JOIN `jt_arena_todo` t ON t.`landblock` = i.`landblock`
WHERE i.`variation_id` IS NULL;

DROP TEMPORARY TABLE IF EXISTS `jt_arena_link`;
CREATE TEMPORARY TABLE `jt_arena_link` AS
SELECT l.`parent_GUID`, l.`child_GUID`, l.`last_Modified`
FROM `landblock_instance_link` l JOIN `jt_arena_inst` a ON a.`guid` = l.`parent_GUID`;

-- 3a) remove today's normal content from the 6 dungeons (links go with it, ON DELETE CASCADE)
DELETE FROM `landblock_instance` WHERE `landblock` IN (127, 325, 429, 739, 22890, 925) AND `variation_id` IS NULL;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
SELECT `guid` + 0x800, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, 1
FROM `jt_arena_inst`;

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
SELECT `parent_GUID` + 0x800, `child_GUID` + 0x800, `last_Modified`
FROM `jt_arena_link`;

-- 3b) stock content back in the normal world

-- 007F (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F000, 87532, 0x007F02EC, 10, -840.747, -0.063, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x007F02EC [10.000000 -840.747009 -0.063000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F001,  7924, 0x007F02E2, -3.61739, -819.68, 0.055, -0.041692, 0, 0, 0.99913, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 5 Min.) */
/* @teleloc 0x007F02E2 [-3.617390 -819.679993 0.055000] -0.041692 0.000000 0.000000 0.999130 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7007F001, 0x7007F002, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F003, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F004, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F005, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F006, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F007, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F008, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F009, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F00A, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F00B, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F00C, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F00D, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F00E, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F00F, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F010, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F011, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F012, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F013, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F014, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F015, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F016, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F017, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F018, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F019, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F01A, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F01B, '2021-11-01 00:00:00') /* Royal Thaumaturge (30297) */
     , (0x7007F001, 0x7007F01C, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F01D, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F01E, '2021-11-01 00:00:00') /* Summoning Chamber Adept (87530) */
     , (0x7007F001, 0x7007F01F, '2021-11-01 00:00:00') /* Summoning Chamber Adept (87530) */
     , (0x7007F001, 0x7007F020, '2021-11-01 00:00:00') /* Summoning Chamber Adept (87530) */
     , (0x7007F001, 0x7007F021, '2021-11-01 00:00:00') /* Summoning Chamber Adept (87530) */
     , (0x7007F001, 0x7007F022, '2021-11-01 00:00:00') /* Summoning Chamber Adept (87530) */
     , (0x7007F001, 0x7007F025, '2021-11-01 00:00:00') /* Adept of Fire (35128) */
     , (0x7007F001, 0x7007F026, '2021-11-01 00:00:00') /* Adept of Fire (35128) */
     , (0x7007F001, 0x7007F027, '2021-11-01 00:00:00') /* Adept of Lightning (35130) */
     , (0x7007F001, 0x7007F028, '2021-11-01 00:00:00') /* Adept of Lightning (35130) */
     , (0x7007F001, 0x7007F029, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F02A, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F02B, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F02C, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F02D, '2021-11-01 00:00:00') /* Viamontian Tribune (30291) */
     , (0x7007F001, 0x7007F02E, '2021-11-01 00:00:00') /* Adept of Fire (35128) */
     , (0x7007F001, 0x7007F02F, '2021-11-01 00:00:00') /* Adept of Lightning (35130) */
     , (0x7007F001, 0x7007F032, '2021-11-01 00:00:00') /* Bound Falatacot (87531) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F002, 30291, 0x007F02E9, 6.41336, -807.57, 0.00679, 0.046259, 0, 0, 0.998929,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F02E9 [6.413360 -807.570007 0.006790] 0.046259 0.000000 0.000000 0.998929 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F003, 30291, 0x007F02E9, 14.1422, -807.74, 0.00679, -0.003724, 0, 0, 0.999993,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F02E9 [14.142200 -807.739990 0.006790] -0.003724 0.000000 0.000000 0.999993 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F004, 30297, 0x007F02AF, -0.150907, -727.525, -5.995, -0.2658, 0, 0, 0.964028,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F02AF [-0.150907 -727.525024 -5.995000] -0.265800 0.000000 0.000000 0.964028 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F005, 30297, 0x007F02AF, 3.7659, -734.088, -5.995, -0.2658, 0, 0, 0.964028,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F02AF [3.765900 -734.088013 -5.995000] -0.265800 0.000000 0.000000 0.964028 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F006, 30297, 0x007F02D3, 80.4182, -749.939, -5.995, 0.702598, 0, 0, 0.711587,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F02D3 [80.418198 -749.939026 -5.995000] 0.702598 0.000000 0.000000 0.711587 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F007, 30291, 0x007F02D3, 82.5704, -753.601, -5.99321, 0.702598, 0, 0, 0.711587,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F02D3 [82.570396 -753.601013 -5.993210] 0.702598 0.000000 0.000000 0.711587 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F008, 30291, 0x007F02D3, 82.4698, -745.688, -5.99321, 0.702598, 0, 0, 0.711587,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F02D3 [82.469803 -745.687988 -5.993210] 0.702598 0.000000 0.000000 0.711587 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F009, 30291, 0x007F027B, 69.2769, -680.342, -11.9932, 0.947632, 0, 0, -0.319365,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F027B [69.276901 -680.341980 -11.993200] 0.947632 0.000000 0.000000 -0.319365 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F00A, 30291, 0x007F02A1, 91.2358, -658.977, -11.9932, -0.502398, 0, 0, -0.864636,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F02A1 [91.235802 -658.976990 -11.993200] -0.502398 0.000000 0.000000 -0.864636 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F00B, 30297, 0x007F0279, 69.2068, -658.02, -11.995, 0.300644, 0, 0, -0.953737,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F0279 [69.206802 -658.020020 -11.995000] 0.300644 0.000000 0.000000 -0.953737 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F00C, 30297, 0x007F02A3, 90.1534, -680.343, -11.995, 0.851543, 0, 0, 0.524284,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F02A3 [90.153397 -680.343018 -11.995000] 0.851543 0.000000 0.000000 0.524284 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F00D, 30297, 0x007F0248, 79.9782, -590.039, -17.995, 0.01019, 0, 0, -0.999948,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F0248 [79.978203 -590.039001 -17.995001] 0.010190 0.000000 0.000000 -0.999948 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F00E, 30291, 0x007F0256, 90.1021, -591.333, -17.9932, -0.019076, 0, 0, 0.999818,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F0256 [90.102097 -591.333008 -17.993200] -0.019076 0.000000 0.000000 0.999818 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F00F, 30291, 0x007F0234, 69.9702, -590.413, -17.9932, 0.010246, 0, 0, 0.999947,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F0234 [69.970200 -590.413025 -17.993200] 0.010246 0.000000 0.000000 0.999947 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F010, 30297, 0x007F01FE, 50.3521, -538.844, -17.995, 0.367291, 0, 0, 0.930106,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F01FE [50.352100 -538.843994 -17.995001] 0.367291 0.000000 0.000000 0.930106 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F011, 30291, 0x007F01DA, 39.6409, -530.627, -17.9932, -0.019576, 0, 0, 0.999808,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F01DA [39.640900 -530.627014 -17.993200] -0.019576 0.000000 0.000000 0.999808 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F012, 30291, 0x007F0211, 61.4359, -529.73, -17.9932, 0.520338, 0, 0, 0.853961,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F0211 [61.435902 -529.729980 -17.993200] 0.520338 0.000000 0.000000 0.853961 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F013, 30297, 0x007F01F4, 50.1325, -519.056, -17.995, 0.408502, 0, 0, 0.912758,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F01F4 [50.132500 -519.056030 -17.995001] 0.408502 0.000000 0.000000 0.912758 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F014, 30297, 0x007F025D, 99.9325, -491.766, -17.995, -0.115519, 0, 0, -0.993305,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F025D [99.932503 -491.765991 -17.995001] -0.115519 0.000000 0.000000 -0.993305 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F015, 30291, 0x007F025D, 101.05, -489.347, -17.9932, -0.115519, 0, 0, -0.993305,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F025D [101.050003 -489.346985 -17.993200] -0.115519 0.000000 0.000000 -0.993305 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F016, 30297, 0x007F02A5, 98.2246, -443.705, -11.995, 0.735914, 0, 0, 0.677075,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F02A5 [98.224602 -443.704987 -11.995000] 0.735914 0.000000 0.000000 0.677075 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F017, 30297, 0x007F0270, 63.2551, -444.166, -11.995, -0.774222, 0, 0, 0.632914,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F0270 [63.255100 -444.165985 -11.995000] -0.774222 0.000000 0.000000 0.632914 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F018, 30291, 0x007F023E, 84.1828, -427.799, -17.9932, 0.016429, 0, 0, 0.999865,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F023E [84.182800 -427.799011 -17.993200] 0.016429 0.000000 0.000000 0.999865 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F019, 30291, 0x007F023E, 75.9925, -427.53, -17.9932, 0.016429, 0, 0, 0.999865,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F023E [75.992500 -427.529999 -17.993200] 0.016429 0.000000 0.000000 0.999865 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F01A, 30291, 0x007F019A, 118.508, -410.191, -23.9932, 0.656689, 0, 0, 0.754162,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F019A [118.508003 -410.191010 -23.993200] 0.656689 0.000000 0.000000 0.754162 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F01B, 30297, 0x007F019A, 120.921, -409.15, -23.995, 0.656689, 0, 0, 0.754162,  True, '2021-11-01 00:00:00'); /* Royal Thaumaturge */
/* @teleloc 0x007F019A [120.920998 -409.149994 -23.995001] 0.656689 0.000000 0.000000 0.754162 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F01C, 30291, 0x007F01A6, 160.217, -420.143, -23.9932, 0.189315, 0, 0, 0.981916,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F01A6 [160.216995 -420.143005 -23.993200] 0.189315 0.000000 0.000000 0.981916 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F01D, 30291, 0x007F01AA, 160.601, -460.569, -23.9932, 0.995827, 0, 0, 0.09126,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F01AA [160.600998 -460.569000 -23.993200] 0.995827 0.000000 0.000000 0.091260 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F01E, 87530, 0x007F01AC, 172.163, -437.173, -23.994, -0.715223, 0, 0, -0.698896,  True, '2021-11-01 00:00:00'); /* Summoning Chamber Adept */
/* @teleloc 0x007F01AC [172.162994 -437.173004 -23.993999] -0.715223 0.000000 0.000000 -0.698896 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F01F, 87530, 0x007F01AC, 172.03, -442.924, -23.994, -0.715223, 0, 0, -0.698896,  True, '2021-11-01 00:00:00'); /* Summoning Chamber Adept */
/* @teleloc 0x007F01AC [172.029999 -442.924011 -23.993999] -0.715223 0.000000 0.000000 -0.698896 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F020, 87530, 0x007F018D, 251.491, -440.219, -29.994, 0.712354, 0, 0, 0.701821,  True, '2021-11-01 00:00:00'); /* Summoning Chamber Adept */
/* @teleloc 0x007F018D [251.490997 -440.218994 -29.993999] 0.712354 0.000000 0.000000 0.701821 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F021, 87530, 0x007F0192, 256.241, -443.187, -29.994, 0.712354, 0, 0, 0.701821,  True, '2021-11-01 00:00:00'); /* Summoning Chamber Adept */
/* @teleloc 0x007F0192 [256.240997 -443.187012 -29.993999] 0.712354 0.000000 0.000000 0.701821 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F022, 87530, 0x007F0192, 256.33, -437.22, -29.994, 0.712354, 0, 0, 0.701821,  True, '2021-11-01 00:00:00'); /* Summoning Chamber Adept */
/* @teleloc 0x007F0192 [256.329987 -437.220001 -29.993999] 0.712354 0.000000 0.000000 0.701821 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F023, 87532, 0x007F0196, 272.023, -440.354, -30.063, 0.712354, 0, 0, 0.701821, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x007F0196 [272.023010 -440.354004 -30.063000] 0.712354 0.000000 0.000000 0.701821 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F024, 87533, 0x007F018B, 250.091, -419.422, -30.063, -0.01038, 0, 0, -0.999946, False, '2021-11-01 00:00:00'); /* Summoning Chamber */
/* @teleloc 0x007F018B [250.091003 -419.421997 -30.063000] -0.010380 0.000000 0.000000 -0.999946 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F025, 35128, 0x007F017D, 244.389, -280.011, -29.995, 0.659983, 0, 0, -0.75128,  True, '2021-11-01 00:00:00'); /* Adept of Fire */
/* @teleloc 0x007F017D [244.389008 -280.010986 -29.995001] 0.659983 0.000000 0.000000 -0.751280 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F026, 35128, 0x007F018F, 255.584, -259.961, -29.995, 0.601835, 0, 0, 0.798621,  True, '2021-11-01 00:00:00'); /* Adept of Fire */
/* @teleloc 0x007F018F [255.584000 -259.960999 -29.995001] 0.601835 0.000000 0.000000 0.798621 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F027, 35130, 0x007F0190, 255.808, -279.971, -29.995, 0.660336, 0, 0, 0.75097,  True, '2021-11-01 00:00:00'); /* Adept of Lightning */
/* @teleloc 0x007F0190 [255.807999 -279.971008 -29.995001] 0.660336 0.000000 0.000000 0.750970 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F028, 35130, 0x007F017C, 244.251, -260.018, -29.995, 0.668973, 0, 0, -0.743287,  True, '2021-11-01 00:00:00'); /* Adept of Lightning */
/* @teleloc 0x007F017C [244.251007 -260.018005 -29.995001] 0.668973 0.000000 0.000000 -0.743287 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F029, 30291, 0x007F0184, 247.736, -246.671, -29.9932, -0.022944, 0, 0, -0.999737,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F0184 [247.735992 -246.671005 -29.993200] -0.022944 0.000000 0.000000 -0.999737 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F02A, 30291, 0x007F0184, 252.052, -246.869, -29.9932, -0.022944, 0, 0, -0.999737,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F0184 [252.052002 -246.869003 -29.993200] -0.022944 0.000000 0.000000 -0.999737 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F02B, 30291, 0x007F016D, 256.767, -219.992, -35.9932, -0.720605, 0, 0, -0.693346,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F016D [256.766998 -219.992004 -35.993198] -0.720605 0.000000 0.000000 -0.693346 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F02C, 30291, 0x007F015A, 242.674, -220.31, -35.9932, 0.696369, 0, 0, -0.717684,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F015A [242.673996 -220.309998 -35.993198] 0.696369 0.000000 0.000000 -0.717684 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F02D, 30291, 0x007F0136, 249.89, -168.547, -41.9932, 0.015992, 0, 0, -0.999872,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x007F0136 [249.889999 -168.546997 -41.993198] 0.015992 0.000000 0.000000 -0.999872 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F02E, 35128, 0x007F0136, 251.998, -165.673, -41.995, 0.015992, 0, 0, -0.999872,  True, '2021-11-01 00:00:00'); /* Adept of Fire */
/* @teleloc 0x007F0136 [251.998001 -165.673004 -41.994999] 0.015992 0.000000 0.000000 -0.999872 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F02F, 35130, 0x007F0136, 246.577, -165.846, -41.995, 0.015992, 0, 0, -0.999872,  True, '2021-11-01 00:00:00'); /* Adept of Lightning */
/* @teleloc 0x007F0136 [246.576996 -165.845993 -41.994999] 0.015992 0.000000 0.000000 -0.999872 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F030, 87532, 0x007F0146, 289.389, -159.951, -42.063, -0.710526, 0, 0, -0.703671, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x007F0146 [289.389008 -159.951004 -42.063000] -0.710526 0.000000 0.000000 -0.703671 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F031, 87534, 0x007F0123, 209.703, -159.8, -42.063, 0.706652, 0, 0, -0.707562, False, '2021-11-01 00:00:00'); /* Binding Realm */
/* @teleloc 0x007F0123 [209.703003 -159.800003 -42.063000] 0.706652 0.000000 0.000000 -0.707562 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7007F032, 87531, 0x007F0103, 250, -10.1622, -59.9864, 0.020795, 0, 0, -0.999784,  True, '2021-11-01 00:00:00'); /* Bound Falatacot */
/* @teleloc 0x007F0103 [250.000000 -10.162200 -59.986401] 0.020795 0.000000 0.000000 -0.999784 */

-- 0145 (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145000,  1760, 0x01450100, 60, -70, -5.9975, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450100 [60.000000 -70.000000 -5.997500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145001,  1760, 0x01450100, 59.1045, -68.0411, -5.9975, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450100 [59.104500 -68.041100 -5.997500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145002,  1760, 0x01450100, 58.9444, -72.6668, -5.9975, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450100 [58.944401 -72.666801 -5.997500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145003,  3977, 0x01450100, 55.966, -70.703, -6, -0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Chest */
/* @teleloc 0x01450100 [55.966000 -70.703003 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145004,   285, 0x01450100, 56.4204, -65.6012, -4.61525, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x01450100 [56.420399 -65.601196 -4.615250] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145005,  1760, 0x01450103, 80, -10, -5.9975, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450103 [80.000000 -10.000000 -5.997500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145006,  1760, 0x01450103, 81.0295, -8.82424, -5.9975, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450103 [81.029503 -8.824240 -5.997500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145007,  2131, 0x01450103, 80, -10, -6, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Pressure Plate */
/* @teleloc 0x01450103 [80.000000 -10.000000 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145008,  2180, 0x01450105, 80, -15, -6, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01450105 [80.000000 -15.000000 -6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70145008, 0x70145007, '2005-02-09 10:00:00') /* Pressure Plate (2131) */
     , (0x70145008, 0x7014500C, '2005-02-09 10:00:00') /* Lever (285) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145009,  1761, 0x01450108, 82.0404, -17.733, -5.9975, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Captain */
/* @teleloc 0x01450108 [82.040398 -17.733000 -5.997500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014500A,  2609, 0x01450108, 80, -20, -6, 0, 0, 0, -1,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x01450108 [80.000000 -20.000000 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014500B,  2131, 0x01450108, 79.9134, -17.7677, -6, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Pressure Plate */
/* @teleloc 0x01450108 [79.913399 -17.767700 -6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014500C,   285, 0x01450108, 75.6098, -23.3996, -4.56175, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x01450108 [75.609802 -23.399599 -4.561750] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014500D,  1760, 0x0145010B, 100, -30, -5.9975, 0, 0, 0, -1,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x0145010B [100.000000 -30.000000 -5.997500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014500E,  2131, 0x0145010B, 100.164, -32.8773, -6, 0, 0, 0, -1,  True, '2005-02-09 10:00:00'); /* Pressure Plate */
/* @teleloc 0x0145010B [100.164001 -32.877300 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014500F,   285, 0x0145010B, 104.387, -26.4339, -4.54838, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x0145010B [104.387001 -26.433901 -4.548380] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145010,  2180, 0x0145010D, 100, -34.75, -6, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x0145010D [100.000000 -34.750000 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70145010, 0x7014500F, '2005-02-09 10:00:00') /* Lever (285) */
     , (0x70145010, 0x70145024, '2005-02-09 10:00:00') /* Lever (286) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145011,  1760, 0x0145010E, 100, -50, -5.9975, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x0145010E [100.000000 -50.000000 -5.997500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145012,   285, 0x0145010E, 95.604, -53.452, -4.575, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x0145010E [95.603996 -53.452000 -4.575000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145013,  2180, 0x01450110, 100, -45.25, -6, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01450110 [100.000000 -45.250000 -6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70145013, 0x7014500E, '2005-02-09 10:00:00') /* Pressure Plate (2131) */
     , (0x70145013, 0x70145012, '2005-02-09 10:00:00') /* Lever (285) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145014,  1760, 0x01450111, 0.389, -72.579, 0.0025, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450111 [0.389000 -72.579002 0.002500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145015,  1760, 0x01450112, 3.372, -81.308, 0.0025, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450112 [3.372000 -81.307999 0.002500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145016,  1760, 0x01450112, -0.059, -75.784, 0.0025, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450112 [-0.059000 -75.783997 0.002500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145017,  3970, 0x01450112, -0.947851, -79.4443, 0, -0.5, 0, 0, -0.866025, False, '2005-02-09 10:00:00'); /* Chest */
/* @teleloc 0x01450112 [-0.947851 -79.444298 0.000000] -0.500000 0.000000 0.000000 -0.866025 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145019,  4020, 0x01450113, 11.6724, -66.5432, 0, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Cheap Warrior Generator */
/* @teleloc 0x01450113 [11.672400 -66.543198 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014501C,  1760, 0x01450117, 29.393, -13.127, 0.0025, 0, 0, 0, -1,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450117 [29.393000 -13.127000 0.002500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014501D,  1760, 0x01450120, 28.9696, -52.4686, 0.0025, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450120 [28.969601 -52.468601 0.002500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014501E,  1290, 0x01450135, 64.7283, -29.9641, 0, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01450135 [64.728302 -29.964100 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014501F,  2180, 0x0145013B, 64.6957, -39.9983, 0, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x0145013B [64.695702 -39.998299 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7014501F, 0x7014502B, '2005-02-09 10:00:00') /* Lever (2609) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145020,  2180, 0x0145013E, 64.7501, -49.991, 0, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x0145013E [64.750099 -49.991001 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70145020, 0x70145004, '2005-02-09 10:00:00') /* Lever (285) */
     , (0x70145020, 0x7014500B, '2005-02-09 10:00:00') /* Pressure Plate (2131) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145021,  7923, 0x0145014A, 70, -40, 0, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Linkable Monster Generator ( 3 Min.) */
/* @teleloc 0x0145014A [70.000000 -40.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70145021, 0x70145000, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145001, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145002, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145005, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145006, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145009, '2005-02-09 10:00:00') /* Skeleton Captain (1761) */
     , (0x70145021, 0x7014500D, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145011, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145014, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145015, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145016, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x7014501C, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x7014501D, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145022, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145025, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145027, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145028, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145029, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x7014502A, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x7014502F, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */
     , (0x70145021, 0x70145030, '2005-02-09 10:00:00') /* Skeleton Warrior (1760) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145022,  1760, 0x01450167, 88.8055, -0.044947, 0.0025, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450167 [88.805496 -0.044947 0.002500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145023,  2180, 0x01450167, 90, 0, 0, -0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01450167 [90.000000 0.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70145023, 0x7014500A, '2005-02-09 10:00:00') /* Lever (2609) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145024,   286, 0x01450174, 101.563, -39.8744, -1.4785, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x01450174 [101.563004 -39.874401 -1.478500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145025,  1760, 0x0145017C, 20, -30, 6.0025, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x0145017C [20.000000 -30.000000 6.002500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145026,  4918, 0x01450188, 40, -40, 6, -0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Surface */
/* @teleloc 0x01450188 [40.000000 -40.000000 6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145027,  1760, 0x01450197, 83.8011, -71.4751, 6.0025, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450197 [83.801102 -71.475098 6.002500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145028,  1760, 0x01450197, 78.2366, -71.7893, 6.0025, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450197 [78.236603 -71.789299 6.002500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145029,  1760, 0x0145019A, 78.3054, -90.848, 6.0025, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x0145019A [78.305397 -90.848000 6.002500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014502A,  1760, 0x0145019A, 82.9069, -91.1486, 6.0025, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x0145019A [82.906898 -91.148598 6.002500] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014502B,  2609, 0x0145019A, 80, -90, 6, 1, 0, 0, 0,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x0145019A [80.000000 -90.000000 6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014502C,  4918, 0x014501A3, 100.362, -46.4276, 6, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Surface */
/* @teleloc 0x014501A3 [100.362000 -46.427601 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014502D, 15759, 0x01450111, -3.78318, -66.2644, 0.005, 0.911915, 0, 0, 0.410379, False, '2005-02-09 10:00:00'); /* Linkable Item Generator */
/* @teleloc 0x01450111 [-3.783180 -66.264397 0.005000] 0.911915 0.000000 0.000000 0.410379 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7014502D, 0x7014502E, '2005-02-09 10:00:00') /* Alloy Instrument (25317) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014502E, 25317, 0x01450111, -2.93721, -67.4071, 0.005, 0.911915, 0, 0, 0.410379,  True, '2005-02-09 10:00:00'); /* Alloy Instrument */
/* @teleloc 0x01450111 [-2.937210 -67.407097 0.005000] 0.911915 0.000000 0.000000 0.410379 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7014502F,  1760, 0x01450114, 9.782, -78.231, 0.0025, 0.866025, 0, 0, -0.5,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450114 [9.782000 -78.231003 0.002500] 0.866025 0.000000 0.000000 -0.500000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70145030,  1760, 0x01450113, 11.4203, -68.0055, 0.0025, 0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Skeleton Warrior */
/* @teleloc 0x01450113 [11.420300 -68.005501 0.002500] 0.707107 0.000000 0.000000 -0.707107 */

-- 01AD (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD000,   954, 0x01AD0100, 0, 0, 0, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Drudge Sneaker Generator */
/* @teleloc 0x01AD0100 [0.000000 0.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD001,   893, 0x01AD0107, 10, -40, 0, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Drudge Skulker Generator */
/* @teleloc 0x01AD0107 [10.000000 -40.000000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD002,   893, 0x01AD0107, 8.79901, -36.9528, 0, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Drudge Skulker Generator */
/* @teleloc 0x01AD0107 [8.799010 -36.952801 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD003,   893, 0x01AD0107, 5.72246, -40.8745, 0, -0.895178, 0, 0, -0.44571, False, '2005-02-09 10:00:00'); /* Drudge Skulker Generator */
/* @teleloc 0x01AD0107 [5.722460 -40.874500 0.000000] -0.895178 0.000000 0.000000 -0.445710 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD004,   152, 0x01AD0112, 30, -20, 0, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Font */
/* @teleloc 0x01AD0112 [30.000000 -20.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD005,  2077, 0x01AD0117, 30, -40, 0, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Surface */
/* @teleloc 0x01AD0117 [30.000000 -40.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD006,   568, 0x01AD0119, 30, -35.25, 0, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01AD0119 [30.000000 -35.250000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD007,   954, 0x01AD0145, 52.4335, 1.66437, 6, -0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Drudge Sneaker Generator */
/* @teleloc 0x01AD0145 [52.433498 1.664370 6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD008,   381, 0x01AD014C, 60.5368, -13.3345, 6, -0.732469, 0, 0, -0.680801, False, '2005-02-09 10:00:00'); /* Drudge Generator */
/* @teleloc 0x01AD014C [60.536800 -13.334500 6.000000] -0.732469 0.000000 0.000000 -0.680801 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD009,   954, 0x01AD014C, 56.5785, -12.4389, 6, 0.649614, 0, 0, -0.760264, False, '2005-02-09 10:00:00'); /* Drudge Sneaker Generator */
/* @teleloc 0x01AD014C [56.578499 -12.438900 6.000000] 0.649614 0.000000 0.000000 -0.760264 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD00A,  1474, 0x01AD0155, 29.7407, -19.9854, 12, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Drudge Robber Generator */
/* @teleloc 0x01AD0155 [29.740700 -19.985399 12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD00B,   892, 0x01AD0155, 28.4825, -20.6146, 12, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Drudge Prowler Generator */
/* @teleloc 0x01AD0155 [28.482500 -20.614599 12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD00C,  1478, 0x01AD016E, 39.0137, -2.42274, 18, -0.898842, 0, 0, -0.438273, False, '2005-02-09 10:00:00'); /* Drudge Food Generator */
/* @teleloc 0x01AD016E [39.013699 -2.422740 18.000000] -0.898842 0.000000 0.000000 -0.438273 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD00D,   892, 0x01AD016E, 36.3414, 0.373816, 18, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Drudge Prowler Generator */
/* @teleloc 0x01AD016E [36.341400 0.373816 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD00E,   892, 0x01AD016E, 37.1101, 3.02118, 18, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Drudge Prowler Generator */
/* @teleloc 0x01AD016E [37.110100 3.021180 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD00F,  1459, 0x01AD016E, 39.4497, 2.97464, 18, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Food Stamina Gen */
/* @teleloc 0x01AD016E [39.449699 2.974640 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701AD010,  4019, 0x01AD016E, 40, 0, 18, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Cheap Utility Generator */
/* @teleloc 0x01AD016E [40.000000 0.000000 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

-- 02E3 (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3000,  2179, 0x02E30116, 74.682, -40, 6.005, 0.710744, 0, 0, -0.70345, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x02E30116 [74.681999 -40.000000 6.005000] 0.710744 0.000000 0.000000 -0.703450 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702E3000, 0x702E3005, '2005-02-09 10:00:00') /* Lever (2609) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3001,  2179, 0x02E30117, 70, -44.721, 6.005, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x02E30117 [70.000000 -44.721001 6.005000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702E3001, 0x702E3004, '2005-02-09 10:00:00') /* Lever (2609) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3002,  2179, 0x02E3011C, 70, -65.164, 6.005, 0.016266, 0, 0, -0.999868, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x02E3011C [70.000000 -65.164001 6.005000] 0.016266 0.000000 0.000000 -0.999868 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702E3002, 0x702E3007, '2005-02-09 10:00:00') /* Lever (2609) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3003,  2179, 0x02E3011D, 74.838, -70, 6.005, 0.725591, 0, 0, -0.688127, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x02E3011D [74.837997 -70.000000 6.005000] 0.725591 0.000000 0.000000 -0.688127 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702E3003, 0x702E3006, '2005-02-09 10:00:00') /* Lever (2609) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3004,  2609, 0x02E30159, 60.1701, -51.478, 12.055, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x02E30159 [60.170101 -51.478001 12.055000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3005,  2609, 0x02E30159, 58.3996, -51.5946, 12.055, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x02E30159 [58.399601 -51.594601 12.055000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3006,  2609, 0x02E3015A, 58.6144, -59.7702, 12.055, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x02E3015A [58.614399 -59.770199 12.055000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3007,  2609, 0x02E3015A, 60.7142, -59.8905, 12.055, -0.707107, 0, 0, -0.707107,  True, '2005-02-09 10:00:00'); /* Lever */
/* @teleloc 0x02E3015A [60.714199 -59.890499 12.055000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3008,  7892, 0x02E301A3, 130, -45.7849, 12.005, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Surface Portal */
/* @teleloc 0x02E301A3 [130.000000 -45.784901 12.005000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E3009,   509, 0x02E301A5, 125.144, -55.0856, 12.005, -0.012023, 0, 0, 0.999928, False, '2005-02-09 10:00:00'); /* Life Stone */
/* @teleloc 0x02E301A5 [125.143997 -55.085602 12.005000] -0.012023 0.000000 0.000000 0.999928 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E300A,  7893, 0x02E301A6, 129.836, -64.8859, 12.005, -0.023372, 0, 0, -0.999727, False, '2005-02-09 10:00:00'); /* Judging Station */
/* @teleloc 0x02E301A6 [129.835999 -64.885902 12.005000] -0.023372 0.000000 0.000000 -0.999727 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702E300B,  7938, 0x02E301A6, 131.511, -62.3886, 12.005, -0.042755, 0, 0, 0.999086, False, '2005-02-09 10:00:00'); /* Warning for PK Arena! */
/* @teleloc 0x02E301A6 [131.511002 -62.388599 12.005000] -0.042755 0.000000 0.000000 0.999086 */

-- 596A (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A001,  7926, 0x596A0102, 12.0935, -20, -0.028, 0.696707, 0, 0, -0.717356, False, '2022-03-31 06:02:40'); /* Linkable Monster Generator ( 20 Min.) */
/* @teleloc 0x596A0102 [12.093500 -20.000000 -0.028000] 0.696707 0.000000 0.000000 -0.717356 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7596A001, 0x7596A002, '2022-03-31 06:02:40') /* Thunder Turkey (53015) */
     , (0x7596A001, 0x7596A003, '2022-03-31 06:02:40') /* Thunder Poult (53014) */
     , (0x7596A001, 0x7596A004, '2022-03-31 06:02:40') /* Thunder Poult (53014) */
     , (0x7596A001, 0x7596A005, '2022-03-31 06:02:40') /* Thunder Poult (53014) */
     , (0x7596A001, 0x7596A006, '2022-03-31 06:02:40') /* Thunder Poult (53014) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A002, 53015, 0x596A0102, 12.0935, -20, -0.028, 0.696707, 0, 0, -0.717356,  True, '2022-03-31 06:02:40'); /* Thunder Turkey */
/* @teleloc 0x596A0102 [12.093500 -20.000000 -0.028000] 0.696707 0.000000 0.000000 -0.717356 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A003, 53014, 0x596A010C, 42.1, -20, -0.008, -0.707107, 0, 0, -0.707107,  True, '2022-03-31 06:02:40'); /* Thunder Poult */
/* @teleloc 0x596A010C [42.099998 -20.000000 -0.008000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A004, 53014, 0x596A0104, 20, 2.2, -0.008, 0, 0, 0, -1,  True, '2022-03-31 06:02:40'); /* Thunder Poult */
/* @teleloc 0x596A0104 [20.000000 2.200000 -0.008000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A005, 53014, 0x596A0100, -2.2, -20, -0.008, 0.707107, 0, 0, -0.707107,  True, '2022-03-31 06:02:40'); /* Thunder Poult */
/* @teleloc 0x596A0100 [-2.200000 -20.000000 -0.008000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A006, 53014, 0x596A0108, 20, -42.1, -0.008, 1, 0, 0, 0,  True, '2022-03-31 06:02:40'); /* Thunder Poult */
/* @teleloc 0x596A0108 [20.000000 -42.099998 -0.008000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7596A007, 88097, 0x596A0106, 20.3032, -15.1519, 0, 1, 0, 0, 0, False, '2022-03-31 06:02:40'); /* Fowl Basement Gen */
/* @teleloc 0x596A0106 [20.303200 -15.151900 0.000000] 1.000000 0.000000 0.000000 0.000000 */

-- 039D (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D000,  7924, 0x039D029C, 110, -35, 47.937, 1, 0, 0, 0, False, '2023-05-15 03:25:02'); /* Linkable Monster Generator ( 5 Min.) */
/* @teleloc 0x039D029C [110.000000 -35.000000 47.937000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7039D000, 0x7039D004, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D005, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D006, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D007, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D008, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D009, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D00A, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D00B, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D00C, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D00D, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D00E, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D00F, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D010, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D011, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D012, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D013, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D014, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D015, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D016, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D017, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D018, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D019, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D01A, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D01B, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D01C, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D01D, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D01E, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D01F, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D020, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D021, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D022, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D023, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D024, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D025, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D026, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D027, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D028, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D029, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D02A, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D02B, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D02C, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D02D, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D02E, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D02F, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D030, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D031, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D032, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D033, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D034, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D035, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D036, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D037, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D038, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D039, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */
     , (0x7039D000, 0x7039D03A, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */
     , (0x7039D000, 0x7039D03B, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D03C, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D03D, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D03E, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D03F, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D040, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D041, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D042, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D043, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D044, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D045, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D046, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D047, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D048, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D049, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D04A, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D04B, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D04C, '2023-05-15 03:25:02') /* Ravenous Eater (28637) */
     , (0x7039D000, 0x7039D04D, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */
     , (0x7039D000, 0x7039D04E, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */
     , (0x7039D000, 0x7039D04F, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D001, 24129, 0x039D0149, 38.8531, -77.816, -29.995, 0.549412, 0, 0, 0.835551, False, '2023-05-15 03:25:02'); /* Linkable Monster Generator ( 2 Min.) */
/* @teleloc 0x039D0149 [38.853100 -77.816002 -29.995001] 0.549412 0.000000 0.000000 0.835551 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7039D001, 0x7039D04D, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */
     , (0x7039D001, 0x7039D04E, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */
     , (0x7039D001, 0x7039D04F, '2023-05-15 03:25:02') /* Ravenous Eater (28847) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D002, 28803, 0x039D02A2, 100, -30, 47.937, 1, 0, 0, 0, False, '2023-05-15 03:25:02'); /* Surface */
/* @teleloc 0x039D02A2 [100.000000 -30.000000 47.937000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D003, 28803, 0x039D0127, 22.1202, -79.9599, -30.063, -0.721127, 0, 0, -0.692803, False, '2023-05-15 03:25:02'); /* Surface */
/* @teleloc 0x039D0127 [22.120199 -79.959900 -30.063000] -0.721127 0.000000 0.000000 -0.692803 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D004, 28637, 0x039D0266, 108.161, -32.4341, 6.005, -0.8733, 0, 0, 0.487184,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0266 [108.161003 -32.434101 6.005000] -0.873300 0.000000 0.000000 0.487184 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D005, 28637, 0x039D0268, 122.442, -18.0643, 6.005, -0.686298, 0, 0, -0.727321,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0268 [122.442001 -18.064301 6.005000] -0.686298 0.000000 0.000000 -0.727321 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D006, 28637, 0x039D0252, 79.7229, -18.8181, 6.005, -0.686298, 0, 0, -0.727321,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0252 [79.722900 -18.818100 6.005000] -0.686298 0.000000 0.000000 -0.727321 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D007, 28637, 0x039D0256, 78.6671, -60.8933, 6.005, 0.539657, 0, 0, -0.841885,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0256 [78.667099 -60.893299 6.005000] 0.539657 0.000000 0.000000 -0.841885 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D008, 28637, 0x039D0258, 92.1714, -47.5429, 6.005, 0.816776, 0, 0, -0.576955,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0258 [92.171402 -47.542900 6.005000] 0.816776 0.000000 0.000000 -0.576955 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D009, 28637, 0x039D026C, 121.513, -63.1728, 6.005, 0.838905, 0, 0, -0.544278,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D026C [121.513000 -63.172798 6.005000] 0.838905 0.000000 0.000000 -0.544278 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D00A, 28637, 0x039D0262, 99.363, -70.6679, 6.005, 0.721825, 0, 0, 0.692076,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0262 [99.362999 -70.667900 6.005000] 0.721825 0.000000 0.000000 0.692076 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D00B, 28637, 0x039D0250, 70.1006, -39.8258, 6.005, 0.674601, 0, 0, 0.738182,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0250 [70.100601 -39.825802 6.005000] 0.674601 0.000000 0.000000 0.738182 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D00C, 28637, 0x039D025C, 100.285, -9.92392, 6.005, 0.135212, 0, 0, 0.990817,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D025C [100.285004 -9.923920 6.005000] 0.135212 0.000000 0.000000 0.990817 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D00D, 28637, 0x039D026E, 129.909, -39.8542, 6.005, 0.637347, 0, 0, 0.770577,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D026E [129.908997 -39.854198 6.005000] 0.637347 0.000000 0.000000 0.770577 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D00E, 28637, 0x039D0247, 121.032, -10.3832, 0.005, -0.052686, 0, 0, -0.998611,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0247 [121.031998 -10.383200 0.005000] -0.052686 0.000000 0.000000 -0.998611 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D00F, 28637, 0x039D022B, 120.362, -38.9995, -11.995, -0.090766, 0, 0, -0.995872,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D022B [120.362000 -38.999500 -11.995000] -0.090766 0.000000 0.000000 -0.995872 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D010, 28637, 0x039D01EF, 141.789, -29.5146, -17.995, 0.973173, 0, 0, 0.230075,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01EF [141.789001 -29.514601 -17.995001] 0.973173 0.000000 0.000000 0.230075 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D011, 28637, 0x039D01EC, 129.277, -33.1473, -17.995, 0.997157, 0, 0, -0.075347,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01EC [129.276993 -33.147301 -17.995001] 0.997157 0.000000 0.000000 -0.075347 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D012, 28637, 0x039D01EB, 130.247, -19.0414, -17.995, 0.921631, 0, 0, 0.388067,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01EB [130.246994 -19.041401 -17.995001] 0.921631 0.000000 0.000000 0.388067 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D013, 28637, 0x039D01E7, 121.998, -9.55495, -17.995, 0.960268, 0, 0, 0.279079,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01E7 [121.998001 -9.554950 -17.995001] 0.960268 0.000000 0.000000 0.279079 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D014, 28637, 0x039D01E4, 108.822, -12.2012, -17.995, 0.827651, 0, 0, 0.561243,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01E4 [108.821999 -12.201200 -17.995001] 0.827651 0.000000 0.000000 0.561243 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D015, 28637, 0x039D01DD, 89.5479, 1.85459, -17.995, 0.637488, 0, 0, 0.77046,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01DD [89.547897 1.854590 -17.995001] 0.637488 0.000000 0.000000 0.770460 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D016, 28637, 0x039D01DE, 92.7778, -11.8447, -17.995, 0.762217, 0, 0, 0.647322,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01DE [92.777802 -11.844700 -17.995001] 0.762217 0.000000 0.000000 0.647322 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D017, 28637, 0x039D01D9, 78.7839, -7.01231, -17.995, 0.373806, 0, 0, 0.927507,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01D9 [78.783897 -7.012310 -17.995001] 0.373806 0.000000 0.000000 0.927507 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D018, 28637, 0x039D01D3, 72.6308, -31.7204, -17.995, 0.231004, 0, 0, 0.972953,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01D3 [72.630798 -31.720400 -17.995001] 0.231004 0.000000 0.000000 0.972953 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D019, 28637, 0x039D01CF, 57.5935, -27.0605, -17.995, 0.550469, 0, 0, 0.834856,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01CF [57.593498 -27.060499 -17.995001] 0.550469 0.000000 0.000000 0.834856 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D01A, 28637, 0x039D01D1, 56.9214, -51.0167, -17.995, -0.553836, 0, 0, 0.832626,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01D1 [56.921398 -51.016701 -17.995001] -0.553836 0.000000 0.000000 0.832626 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D01B, 28637, 0x039D01D4, 70.1174, -48.1796, -17.995, -0.743561, 0, 0, 0.668668,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01D4 [70.117401 -48.179600 -17.995001] -0.743561 0.000000 0.000000 0.668668 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D01C, 28637, 0x039D01DC, 78.005, -69.9709, -17.995, -0.487902, 0, 0, 0.872898,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01DC [78.004997 -69.970901 -17.995001] -0.487902 0.000000 0.000000 0.872898 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D01D, 28637, 0x039D01DF, 91.3114, -68.7411, -17.995, 0.027811, 0, 0, 0.999613,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01DF [91.311401 -68.741096 -17.995001] 0.027811 0.000000 0.000000 0.999613 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D01E, 28637, 0x039D01E0, 88.4069, -82.2158, -17.995, -0.704988, 0, 0, 0.70922,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01E0 [88.406898 -82.215797 -17.995001] -0.704988 0.000000 0.000000 0.709220 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D01F, 28637, 0x039D01E6, 110.154, -82.1195, -17.995, -0.985837, 0, 0, 0.167705,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01E6 [110.153999 -82.119499 -17.995001] -0.985837 0.000000 0.000000 0.167705 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D020, 28637, 0x039D01E5, 108.535, -68.6647, -17.995, -0.667607, 0, 0, 0.744514,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01E5 [108.535004 -68.664703 -17.995001] -0.667607 0.000000 0.000000 0.744514 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D021, 28637, 0x039D01EA, 122.088, -71.2601, -17.995, -0.989923, 0, 0, 0.141608,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01EA [122.087997 -71.260101 -17.995001] -0.989923 0.000000 0.000000 0.141608 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D022, 28637, 0x039D01ED, 127.253, -48.2366, -17.995, -0.607304, 0, 0, 0.794469,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01ED [127.252998 -48.236599 -17.995001] -0.607304 0.000000 0.000000 0.794469 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D023, 28637, 0x039D01F1, 141.506, -52.1005, -17.995, -0.415699, 0, 0, 0.909502,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01F1 [141.505997 -52.100498 -17.995001] -0.415699 0.000000 0.000000 0.909502 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D024, 28637, 0x039D01F3, 50.0113, -71.201, -11.995, -0.393727, 0, 0, -0.919227,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01F3 [50.011299 -71.200996 -11.995000] -0.393727 0.000000 0.000000 -0.919227 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D025, 28637, 0x039D01C6, 55.4779, -69.8689, -23.995, 0.686431, 0, 0, 0.727195,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01C6 [55.477901 -69.868896 -23.995001] 0.686431 0.000000 0.000000 0.727195 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D026, 28637, 0x039D0195, 29.7967, -64.732, -23.995, 0.858642, 0, 0, -0.512576,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0195 [29.796700 -64.732002 -23.995001] 0.858642 0.000000 0.000000 -0.512576 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D027, 28637, 0x039D01B5, 49.8131, -47.1148, -23.995, -0.013742, 0, 0, 0.999906,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01B5 [49.813099 -47.114799 -23.995001] -0.013742 0.000000 0.000000 0.999906 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D028, 28637, 0x039D0217, 99.3574, -39.3857, -11.995, 0.648268, 0, 0, 0.761412,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0217 [99.357399 -39.385700 -11.995000] 0.648268 0.000000 0.000000 0.761412 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D029, 28637, 0x039D021C, 99.8716, -59.1861, -11.995, 0.071912, 0, 0, 0.997411,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D021C [99.871597 -59.186100 -11.995000] 0.071912 0.000000 0.000000 0.997411 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D02A, 28637, 0x039D0214, 100.874, -19.5854, -11.995, 0.99988, 0, 0, 0.015488,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0214 [100.874001 -19.585400 -11.995000] 0.999880 0.000000 0.000000 0.015488 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D02B, 28637, 0x039D0205, 80.547, -40.0497, -11.995, 0.762914, 0, 0, 0.646501,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0205 [80.546997 -40.049702 -11.995000] 0.762914 0.000000 0.000000 0.646501 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D02C, 28637, 0x039D0243, 81.2296, -70.177, 0.005, -0.686884, 0, 0, 0.726767,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0243 [81.229599 -70.177002 0.005000] -0.686884 0.000000 0.000000 0.726767 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D02D, 28637, 0x039D024C, 129.101, -59.1262, 0.005, 0.755959, 0, 0, -0.654619,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D024C [129.100998 -59.126202 0.005000] 0.755959 0.000000 0.000000 -0.654619 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D02E, 28637, 0x039D023E, 71.4554, -19.984, 0.005, 0.696215, 0, 0, -0.717834,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D023E [71.455399 -19.983999 0.005000] 0.696215 0.000000 0.000000 -0.717834 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D02F, 28637, 0x039D0193, 29.9507, -48.747, -23.995, -0.998922, 0, 0, 0.046429,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0193 [29.950701 -48.747002 -23.995001] -0.998922 0.000000 0.000000 0.046429 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D030, 28637, 0x039D017B, 9.11172, -47.4548, -23.995, 0.594726, 0, 0, -0.803928,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D017B [9.111720 -47.454800 -23.995001] 0.594726 0.000000 0.000000 -0.803928 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D031, 28637, 0x039D012B, 29.7896, -20.1235, -29.995, 0.582121, 0, 0, 0.813103,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D012B [29.789600 -20.123501 -29.995001] 0.582121 0.000000 0.000000 0.813103 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D032, 28637, 0x039D0123, 20.5128, -50.4845, -29.995, -0.722791, 0, 0, 0.691067,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0123 [20.512800 -50.484501 -29.995001] -0.722791 0.000000 0.000000 0.691067 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D033, 28637, 0x039D0132, 25.1279, -60.6791, -29.995, 0.450359, 0, 0, 0.892848,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0132 [25.127899 -60.679100 -29.995001] 0.450359 0.000000 0.000000 0.892848 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D034, 28637, 0x039D0109, 10.3878, -53.2244, -29.995, -0.011999, 0, 0, 0.999928,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0109 [10.387800 -53.224400 -29.995001] -0.011999 0.000000 0.000000 0.999928 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D035, 28637, 0x039D0100, 3.18131, -60.1361, -29.995, -0.708238, 0, 0, 0.705974,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0100 [3.181310 -60.136101 -29.995001] -0.708238 0.000000 0.000000 0.705974 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D036, 28637, 0x039D0112, 9.93263, -83.4554, -29.995, -0.033753, 0, 0, -0.99943,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0112 [9.932630 -83.455399 -29.995001] -0.033753 0.000000 0.000000 -0.999430 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D037, 28637, 0x039D0108, 2.57315, -100.26, -29.995, 0.728576, 0, 0, -0.684965,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0108 [2.573150 -100.260002 -29.995001] 0.728576 0.000000 0.000000 -0.684965 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D038, 28637, 0x039D011C, 10.1491, -106.879, -29.995, 0.995766, 0, 0, -0.091926,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D011C [10.149100 -106.878998 -29.995001] 0.995766 0.000000 0.000000 -0.091926 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D039, 28847, 0x039D0149, 36.799, -80.2687, -29.995, 0.737606, 0, 0, 0.675231,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0149 [36.799000 -80.268700 -29.995001] 0.737606 0.000000 0.000000 0.675231 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D03A, 28847, 0x039D0127, 22.9955, -79.8348, -29.995, 0.717059, 0, 0, -0.697012,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0127 [22.995501 -79.834801 -29.995001] 0.717059 0.000000 0.000000 -0.697012 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D03B, 28637, 0x039D0154, 49.9489, -52.2185, -29.995, 0.012851, 0, 0, 0.999917,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0154 [49.948898 -52.218498 -29.995001] 0.012851 0.000000 0.000000 0.999917 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D03C, 28637, 0x039D016A, 56.7044, -60.0201, -29.995, 0.734787, 0, 0, 0.678298,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D016A [56.704399 -60.020100 -29.995001] 0.734787 0.000000 0.000000 0.678298 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D03D, 28637, 0x039D016D, 60.694, -74.4558, -29.995, 0.585383, 0, 0, 0.810757,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D016D [60.694000 -74.455803 -29.995001] 0.585383 0.000000 0.000000 0.810757 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D03E, 28637, 0x039D0161, 50.3839, -86.4698, -29.995, -0.095336, 0, 0, 0.995445,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0161 [50.383900 -86.469803 -29.995001] -0.095336 0.000000 0.000000 0.995445 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D03F, 28637, 0x039D0169, 49.9621, -107.444, -29.995, -0.999476, 0, 0, -0.032369,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0169 [49.962101 -107.444000 -29.995001] -0.999476 0.000000 0.000000 -0.032369 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D040, 28637, 0x039D0143, 30.1328, -105.636, -29.995, 0.377022, 0, 0, -0.926204,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0143 [30.132799 -105.636002 -29.995001] 0.377022 0.000000 0.000000 -0.926204 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D041, 28637, 0x039D0144, 33.9185, -140.779, -29.995, -0.895367, 0, 0, -0.445329,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0144 [33.918499 -140.779007 -29.995001] -0.895367 0.000000 0.000000 -0.445329 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D042, 28637, 0x039D01A0, 30.1754, -116.572, -23.995, -0.999332, 0, 0, -0.036533,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01A0 [30.175400 -116.571999 -23.995001] -0.999332 0.000000 0.000000 -0.036533 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D043, 28637, 0x039D0182, 9.42212, -115.488, -23.995, -0.998243, 0, 0, 0.059257,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0182 [9.422120 -115.487999 -23.995001] -0.998243 0.000000 0.000000 0.059257 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D044, 28637, 0x039D01C3, 49.9753, -115.468, -23.995, 0.998238, 0, 0, -0.059331,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01C3 [49.975300 -115.468002 -23.995001] 0.998238 0.000000 0.000000 -0.059331 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D045, 28637, 0x039D01EA, 122.088, -71.2601, -17.995, -0.989923, 0, 0, 0.141608,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01EA [122.087997 -71.260101 -17.995001] -0.989923 0.000000 0.000000 0.141608 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D046, 28637, 0x039D01ED, 127.253, -48.2366, -17.995, -0.607304, 0, 0, 0.794469,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01ED [127.252998 -48.236599 -17.995001] -0.607304 0.000000 0.000000 0.794469 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D047, 28637, 0x039D01F1, 141.506, -52.1005, -17.995, -0.415699, 0, 0, 0.909502,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01F1 [141.505997 -52.100498 -17.995001] -0.415699 0.000000 0.000000 0.909502 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D048, 28637, 0x039D01F3, 50.0113, -71.201, -11.995, -0.393727, 0, 0, -0.919227,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01F3 [50.011299 -71.200996 -11.995000] -0.393727 0.000000 0.000000 -0.919227 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D049, 28637, 0x039D01CD, 55.6315, -100.373, -23.995, 0.716321, 0, 0, -0.697771,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01CD [55.631500 -100.373001 -23.995001] 0.716321 0.000000 0.000000 -0.697771 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D04A, 28637, 0x039D01AA, 43.8594, -80.1464, -23.995, 0.949097, 0, 0, 0.314983,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01AA [43.859402 -80.146400 -23.995001] 0.949097 0.000000 0.000000 0.314983 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D04B, 28637, 0x039D0195, 29.7967, -64.732, -23.995, 0.858642, 0, 0, -0.512576,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0195 [29.796700 -64.732002 -23.995001] 0.858642 0.000000 0.000000 -0.512576 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D04C, 28637, 0x039D01B5, 49.8131, -47.1148, -23.995, -0.013742, 0, 0, 0.999906,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D01B5 [49.813099 -47.114799 -23.995001] -0.013742 0.000000 0.000000 0.999906 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D04D, 28847, 0x039D0134, 30.1236, -71.3268, -29.995, -0.729238, 0, 0, 0.684261,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0134 [30.123600 -71.326797 -29.995001] -0.729238 0.000000 0.000000 0.684261 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D04E, 28847, 0x039D013C, 29.8517, -90.2681, -29.995, 0.705231, 0, 0, 0.708977,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D013C [29.851700 -90.268097 -29.995001] 0.705231 0.000000 0.000000 0.708977 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7039D04F, 28847, 0x039D0139, 30.3593, -79.5671, -29.995, 0.734043, 0, 0, 0.679103,  True, '2023-05-15 03:25:02'); /* Ravenous Eater */
/* @teleloc 0x039D0139 [30.359301 -79.567101 -29.995001] 0.734043 0.000000 0.000000 0.679103 */

INSERT IGNORE INTO `jt_world_migration` (`name`) VALUES ('instanced-arenas');

DROP TEMPORARY TABLE IF EXISTS `jt_arena_todo`;
DROP TEMPORARY TABLE IF EXISTS `jt_arena_inst`;
DROP TEMPORARY TABLE IF EXISTS `jt_arena_link`;

COMMIT;
