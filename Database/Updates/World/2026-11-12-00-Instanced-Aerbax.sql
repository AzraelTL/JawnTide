-- JawnTide instancing: the Aerbax world boss fights in a private copy of the Lesser Battle Dungeon (6543), like the Tusker Queen.
--
-- 1) Today's content in 6543 (the Death Zones and the rest of the Aerbax lair) becomes the Aerbax version (variation 4).
--    It only spawns inside the copy made for each Aerbax spawn, reached through the Idol of the Progenitor. Guids move up by 0x800.
-- 2) The normal world copy of 6543 gets its stock ACE content back (just a Foot Massager; the dungeon has no stock portal).
--
-- Needs 2026-11-07-00-Instanced-Arenas.sql (variation_id column). Safe to re-run: step 1 runs once (jt_world_migration).

ALTER TABLE `landblock_instance` ADD COLUMN IF NOT EXISTS `variation_id` INT NULL DEFAULT NULL COMMENT 'JawnTide instancing: NULL = normal world, otherwise content for instanced copies';
ALTER TABLE `landblock_instance` ADD INDEX IF NOT EXISTS `instance_variation_idx` (`variation_id`);

CREATE TABLE IF NOT EXISTS `jt_world_migration` (
  `name` VARCHAR(100) NOT NULL PRIMARY KEY,
  `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='JawnTide: one-time world data migrations that have run';

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS `jt_ax_todo`;
CREATE TEMPORARY TABLE `jt_ax_todo` (`landblock` INT NOT NULL PRIMARY KEY);
INSERT INTO `jt_ax_todo` (`landblock`)
SELECT lb.landblock FROM (SELECT 25923 AS landblock) lb
WHERE NOT EXISTS (SELECT 1 FROM `jt_world_migration` m WHERE m.`name` = 'instanced-aerbax')
  AND NOT EXISTS (SELECT 1 FROM `landblock_instance` v WHERE v.`landblock` = lb.landblock AND v.`variation_id` = 4);

DROP TEMPORARY TABLE IF EXISTS `jt_ax_inst`;
CREATE TEMPORARY TABLE `jt_ax_inst` AS
SELECT i.`guid`, i.`weenie_Class_Id`, i.`obj_Cell_Id`, i.`origin_X`, i.`origin_Y`, i.`origin_Z`, i.`angles_W`, i.`angles_X`, i.`angles_Y`, i.`angles_Z`, i.`is_Link_Child`, i.`last_Modified`
FROM `landblock_instance` i JOIN `jt_ax_todo` t ON t.`landblock` = i.`landblock`
WHERE i.`variation_id` IS NULL;

DROP TEMPORARY TABLE IF EXISTS `jt_ax_link`;
CREATE TEMPORARY TABLE `jt_ax_link` AS
SELECT l.`parent_GUID`, l.`child_GUID`, l.`last_Modified`
FROM `landblock_instance_link` l JOIN `jt_ax_inst` a ON a.`guid` = l.`parent_GUID`;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
SELECT `guid` + 0x800, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, 4
FROM `jt_ax_inst`;

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
SELECT `parent_GUID` + 0x800, `child_GUID` + 0x800, `last_Modified`
FROM `jt_ax_link`;

-- 6543 normal world: stock ACE content (its links go with the rows)
DELETE l FROM `landblock_instance_link` l JOIN `landblock_instance` i ON i.`guid` = l.`parent_GUID` WHERE i.`landblock` = 25923 AND i.`variation_id` IS NULL;
DELETE FROM `landblock_instance` WHERE `landblock` = 25923 AND `variation_id` IS NULL;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (1985228800, 25993, 1698890009, 67.3287, -60.2669, 0.005, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Foot Massager (0x76543000 in 0x65430119) */

INSERT IGNORE INTO `jt_world_migration` (`name`) VALUES ('instanced-aerbax');

DROP TEMPORARY TABLE IF EXISTS `jt_ax_todo`;
DROP TEMPORARY TABLE IF EXISTS `jt_ax_inst`;
DROP TEMPORARY TABLE IF EXISTS `jt_ax_link`;

COMMIT;
