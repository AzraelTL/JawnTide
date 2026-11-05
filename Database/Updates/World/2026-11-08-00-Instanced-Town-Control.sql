-- JawnTide instancing: Town Control conflict areas move into private instances, and get their normal content back.
--
-- The governor fights in the towns don't change. The conflict areas behind the crystal portals do:
-- Yaraq (Derethian Combat Arena) 00AB, Holtburg (Dardante's Keep) 4FF1, Shoushi (Hidden Forest) E9F0, Shoushi (Hidden Forest) E9F1, Shoushi (Hidden Forest) E8F1.
-- 1) Today's content there (crystal event generators, gates and walls that keep players in the area, etc.) becomes the
--    Town Control version (variation 2). It only spawns inside an event's private copy. Guids move up by 0x800.
-- 2) The normal world copy gets the stock ACE content back (Yaraq 00AB and Holtburg 4FF1 from ACE-World-16PY-Patches;
--    the Shoushi forest landblocks have no stock spawns, so they become empty).
--
-- Needs 2026-11-07-00-Instanced-Arenas.sql (variation_id column). Safe to re-run: step 1 runs once (jt_world_migration).

ALTER TABLE `landblock_instance` ADD COLUMN IF NOT EXISTS `variation_id` INT NULL DEFAULT NULL COMMENT 'JawnTide instancing: NULL = normal world, otherwise content for instanced copies';
ALTER TABLE `landblock_instance` ADD INDEX IF NOT EXISTS `instance_variation_idx` (`variation_id`);

CREATE TABLE IF NOT EXISTS `jt_world_migration` (
  `name` VARCHAR(100) NOT NULL PRIMARY KEY,
  `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='JawnTide: one-time world data migrations that have run';

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS `jt_tc_todo`;
CREATE TEMPORARY TABLE `jt_tc_todo` (`landblock` INT NOT NULL PRIMARY KEY);
INSERT INTO `jt_tc_todo` (`landblock`)
SELECT lb.landblock FROM (SELECT 171 AS landblock UNION ALL SELECT 20465 AS landblock UNION ALL SELECT 59888 AS landblock UNION ALL SELECT 59889 AS landblock UNION ALL SELECT 59633 AS landblock) lb
WHERE NOT EXISTS (SELECT 1 FROM `jt_world_migration` m WHERE m.`name` = 'instanced-town-control')
  AND NOT EXISTS (SELECT 1 FROM `landblock_instance` v WHERE v.`landblock` = lb.landblock AND v.`variation_id` = 2);

DROP TEMPORARY TABLE IF EXISTS `jt_tc_inst`;
CREATE TEMPORARY TABLE `jt_tc_inst` AS
SELECT i.`guid`, i.`weenie_Class_Id`, i.`obj_Cell_Id`, i.`origin_X`, i.`origin_Y`, i.`origin_Z`, i.`angles_W`, i.`angles_X`, i.`angles_Y`, i.`angles_Z`, i.`is_Link_Child`, i.`last_Modified`
FROM `landblock_instance` i JOIN `jt_tc_todo` t ON t.`landblock` = i.`landblock`
WHERE i.`variation_id` IS NULL;

DROP TEMPORARY TABLE IF EXISTS `jt_tc_link`;
CREATE TEMPORARY TABLE `jt_tc_link` AS
SELECT l.`parent_GUID`, l.`child_GUID`, l.`last_Modified`
FROM `landblock_instance_link` l JOIN `jt_tc_inst` a ON a.`guid` = l.`parent_GUID`;

DELETE FROM `landblock_instance` WHERE `landblock` IN (171, 20465, 59888, 59889, 59633) AND `variation_id` IS NULL;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
SELECT `guid` + 0x800, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, 2
FROM `jt_tc_inst`;

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
SELECT `parent_GUID` + 0x800, `child_GUID` + 0x800, `last_Modified`
FROM `jt_tc_link`;

-- 00AB (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB000, 80100, 0x00AB028A, 46.3667, -39.9219, -0.063, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x00AB028A [46.366699 -39.921902 -0.063000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB001, 80102, 0x00AB0109, 49.7578, -34.6875, -29.945, 0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Statue of Death */
/* @teleloc 0x00AB0109 [49.757801 -34.687500 -29.945000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB002, 80135, 0x00AB0108, 41.9685, -50.7617, -29.945, 0.707107, 0, 0, 0.707107,  True, '2021-11-01 00:00:00'); /* Statue of Illuminating Death */
/* @teleloc 0x00AB0108 [41.968498 -50.761700 -29.945000] 0.707107 0.000000 0.000000 0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB003, 80136, 0x00AB010B, 57.9408, -19.543, -29.945, 0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Statue of Illuminating Death */
/* @teleloc 0x00AB010B [57.940800 -19.542999 -29.945000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB004, 80137, 0x00AB0118, 27.2377, -17.1719, -23.945, 0.382683, 0, 0, -0.92388,  True, '2021-11-01 00:00:00'); /* Statue of Illuminating Death */
/* @teleloc 0x00AB0118 [27.237700 -17.171900 -23.945000] 0.382683 0.000000 0.000000 -0.923880 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB005, 80138, 0x00AB013F, 72.8364, -52.7617, -23.945, 0.92388, 0, 0, 0.382683,  True, '2021-11-01 00:00:00'); /* Statue of Illuminating Death */
/* @teleloc 0x00AB013F [72.836403 -52.761700 -23.945000] 0.923880 0.000000 0.000000 0.382683 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB007, 80104, 0x00AB0103, 31.2422, -30.957, -29.945, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Statue of High Illumination */
/* @teleloc 0x00AB0103 [31.242201 -30.957001 -29.945000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB008, 80103, 0x00AB0109, 47.3958, -34.5039, -29.945, 0.707107, 0, 0, 0.707107,  True, '2021-11-01 00:00:00'); /* Statue of Illuminating Death */
/* @teleloc 0x00AB0109 [47.395802 -34.503899 -29.945000] 0.707107 0.000000 0.000000 0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB009, 80105, 0x00AB010A, 48.7562, -37.1328, -29.945, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Statue of Extreme Illumination */
/* @teleloc 0x00AB010A [48.756199 -37.132801 -29.945000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB00A, 80139, 0x00AB0110, 67.8248, -39.7031, -29.945, 1, 0, 0, 0,  True, '2021-11-01 00:00:00'); /* Statue of High Illumination */
/* @teleloc 0x00AB0110 [67.824799 -39.703098 -29.945000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB00B, 80106, 0x00AB013F, 71.3167, -50.3594, -24, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB013F [71.316704 -50.359402 -24.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB00C, 80106, 0x00AB013B, 70.9889, 0.125, -24, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB013B [70.988899 0.125000 -24.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB00D, 80106, 0x00AB01FE, 99.5845, -57.9883, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB01FE [99.584503 -57.988300 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB00E, 80106, 0x00AB011C, 30.3944, -70.0117, -24, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB011C [30.394400 -70.011703 -24.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB00F, 80106, 0x00AB0244, 49.972, -50.1523, -6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB0244 [49.972000 -50.152302 -6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB010, 80106, 0x00AB0175, 15.356, -19.7227, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB0175 [15.356000 -19.722700 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB011, 80106, 0x00AB015D, 0.506104, -10.3281, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB015D [0.506104 -10.328100 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB012, 80106, 0x00AB01B1, 50.6257, -39.0859, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB01B1 [50.625702 -39.085899 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB013, 80106, 0x00AB01E9, 89.5247, -0.789062, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB01E9 [89.524696 -0.789062 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB014, 80106, 0x00AB0118, 28.155, -18.6133, -24, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB0118 [28.155001 -18.613300 -24.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB015, 80106, 0x00AB01E6, 81.2721, -49.8828, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB01E6 [81.272102 -49.882801 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB016, 80106, 0x00AB0172, 11.6957, -69.6367, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB0172 [11.695700 -69.636703 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB017, 80106, 0x00AB0236, 50.0197, -20.0742, -6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB0236 [50.019699 -20.074200 -6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB018, 80106, 0x00AB028D, 63.39, -40.3477, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA Devices Generator */
/* @teleloc 0x00AB028D [63.389999 -40.347698 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB019, 80140, 0x00AB0109, 49.7578, -34.6875, -29.945, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* DCA Linkable Generator */
/* @teleloc 0x00AB0109 [49.757801 -34.687500 -29.945000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB019, 0x700AB001, '2021-11-01 00:00:00') /* Statue of Death (80102) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB01A, 80142, 0x00AB0109, 47.3958, -34.5039, -29.945, 0.707107, 0, 0, 0.707107, False, '2021-11-01 00:00:00'); /* DCA Lum1 Linkable Generator */
/* @teleloc 0x00AB0109 [47.395802 -34.503899 -29.945000] 0.707107 0.000000 0.000000 0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB01A, 0x700AB008, '2021-11-01 00:00:00') /* Statue of Illuminating Death (80103) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB01B, 80143, 0x00AB0108, 41.9685, -50.7617, -29.945, 0.707107, 0, 0, 0.707107, False, '2021-11-01 00:00:00'); /* DCA Lum2 Linkable Generator */
/* @teleloc 0x00AB0108 [41.968498 -50.761700 -29.945000] 0.707107 0.000000 0.000000 0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB01B, 0x700AB002, '2021-11-01 00:00:00') /* Statue of Illuminating Death (80135) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB01C, 80144, 0x00AB010B, 57.9408, -19.543, -29.945, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* DCA Lum3 Linkable Generator */
/* @teleloc 0x00AB010B [57.940800 -19.542999 -29.945000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB01C, 0x700AB003, '2021-11-01 00:00:00') /* Statue of Illuminating Death (80136) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB01D, 80145, 0x00AB0118, 27.2377, -17.1719, -23.945, 0.382683, 0, 0, -0.92388, False, '2021-11-01 00:00:00'); /* DCA Lum4 Linkable Generator */
/* @teleloc 0x00AB0118 [27.237700 -17.171900 -23.945000] 0.382683 0.000000 0.000000 -0.923880 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB01D, 0x700AB004, '2021-11-01 00:00:00') /* Statue of Illuminating Death (80137) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB01E, 80146, 0x00AB013F, 72.8364, -52.7617, -23.945, 0.92388, 0, 0, 0.382683, False, '2021-11-01 00:00:00'); /* DCA Lum5 Linkable Generator */
/* @teleloc 0x00AB013F [72.836403 -52.761700 -23.945000] 0.923880 0.000000 0.000000 0.382683 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB01E, 0x700AB005, '2021-11-01 00:00:00') /* Statue of Illuminating Death (80138) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB01F, 80147, 0x00AB0103, 31.2422, -30.957, -29.945, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* DCA HiLum1 Linkable Generator */
/* @teleloc 0x00AB0103 [31.242201 -30.957001 -29.945000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB01F, 0x700AB007, '2021-11-01 00:00:00') /* Statue of High Illumination (80104) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB020, 80148, 0x00AB0110, 67.8248, -39.7031, -29.945, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* DCA HiLum2 Linkable Generator */
/* @teleloc 0x00AB0110 [67.824799 -39.703098 -29.945000] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB020, 0x700AB00A, '2021-11-01 00:00:00') /* Statue of High Illumination (80139) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x700AB021, 80149, 0x00AB010A, 48.7562, -37.1328, -29.945, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* DCA ExLum1 Linkable Generator */
/* @teleloc 0x00AB010A [48.756199 -37.132801 -29.945000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x700AB021, 0x700AB009, '2021-11-01 00:00:00') /* Statue of Extreme Illumination (80105) */;

-- 4FF1 (stock)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13E8,  7924, 0x4FF1001C, 73.8988, 86.8679, 84.006, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 5 Min.) */
/* @teleloc 0x4FF1001C [73.898804 86.867897 84.005997] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x74FF13E8, 0x74FF13E9, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13EA, '2021-11-01 00:00:00') /* Adept of Fire (35128) */
     , (0x74FF13E8, 0x74FF13EB, '2021-11-01 00:00:00') /* Adept of Acid (35127) */
     , (0x74FF13E8, 0x74FF13EC, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13ED, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13EE, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13EF, '2021-11-01 00:00:00') /* Adept of Frost (35129) */
     , (0x74FF13E8, 0x74FF13F0, '2021-11-01 00:00:00') /* Adept of Lightning (35130) */
     , (0x74FF13E8, 0x74FF13F1, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13F2, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13F6, '2021-11-01 00:00:00') /* Doorkeeper Knight (73070) */
     , (0x74FF13E8, 0x74FF13F7, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13F8, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13F9, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF13FA, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF13FB, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF13FC, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13FD, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13FE, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF13FF, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF1400, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF1401, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF1402, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF1403, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF1404, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF1405, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */
     , (0x74FF13E8, 0x74FF1406, '2021-11-01 00:00:00') /* Viamontian Tribune (28652) */
     , (0x74FF13E8, 0x74FF1407, '2021-11-01 00:00:00') /* Abhorrent Eater (28641) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13E9, 28652, 0x4FF10014, 57.9375, 74.0556, 84.0068, 0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10014 [57.937500 74.055603 84.006798] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13EA, 35128, 0x4FF10014, 59.8521, 81.5916, 84.005, 0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Adept of Fire */
/* @teleloc 0x4FF10014 [59.852100 81.591599 84.004997] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13EB, 35127, 0x4FF10014, 64.397, 87.4145, 84.005, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Adept of Acid */
/* @teleloc 0x4FF10014 [64.397003 87.414497 84.004997] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13EC, 28652, 0x4FF1001C, 77.0552, 77.6879, 84.0068, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF1001C [77.055199 77.687897 84.006798] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13ED, 28652, 0x4FF1001C, 91.1672, 78.8308, 84.0068, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF1001C [91.167198 78.830803 84.006798] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13EE, 28652, 0x4FF10024, 107.24, 74.0556, 84.0068, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10024 [107.239998 74.055603 84.006798] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13EF, 35129, 0x4FF10024, 107.24, 84.4716, 84.005, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Adept of Frost */
/* @teleloc 0x4FF10024 [107.239998 84.471603 84.004997] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F0, 35130, 0x4FF1001C, 87.4565, 92.1318, 84.005, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Adept of Lightning */
/* @teleloc 0x4FF1001C [87.456497 92.131798 84.004997] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F1, 28652, 0x4FF1012D, 75.8549, 100.906, 84.0069, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF1012D [75.854897 100.905998 84.006897] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F2, 28652, 0x4FF1001D, 83.4045, 108.486, 84.0068, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF1001D [83.404503 108.486000 84.006798] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F3, 73068, 0x4FF10128, 80.9026, 107.106, 79.2034, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Dardante's Keep */
/* @teleloc 0x4FF10128 [80.902603 107.106003 79.203400] -1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F4,   412, 0x4FF10124, 78.5016, 110.517, 84.082, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x4FF10124 [78.501602 110.516998 84.082001] -1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F5, 73076, 0x4FF1012A, 80.8053, 116.052, 79.205, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x4FF1012A [80.805298 116.052002 79.205002] 1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F6, 73070, 0x4FF10127, 83.8648, 118.233, 79.205, 0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Doorkeeper Knight */
/* @teleloc 0x4FF10127 [83.864799 118.233002 79.205002] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F7, 28652, 0x4FF10024, 101.071, 91.8741, 84.0068, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10024 [101.070999 91.874100 84.006798] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F8, 28652, 0x4FF10024, 114.529, 77.7929, 84.0068, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10024 [114.528999 77.792900 84.006798] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13F9, 28641, 0x4FF1001B, 95.0664, 61.7014, 84, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF1001B [95.066399 61.701401 84.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13FA, 28641, 0x4FF10013, 71.4507, 61.7014, 84, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF10013 [71.450699 61.701401 84.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13FB, 28641, 0x4FF1001B, 82.6345, 61.7014, 84, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF1001B [82.634499 61.701401 84.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13FC, 28652, 0x4FF10012, 64.5757, 45.219, 84.0068, 0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10012 [64.575699 45.219002 84.006798] 0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13FD, 28652, 0x4FF10022, 101.487, 44.6231, 84.0068, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10022 [101.487000 44.623100 84.006798] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13FE, 28652, 0x4FF1002C, 122.145, 95.7123, 84.0068, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF1002C [122.144997 95.712303 84.006798] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF13FF, 28641, 0x4FF10024, 119.531, 90.9604, 84, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF10024 [119.530998 90.960403 84.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1400, 28641, 0x4FF10025, 117.289, 97.3443, 84, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF10025 [117.289001 97.344299 84.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1401, 28641, 0x4FF10014, 59.6522, 84.5017, 84, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF10014 [59.652199 84.501701 84.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1402, 28652, 0x4FF10014, 62.2476, 87.5831, 84.0068, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10014 [62.247601 87.583099 84.006798] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1403, 28652, 0x4FF1012D, 75.7387, 101.034, 84.0069, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF1012D [75.738701 101.033997 84.006897] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1404, 28641, 0x4FF1001D, 81.3603, 101.281, 84, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF1001D [81.360298 101.280998 84.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1405, 28641, 0x4FF10122, 78.5913, 114.508, 83.9999, 0, 0, 0, -1,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF10122 [78.591301 114.508003 83.999901] 0.000000 0.000000 0.000000 -1.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1406, 28652, 0x4FF10117, 90.1817, 117.222, 84.0068, -0.707107, 0, 0, -0.707107,  True, '2021-11-01 00:00:00'); /* Viamontian Tribune */
/* @teleloc 0x4FF10117 [90.181702 117.222000 84.006798] -0.707107 0.000000 0.000000 -0.707107 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1407, 28641, 0x4FF10126, 88.8195, 108.205, 79.1998, -1, 0, 0, 0,  True, '2021-11-01 00:00:00'); /* Abhorrent Eater */
/* @teleloc 0x4FF10126 [88.819504 108.205002 79.199799] -1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74FF1408,   412, 0x4FF1012C, 75.8422, 96.6445, 84.082, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x4FF1012C [75.842201 96.644501 84.082001] -1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `jt_world_migration` (`name`) VALUES ('instanced-town-control');

DROP TEMPORARY TABLE IF EXISTS `jt_tc_todo`;
DROP TEMPORARY TABLE IF EXISTS `jt_tc_inst`;
DROP TEMPORARY TABLE IF EXISTS `jt_tc_link`;

COMMIT;
