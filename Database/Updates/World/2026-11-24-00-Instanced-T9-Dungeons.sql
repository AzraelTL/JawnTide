-- JawnTide instancing: the T9 dungeons run in their own shared copy (variation 5), and the lower level dungeons they took over are back.
--
-- The T9 dungeons reused Black Spawn Den (0105), Lost City of Frore (0138), Golem Burial Ground (01B4), Halls of Metos (02F5) and the
-- Mountain Citadel (6147). Now:
-- 1) Today's content in those five becomes the T9 version (variation 5), guids + 0x800, with its portals swapped to the new
--    T9 portal weenies (520300-520314). It only spawns in the T9 copy, reached through the T9 hub portals and the Mountain Citadel NPC.
-- 2) The normal world copies of the five, plus their entrance landblocks (015D, 1B90, 2586, 4532, C770, D33F), get their stock ACE content back.
-- 3) The hub portals (7ACA, 7ACB, 79C8) become the new T9 portal weenies; the stock portal weenies are stock again.
--
-- Needs 2026-11-07-00-Instanced-Arenas.sql (variation_id column). Steps 1-3 run once (jt_world_migration).

ALTER TABLE `landblock_instance` ADD COLUMN IF NOT EXISTS `variation_id` INT NULL DEFAULT NULL COMMENT 'JawnTide instancing: NULL = normal world, otherwise content for instanced copies';
ALTER TABLE `landblock_instance` ADD INDEX IF NOT EXISTS `instance_variation_idx` (`variation_id`);

CREATE TABLE IF NOT EXISTS `jt_world_migration` (
  `name` VARCHAR(100) NOT NULL PRIMARY KEY,
  `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='JawnTide: one-time world data migrations that have run';

-- Portal weenies (safe to re-run)

-- JawnTide: T9 entrance portal (the JawnTide version of 2078, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520300;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520300, 'jt-t9-portal-gbg', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520300,   1,      65536) /* ItemType - Portal */
     , (520300,  16,         32) /* ItemUseable - Remote */
     , (520300,  86,         150) /* MinLevel */
     , (520300,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520300, 111,          56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520300, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520300, 20014,          5) /* TeleportVariation - T9 dungeon copy */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520300,   1, True ) /* Stuck */
     , (520300,  11, False) /* IgnoreCollisions */
     , (520300,  12, True ) /* ReportCollisions */
     , (520300,  13, True ) /* Ethereal */
     , (520300,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520300,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520300,   1, 'Golem Burial Ground') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520300,   1, 0x020005D3) /* Setup */
     , (520300,   2, 0x09000003) /* MotionTable */
     , (520300,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520300, 2, 0x01B40130, 87.0588, -6.76988, 0.005, 0.317305, 0, 0, -0.948324) /* Destination */
/* @teleloc 0x01B40130 [87.058800 -6.769880 0.005000] 0.317305 0.000000 0.000000 -0.948324 */;

-- JawnTide: T9 entrance portal (the JawnTide version of 5900, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520301;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520301, 'jt-t9-portal-frore', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520301,   1,      65536) /* ItemType - Portal */
     , (520301,  16,         32) /* ItemUseable - Remote */
     , (520301,  86,         150) /* MinLevel */
     , (520301,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520301, 111,         56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520301, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520301, 20014,          5) /* TeleportVariation - T9 dungeon copy */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520301,   1, True ) /* Stuck */
     , (520301,  11, False) /* IgnoreCollisions */
     , (520301,  12, True ) /* ReportCollisions */
     , (520301,  13, True ) /* Ethereal */
     , (520301,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520301,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520301,   1, 'Lost City of Frore Portal') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520301,   1, 0x020005D3) /* Setup */
     , (520301,   2, 0x09000003) /* MotionTable */
     , (520301,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520301, 2, 0x01380180, 40, -280, -6, 1, 0, 0, 0) /* Destination */
/* @teleloc 0x01380180 [40.000000 -280.000000 -6.000000] 1.000000 0.000000 0.000000 0.000000 */;

-- JawnTide: T9 entrance portal (the JawnTide version of 7242, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520302;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520302, 'jt-t9-portal-bsd', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520302,   1,      65536) /* ItemType - Portal */
     , (520302,  16,         32) /* ItemUseable - Remote */
     , (520302,  86,         150) /* MinLevel */
     , (520302,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520302, 111,         56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520302, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520302, 20014,          5) /* TeleportVariation - T9 dungeon copy */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520302,   1, True ) /* Stuck */
     , (520302,  11, False) /* IgnoreCollisions */
     , (520302,  12, True ) /* ReportCollisions */
     , (520302,  13, True ) /* Ethereal */
     , (520302,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520302,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520302,   1, 'Black Spawn Den') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520302,   1, 0x020005D3) /* Setup */
     , (520302,   2, 0x09000003) /* MotionTable */
     , (520302,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520302, 2, 0x01050375, 100, -210, 0, 0.707107, 0, 0, -0.707107) /* Destination */
/* @teleloc 0x01050375 [100.000000 -210.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */;

-- JawnTide: T9 entrance portal (the JawnTide version of 7295, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520303;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520303, 'jt-t9-portal-metos', 7, '2021-11-08 06:01:47') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520303,   1,      65536) /* ItemType - Portal */
     , (520303,  16,         32) /* ItemUseable - Remote */
     , (520303,  86,         150) /* MinLevel */
     , (520303,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520303, 111,         56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520303, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520303, 20014,          5) /* TeleportVariation - T9 dungeon copy */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520303,   1, True ) /* Stuck */
     , (520303,  11, False) /* IgnoreCollisions */
     , (520303,  12, True ) /* ReportCollisions */
     , (520303,  13, True ) /* Ethereal */
     , (520303,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520303,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520303,   1, 'Halls of Metos') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520303,   1, 0x020005D3) /* Setup */
     , (520303,   2, 0x09000003) /* MotionTable */
     , (520303,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520303, 2, 0x02F50297, 100, -330, 0, 1, 0, 0, 0) /* Destination */
/* @teleloc 0x02F50297 [100.000000 -330.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */;

-- JawnTide: T9 entrance portal (the JawnTide version of 25281, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520304;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520304, 'jt-t9-portal-citadel', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520304,   1,      65536) /* ItemType - Portal */
     , (520304,  16,         32) /* ItemUseable - Remote */
     , (520304,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520304, 111,         56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520304, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520304, 20014,          5) /* TeleportVariation - T9 dungeon copy */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520304,   1, True ) /* Stuck */
     , (520304,  11, False) /* IgnoreCollisions */
     , (520304,  12, True ) /* ReportCollisions */
     , (520304,  13, True ) /* Ethereal */
     , (520304,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520304,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520304,   1, 'Mountain Citadel Portal') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520304,   1, 0x020001B3) /* Setup */
     , (520304,   2, 0x09000003) /* MotionTable */
     , (520304,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520304, 2, 0x61470152, 140, -130, 0, 1, 0, 0, 0) /* Destination */
/* @teleloc 0x61470152 [140.000000 -130.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */;

-- JawnTide: T9 exit portal (the JawnTide version of 2079, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520310;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520310, 'jt-t9-exit-gbg', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520310,   1,      65536) /* ItemType - Portal */
     , (520310,  16,         32) /* ItemUseable - Remote */
     , (520310,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520310, 111,          56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520310, 133,          4) /* ShowableOnRadar - ShowAlways */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520310,   1, True ) /* Stuck */
     , (520310,  11, False) /* IgnoreCollisions */
     , (520310,  12, True ) /* ReportCollisions */
     , (520310,  13, True ) /* Ethereal */
     , (520310,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520310,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520310,   1, 'Surface') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520310,   1, 0x020001B3) /* Setup */
     , (520310,   2, 0x09000003) /* MotionTable */
     , (520310,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520310, 2, 0x7ACA0011, 50.517986, 20.562872, 200.004990, 0.871866, 0, 0, -0.489745) /* Destination */
/* @teleloc 0x7ACA0011 [50.517986 20.562872 200.004990] 0.871866 0.000000 0.000000 -0.489745 */;

-- JawnTide: T9 exit portal (the JawnTide version of 5110, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520311;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520311, 'jt-t9-exit-frore', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520311,   1,      65536) /* ItemType - Portal */
     , (520311,  16,         32) /* ItemUseable - Remote */
     , (520311,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520311, 111,         56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520311, 133,          4) /* ShowableOnRadar - ShowAlways */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520311,   1, True ) /* Stuck */
     , (520311,  11, False) /* IgnoreCollisions */
     , (520311,  12, True ) /* ReportCollisions */
     , (520311,  13, True ) /* Ethereal */
     , (520311,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520311,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520311,   1, 'Surface') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520311,   1, 0x020001B3) /* Setup */
     , (520311,   2, 0x09000003) /* MotionTable */
     , (520311,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520311, 2, 0x7ACA0011, 50.517986, 20.562872, 200.004990, 0.871866, 0, 0, -0.489745) /* Destination */
/* @teleloc 0x7ACA0011 [50.517986 20.562872 200.004990] 0.871866 0.000000 0.000000 -0.489745 */;

-- JawnTide: T9 exit portal (the JawnTide version of 7243, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520312;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520312, 'jt-t9-exit-bsd', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520312,   1,      65536) /* ItemType - Portal */
     , (520312,  16,         32) /* ItemUseable - Remote */
     , (520312,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520312, 111,         56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520312, 133,          4) /* ShowableOnRadar - ShowAlways */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520312,   1, True ) /* Stuck */
     , (520312,  11, False) /* IgnoreCollisions */
     , (520312,  12, True ) /* ReportCollisions */
     , (520312,  13, True ) /* Ethereal */
     , (520312,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520312,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520312,   1, 'Surface Portal') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520312,   1, 0x020001B3) /* Setup */
     , (520312,   2, 0x09000003) /* MotionTable */
     , (520312,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520312, 2, 0x7ACB0029, 129.385513, 5.043907, 202.080444, -0.974784, 0, 0, 0.223152) /* Destination */
/* @teleloc 0x7ACB0029 [129.385513 5.043907 202.080444] -0.974784 0.000000 0.000000 0.223152  */;

-- JawnTide: T9 exit portal (the JawnTide version of 7296, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520313;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520313, 'jt-t9-exit-metos', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520313,   1,      65536) /* ItemType - Portal */
     , (520313,  16,         32) /* ItemUseable - Remote */
     , (520313,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520313, 111,          56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520313, 133,          4) /* ShowableOnRadar - ShowAlways */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520313,   1, True ) /* Stuck */
     , (520313,  11, False) /* IgnoreCollisions */
     , (520313,  12, True ) /* ReportCollisions */
     , (520313,  13, True ) /* Ethereal */
     , (520313,  14, True ) /* GravityStatus */
     , (520313,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520313,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520313,   1, 'Surface Portal') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520313,   1, 0x020001B3) /* Setup */
     , (520313,   2, 0x09000003) /* MotionTable */
     , (520313,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520313, 2, 0x79C80026, 115.984108, 131.911850, 95.556496, 0.117092, 0, 0, 0.993121) /* Destination */
/* @teleloc 0x79C80026 [115.984108 131.911850 95.556496] 0.117092 0.000000 0.000000 0.993121 */;

-- JawnTide: T9 exit portal (the JawnTide version of 25282, which is stock again).
DELETE FROM `weenie` WHERE `class_Id` = 520314;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520314, 'jt-t9-exit-citadel', 7, '2005-02-09 10:00:00') /* Portal */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520314,   1,      65536) /* ItemType - Portal */
     , (520314,  16,         32) /* ItemUseable - Remote */
     , (520314,  93,       3084) /* PhysicsState - Ethereal, ReportCollisions, Gravity, LightingOn */
     , (520314, 111,          56) /* PortalBitmask - NoSummon, NoRecall, No NPK */
     , (520314, 133,          4) /* ShowableOnRadar - ShowAlways */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520314,   1, True ) /* Stuck */
     , (520314,  11, False) /* IgnoreCollisions */
     , (520314,  12, True ) /* ReportCollisions */
     , (520314,  13, True ) /* Ethereal */
     , (520314,  15, True ) /* LightsStatus */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520314,  54,    -0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520314,   1, 'Surface') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520314,   1, 0x020001B3) /* Setup */
     , (520314,   2, 0x09000003) /* MotionTable */
     , (520314,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520314, 2, 0x79C90017, 71.298882, 158.654800, 211.286148, -0.579465, 0, 0, -0.814997) /* Destination */
/* 0x79C90017 [71.298882 158.654800 211.286148] -0.579465 0.000000 0.000000 -0.814997 */;

-- JawnTide: stock ACE portal again (the T9 version is 520300).
DELETE FROM `weenie` WHERE `class_Id` = 2078;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (2078, 'portalgolemgrounds', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (2078, 1, True)
     , (2078, 11, False)
     , (2078, 12, True)
     , (2078, 13, True)
     , (2078, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (2078, 1, 33555923)
     , (2078, 2, 150994947)
     , (2078, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (2078, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (2078, 1, 65536)
     , (2078, 16, 32)
     , (2078, 86, 10)
     , (2078, 93, 3084)
     , (2078, 111, 1)
     , (2078, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (2078, 2, 28574000, 87.0588, -6.76988, 0.005, 0.317305, 0, 0, -0.948324);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (2078, 1, 'Golem Burial Ground');

-- JawnTide: stock ACE portal again (the T9 version is 520310).
DELETE FROM `weenie` WHERE `class_Id` = 2079;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (2079, 'portalgolemgroundsexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (2079, 1, True)
     , (2079, 11, False)
     , (2079, 12, True)
     , (2079, 13, True)
     , (2079, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (2079, 1, 33554867)
     , (2079, 2, 150994947)
     , (2079, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (2079, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (2079, 1, 65536)
     , (2079, 16, 32)
     , (2079, 93, 3084)
     , (2079, 111, 1)
     , (2079, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (2079, 2, 3544121383, 105.536, 150.378, 202, -0.707107, 0, 0, -0.707107);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (2079, 1, 'Surface');

-- JawnTide: stock ACE portal again (the T9 version is 520311).
DELETE FROM `weenie` WHERE `class_Id` = 5110;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (5110, 'portalfroreexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (5110, 1, True)
     , (5110, 11, False)
     , (5110, 12, True)
     , (5110, 13, True)
     , (5110, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (5110, 1, 33554867)
     , (5110, 2, 150994947)
     , (5110, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (5110, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (5110, 1, 65536)
     , (5110, 16, 32)
     , (5110, 93, 3084)
     , (5110, 111, 33)
     , (5110, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (5110, 2, 2261581832, 19.427, 189.157, 113.369, -0.244309, 0, 0, -0.969698);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (5110, 1, 'Surface');

-- JawnTide: stock ACE portal again (the T9 version is 520301).
DELETE FROM `weenie` WHERE `class_Id` = 5900;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (5900, 'portallostcity', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (5900, 1, True)
     , (5900, 11, False)
     , (5900, 12, True)
     , (5900, 13, True)
     , (5900, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (5900, 1, 33555923)
     , (5900, 2, 150994947)
     , (5900, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (5900, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (5900, 1, 65536)
     , (5900, 16, 32)
     , (5900, 86, 20)
     , (5900, 93, 3084)
     , (5900, 111, 17)
     , (5900, 133, 1);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (5900, 2, 20447616, 40, -280, -6, 1, 0, 0, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (5900, 1, 'Lost City of Frore Portal');

-- JawnTide: stock ACE portal again (the T9 version is 520302).
DELETE FROM `weenie` WHERE `class_Id` = 7242;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7242, 'portalblackdrudgespawnalu', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7242, 1, True)
     , (7242, 11, False)
     , (7242, 12, True)
     , (7242, 13, True)
     , (7242, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7242, 1, 33555923)
     , (7242, 2, 150994947)
     , (7242, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7242, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7242, 1, 65536)
     , (7242, 16, 32)
     , (7242, 86, 20)
     , (7242, 93, 3084)
     , (7242, 111, 1)
     , (7242, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7242, 2, 17105781, 100, -210, 0, 0.707107, 0, 0, -0.707107);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7242, 1, 'Black Spawn Den');

-- JawnTide: stock ACE portal again (the T9 version is 520312).
DELETE FROM `weenie` WHERE `class_Id` = 7243;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7243, 'portalblackdrudgespawnaluexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7243, 1, True)
     , (7243, 11, False)
     , (7243, 12, True)
     , (7243, 13, True)
     , (7243, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7243, 1, 33554867)
     , (7243, 2, 150994947)
     , (7243, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7243, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7243, 1, 65536)
     , (7243, 16, 32)
     , (7243, 93, 3084)
     , (7243, 111, 17)
     , (7243, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7243, 2, 462422061, 122.6, 111.8, 30, 0.707107, 0, 0, -0.707107);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7243, 1, 'Surface Portal');

-- JawnTide: stock ACE portal again (the T9 version is 520303).
DELETE FROM `weenie` WHERE `class_Id` = 7295;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7295, 'portalgolemheimsho', 7, '2021-11-08 06:01:47');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7295, 1, True)
     , (7295, 11, False)
     , (7295, 12, True)
     , (7295, 13, True)
     , (7295, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7295, 1, 33555923)
     , (7295, 2, 150994947)
     , (7295, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7295, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7295, 1, 65536)
     , (7295, 16, 32)
     , (7295, 86, 15)
     , (7295, 93, 3084)
     , (7295, 111, 1)
     , (7295, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7295, 2, 49611415, 100, -330, 0, 1, 0, 0, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7295, 1, 'Halls of Metos');

-- JawnTide: stock ACE portal again (the T9 version is 520313).
DELETE FROM `weenie` WHERE `class_Id` = 7296;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7296, 'portalgolemheimshoexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7296, 1, True)
     , (7296, 11, False)
     , (7296, 12, True)
     , (7296, 13, True)
     , (7296, 14, True)
     , (7296, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7296, 1, 33554867)
     , (7296, 2, 150994947)
     , (7296, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7296, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7296, 1, 65536)
     , (7296, 16, 32)
     , (7296, 93, 3084)
     , (7296, 111, 1)
     , (7296, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7296, 2, 1160904718, 28.7, 126.5, 70, 0.92388, 0, 0, -0.382684);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7296, 1, 'Surface Portal');

-- JawnTide: stock ACE portal again (the T9 version is 520304).
DELETE FROM `weenie` WHERE `class_Id` = 25281;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (25281, 'portallugiancitadelndires', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (25281, 1, True)
     , (25281, 11, False)
     , (25281, 12, True)
     , (25281, 13, True)
     , (25281, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (25281, 1, 33555924)
     , (25281, 2, 150994947)
     , (25281, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (25281, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (25281, 1, 65536)
     , (25281, 16, 32)
     , (25281, 93, 3084)
     , (25281, 111, 1)
     , (25281, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (25281, 2, 1632043346, 140, -130, 0, 1, 0, 0, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (25281, 1, 'Mountain Citadel Portal');

-- JawnTide: stock ACE portal again (the T9 version is 520314).
DELETE FROM `weenie` WHERE `class_Id` = 25282;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (25282, 'portallugiancitadelndiresexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (25282, 1, True)
     , (25282, 11, False)
     , (25282, 12, True)
     , (25282, 13, True)
     , (25282, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (25282, 1, 33554867)
     , (25282, 2, 150994947)
     , (25282, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (25282, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (25282, 1, 65536)
     , (25282, 16, 32)
     , (25282, 93, 3084)
     , (25282, 111, 1)
     , (25282, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (25282, 2, 646316042, 33.4, 34.5, 148, 0.873348, 0, 0, -0.487098);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (25282, 1, 'Surface');

DELETE FROM `weenie` WHERE `class_Id` = 600054;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (600054, 'ace600054-Mountain Citadel', 10, '2022-08-22 03:09:27') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (600054,   1,         16) /* ItemType - Creature */
     , (600054,   6,         -1) /* ItemsCapacity */
     , (600054,   7,         -1) /* ContainersCapacity */
     , (600054,  16,         32) /* ItemUseable - Remote */
     , (600054,  93,    6294556) /* PhysicsState - Ethereal, ReportCollisions, IgnoreCollisions, Gravity, LightingOn, ReportCollisionsAsEnvironment, EdgeSlide */
     , (600054,  95,          4) /* RadarBlipColor - Purple */
     , (600054, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (600054, 20014,          5) /* TeleportVariation - sends you into the T9 copy */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (600054,   1, True ) /* Stuck */
     , (600054,  19, False) /* Attackable */
     , (600054,  52, True ) /* AiImmobile */
     , (600054,  82, True ) /* DontTurnOrMoveWhenGiving */
     , (600054,  83, True ) /* NpcLooksLikeObject */
     , (600054,  90, True ) /* NpcInteractsSilently */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (600054,  54,     0.1) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (600054,   1, 'Mountain Citadel') /* Name */
     , (600054,  14, 'Restricted to characters of Level 150 or greater.') /* Use */
     , (600054,  16, 'This portal cannot be recalled, linked nor summoned.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (600054,   1, 0x020001B3) /* Setup */
     , (600054,   2, 0x09000003) /* MotionTable */
     , (600054,   8, 0x0600106B) /* Icon */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (600054,   1, 200, 0, 0) /* Strength */
     , (600054,   2, 250, 0, 0) /* Endurance */
     , (600054,   3, 200, 0, 0) /* Quickness */
     , (600054,   4, 260, 0, 0) /* Coordination */
     , (600054,   5, 300, 0, 0) /* Focus */
     , (600054,   6, 300, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (600054,   1,   150, 0, 0, 275) /* MaxHealth */
     , (600054,   3,   235, 0, 0, 485) /* MaxStamina */
     , (600054,   5,   300, 0, 0, 600) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (600054, 31, 0, 3, 0, 999, 0, 1642.85095430452) /* CreatureEnchantment Specialized */
     , (600054, 32, 0, 3, 0, 999, 0, 1642.85095430452) /* ItemEnchantment     Specialized */
     , (600054, 33, 0, 3, 0, 999, 0, 1642.85095430452) /* LifeMagic           Specialized */
     , (600054, 34, 0, 3, 0, 999, 0, 1642.85095430452) /* WarMagic            Specialized */;

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054,  7 /* Use */,      1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  36 /* InqIntStat */, 0, 1, NULL, 'Level_150-9999', NULL, 150, 9999, NULL, NULL, NULL, NULL, 25 /* PropertyInt.Level */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 12 /* QuestSuccess */,      1, NULL, NULL, NULL, 'CitadelAccess', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  67 /* Goto */, 0, 1, NULL, 'CheckPKStatus', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 13 /* QuestFailure */,      1, NULL, NULL, NULL, 'CitadelAccess', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  18 /* DirectBroadcast */, 0, 1, NULL, 'The portal hums with energy.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 22 /* TestSuccess */,      1, NULL, NULL, NULL, 'Level_150-9999', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  21 /* InqQuest */, 0, 1, NULL, 'CitadelAccess', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 22 /* TestSuccess */,      1, NULL, NULL, NULL, 'PlayerKillerStatus_4-4', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  67 /* Goto */, 0, 1, NULL, 'IsPKready', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 23 /* TestFailure */,      1, NULL, NULL, NULL, 'Level_150-9999', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  18 /* DirectBroadcast */, 0, 1, NULL, 'You must be at least level 150 to enter this dungeon.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 23 /* TestFailure */,      1, NULL, NULL, NULL, 'PlayerKillerStatus_4-4', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  18 /* DirectBroadcast */, 0, 1, NULL, 'The portal hums with energy.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  1,  18 /* DirectBroadcast */, 0, 1, NULL, 'You must be a player killer to enter the %n.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 32 /* GotoSet */,      1, NULL, NULL, NULL, 'IsPKready', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  31 /* EraseQuest */, 0, 1, NULL, 'CitadelAccess', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  1,  19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5582 /* Nullify All Rares */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  2,   3 /* Give */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0 /* Undef */, 600053 /* Lugian Medallion */, 1, 0 /* Undef */, 0, False, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  3,  67 /* Goto */, 0, 1, NULL, 'DoTeleportCitadel', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 32 /* GotoSet */,      1, NULL, NULL, NULL, 'CheckPKStatus', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  36 /* InqIntStat */, 0, 1, NULL, 'PlayerKillerStatus_4-4', NULL, 4, 4, NULL, NULL, NULL, NULL, 134 /* PropertyInt.PlayerKillerStatus */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (600054, 32 /* GotoSet */,      1, NULL, NULL, NULL, 'DoTeleportCitadel', NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  99 /* TeleportTarget */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0x61470152 /* @teleloc 0x61470152 [140.000000 -130.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */, 140, -130, 0, 1, 0, 0, 0);


START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS `jt_t9_run`;
CREATE TEMPORARY TABLE `jt_t9_run` (`ok` INT NOT NULL);
INSERT INTO `jt_t9_run` (`ok`) SELECT 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `jt_world_migration` m WHERE m.`name` = 'instanced-t9-dungeons');

DROP TEMPORARY TABLE IF EXISTS `jt_t9_inst`;
CREATE TEMPORARY TABLE `jt_t9_inst` AS
SELECT i.`guid`, i.`weenie_Class_Id`, i.`obj_Cell_Id`, i.`origin_X`, i.`origin_Y`, i.`origin_Z`, i.`angles_W`, i.`angles_X`, i.`angles_Y`, i.`angles_Z`, i.`is_Link_Child`, i.`last_Modified`
FROM `landblock_instance` i
WHERE i.`landblock` IN (261,312,436,757,24903) AND i.`variation_id` IS NULL AND EXISTS (SELECT 1 FROM `jt_t9_run`)
  AND NOT EXISTS (SELECT 1 FROM `landblock_instance` v WHERE v.`landblock` = i.`landblock` AND v.`variation_id` = 5);

DROP TEMPORARY TABLE IF EXISTS `jt_t9_link`;
CREATE TEMPORARY TABLE `jt_t9_link` AS
SELECT l.`parent_GUID`, l.`child_GUID`, l.`last_Modified`
FROM `landblock_instance_link` l JOIN `jt_t9_inst` a ON a.`guid` = l.`parent_GUID`;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
SELECT `guid` + 0x800, CASE `weenie_Class_Id` WHEN 2078 THEN 520300 WHEN 5900 THEN 520301 WHEN 7242 THEN 520302 WHEN 7295 THEN 520303 WHEN 25281 THEN 520304 WHEN 2079 THEN 520310 WHEN 5110 THEN 520311 WHEN 7243 THEN 520312 WHEN 7296 THEN 520313 WHEN 25282 THEN 520314 ELSE `weenie_Class_Id` END, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, 5
FROM `jt_t9_inst`;

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
SELECT `parent_GUID` + 0x800, `child_GUID` + 0x800, `last_Modified`
FROM `jt_t9_link`;

-- Hub portals: the new T9 portal weenies
UPDATE `landblock_instance` SET `last_Modified` = `last_Modified`, `weenie_Class_Id` = CASE `weenie_Class_Id` WHEN 2078 THEN 520300 WHEN 5900 THEN 520301 WHEN 7242 THEN 520302 WHEN 7295 THEN 520303 ELSE `weenie_Class_Id` END
WHERE `landblock` IN (31434,31435,31176) AND `variation_id` IS NULL AND `weenie_Class_Id` IN (2078,5900,7242,7295) AND EXISTS (SELECT 1 FROM `jt_t9_run`);

-- Normal world: stock ACE content for the five dungeons and their entrance landblocks (links go with the rows).
-- Only on the first run: the stock rows below are skipped by INSERT IGNORE on re-runs because the guids are already there.
DELETE l FROM `landblock_instance_link` l JOIN `landblock_instance` i ON i.`guid` = l.`parent_GUID` WHERE i.`landblock` IN (261,312,436,757,24903,349,7056,9606,17714,51056,54079) AND i.`variation_id` IS NULL AND EXISTS (SELECT 1 FROM `jt_t9_run`);
DELETE FROM `landblock_instance` WHERE `landblock` IN (261,312,436,757,24903,349,7056,9606,17714,51056,54079) AND `variation_id` IS NULL AND EXISTS (SELECT 1 FROM `jt_t9_run`);

-- 0x0105 Black Spawn Den
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105000, 1609, 0x01050100, 43.572, -70.1673, -29.995, -0.714278, 0, 0, 0.699862, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050100 [43.571999 -70.167297 -29.995001] -0.714278 0.000000 0.000000 0.699862 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105001, 1609, 0x01050101, 43.189, -80.0995, -29.995, 0.639605, 0, 0, -0.768704, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050101 [43.188999 -80.099503 -29.995001] 0.639605 0.000000 0.000000 -0.768704 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105002, 1609, 0x01050102, 43.0124, -90.013, -29.995, 0.711946, 0, 0, -0.702234, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050102 [43.012402 -90.013000 -29.995001] 0.711946 0.000000 0.000000 -0.702234 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105003, 1609, 0x01050103, 43.0318, -99.926, -29.995, -0.729916, 0, 0, 0.683537, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050103 [43.031799 -99.926003 -29.995001] -0.729916 0.000000 0.000000 0.683537 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105004, 1295, 0x01050104, 52, -50, -29.995, -0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01050104 [52.000000 -50.000000 -29.995001] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105005, 1295, 0x01050104, 48, -50, -29.995, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Door */
/* @teleloc 0x01050104 [48.000000 -50.000000 -29.995001] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105006, 237, 0x01050104, 50.1037, -49.1287, -29.971, -0.001962, 0, 0, 0.999998, True, '2005-02-09 10:00:00'); /* Virindi Master */
/* @teleloc 0x01050104 [50.103699 -49.128700 -29.971001] -0.001962 0.000000 0.000000 0.999998 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105007, 23, 0x01050108, 49.907, -68.8986, -29.971, -0.025218, 0, 0, 0.999682, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x01050108 [49.907001 -68.898598 -29.971001] -0.025218 0.000000 0.000000 0.999682 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105008, 3969, 0x01050109, 50, -80, -29.995, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Chest */
/* @teleloc 0x01050109 [50.000000 -80.000000 -29.995001] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105009, 23, 0x0105010B, 49.8783, -96.9149, -29.971, 0.02285, 0, 0, 0.999739, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x0105010B [49.878300 -96.914902 -29.971001] 0.022850 0.000000 0.000000 0.999739 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010500A, 1629, 0x0105010D, 49.6005, -121.11, -29.989, -0.014911, 0, 0, -0.999889, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x0105010D [49.600498 -121.110001 -29.989000] -0.014911 0.000000 0.000000 -0.999889 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010500B, 1609, 0x0105010F, 57.4338, -70.1436, -29.995, 0.745879, 0, 0, 0.666082, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x0105010F [57.433800 -70.143600 -29.995001] 0.745879 0.000000 0.000000 0.666082 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010500C, 1609, 0x01050110, 57.2982, -80.2555, -29.995, -0.626704, 0, 0, -0.779257, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050110 [57.298199 -80.255501 -29.995001] -0.626704 0.000000 0.000000 -0.779257 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010500D, 1609, 0x01050111, 57.023, -89.8695, -29.995, 0.687631, 0, 0, 0.72606, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050111 [57.022999 -89.869499 -29.995001] 0.687631 0.000000 0.000000 0.726060 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010500E, 1609, 0x01050112, 57.2996, -99.816, -29.995, -0.690043, 0, 0, -0.723769, True, '2005-02-09 10:00:00'); /* Drudge Stalker */
/* @teleloc 0x01050112 [57.299599 -99.816002 -29.995001] -0.690043 0.000000 0.000000 -0.723769 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010500F, 1610, 0x01050113, 33.118, -70.3214, -23.995, -0.565535, 0, 0, 0.824725, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050113 [33.118000 -70.321404 -23.995001] -0.565535 0.000000 0.000000 0.824725 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105010, 1610, 0x01050114, 32.9363, -79.7362, -23.995, 0.555508, 0, 0, -0.831511, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050114 [32.936298 -79.736198 -23.995001] 0.555508 0.000000 0.000000 -0.831511 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105011, 1610, 0x01050115, 32.9976, -89.9293, -23.995, -0.604202, 0, 0, 0.796831, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050115 [32.997601 -89.929298 -23.995001] -0.604202 0.000000 0.000000 0.796831 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105012, 1610, 0x01050116, 33.2514, -99.8193, -23.995, 0.636841, 0, 0, -0.770995, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050116 [33.251400 -99.819298 -23.995001] 0.636841 0.000000 0.000000 -0.770995 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105013, 1610, 0x01050117, 33.6875, -109.839, -23.995, -0.698834, 0, 0, 0.715284, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050117 [33.687500 -109.838997 -23.995001] -0.698834 0.000000 0.000000 0.715284 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105014, 1629, 0x01050118, 28.2383, -270.488, -23.989, 0.819661, 0, 0, 0.572849, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050118 [28.238300 -270.488007 -23.989000] 0.819661 0.000000 0.000000 0.572849 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105015, 1629, 0x01050118, 29.6415, -269.403, -23.989, 0.797274, 0, 0, 0.603617, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050118 [29.641500 -269.403015 -23.989000] 0.797274 0.000000 0.000000 0.603617 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105016, 23, 0x0105011A, 39.8133, -49.8661, -26.971, -0.714805, 0, 0, 0.699324, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x0105011A [39.813301 -49.866100 -26.971001] -0.714805 0.000000 0.000000 0.699324 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105017, 1610, 0x0105011D, 44.2422, -71.1141, -23.995, -0.610673, 0, 0, 0.791883, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105011D [44.242199 -71.114098 -23.995001] -0.610673 0.000000 0.000000 0.791883 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105018, 23, 0x0105011D, 37.8695, -72.2563, -23.971, -0.973039, 0, 0, 0.230641, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x0105011D [37.869499 -72.256302 -23.971001] -0.973039 0.000000 0.000000 0.230641 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105019, 1610, 0x0105011F, 43.4082, -91.2635, -23.995, -0.676424, 0, 0, 0.736512, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105011F [43.408199 -91.263496 -23.995001] -0.676424 0.000000 0.000000 0.736512 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010501A, 1610, 0x01050121, 42.6135, -106.806, -23.995, -0.78053, 0, 0, 0.625119, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050121 [42.613499 -106.806000 -23.995001] -0.780530 0.000000 0.000000 0.625119 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010501B, 1629, 0x01050122, 41.7378, -149.735, -23.989, 0.692279, 0, 0, -0.721631, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050122 [41.737801 -149.735001 -23.989000] 0.692279 0.000000 0.000000 -0.721631 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010501C, 1629, 0x01050123, 42.9987, -170.39, -23.989, 0.693294, 0, 0, -0.720655, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050123 [42.998699 -170.389999 -23.989000] 0.693294 0.000000 0.000000 -0.720655 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010501D, 1629, 0x01050124, 42.6402, -190.449, -23.989, 0.70436, 0, 0, -0.709843, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050124 [42.640202 -190.449005 -23.989000] 0.704360 0.000000 0.000000 -0.709843 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010501E, 1629, 0x01050125, 42.1605, -210.656, -23.989, 0.716327, 0, 0, -0.697764, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050125 [42.160500 -210.656006 -23.989000] 0.716327 0.000000 0.000000 -0.697764 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010501F, 1629, 0x01050127, 40.2185, -230.805, -23.989, 0.012462, 0, 0, -0.999922, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050127 [40.218498 -230.804993 -23.989000] 0.012462 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105020, 1629, 0x01050146, 50.1836, -166.794, -23.945, -0.03184, 0, 0, -0.999493, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050146 [50.183601 -166.794006 -23.945000] -0.031840 0.000000 0.000000 -0.999493 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105021, 1629, 0x01050150, 49.8087, -202.788, -23.989, 0.007625, 0, 0, 0.999971, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050150 [49.808701 -202.787994 -23.989000] 0.007625 0.000000 0.000000 0.999971 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105022, 3955, 0x01050154, 49.3402, -209.248, -23.995, 0.999956, 0, 0, 0.009417, False, '2005-02-09 10:00:00'); /* Linkable Monster Gen (15 min.) */
/* @teleloc 0x01050154 [49.340199 -209.248001 -23.995001] 0.999956 0.000000 0.000000 0.009417 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70105022, 0x70105000, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105001, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105002, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105003, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010500A, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010500B, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010500C, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010500D, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010500E, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010500F, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105010, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105011, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105012, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105013, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105017, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105019, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010501A, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010501B, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010501C, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010501D, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010501E, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105020, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105021, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105027, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105028, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105029, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010502A, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010502B, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010502C, '2005-02-09 10:00:00')
     , (0x70105022, 0x7010502D, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105031, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105032, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105033, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105034, '2005-02-09 10:00:00')
     , (0x70105022, 0x70105035, '2005-02-09 10:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105023, 1629, 0x01050157, 46.9803, -228.518, -23.945, -0.514011, 0, 0, -0.857784, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050157 [46.980301 -228.518005 -23.945000] -0.514011 0.000000 0.000000 -0.857784 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105024, 1629, 0x01050159, 52.0015, -229.335, -23.989, 0.239726, 0, 0, -0.970841, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050159 [52.001499 -229.335007 -23.989000] 0.239726 0.000000 0.000000 -0.970841 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105025, 23, 0x0105016A, 59.6545, -50.1152, -26.971, 0.703272, 0, 0, 0.710921, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x0105016A [59.654499 -50.115200 -26.971001] 0.703272 0.000000 0.000000 0.710921 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105026, 23, 0x0105016C, 61.6973, -70.5784, -23.971, -0.930289, 0, 0, -0.366828, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x0105016C [61.697300 -70.578400 -23.971001] -0.930289 0.000000 0.000000 -0.366828 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105027, 1610, 0x0105016D, 56.6512, -76.5149, -23.995, 0.696427, 0, 0, 0.717628, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105016D [56.651199 -76.514900 -23.995001] 0.696427 0.000000 0.000000 0.717628 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105028, 1610, 0x0105016E, 56.6847, -86.8118, -23.995, 0.560381, 0, 0, 0.828235, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105016E [56.684700 -86.811798 -23.995001] 0.560381 0.000000 0.000000 0.828235 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105029, 1610, 0x0105016F, 56.4259, -101.08, -23.995, 0.663166, 0, 0, 0.748473, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105016F [56.425900 -101.080002 -23.995001] 0.663166 0.000000 0.000000 0.748473 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010502A, 1629, 0x01050171, 56.4287, -149.34, -23.945, -0.63961, 0, 0, -0.7687, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050171 [56.428699 -149.339996 -23.945000] -0.639610 0.000000 0.000000 -0.768700 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010502B, 1629, 0x01050172, 57.1122, -170.827, -23.989, 0.716215, 0, 0, 0.69788, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050172 [57.112202 -170.826996 -23.989000] 0.716215 0.000000 0.000000 0.697880 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010502C, 1629, 0x01050173, 58.0964, -189.567, -23.989, -0.674981, 0, 0, -0.737835, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050173 [58.096401 -189.567001 -23.989000] -0.674981 0.000000 0.000000 -0.737835 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010502D, 1629, 0x01050174, 56.532, -210.725, -23.989, -0.797303, 0, 0, -0.603579, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050174 [56.532001 -210.725006 -23.989000] -0.797303 0.000000 0.000000 -0.603579 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010502E, 1629, 0x01050176, 58.1749, -230.253, -23.945, -0.05455, 0, 0, -0.998511, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050176 [58.174900 -230.253006 -23.945000] -0.054550 0.000000 0.000000 -0.998511 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010502F, 1629, 0x01050182, 60.3451, -261.46, -23.989, 0.169967, 0, 0, -0.98545, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050182 [60.345100 -261.459991 -23.989000] 0.169967 0.000000 0.000000 -0.985450 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105030, 1629, 0x01050182, 58.4706, -260.842, -23.989, 0.117089, 0, 0, -0.993121, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050182 [58.470600 -260.842010 -23.989000] 0.117089 0.000000 0.000000 -0.993121 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105031, 1610, 0x01050187, 66.3435, -69.7593, -23.995, -0.725944, 0, 0, -0.687753, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050187 [66.343498 -69.759300 -23.995001] -0.725944 0.000000 0.000000 -0.687753 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105032, 1610, 0x01050188, 67.5602, -80.3295, -23.995, 0.780742, 0, 0, 0.624853, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050188 [67.560204 -80.329498 -23.995001] 0.780742 0.000000 0.000000 0.624853 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105033, 1610, 0x01050189, 66.9265, -90.3533, -23.995, 0.659997, 0, 0, 0.751268, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x01050189 [66.926498 -90.353302 -23.995001] 0.659997 0.000000 0.000000 0.751268 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105034, 1610, 0x0105018A, 67.102, -100.576, -23.995, 0.738844, 0, 0, 0.673876, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105018A [67.101997 -100.575996 -23.995001] 0.738844 0.000000 0.000000 0.673876 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105035, 1610, 0x0105018B, 67.296, -109.996, -23.995, -0.764999, 0, 0, -0.644031, True, '2005-02-09 10:00:00'); /* Drudge Ravener */
/* @teleloc 0x0105018B [67.295998 -109.996002 -23.995001] -0.764999 0.000000 0.000000 -0.644031 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105036, 1629, 0x01050191, 1e-06, -169.91, -17.989, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050191 [0.000001 -169.910004 -17.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105037, 1629, 0x01050191, 1e-06, -172.09, -17.989, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050191 [0.000001 -172.089996 -17.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105038, 1629, 0x01050192, -0.009024, -184.363, -17.945, 0.980067, 0, 0, -0.198669, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050192 [-0.009024 -184.363007 -17.945000] 0.980067 0.000000 0.000000 -0.198669 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105039, 1629, 0x01050193, 1.15304, -189.445, -17.989, 0.999933, 0, 0, -0.011538, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050193 [1.153040 -189.445007 -17.989000] 0.999933 0.000000 0.000000 -0.011538 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010503A, 1629, 0x01050196, -0.419398, -219.6, -17.989, 0.733317, 0, 0, -0.679887, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050196 [-0.419398 -219.600006 -17.989000] 0.733317 0.000000 0.000000 -0.679887 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010503B, 1629, 0x010501AB, 9.68488, -222.779, -17.945, 0.99875, 0, 0, 0.049979, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501AB [9.684880 -222.779007 -17.945000] 0.998750 0.000000 0.000000 0.049979 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010503C, 1629, 0x010501BA, 10, -251.092, -17.989, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501BA [10.000000 -251.091995 -17.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010503D, 1629, 0x010501BA, 11.2335, -249.074, -17.989, 0.99992, 0, 0, 0.012668, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501BA [11.233500 -249.074005 -17.989000] 0.999920 0.000000 0.000000 0.012668 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010503E, 1629, 0x010501C0, 18.1329, -190.582, -17.989, 0.724162, 0, 0, -0.68963, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501C0 [18.132900 -190.582001 -17.989000] 0.724162 0.000000 0.000000 -0.689630 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010503F, 1629, 0x010501C0, 19.9043, -192.785, -17.989, 0.84088, 0, 0, -0.541222, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501C0 [19.904301 -192.785004 -17.989000] 0.840880 0.000000 0.000000 -0.541222 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105040, 1629, 0x010501C3, 19.8006, -222.002, -17.945, 0.764963, 0, 0, 0.644074, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501C3 [19.800600 -222.001999 -17.945000] 0.764963 0.000000 0.000000 0.644074 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105041, 1629, 0x010501C3, 20.4939, -220.268, -17.989, 0.782246, 0, 0, 0.62297, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501C3 [20.493900 -220.268005 -17.989000] 0.782246 0.000000 0.000000 0.622970 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105042, 1629, 0x010501EE, 80, -200, -17.989, 0.947651, 0, 0, -0.319309, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501EE [80.000000 -200.000000 -17.989000] 0.947651 0.000000 0.000000 -0.319309 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105043, 1629, 0x010501EE, 79.5623, -202.491, -17.989, 0.996258, 0, 0, -0.08643, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501EE [79.562302 -202.490997 -17.989000] 0.996258 0.000000 0.000000 -0.086430 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105044, 1629, 0x010501F0, 81.9908, -219.787, -17.945, 0.706638, 0, 0, -0.707575, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010501F0 [81.990799 -219.787003 -17.945000] 0.706638 0.000000 0.000000 -0.707575 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105045, 1629, 0x01050202, 90, -208.312, -17.989, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050202 [90.000000 -208.311996 -17.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105046, 1629, 0x0105020B, 90.1296, -228.261, -17.989, -0.999982, 0, 0, 0.006016, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x0105020B [90.129601 -228.261002 -17.989000] -0.999982 0.000000 0.000000 0.006016 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105047, 1629, 0x01050218, 91.7557, -266.646, -17.945, 0.973554, 0, 0, 0.228458, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050218 [91.755699 -266.645996 -17.945000] 0.973554 0.000000 0.000000 0.228458 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105048, 1629, 0x01050219, 89.784, -269.99, -17.989, 0.978253, 0, 0, 0.207415, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050219 [89.783997 -269.989990 -17.989000] 0.978253 0.000000 0.000000 0.207415 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105049, 1629, 0x01050221, 100, -187.532, -17.989, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050221 [100.000000 -187.531998 -17.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010504A, 1629, 0x01050221, 102.109, -189.791, -17.989, 0.998916, 0, 0, 0.046546, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050221 [102.109001 -189.791000 -17.989000] 0.998916 0.000000 0.000000 0.046546 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010504B, 1629, 0x0105022C, 99.4869, -239.158, -17.989, 0.877582, 0, 0, 0.479426, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x0105022C [99.486900 -239.158005 -17.989000] 0.877582 0.000000 0.000000 0.479426 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010504C, 1629, 0x0105022C, 97.4658, -240.389, -17.945, 0.809628, 0, 0, 0.586944, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x0105022C [97.465797 -240.389008 -17.945000] 0.809628 0.000000 0.000000 0.586944 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010504D, 1629, 0x0105023A, 31.6378, -151.01, -11.989, 0.793066, 0, 0, -0.609136, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x0105023A [31.637800 -151.009995 -11.989000] 0.793066 0.000000 0.000000 -0.609136 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010504E, 1629, 0x01050243, 46.8028, -136.092, -11.989, 0.986968, 0, 0, -0.160919, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050243 [46.802799 -136.091995 -11.989000] 0.986968 0.000000 0.000000 -0.160919 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010504F, 1629, 0x01050243, 51.6864, -136.553, -11.945, 0.999974, 0, 0, 0.007218, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050243 [51.686401 -136.552994 -11.945000] 0.999974 0.000000 0.000000 0.007218 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105050, 23, 0x01050244, 50, -151.208, -11.971, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x01050244 [50.000000 -151.207993 -11.971000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105051, 1629, 0x01050245, 49.653, -160.372, -11.989, 0.998802, 0, 0, 0.048934, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050245 [49.653000 -160.371994 -11.989000] 0.998802 0.000000 0.000000 0.048934 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105052, 1629, 0x0105024C, 60.4711, -143.117, -11.989, 0.997189, 0, 0, 0.07493, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x0105024C [60.471100 -143.117004 -11.989000] 0.997189 0.000000 0.000000 0.074930 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105053, 1628, 0x01050263, 31.1164, -89.0045, -5.989, -0.998224, 0, 0, -0.059569, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050263 [31.116400 -89.004501 -5.989000] -0.998224 0.000000 0.000000 -0.059569 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105054, 1628, 0x01050263, 28.2423, -87.777, -5.989, -0.994004, 0, 0, -0.109347, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050263 [28.242300 -87.777000 -5.989000] -0.994004 0.000000 0.000000 -0.109347 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105055, 7243, 0x01050279, 60, -50, -5.995, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Surface Portal */
/* @teleloc 0x01050279 [60.000000 -50.000000 -5.995000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105056, 1629, 0x01050280, 83.6316, -108.721, -5.989, 0.724388, 0, 0, -0.689393, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050280 [83.631599 -108.721001 -5.989000] 0.724388 0.000000 0.000000 -0.689393 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105057, 1629, 0x01050280, 83.4299, -111.32, -5.989, 0.819275, 0, 0, -0.5734, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050280 [83.429901 -111.320000 -5.989000] 0.819275 0.000000 0.000000 -0.573400 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105058, 1629, 0x01050281, 84.1048, -128.725, -5.945, -0.602201, 0, 0, 0.798344, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050281 [84.104797 -128.725006 -5.945000] -0.602201 0.000000 0.000000 0.798344 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105059, 1629, 0x01050281, 81.7583, -131.377, -5.989, -0.724534, 0, 0, 0.689239, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x01050281 [81.758301 -131.376999 -5.989000] -0.724534 0.000000 0.000000 0.689239 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010505A, 1629, 0x010502A0, 100, -99.3964, -5.989, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502A0 [100.000000 -99.396400 -5.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010505B, 1629, 0x010502A0, 102.174, -101.659, -5.945, 0.999703, 0, 0, -0.024362, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502A0 [102.174004 -101.658997 -5.945000] 0.999703 0.000000 0.000000 -0.024362 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010505C, 1629, 0x010502A1, 96.2318, -100.912, -5.945, 0.977471, 0, 0, -0.211069, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502A1 [96.231796 -100.912003 -5.945000] 0.977471 0.000000 0.000000 -0.211069 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010505D, 1629, 0x010502B6, 99.9638, -150.348, -5.989, -0.999516, 0, 0, -0.031124, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502B6 [99.963799 -150.348007 -5.989000] -0.999516 0.000000 0.000000 -0.031124 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010505E, 1629, 0x010502B6, 101.507, -147.4, -5.989, -0.999401, 0, 0, 0.034596, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502B6 [101.507004 -147.399994 -5.989000] -0.999401 0.000000 0.000000 0.034596 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010505F, 1629, 0x010502BE, 113.951, -109.719, -5.989, 0.413155, 0, 0, 0.910661, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502BE [113.950996 -109.719002 -5.989000] 0.413155 0.000000 0.000000 0.910661 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105060, 1629, 0x010502D1, 116.777, -108.934, -5.945, 0.663821, 0, 0, 0.747892, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D1 [116.777000 -108.933998 -5.945000] 0.663821 0.000000 0.000000 0.747892 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105061, 1629, 0x010502D2, 115.78, -130.449, -5.945, 0.771548, 0, 0, 0.636171, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D2 [115.779999 -130.449005 -5.945000] 0.771548 0.000000 0.000000 0.636171 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105062, 1629, 0x010502D2, 117.568, -129.826, -5.989, 0.793028, 0, 0, 0.609186, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D2 [117.568001 -129.826004 -5.989000] 0.793028 0.000000 0.000000 0.609186 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105063, 1629, 0x010502D3, 123.019, -170.285, -5.989, 0.707642, 0, 0, 0.706571, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D3 [123.018997 -170.285004 -5.989000] 0.707642 0.000000 0.000000 0.706571 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105064, 1629, 0x010502D5, 142.657, -171.541, -5.989, 0.81535, 0, 0, 0.578968, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D5 [142.656998 -171.541000 -5.989000] 0.815350 0.000000 0.000000 0.578968 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105065, 1629, 0x010502D5, 140.693, -169.362, -5.989, 0.755708, 0, 0, 0.654909, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D5 [140.692993 -169.362000 -5.989000] 0.755708 0.000000 0.000000 0.654909 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105066, 1629, 0x010502D6, 139.366, -180.701, -5.989, 0.994424, 0, 0, 0.105458, True, '2005-02-09 10:00:00'); /* Tusker Guard */
/* @teleloc 0x010502D6 [139.365997 -180.701004 -5.989000] 0.994424 0.000000 0.000000 0.105458 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105067, 237, 0x010502D6, 142.467, -182.299, -5.971, 0.993202, 0, 0, 0.116402, True, '2005-02-09 10:00:00'); /* Virindi Master */
/* @teleloc 0x010502D6 [142.466995 -182.298996 -5.971000] 0.993202 0.000000 0.000000 0.116402 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105068, 23, 0x010502D6, 140, -182.666, -5.971, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Virindi Servant */
/* @teleloc 0x010502D6 [140.000000 -182.666000 -5.971000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105069, 3985, 0x010502D6, 140, -184.5, -5.995, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Chest */
/* @teleloc 0x010502D6 [140.000000 -184.500000 -5.995000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010506A, 1628, 0x010502E1, 49.6498, -61.2202, 0.011, -0.185889, 0, 0, 0.982571, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x010502E1 [49.649799 -61.220200 0.011000] -0.185889 0.000000 0.000000 0.982571 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010506B, 1628, 0x010502E1, 48.5054, -59.7745, 0.011, -0.022663, 0, 0, 0.999743, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x010502E1 [48.505402 -59.774502 0.011000] -0.022663 0.000000 0.000000 0.999743 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010506C, 1628, 0x010502E2, 48.7024, -64.1167, 0.055, -0.022663, 0, 0, 0.999743, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x010502E2 [48.702400 -64.116699 0.055000] -0.022663 0.000000 0.000000 0.999743 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010506D, 1628, 0x01050303, 59.7264, -99.3372, 0.011, -0.249123, 0, 0, 0.968472, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050303 [59.726398 -99.337196 0.011000] -0.249123 0.000000 0.000000 0.968472 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010506E, 1628, 0x01050303, 61.8249, -98.4747, 0.055, -0.490748, 0, 0, 0.871302, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050303 [61.824902 -98.474701 0.055000] -0.490748 0.000000 0.000000 0.871302 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010506F, 1628, 0x0105030D, 74.1245, -80.2826, 0.055, -0.367124, 0, 0, 0.930172, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x0105030D [74.124496 -80.282600 0.055000] -0.367124 0.000000 0.000000 0.930172 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105070, 1628, 0x01050310, 65.478, -79.2964, 0.055, -0.183281, 0, 0, 0.983061, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050310 [65.477997 -79.296402 0.055000] -0.183281 0.000000 0.000000 0.983061 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105071, 1628, 0x01050320, 70.9182, -121.009, 0.011, 0.696707, 0, 0, -0.717356, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050320 [70.918198 -121.009003 0.011000] 0.696707 0.000000 0.000000 -0.717356 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105072, 1628, 0x01050320, 69.4432, -118.515, 0.011, 0.684654, 0, 0, -0.728868, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050320 [69.443199 -118.514999 0.011000] 0.684654 0.000000 0.000000 -0.728868 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105073, 1628, 0x01050325, 80.0456, -69.2208, 0.011, -0.0292, 0, 0, -0.999574, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050325 [80.045601 -69.220802 0.011000] -0.029200 0.000000 0.000000 -0.999574 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105074, 1628, 0x01050325, 81.7767, -71.5448, 0.052949, -0.076849, 0, 0, -0.997043, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050325 [81.776703 -71.544800 0.052949] -0.076849 0.000000 0.000000 -0.997043 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105075, 1628, 0x01050338, 80, -130, 0.011, 0.911039, 0, 0, -0.412321, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050338 [80.000000 -130.000000 0.011000] 0.911039 0.000000 0.000000 -0.412321 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105076, 1628, 0x0105033F, 80, -150, 0.011, 0.714421, 0, 0, -0.699716, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x0105033F [80.000000 -150.000000 0.011000] 0.714421 0.000000 0.000000 -0.699716 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105077, 7243, 0x01050341, 80, -210, 0.005, 0.696707, 0, 0, -0.717356, False, '2005-02-09 10:00:00'); /* Surface Portal */
/* @teleloc 0x01050341 [80.000000 -210.000000 0.005000] 0.696707 0.000000 0.000000 -0.717356 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105078, 1628, 0x0105036F, 97.8906, -140.412, 0.055, -0.363027, 0, 0, 0.931779, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x0105036F [97.890602 -140.412003 0.055000] -0.363027 0.000000 0.000000 0.931779 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70105079, 1628, 0x01050377, 109.603, -140.554, 0.011, 0.027623, 0, 0, 0.999618, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050377 [109.602997 -140.554001 0.011000] 0.027623 0.000000 0.000000 0.999618 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010507A, 3955, 0x01050382, 110.001, -210.013, 0.005, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Linkable Monster Gen (15 min.) */
/* @teleloc 0x01050382 [110.000999 -210.013000 0.005000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7010507A, 0x70105067, '2005-02-09 10:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010507B, 3955, 0x01050382, 110.179, -208.522, 0.005, 0.999792, 0, 0, 0.020411, False, '2005-02-09 10:00:00'); /* Linkable Monster Gen (15 min.) */
/* @teleloc 0x01050382 [110.179001 -208.522003 0.005000] 0.999792 0.000000 0.000000 0.020411 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7010507B, 0x70105006, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105007, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105009, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105014, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105015, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105016, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105018, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010501F, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105023, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105024, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105025, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105026, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010502E, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010502F, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105030, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105036, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105037, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105038, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105039, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010503A, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010503B, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010503C, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010503D, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010503E, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010503F, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105040, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105041, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105042, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105043, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105044, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105045, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105046, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105047, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105048, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105049, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010504A, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010504B, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010504C, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010504D, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010504E, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010504F, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105050, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105051, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105052, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105053, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105054, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105056, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105057, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105058, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105059, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010505A, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010505B, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010505C, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010505D, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010505E, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010505F, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105060, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105061, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105062, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105063, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105064, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105065, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105066, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105068, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010506A, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010506B, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010506C, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010506D, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010506E, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010506F, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105070, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105071, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105072, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105073, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105074, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105075, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105076, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105078, '2005-02-09 10:00:00')
     , (0x7010507B, 0x70105079, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010507C, '2005-02-09 10:00:00')
     , (0x7010507B, 0x7010507D, '2005-02-09 10:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010507C, 1628, 0x01050383, 120.907, -168.382, 0.011, 0.430797, 0, 0, 0.902449, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050383 [120.906998 -168.382004 0.011000] 0.430797 0.000000 0.000000 0.902449 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7010507D, 1628, 0x01050383, 116.984, -167.955, 0.011, 0.062824, 0, 0, 0.998025, True, '2005-02-09 10:00:00'); /* Tusker Slave */
/* @teleloc 0x01050383 [116.984001 -167.955002 0.011000] 0.062824 0.000000 0.000000 0.998025 */

-- 0x0138 Lost City of Frore
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138001, 4998, 0x01380104, 10, -140, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380104 [10.000000 -140.000000 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138002, 4998, 0x01380108, 10, -158.667, -12, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380108 [10.000000 -158.667007 -12.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138003, 4998, 0x0138010B, 20, -140, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138010B [20.000000 -140.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138004, 4998, 0x0138010F, 20, -148.667, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138010F [20.000000 -148.667007 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138005, 1625, 0x01380113, 30.0408, -139.358, -11.988, 0.432184, 0, 0, -0.901786, True, '2021-11-01 00:00:00'); /* Mountain Rat */
/* @teleloc 0x01380113 [30.040800 -139.358002 -11.988000] 0.432184 0.000000 0.000000 -0.901786 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138006, 4998, 0x01380114, 30, -160, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380114 [30.000000 -160.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138007, 4998, 0x0138011E, 40, -130, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138011E [40.000000 -130.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138008, 4986, 0x0138011E, 40, -130, -11.9925, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x0138011E [40.000000 -130.000000 -11.992500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138009, 4998, 0x01380128, 40, -170, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380128 [40.000000 -170.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013800A, 4998, 0x0138012C, 40, -180, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138012C [40.000000 -180.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013800B, 4998, 0x0138012D, 50, -120, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138012D [50.000000 -120.000000 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013800D, 4998, 0x0138013D, 60, -110, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138013D [60.000000 -110.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013800E, 4986, 0x0138013D, 59.5547, -110.603, -11.9925, 0.054949, 0, 0, -0.998489, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x0138013D [59.554699 -110.602997 -11.992500] 0.054949 0.000000 0.000000 -0.998489 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013800F, 4998, 0x01380141, 60, -160, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380141 [60.000000 -160.000000 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138011, 4998, 0x01380142, 60, -180, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380142 [60.000000 -180.000000 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138013, 4998, 0x01380143, 70, -100, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380143 [70.000000 -100.000000 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138014, 4998, 0x01380144, 71.1547, -120.667, -12, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380144 [71.154701 -120.667000 -12.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138016, 4998, 0x01380148, 70, -140, -12, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380148 [70.000000 -140.000000 -12.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138017, 4998, 0x01380154, 80, -150, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380154 [80.000000 -150.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138018, 4986, 0x01380158, 80, -160, -11.9925, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x01380158 [80.000000 -160.000000 -11.992500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138019, 4998, 0x01380159, 80, -168.667, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380159 [80.000000 -168.667007 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013801A, 4998, 0x0138015C, 90, -151.333, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138015C [90.000000 -151.332993 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013801B, 4998, 0x0138015F, 90, -160, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138015F [90.000000 -160.000000 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013801C, 1625, 0x0138015F, 88.8918, -160.546, -11.988, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Mountain Rat */
/* @teleloc 0x0138015F [88.891800 -160.546005 -11.988000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013801D, 1625, 0x0138015F, 91.1794, -158.225, -11.988, -0.954306, 0, 0, -0.298832, True, '2021-11-01 00:00:00'); /* Mountain Rat */
/* @teleloc 0x0138015F [91.179398 -158.225006 -11.988000] -0.954306 0.000000 0.000000 -0.298832 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013801E, 4998, 0x01380160, 90, -170, -12, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380160 [90.000000 -170.000000 -12.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013801F, 4998, 0x01380164, 101.155, -150.667, -12, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380164 [101.154999 -150.667007 -12.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138020, 4998, 0x01380167, 100, -160, -12, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380167 [100.000000 -160.000000 -12.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138021, 4984, 0x01380168, 99.0268, -170.748, -11.9925, -0.006764, 0, 0, -0.999977, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x01380168 [99.026802 -170.748001 -11.992500] -0.006764 0.000000 0.000000 -0.999977 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138023, 4998, 0x01380169, 100, -178.667, -12, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380169 [100.000000 -178.667007 -12.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138024, 4998, 0x0138016D, 34.9151, -191.27, -6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138016D [34.915100 -191.270004 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138025, 5625, 0x01380172, 30, -265.25, -6, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380172 [30.000000 -265.250000 -6.000000] -1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138026, 5625, 0x01380173, 30, -274.75, -6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380173 [30.000000 -274.750000 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138027, 5625, 0x01380174, 34.75, -270, -6, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380174 [34.750000 -270.000000 -6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138028, 4998, 0x0138017A, 38.9521, -199.077, -6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138017A [38.952099 -199.076996 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138029, 1299, 0x0138017D, 40, -254.75, -6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138017D [40.000000 -254.750000 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013802A, 4997, 0x0138017F, 40.2686, -269.387, -6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x0138017F [40.268600 -269.386993 -6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013802D, 5110, 0x01380185, 53.1155, -269.761, -6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x01380185 [53.115501 -269.760986 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013802F, 5624, 0x01380187, 50, -274.75, -6, 0, 0, 0, 1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380187 [50.000000 -274.750000 -6.000000] 0.000000 0.000000 0.000000 1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138030, 5624, 0x01380188, 50, -265.25, -6, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380188 [50.000000 -265.250000 -6.000000] -1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138031, 5624, 0x01380189, 45.25, -270, -6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380189 [45.250000 -270.000000 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138032, 4998, 0x0138018E, 75.5143, -90.9658, -6, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138018E [75.514297 -90.965797 -6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138033, 4998, 0x01380190, 82.7707, -101.921, -6, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x01380190 [82.770699 -101.920998 -6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138034, 4998, 0x0138019D, 112.039, -159.686, -5.9389, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x0138019D [112.039001 -159.686005 -5.938900] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138035, 5118, 0x0138019E, 120, -140, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x0138019E [120.000000 -140.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138036, 4998, 0x013801A0, 117.865, -146.33, -6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x013801A0 [117.864998 -146.330002 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138037, 2131, 0x013801A0, 115.518, -150, -6, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x013801A0 [115.517998 -150.000000 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138038, 2131, 0x013801A0, 118.609, -150, -6, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x013801A0 [118.609001 -150.000000 -6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138039, 5118, 0x013801A1, 120, -160, 0, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801A1 [120.000000 -160.000000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013803A, 5626, 0x013801A6, 126.785, -150, -6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801A6 [126.785004 -150.000000 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013803B, 4986, 0x013801A7, 20, -210, 0.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x013801A7 [20.000000 -210.000000 0.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013803C, 5117, 0x013801AE, 32.2805, -209.095, 0.40125, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x013801AE [32.280499 -209.095001 0.401250] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013803E, 4999, 0x013801BB, 39.9811, -227.256, 6, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801BB [39.981098 -227.255997 6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013803F, 4986, 0x013801C1, 41.0665, -240.445, 0.0075, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x013801C1 [41.066502 -240.445007 0.007500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138041, 5624, 0x013801C3, 40, -244.75, 0, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801C3 [40.000000 -244.750000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138042, 5117, 0x013801CB, 52.6353, -211.378, 0.414625, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x013801CB [52.635300 -211.378006 0.414625] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138043, 143, 0x013801D8, 68.2475, -26.0875, 0.0125, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x013801D8 [68.247498 -26.087500 0.012500] -1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138044, 4986, 0x013801D8, 67.0795, -30.1519, 0.0075, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x013801D8 [67.079498 -30.151899 0.007500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138045, 5624, 0x013801DA, 74.75, -30, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801DA [74.750000 -30.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138046, 4984, 0x013801DC, 71.3124, -50.2768, 0.0075, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013801DC [71.312401 -50.276798 0.007500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138047, 143, 0x013801DC, 70.62, -45.925, 0, -1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x013801DC [70.620003 -45.924999 0.000000] -1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138048, 5624, 0x013801DE, 74.7606, -49.9918, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801DE [74.760597 -49.991798 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138049, 5110, 0x013801E1, 69.6982, -83.0857, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x013801E1 [69.698196 -83.085701 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013804B, 5624, 0x013801E3, 70, -75.25, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801E3 [70.000000 -75.250000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013804C, 5118, 0x013801E7, 80, -20, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801E7 [80.000000 -20.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013804D, 4984, 0x013801EC, 80.3146, -71.3276, 0.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013801EC [80.314598 -71.327599 0.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013804E, 3967, 0x013801EC, 77.1675, -74.05, 0.0125, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x013801EC [77.167503 -74.050003 0.012500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013804F, 5624, 0x013801EE, 80, -65.25, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801EE [80.000000 -65.250000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138050, 5118, 0x013801F3, 90, -20, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801F3 [90.000000 -20.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138053, 5118, 0x013801F5, 90, -50, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801F5 [90.000000 -50.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138054, 4984, 0x013801F6, 90.212, -58.6539, 0.0075, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013801F6 [90.211998 -58.653900 0.007500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138055, 4984, 0x013801F6, 87.8766, -60.2341, 0.0075, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013801F6 [87.876602 -60.234100 0.007500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138056, 5624, 0x013801F8, 94.75, -60, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013801F8 [94.750000 -60.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138057, 5118, 0x013801FA, 90, -80, 6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801FA [90.000000 -80.000000 6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138058, 5118, 0x013801FB, 90, -90, 6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013801FB [90.000000 -90.000000 6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138059, 4984, 0x013801FE, 100, 0, 0.0075, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013801FE [100.000000 0.000000 0.007500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013805A, 4984, 0x01380201, 99.9502, -18.2796, 0.0075, -0.995644, 0, 0, -0.093239, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x01380201 [99.950203 -18.279600 0.007500] -0.995644 0.000000 0.000000 -0.093239 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013805B, 5624, 0x01380203, 95.25, -20, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380203 [95.250000 -20.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013805C, 5624, 0x01380204, 100, -15.25, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380204 [100.000000 -15.250000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013805D, 5118, 0x01380205, 100, -30, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380205 [100.000000 -30.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013805E, 4986, 0x01380206, 100.307, -41.137, 0.0075, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x01380206 [100.306999 -41.137001 0.007500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013805F, 5868, 0x01380206, 100.847, -38.0466, 0.0075, -0.462531, 0, 0, -0.886603, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x01380206 [100.847000 -38.046600 0.007500] -0.462531 0.000000 0.000000 -0.886603 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138060, 5000, 0x01380206, 96.5457, -40.0341, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x01380206 [96.545700 -40.034100 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138063, 4999, 0x01380206, 97.9245, -41.8037, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380206 [97.924500 -41.803699 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138064, 4999, 0x01380206, 97.8824, -37.8229, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380206 [97.882401 -37.822899 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138065, 5624, 0x01380208, 95.25, -40, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380208 [95.250000 -40.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138066, 5118, 0x01380209, 100, -50, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380209 [100.000000 -50.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138067, 5118, 0x0138020B, 100, -70, 6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x0138020B [100.000000 -70.000000 6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138068, 5118, 0x01380213, 110, -30, 0, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380213 [110.000000 -30.000000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138069, 4984, 0x01380215, 110, -60, 0.0075, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x01380215 [110.000000 -60.000000 0.007500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013806A, 5624, 0x01380217, 105.25, -60, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380217 [105.250000 -60.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013806B, 5117, 0x0138021F, 110, -110, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x0138021F [110.000000 -110.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013806C, 5117, 0x01380223, 120, -90, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380223 [120.000000 -90.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013806D, 4064, 0x0138022D, 123.795, -151.061, 4.614, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Whirling Blade Trap */
/* @teleloc 0x0138022D [123.794998 -151.061005 4.614000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7013806D, 0x70138038, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013806E, 4064, 0x0138022D, 123.803, -149.215, 4.574, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Whirling Blade Trap */
/* @teleloc 0x0138022D [123.803001 -149.214996 4.574000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7013806E, 0x70138037, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013806F, 4984, 0x0138022F, 130, -90, 0.0075, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x0138022F [130.000000 -90.000000 0.007500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138070, 4984, 0x0138022F, 128.718, -87.9697, 0.0075, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x0138022F [128.718002 -87.969704 0.007500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138071, 4984, 0x0138023B, 129.385, -138.041, 0.0075, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x0138023B [129.384995 -138.041000 0.007500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138072, 4984, 0x0138023B, 129.85, -141.054, 0.0075, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x0138023B [129.850006 -141.054001 0.007500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138073, 5624, 0x0138023D, 125.25, -140, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138023D [125.250000 -140.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138074, 4984, 0x0138023F, 130, -160, 0.0075, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x0138023F [130.000000 -160.000000 0.007500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138075, 278, 0x01380241, 134.75, -160, 0, -0.707107, 0, 0, 0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380241 [134.750000 -160.000000 0.000000] -0.707107 0.000000 0.000000 0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138076, 5624, 0x01380242, 125.25, -160, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380242 [125.250000 -160.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138077, 278, 0x01380243, 130, -164.75, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380243 [130.000000 -164.750000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138078, 5117, 0x01380246, 140, -90, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380246 [140.000000 -90.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138079, 4984, 0x01380248, 143.211, -101.992, 0.0075, 0.617293, 0, 0, -0.786733, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x01380248 [143.210999 -101.991997 0.007500] 0.617293 0.000000 0.000000 -0.786733 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013807A, 4984, 0x01380248, 141.953, -104.176, 0.0075, 0.242662, 0, 0, -0.970111, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x01380248 [141.953003 -104.176003 0.007500] 0.242662 0.000000 0.000000 -0.970111 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013807B, 5117, 0x01380255, 140, -130, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380255 [140.000000 -130.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013807C, 5868, 0x01380266, 145.99, -111.208, 0.0075, -0.879511, 0, 0, 0.475879, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x01380266 [145.990005 -111.208000 0.007500] -0.879511 0.000000 0.000000 0.475879 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013807F, 4984, 0x01380270, 150, -160, 0.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x01380270 [150.000000 -160.000000 0.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138080, 5117, 0x01380273, 160, -100, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380273 [160.000000 -100.000000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138081, 4997, 0x01380273, 162.536, -102.976, 0, -0.707107, 0, 0, 0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380273 [162.535995 -102.975998 0.000000] -0.707107 0.000000 0.000000 0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138082, 5117, 0x01380276, 160, -130, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380276 [160.000000 -130.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138083, 4986, 0x01380280, 163.516, -171.45, 0.0075, 0.88223, 0, 0, -0.470819, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x01380280 [163.516006 -171.449997 0.007500] 0.882230 0.000000 0.000000 -0.470819 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138085, 2131, 0x01380282, 160, -170, 0, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x01380282 [160.000000 -170.000000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138086, 4067, 0x01380282, 159.989, -171.741, 0.53225, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Frost Trap */
/* @teleloc 0x01380282 [159.988998 -171.740997 0.532250] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x70138086, 0x70138085, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138087, 4999, 0x01380287, 162.97, -190.041, 6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380287 [162.970001 -190.041000 6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138088, 4999, 0x01380287, 156.95, -190.035, 6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380287 [156.949997 -190.035004 6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138089, 5117, 0x01380296, 165.25, -154.75, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x01380296 [165.250000 -154.750000 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013808A, 1924, 0x013802A0, 168.967, -173.545, 0, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x013802A0 [168.966995 -173.544998 0.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013808B, 4986, 0x013802A0, 166.584, -165.704, 0.0075, -0.177514, 0, 0, -0.984118, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x013802A0 [166.584000 -165.703995 0.007500] -0.177514 0.000000 0.000000 -0.984118 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013808C, 4984, 0x013802A0, 167.978, -167.725, 0.0075, -0.821398, 0, 0, -0.570355, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013802A0 [167.977997 -167.725006 0.007500] -0.821398 0.000000 0.000000 -0.570355 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013808D, 4999, 0x013802A9, 172.648, -190.016, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802A9 [172.647995 -190.016006 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013808E, 4999, 0x013802A9, 167.913, -190.008, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802A9 [167.912994 -190.007996 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013808F, 4139, 0x013802B2, 180, -114.75, 0, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013802B2 [180.000000 -114.750000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7013808F, 0x701380AF, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138090, 5117, 0x013802B3, 180, -120, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x013802B3 [180.000000 -120.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138091, 4984, 0x013802B3, 180, -120, 0.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013802B3 [180.000000 -120.000000 0.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138092, 4997, 0x013802B3, 180.864, -116.907, 0, 0, 0, 0, 1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x013802B3 [180.863998 -116.906998 0.000000] 0.000000 0.000000 0.000000 1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138093, 5117, 0x013802C2, 180, -170, 0, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x013802C2 [180.000000 -170.000000 0.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138095, 4984, 0x013802C4, 190, -130, 0.0075, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013802C4 [190.000000 -130.000000 0.007500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138096, 5624, 0x013802C6, 185.245, -130, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013802C6 [185.244995 -130.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138097, 4999, 0x013802C7, 189.969, -142.367, 6, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802C7 [189.968994 -142.367004 6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138098, 4999, 0x013802C7, 190.099, -137.464, 6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802C7 [190.098999 -137.464005 6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x70138099, 4999, 0x013802CD, 190, -150.013, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802CD [190.000000 -150.013000 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013809A, 4984, 0x013802D3, 190, -160, 0.0075, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013802D3 [190.000000 -160.000000 0.007500] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013809B, 5624, 0x013802D6, 185.25, -160, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013802D6 [185.250000 -160.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013809C, 4984, 0x013802D7, 190, -170, 0.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013802D7 [190.000000 -170.000000 0.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013809D, 4984, 0x013802D7, 190, -170, 0.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013802D7 [190.000000 -170.000000 0.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013809E, 5624, 0x013802D9, 185.25, -170, 0, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013802D9 [185.250000 -170.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7013809F, 5118, 0x013802EE, 39.8798, -210.007, 8.48775, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802EE [39.879799 -210.007004 8.487750] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380A0, 4986, 0x013802EF, 36.7609, -218.347, 6.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x013802EF [36.760899 -218.347000 6.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380A1, 4999, 0x013802EF, 40.0203, -215.679, 6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x013802EF [40.020302 -215.679001 6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380A8, 5118, 0x0138031F, 90, -60, 6, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x0138031F [90.000000 -60.000000 6.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380A9, 5118, 0x01380325, 100, -20, 6, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380325 [100.000000 -20.000000 6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380AC, 5118, 0x0138032C, 100, -90, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x0138032C [100.000000 -90.000000 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380AD, 5118, 0x01380338, 110, -60, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380338 [110.000000 -60.000000 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380AF, 2609, 0x01380390, 190, -130, 6, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Lever */
/* @teleloc 0x01380390 [190.000000 -130.000000 6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B0, 4999, 0x01380390, 190, -130, 7.93937, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380390 [190.000000 -130.000000 7.939370] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B3, 4999, 0x01380396, 190, -170, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380396 [190.000000 -170.000000 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B4, 4999, 0x01380396, 187.742, -173.5, 6, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380396 [187.742004 -173.500000 6.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B5, 4986, 0x01380398, 190, -190, 6.0075, -0.88223, 0, 0, -0.470819, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x01380398 [190.000000 -190.000000 6.007500] -0.882230 0.000000 0.000000 -0.470819 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B7, 4984, 0x013803D0, 89.9242, -13.7048, 12.0075, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x013803D0 [89.924202 -13.704800 12.007500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B8, 5868, 0x013803E3, 100.503, -100.096, 12.0075, 0.779475, 0, 0, -0.626433, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x013803E3 [100.502998 -100.096001 12.007500] 0.779475 0.000000 0.000000 -0.626433 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380B9, 1292, 0x013803E5, 99.9973, -95.2369, 12, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x013803E5 [99.997299 -95.236900 12.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380BA, 4068, 0x01380400, 112.056, -100.995, 13.926, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Shockwave Trap */
/* @teleloc 0x01380400 [112.056000 -100.995003 13.926000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x701380BA, 0x701380BB, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380BB, 2131, 0x01380400, 109.929, -96.3489, 12, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x01380400 [109.929001 -96.348900 12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380BC, 5868, 0x0138045C, 83.3126, -50.0363, 18.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x0138045C [83.312599 -50.036301 18.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380BD, 5625, 0x0138045C, 84.8578, -49.9791, 18, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138045C [84.857803 -49.979099 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380BE, 5625, 0x0138045D, 84.85, -59.99, 18, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138045D [84.849998 -59.990002 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380BF, 5868, 0x0138045E, 82.1602, -69.6088, 18.0075, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x0138045E [82.160202 -69.608803 18.007500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C0, 5625, 0x0138045E, 84.85, -69.99, 18, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138045E [84.849998 -69.989998 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C1, 5118, 0x0138045F, 83.112, -93.6053, 18, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x0138045F [83.112000 -93.605301 18.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C4, 5624, 0x01380463, 90, -44.75, 18, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380463 [90.000000 -44.750000 18.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C5, 4999, 0x01380464, 87.0586, -52.6198, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380464 [87.058601 -52.619801 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C6, 4999, 0x01380464, 92.6206, -52.7717, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380464 [92.620598 -52.771702 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C7, 4999, 0x01380464, 92.6304, -47.5407, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380464 [92.630402 -47.540699 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C8, 4999, 0x01380464, 87.2005, -47.459, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380464 [87.200500 -47.459000 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380C9, 5000, 0x01380464, 90.0244, -46.6207, 18.005, 0.001091, 0, 0, 0.999999, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x01380464 [90.024399 -46.620701 18.004999] 0.001091 0.000000 0.000000 0.999999 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380CA, 4999, 0x01380465, 87.2922, -62.9386, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380465 [87.292198 -62.938599 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380CB, 4999, 0x01380465, 92.7673, -62.8208, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380465 [92.767303 -62.820801 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380CC, 4999, 0x01380465, 92.6358, -57.3588, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380465 [92.635803 -57.358799 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380CD, 4999, 0x01380465, 87.2226, -57.1437, 18.005, -0.012451, 0, 0, -0.999922, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380465 [87.222603 -57.143700 18.004999] -0.012451 0.000000 0.000000 -0.999922 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380CE, 5902, 0x01380466, 86.0822, -73.9504, 18.005, -0.386554, 0, 0, -0.922267, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x01380466 [86.082199 -73.950401 18.004999] -0.386554 0.000000 0.000000 -0.922267 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380CF, 4999, 0x01380466, 87.2317, -72.8073, 18, -0.001514, 0, 0, -0.999999, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380466 [87.231697 -72.807297 18.000000] -0.001514 0.000000 0.000000 -0.999999 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D0, 4999, 0x01380466, 87.3601, -66.9625, 18, -0.001514, 0, 0, -0.999999, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380466 [87.360100 -66.962502 18.000000] -0.001514 0.000000 0.000000 -0.999999 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D1, 4999, 0x01380466, 92.6783, -67.1875, 18, -0.001514, 0, 0, -0.999999, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380466 [92.678299 -67.187500 18.000000] -0.001514 0.000000 0.000000 -0.999999 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D2, 4999, 0x01380466, 92.7345, -72.7176, 18, -0.001514, 0, 0, -0.999999, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380466 [92.734497 -72.717598 18.000000] -0.001514 0.000000 0.000000 -0.999999 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D3, 5624, 0x01380467, 90, -75.25, 18, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x01380467 [90.000000 -75.250000 18.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D4, 5000, 0x01380467, 90.0436, -83.412, 18, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x01380467 [90.043602 -83.412003 18.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D5, 5118, 0x01380468, 90.0721, -89.75, 18.005, -0.010284, 0, 0, 0.999947, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x01380468 [90.072098 -89.750000 18.004999] -0.010284 0.000000 0.000000 0.999947 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380D6, 5000, 0x01380468, 90.0393, -86.4424, 18, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x01380468 [90.039299 -86.442398 18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380DD, 5625, 0x0138046B, 95.15, -50.01, 18, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138046B [95.150002 -50.009998 18.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380DE, 5868, 0x0138046C, 96.8243, -59.6688, 18.0075, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x0138046C [96.824303 -59.668800 18.007500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380DF, 5625, 0x0138046C, 95.15, -60.01, 18, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138046C [95.150002 -60.009998 18.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E0, 5625, 0x0138046D, 95.15, -70.01, 18, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x0138046D [95.150002 -70.010002 18.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E1, 26008, 0x01380100, 0.62683, -142.126, -11.989, 0.934049, 0, 0, -0.357146, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x01380100 [0.626830 -142.126007 -11.989000] 0.934049 0.000000 0.000000 -0.357146 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E2, 26008, 0x0138012D, 50.8919, -121.673, -11.989, 0.999887, 0, 0, -0.015054, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x0138012D [50.891899 -121.672997 -11.989000] 0.999887 0.000000 0.000000 -0.015054 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E3, 26008, 0x01380141, 60.9545, -161.673, -11.989, -0.999966, 0, 0, -0.008291, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x01380141 [60.954498 -161.673004 -11.989000] -0.999966 0.000000 0.000000 -0.008291 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E4, 26008, 0x01380142, 60.7346, -181.673, -11.989, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x01380142 [60.734600 -181.673004 -11.989000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E5, 26008, 0x01380144, 69.732, -119.8, -11.989, 0.382684, 0, 0, -0.923879, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x01380144 [69.732002 -119.800003 -11.989000] 0.382684 0.000000 0.000000 -0.923879 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E6, 26008, 0x01380168, 100.199, -173.714, -11.989, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x01380168 [100.198997 -173.714005 -11.989000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E7, 7925, 0x01380180, 40.8908, -277.673, -5.995, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 10 Min.) */
/* @teleloc 0x01380180 [40.890800 -277.673004 -5.995000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x701380E7, 0x701380E1, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380E2, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380E3, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380E4, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380E5, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380E6, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380E9, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380EA, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380EB, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380EC, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380ED, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380EE, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380EF, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380F0, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380F1, '2021-11-01 00:00:00')
     , (0x701380E7, 0x701380F2, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E8, 4219, 0x01380180, 37.6995, -277.673, -6, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 7 Min.) */
/* @teleloc 0x01380180 [37.699501 -277.673004 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x701380E8, 0x70138005, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138008, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013800E, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138018, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013801C, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013801D, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138021, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013803B, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013803F, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138044, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138046, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013804D, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138054, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138055, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138059, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013805A, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013805E, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013805F, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138069, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013806F, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138070, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138071, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138072, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138074, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138079, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013807A, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013807C, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013807F, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138083, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013808B, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013808C, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138091, '2021-11-01 00:00:00')
     , (0x701380E8, 0x70138095, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013809A, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013809C, '2021-11-01 00:00:00')
     , (0x701380E8, 0x7013809D, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380A0, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380B5, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380B7, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380B8, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380BC, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380BF, '2021-11-01 00:00:00')
     , (0x701380E8, 0x701380DE, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380E9, 26008, 0x01380185, 50, -270, -5.989, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x01380185 [50.000000 -270.000000 -5.989000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380EA, 26008, 0x013801C1, 39.1554, -238.724, 0.011, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x013801C1 [39.155399 -238.723999 0.011000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380EB, 26008, 0x013801E1, 70, -80, 0.011, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x013801E1 [70.000000 -80.000000 0.011000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380EC, 26008, 0x013801F3, 92.9234, -17.1053, 0.011, -0.44268, 0, 0, -0.89668, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x013801F3 [92.923401 -17.105301 0.011000] -0.442680 0.000000 0.000000 -0.896680 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380ED, 26008, 0x013801F3, 92.9516, -22.4556, 0.011, -0.945979, 0, 0, -0.324227, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x013801F3 [92.951599 -22.455601 0.011000] -0.945979 0.000000 0.000000 -0.324227 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380EE, 26008, 0x0138026F, 146.422, -150.053, 0.011, -0.717671, 0, 0, -0.696382, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x0138026F [146.421997 -150.052994 0.011000] -0.717671 0.000000 0.000000 -0.696382 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380EF, 26008, 0x0138032B, 100, -80, 6.011, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Golem */
/* @teleloc 0x0138032B [100.000000 -80.000000 6.011000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380F0, 23616, 0x01380469, 91.291, -100.546, 18, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Crystal Shard */
/* @teleloc 0x01380469 [91.291000 -100.545998 18.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380F1, 23616, 0x01380469, 87.952, -102.575, 18, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Crystal Shard */
/* @teleloc 0x01380469 [87.952003 -102.574997 18.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380F2, 23616, 0x01380469, 88.8106, -98.5545, 18, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Crystal Shard */
/* @teleloc 0x01380469 [88.810600 -98.554497 18.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701380F3, 43840, 0x013801D1, 54.4104, -270, 0, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Enchanted Mnemosyne */
/* @teleloc 0x013801D1 [54.410400 -270.000000 0.000000] 1.000000 0.000000 0.000000 0.000000 */

-- 0x01B4 Golem Burial Ground
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B400C, 2079, 0x01B40136, 100, -10, 0, -0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Surface */
/* @teleloc 0x01B40136 [100.000000 -10.000000 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4015, 201, 0x01B40100, 2.90323, -39.9944, 0.01, 0.678557, 0, 0, -0.734547, True, '2005-02-09 10:00:00'); /* Obsidian Golem */
/* @teleloc 0x01B40100 [2.903230 -39.994400 0.010000] 0.678557 0.000000 0.000000 -0.734547 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4016, 14521, 0x01B40104, 17.2028, 3.50972, 0.01, 0.24526, 0, 0, -0.969457, True, '2005-02-09 10:00:00'); /* Glacial Golem */
/* @teleloc 0x01B40104 [17.202801 3.509720 0.010000] 0.245260 0.000000 0.000000 -0.969457 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4017, 14521, 0x01B4010E, 34.2994, -14.0383, 0.01, 0.999981, 0, 0, -0.006106, True, '2005-02-09 10:00:00'); /* Glacial Golem */
/* @teleloc 0x01B4010E [34.299400 -14.038300 0.010000] 0.999981 0.000000 0.000000 -0.006106 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4018, 14521, 0x01B40118, 43.2907, -0.115853, 0.01, 0.550715, 0, 0, 0.834693, True, '2005-02-09 10:00:00'); /* Glacial Golem */
/* @teleloc 0x01B40118 [43.290699 -0.115853 0.010000] 0.550715 0.000000 0.000000 0.834693 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4019, 14521, 0x01B40118, 40.539, 2.93731, 0.01, 0.364673, 0, 0, 0.931136, True, '2005-02-09 10:00:00'); /* Glacial Golem */
/* @teleloc 0x01B40118 [40.539001 2.937310 0.010000] 0.364673 0.000000 0.000000 0.931136 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B401A, 14559, 0x01B4011F, 53.022, -19.899, 0.011, 0.707107, 0, 0, -0.707107, True, '2005-02-09 10:00:00'); /* Oak Golem */
/* @teleloc 0x01B4011F [53.021999 -19.899000 0.011000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B401B, 22933, 0x01B40125, 59.1172, -48.5905, 0.011, 0.707107, 0, 0, -0.707107, True, '2005-02-09 10:00:00'); /* Mist Golem */
/* @teleloc 0x01B40125 [59.117199 -48.590500 0.011000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B401C, 6645, 0x01B40126, 67.3715, -26.9436, 0.01, 0.592206, 0, 0, -0.805786, True, '2005-02-09 10:00:00'); /* Magma Golem */
/* @teleloc 0x01B40126 [67.371498 -26.943600 0.010000] 0.592206 0.000000 0.000000 -0.805786 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B401D, 23607, 0x01B40127, 71.9, -43.7, 0.005, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Runed Chest */
/* @teleloc 0x01B40127 [71.900002 -43.700001 0.005000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B401E, 4020, 0x01B40127, 72.24, -42.2196, 0.005, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Cheap Warrior Generator */
/* @teleloc 0x01B40127 [72.239998 -42.219601 0.005000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B401F, 4014, 0x01B40127, 70.689, -40.409, 0.005, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Cheap Magic Generator */
/* @teleloc 0x01B40127 [70.689003 -40.409000 0.005000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4020, 201, 0x01B40127, 67.8729, -39.8426, 0.01, -0.976196, 0, 0, 0.216892, True, '2005-02-09 10:00:00'); /* Obsidian Golem */
/* @teleloc 0x01B40127 [67.872902 -39.842602 0.010000] -0.976196 0.000000 0.000000 0.216892 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4021, 6645, 0x01B4012D, 78.0837, -33.7085, 0.01, -0.999789, 0, 0, -0.020539, True, '2005-02-09 10:00:00'); /* Magma Golem */
/* @teleloc 0x01B4012D [78.083702 -33.708500 0.010000] -0.999789 0.000000 0.000000 -0.020539 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4022, 6645, 0x01B4012D, 83.6141, -27.4804, 0.01, 0.732096, 0, 0, 0.681201, True, '2005-02-09 10:00:00'); /* Magma Golem */
/* @teleloc 0x01B4012D [83.614098 -27.480400 0.010000] 0.732096 0.000000 0.000000 0.681201 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4023, 194, 0x01B40133, 87.2964, -43.3201, 0.011, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Copper Golem */
/* @teleloc 0x01B40133 [87.296402 -43.320099 0.011000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4024, 194, 0x01B40133, 91.5018, -44.0492, 0.011, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Copper Golem */
/* @teleloc 0x01B40133 [91.501801 -44.049198 0.011000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4025, 7924, 0x01B40136, 96.9852, -10.0881, 0.005, 0.696707, 0, 0, 0.717356, False, '2005-02-09 10:00:00'); /* Linkable Monster Generator ( 5 Min.) */
/* @teleloc 0x01B40136 [96.985199 -10.088100 0.005000] 0.696707 0.000000 0.000000 0.717356 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x701B4025, 0x701B4015, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4016, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4017, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4018, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4019, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B401A, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B401B, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B401C, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4020, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4021, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4022, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4023, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4024, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4026, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4027, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4028, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B4029, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B402A, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B402B, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B402C, '2005-02-09 10:00:00')
     , (0x701B4025, 0x701B402D, '2005-02-09 10:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4026, 201, 0x01B4013D, 110.919, -11.0292, 0.011, 0.998404, 0, 0, -0.056475, True, '2005-02-09 10:00:00'); /* Obsidian Golem */
/* @teleloc 0x01B4013D [110.918999 -11.029200 0.011000] 0.998404 0.000000 0.000000 -0.056475 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4027, 201, 0x01B4013F, 110, -30, 0.011, 0.018434, 0, 0, -0.99983, True, '2005-02-09 10:00:00'); /* Obsidian Golem */
/* @teleloc 0x01B4013F [110.000000 -30.000000 0.011000] 0.018434 0.000000 0.000000 -0.999830 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4028, 201, 0x01B4013F, 107.526, -31.1445, 0.011, -0.236096, 0, 0, -0.97173, True, '2005-02-09 10:00:00'); /* Obsidian Golem */
/* @teleloc 0x01B4013F [107.526001 -31.144501 0.011000] -0.236096 0.000000 0.000000 -0.971730 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B4029, 14559, 0x01B40142, 107.625, -82.4293, 0.01, 0.918865, 0, 0, -0.394572, True, '2005-02-09 10:00:00'); /* Oak Golem */
/* @teleloc 0x01B40142 [107.625000 -82.429298 0.010000] 0.918865 0.000000 0.000000 -0.394572 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B402A, 14559, 0x01B40142, 112.427, -82.356, 0.01, 0.957313, 0, 0, 0.289055, True, '2005-02-09 10:00:00'); /* Oak Golem */
/* @teleloc 0x01B40142 [112.427002 -82.356003 0.010000] 0.957313 0.000000 0.000000 0.289055 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B402B, 22933, 0x01B40145, 117.558, -47.3163, 0.01, 0.023003, 0, 0, -0.999735, True, '2005-02-09 10:00:00'); /* Mist Golem */
/* @teleloc 0x01B40145 [117.557999 -47.316299 0.010000] 0.023003 0.000000 0.000000 -0.999735 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B402C, 22933, 0x01B40145, 121.983, -47.1125, 0.01, 0.023003, 0, 0, -0.999735, True, '2005-02-09 10:00:00'); /* Mist Golem */
/* @teleloc 0x01B40145 [121.983002 -47.112499 0.010000] 0.023003 0.000000 0.000000 -0.999735 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x701B402D, 22933, 0x01B40145, 120.146, -52.6413, 0.01, -0.999732, 0, 0, -0.023168, True, '2005-02-09 10:00:00'); /* Mist Golem */
/* @teleloc 0x01B40145 [120.146004 -52.641300 0.010000] -0.999732 0.000000 0.000000 -0.023168 */

-- 0x02F5 Halls of Metos
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5000, 5085, 0x02F50111, 60, -94.1, -52.9666, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Linkable Item Gen - 25 seconds */
/* @teleloc 0x02F50111 [60.000000 -94.099998 -52.966599] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F5000, 0x702F500E, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F500E, 34351, 0x02F50111, 60, -94.1, -52.9666, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Pyreal Mote */
/* @teleloc 0x02F50111 [60.000000 -94.099998 -52.966599] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53E8, 7296, 0x02F50100, 60, -70, -65.995, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Surface Portal */
/* @teleloc 0x02F50100 [60.000000 -70.000000 -65.995003] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53E9, 7296, 0x02F50161, 120, -320, -47.995, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Surface Portal */
/* @teleloc 0x02F50161 [120.000000 -320.000000 -47.994999] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53EA, 7296, 0x02F502B3, 110, -340, 0.005, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Surface Portal */
/* @teleloc 0x02F502B3 [110.000000 -340.000000 0.005000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53EB, 7923, 0x02F50296, 102.011, -319.496, 0.005, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 3 Min.) */
/* @teleloc 0x02F50296 [102.011002 -319.496002 0.005000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53EB, 0x702F5402, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5403, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5404, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5405, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5406, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5407, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5408, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5409, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F540A, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F540B, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F540C, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F540D, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F540E, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F540F, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5410, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5411, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5412, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5413, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5414, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5415, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5416, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5417, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5418, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5419, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F541A, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F541B, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F541C, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F541D, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F541E, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F541F, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5420, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5421, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5422, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5423, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5424, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5425, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5426, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5427, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5428, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5429, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F542A, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F542B, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F542C, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F542D, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F542E, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F542F, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5430, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5431, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5432, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5433, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5434, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5435, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5436, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5437, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5438, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5439, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F543A, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F543B, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F543C, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F543D, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F543E, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F543F, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5440, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5441, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5442, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5443, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5444, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5445, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5446, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5447, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5448, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F5449, '2021-11-01 00:00:00')
     , (0x702F53EB, 0x702F544A, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53EC, 4063, 0x02F5016A, 30, 1, -40.976, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Acid Trap */
/* @teleloc 0x02F5016A [30.000000 1.000000 -40.976002] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53EC, 0x702F53FA, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53ED, 4095, 0x02F5016A, 33.5438, 1.36339, -41.995, -0.999965, 0, 0, 0.008407, False, '2021-11-01 00:00:00'); /* Magic trap */
/* @teleloc 0x02F5016A [33.543800 1.363390 -41.994999] -0.999965 0.000000 0.000000 0.008407 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53ED, 0x702F53F9, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53EE, 4063, 0x02F50171, 30, -61.041, -40.976, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Acid Trap */
/* @teleloc 0x02F50171 [30.000000 -61.041000 -40.976002] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53EE, 0x702F53FB, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53EF, 4077, 0x02F50173, 42.2427, -10.051, -41.995, 0.720823, 0, 0, -0.693119, False, '2021-11-01 00:00:00'); /* Magic trap */
/* @teleloc 0x02F50173 [42.242699 -10.051000 -41.994999] 0.720823 0.000000 0.000000 -0.693119 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53EF, 0x702F53FC, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F0, 4098, 0x02F50178, 39.9251, -47.5489, -41.995, -0.99872, 0, 0, 0.050575, False, '2021-11-01 00:00:00'); /* Magic trap */
/* @teleloc 0x02F50178 [39.925098 -47.548901 -41.994999] -0.998720 0.000000 0.000000 0.050575 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53F0, 0x702F53FD, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F1, 4083, 0x02F5018A, 62.1104, -60.3552, -41.995, 0.780707, 0, 0, -0.624897, False, '2021-11-01 00:00:00'); /* Magic trap */
/* @teleloc 0x02F5018A [62.110401 -60.355202 -41.994999] 0.780707 0.000000 0.000000 -0.624897 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53F1, 0x702F53FE, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F2, 4077, 0x02F5018C, 70, -12.0249, -41.995, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Magic trap */
/* @teleloc 0x02F5018C [70.000000 -12.024900 -41.994999] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53F2, 0x702F53FF, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F3, 4071, 0x02F50195, 67.349, -49.9031, -41.995, -0.717785, 0, 0, -0.696265, False, '2021-11-01 00:00:00'); /* Magic trap */
/* @teleloc 0x02F50195 [67.348999 -49.903099 -41.994999] -0.717785 0.000000 0.000000 -0.696265 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53F3, 0x702F5400, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F4, 4068, 0x02F501B4, 64.2264, -40.1378, -28.976, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Shockwave Trap */
/* @teleloc 0x02F501B4 [64.226402 -40.137798 -28.976000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x702F53F4, 0x702F5401, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F5, 6122, 0x02F50207, 80, -230, -17.995, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Acid */
/* @teleloc 0x02F50207 [80.000000 -230.000000 -17.995001] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F6, 6122, 0x02F50216, 110, -230, -17.995, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Acid */
/* @teleloc 0x02F50216 [110.000000 -230.000000 -17.995001] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F7, 3994, 0x02F501B4, 61.5, -40, -29.995, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x02F501B4 [61.500000 -40.000000 -29.995001] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F8, 3969, 0x02F50218, -4, -200, -11.995, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chest */
/* @teleloc 0x02F50218 [-4.000000 -200.000000 -11.995000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53F9, 2131, 0x02F5016A, 33.5, 0, -41.995, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F5016A [33.500000 0.000000 -41.994999] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53FA, 2131, 0x02F5016C, 30, -7, -41.995, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F5016C [30.000000 -7.000000 -41.994999] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53FB, 2131, 0x02F5016F, 30, -40, -41.995, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F5016F [30.000000 -40.000000 -41.994999] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53FC, 2131, 0x02F50173, 40, -10, -41.995, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F50173 [40.000000 -10.000000 -41.994999] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53FD, 2131, 0x02F50178, 40, -50, -41.995, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F50178 [40.000000 -50.000000 -41.994999] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53FE, 2131, 0x02F5018A, 60, -60, -41.995, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F5018A [60.000000 -60.000000 -41.994999] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F53FF, 2131, 0x02F5018C, 70, -10, -41.995, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F5018C [70.000000 -10.000000 -41.994999] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5400, 2131, 0x02F50194, 69.9048, -50.1559, -41.995, -0.009248, 0, 0, -0.999957, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F50194 [69.904800 -50.155899 -41.994999] -0.009248 0.000000 0.000000 -0.999957 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5401, 2131, 0x02F501B4, 60, -40, -29.995, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x02F501B4 [60.000000 -40.000000 -29.995001] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5402, 201, 0x02F5010B, 47.4269, -92.2604, -53.99, 0.911039, 0, 0, -0.412321, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F5010B [47.426899 -92.260399 -53.990002] 0.911039 0.000000 0.000000 -0.412321 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5403, 619, 0x02F5010D, 59.4875, -50.9797, -53.9917, 1, 0, 0, 0.000336, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F5010D [59.487499 -50.979698 -53.991699] 1.000000 0.000000 0.000000 0.000336 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5404, 619, 0x02F5010D, 60.2682, -52.2818, -53.9917, 0.998733, 0, 0, 0.050315, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F5010D [60.268200 -52.281799 -53.991699] 0.998733 0.000000 0.000000 0.050315 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5405, 201, 0x02F50110, 56.7711, -82.8814, -53.99, -0.98207, 0, 0, 0.188515, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F50110 [56.771099 -82.881401 -53.990002] -0.982070 0.000000 0.000000 0.188515 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5406, 201, 0x02F50110, 61.088, -82.6667, -53.99, -0.986458, 0, 0, -0.164016, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F50110 [61.088001 -82.666702 -53.990002] -0.986458 0.000000 0.000000 -0.164016 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5407, 201, 0x02F50111, 59.6431, -89.3014, -53.99, 0.99996, 0, 0, 0.00893, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F50111 [59.643101 -89.301399 -53.990002] 0.999960 0.000000 0.000000 0.008930 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5408, 201, 0x02F50111, 56.5144, -90.838, -53.99, 0.995566, 0, 0, -0.094065, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F50111 [56.514400 -90.837997 -53.990002] 0.995566 0.000000 0.000000 -0.094065 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5409, 201, 0x02F50117, 78.7166, -91.8811, -53.99, 0.913275, 0, 0, 0.407343, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F50117 [78.716599 -91.881104 -53.990002] 0.913275 0.000000 0.000000 0.407343 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F540A, 619, 0x02F50124, 60.0929, -248.874, -47.9917, -0.999744, 0, 0, -0.022607, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50124 [60.092899 -248.873993 -47.991699] -0.999744 0.000000 0.000000 -0.022607 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F540B, 619, 0x02F5012B, 68.8595, -260.304, -47.9917, -0.841138, 0, 0, -0.540821, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F5012B [68.859497 -260.303986 -47.991699] -0.841138 0.000000 0.000000 -0.540821 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F540C, 619, 0x02F50134, 89.6115, -270.921, -47.9917, -0.999094, 0, 0, 0.042553, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50134 [89.611504 -270.920990 -47.991699] -0.999094 0.000000 0.000000 0.042553 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F540D, 619, 0x02F50140, 90.1638, -299.15, -47.9917, 0.998988, 0, 0, 0.044976, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50140 [90.163803 -299.149994 -47.991699] 0.998988 0.000000 0.000000 0.044976 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F540E, 619, 0x02F50151, 100.682, -281.089, -47.9917, 0.998756, 0, 0, 0.049865, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50151 [100.681999 -281.088989 -47.991699] 0.998756 0.000000 0.000000 0.049865 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F540F, 619, 0x02F50166, 129.001, -249.128, -47.9917, -0.999658, 0, 0, 0.026154, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50166 [129.001007 -249.128006 -47.991699] -0.999658 0.000000 0.000000 0.026154 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5410, 619, 0x02F50166, 130.571, -251.396, -47.9917, -0.999658, 0, 0, 0.026154, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50166 [130.570999 -251.395996 -47.991699] -0.999658 0.000000 0.000000 0.026154 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5411, 619, 0x02F50176, 40.7342, -34.5655, -41.945, -0.013623, 0, 0, 0.999907, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50176 [40.734200 -34.565498 -41.945000] -0.013623 0.000000 0.000000 0.999907 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5412, 619, 0x02F50176, 39.4198, -31.1925, -41.9917, -0.027081, 0, 0, 0.999633, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50176 [39.419800 -31.192499 -41.991699] -0.027081 0.000000 0.000000 0.999633 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5413, 619, 0x02F5017A, 40.2895, -60.3869, -41.9917, -0.692486, 0, 0, -0.721431, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F5017A [40.289501 -60.386902 -41.991699] -0.692486 0.000000 0.000000 -0.721431 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5414, 619, 0x02F50181, 49.7536, -49.5851, -41.9917, 0.710146, 0, 0, -0.704054, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50181 [49.753601 -49.585098 -41.991699] 0.710146 0.000000 0.000000 -0.704054 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5415, 619, 0x02F50182, 48.3498, -59.8372, -41.9917, 0.739525, 0, 0, 0.673129, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50182 [48.349800 -59.837200 -41.991699] 0.739525 0.000000 0.000000 0.673129 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5416, 619, 0x02F5018E, 70.7504, -18.5318, -41.9917, -0.994816, 0, 0, -0.101693, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F5018E [70.750397 -18.531799 -41.991699] -0.994816 0.000000 0.000000 -0.101693 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5417, 201, 0x02F501AF, 40, -42.997, -29.99, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501AF [40.000000 -42.997002 -29.990000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5418, 201, 0x02F501B1, 45.9158, -30.7556, -29.99, 0.977432, 0, 0, 0.211251, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501B1 [45.915798 -30.755600 -29.990000] 0.977432 0.000000 0.000000 0.211251 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5419, 201, 0x02F501C2, 34.316, -97.4314, -23.99, 0.275751, 0, 0, -0.961229, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501C2 [34.316002 -97.431396 -23.990000] 0.275751 0.000000 0.000000 -0.961229 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F541A, 201, 0x02F501C8, 43.2424, -77.3391, -23.99, -0.019208, 0, 0, -0.999816, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501C8 [43.242401 -77.339104 -23.990000] -0.019208 0.000000 0.000000 -0.999816 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F541B, 201, 0x02F501C8, 37.4877, -81.4122, -23.99, -0.008484, 0, 0, -0.999964, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501C8 [37.487701 -81.412201 -23.990000] -0.008484 0.000000 0.000000 -0.999964 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F541C, 201, 0x02F501C9, 39.7855, -89.0204, -23.99, 0.024249, 0, 0, -0.999706, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501C9 [39.785500 -89.020401 -23.990000] 0.024249 0.000000 0.000000 -0.999706 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F541D, 619, 0x02F501D2, 41.7216, -132.791, -23.9918, 0.923229, 0, 0, -0.38425, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F501D2 [41.721600 -132.791000 -23.991800] 0.923229 0.000000 0.000000 -0.384250 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F541E, 201, 0x02F501D8, 48.5152, -97.3105, -23.99, -0.260886, 0, 0, -0.96537, True, '2021-11-01 00:00:00'); /* Obsidian Golem */
/* @teleloc 0x02F501D8 [48.515202 -97.310501 -23.990000] -0.260886 0.000000 0.000000 -0.965370 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F541F, 619, 0x02F501E3, 47.8082, -143.165, -23.945, 0.749465, 0, 0, -0.662044, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F501E3 [47.808201 -143.164993 -23.945000] 0.749465 0.000000 0.000000 -0.662044 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5420, 619, 0x02F501E5, 51.7958, -141.512, -23.945, 0.811815, 0, 0, -0.583915, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F501E5 [51.795799 -141.511993 -23.945000] 0.811815 0.000000 0.000000 -0.583915 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5421, 619, 0x02F501F9, 81.4942, -130.58, -17.9918, 0.128301, 0, 0, -0.991735, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F501F9 [81.494202 -130.580002 -17.991800] 0.128301 0.000000 0.000000 -0.991735 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5422, 619, 0x02F501F9, 78.9396, -132.477, -17.9918, -0.073297, 0, 0, -0.99731, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F501F9 [78.939598 -132.477005 -17.991800] -0.073297 0.000000 0.000000 -0.997310 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5423, 619, 0x02F50202, 77.9965, -150.878, -17.9918, 0.998249, 0, 0, -0.059158, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50202 [77.996498 -150.878006 -17.991800] 0.998249 0.000000 0.000000 -0.059158 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5424, 619, 0x02F50202, 80.9455, -151.51, -17.9918, 0.999594, 0, 0, -0.028498, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50202 [80.945503 -151.509995 -17.991800] 0.999594 0.000000 0.000000 -0.028498 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5425, 619, 0x02F50208, 88.0527, -139.831, -17.9918, 0.728018, 0, 0, -0.685558, True, '2021-11-01 00:00:00'); /* Revenant */
/* @teleloc 0x02F50208 [88.052696 -139.830994 -17.991800] 0.728018 0.000000 0.000000 -0.685558 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5426, 194, 0x02F50218, 3.07103, -198.164, -11.99, 0.778014, 0, 0, -0.628247, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F50218 [3.071030 -198.164001 -11.990000] 0.778014 0.000000 0.000000 -0.628247 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5427, 194, 0x02F50218, 1.95365, -203.277, -11.99, 0.717239, 0, 0, -0.696827, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F50218 [1.953650 -203.276993 -11.990000] 0.717239 0.000000 0.000000 -0.696827 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5428, 194, 0x02F5021A, 10.3338, -192.693, -11.99, 0.315322, 0, 0, -0.948985, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F5021A [10.333800 -192.692993 -11.990000] 0.315322 0.000000 0.000000 -0.948985 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5429, 195, 0x02F5021B, 11.6395, -195.447, -11.945, -0.620153, 0, 0, 0.784481, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F5021B [11.639500 -195.447006 -11.945000] -0.620153 0.000000 0.000000 0.784481 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F542A, 195, 0x02F5021C, 12.4132, -206.487, -11.989, -0.787739, 0, 0, 0.616009, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F5021C [12.413200 -206.487000 -11.989000] -0.787739 0.000000 0.000000 0.616009 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F542B, 194, 0x02F5021E, 17.1242, -198.78, -11.99, 0.748499, 0, 0, -0.663135, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F5021E [17.124201 -198.779999 -11.990000] 0.748499 0.000000 0.000000 -0.663135 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F542C, 194, 0x02F5021E, 22.8415, -203.922, -11.99, 0.702128, 0, 0, -0.71205, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F5021E [22.841499 -203.921997 -11.990000] 0.702128 0.000000 0.000000 -0.712050 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F542D, 194, 0x02F5021E, 22.8517, -196.193, -11.99, 0.689136, 0, 0, -0.724632, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F5021E [22.851700 -196.192993 -11.990000] 0.689136 0.000000 0.000000 -0.724632 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F542E, 194, 0x02F5021F, 17.2808, -212.389, -11.99, 0.911039, 0, 0, -0.412321, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F5021F [17.280800 -212.389008 -11.990000] 0.911039 0.000000 0.000000 -0.412321 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F542F, 194, 0x02F5023C, 121.272, -157.287, -11.99, 0.070737, 0, 0, 0.997495, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F5023C [121.272003 -157.287003 -11.990000] 0.070737 0.000000 0.000000 0.997495 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5430, 194, 0x02F50242, 128.667, -148.741, -11.99, -0.133143, 0, 0, -0.991097, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F50242 [128.667007 -148.740997 -11.990000] -0.133143 0.000000 0.000000 -0.991097 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5431, 194, 0x02F50242, 132.509, -147.739, -11.99, 0.020532, 0, 0, -0.999789, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F50242 [132.509003 -147.738998 -11.990000] 0.020532 0.000000 0.000000 -0.999789 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5432, 194, 0x02F50243, 127.121, -162.332, -11.99, 0.243329, 0, 0, 0.969944, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F50243 [127.121002 -162.332001 -11.990000] 0.243329 0.000000 0.000000 0.969944 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5433, 194, 0x02F50244, 130.83, -168.503, -11.99, 0.408488, 0, 0, 0.912764, True, '2021-11-01 00:00:00'); /* Copper Golem */
/* @teleloc 0x02F50244 [130.830002 -168.503006 -11.990000] 0.408488 0.000000 0.000000 0.912764 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5434, 195, 0x02F50264, 30, -280, 0.011, 0.731689, 0, 0, -0.681639, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F50264 [30.000000 -280.000000 0.011000] 0.731689 0.000000 0.000000 -0.681639 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5435, 195, 0x02F50265, 30, -290, 0.011, 0.877582, 0, 0, -0.479426, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F50265 [30.000000 -290.000000 0.011000] 0.877582 0.000000 0.000000 -0.479426 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5436, 195, 0x02F50267, 40, -290, 0.011, 0.968913, 0, 0, -0.247403, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F50267 [40.000000 -290.000000 0.011000] 0.968913 0.000000 0.000000 -0.247403 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5437, 195, 0x02F50269, 50, -287.298, 0.011, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F50269 [50.000000 -287.298004 0.011000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5438, 195, 0x02F50269, 53.453, -290.335, 0.011, 0.984161, 0, 0, 0.177278, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F50269 [53.452999 -290.334991 0.011000] 0.984161 0.000000 0.000000 0.177278 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5439, 204, 0x02F50283, 88.2618, -297.354, 0.0075, -0.421339, 0, 0, 0.906903, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F50283 [88.261803 -297.354004 0.007500] -0.421339 0.000000 0.000000 0.906903 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F543A, 204, 0x02F50283, 87.8385, -302.198, 0.0075, 0.773392, 0, 0, -0.633928, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F50283 [87.838501 -302.197998 0.007500] 0.773392 0.000000 0.000000 -0.633928 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F543B, 204, 0x02F50283, 91.0798, -300.173, 0.0075, 0.750504, 0, 0, -0.660866, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F50283 [91.079803 -300.173004 0.007500] 0.750504 0.000000 0.000000 -0.660866 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F543C, 1630, 0x02F50287, 100.23, -259.223, 0.0075, 0.037712, 0, 0, 0.999289, True, '2021-11-01 00:00:00'); /* Lich Lord */
/* @teleloc 0x02F50287 [100.230003 -259.222992 0.007500] 0.037712 0.000000 0.000000 0.999289 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F543D, 204, 0x02F50288, 99.3351, -263.36, 0.055, 0.112991, 0, 0, 0.993596, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F50288 [99.335098 -263.359985 0.055000] 0.112991 0.000000 0.000000 0.993596 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F543E, 204, 0x02F50288, 100.772, -265.003, 0.0075, -0.028677, 0, 0, 0.999589, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F50288 [100.772003 -265.002991 0.007500] -0.028677 0.000000 0.000000 0.999589 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F543F, 204, 0x02F5028A, 99.79, -283.235, 0.0075, 0.081543, 0, 0, -0.99667, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F5028A [99.790001 -283.234985 0.007500] 0.081543 0.000000 0.000000 -0.996670 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5440, 204, 0x02F502AA, 109.473, -290.169, 0.0075, 0.109366, 0, 0, 0.994002, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F502AA [109.473000 -290.169006 0.007500] 0.109366 0.000000 0.000000 0.994002 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5441, 204, 0x02F502AA, 109.951, -288.023, 0.0075, 0.109366, 0, 0, 0.994002, True, '2021-11-01 00:00:00'); /* Lich */
/* @teleloc 0x02F502AA [109.950996 -288.023010 0.007500] 0.109366 0.000000 0.000000 0.994002 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5442, 195, 0x02F502C5, 152.546, -260.871, 0.011, 0.445985, 0, 0, 0.89504, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502C5 [152.546005 -260.871002 0.011000] 0.445985 0.000000 0.000000 0.895040 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5443, 195, 0x02F502CB, 155.264, -266.824, 0.055, 0.653438, 0, 0, 0.75698, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502CB [155.264008 -266.824005 0.055000] 0.653438 0.000000 0.000000 0.756980 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5444, 195, 0x02F502CB, 163.736, -271.9, 0.011, 0.6943, 0, 0, 0.719686, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502CB [163.735992 -271.899994 0.011000] 0.694300 0.000000 0.000000 0.719686 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5445, 195, 0x02F502CC, 160.052, -281.914, 0.011, 0.949805, 0, 0, 0.312844, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502CC [160.052002 -281.914001 0.011000] 0.949805 0.000000 0.000000 0.312844 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5446, 195, 0x02F502D4, 158, -348.119, 0.011, 0.909243, 0, 0, 0.416266, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502D4 [158.000000 -348.118988 0.011000] 0.909243 0.000000 0.000000 0.416266 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5447, 195, 0x02F502D4, 161.56, -350.787, 0.011, 0.964526, 0, 0, 0.263988, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502D4 [161.559998 -350.786987 0.011000] 0.964526 0.000000 0.000000 0.263988 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5448, 195, 0x02F502D8, 166.283, -328.228, 0.011, -0.683255, 0, 0, -0.73018, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502D8 [166.283005 -328.227997 0.011000] -0.683255 0.000000 0.000000 -0.730180 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F5449, 195, 0x02F502D8, 168.999, -330.475, 0.011, -0.654877, 0, 0, -0.755736, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502D8 [168.998993 -330.475006 0.011000] -0.654877 0.000000 0.000000 -0.755736 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x702F544A, 195, 0x02F502D9, 170, -340, 0.011, 0.939373, 0, 0, 0.342898, True, '2021-11-01 00:00:00'); /* Granite Golem */
/* @teleloc 0x02F502D9 [170.000000 -340.000000 0.011000] 0.939373 0.000000 0.000000 0.342898 */

-- 0x6147 Mountain Citadel
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147000, 24497, 0x61470103, 10.0681, -60.5089, 0.01, 0.041552, 0, 0, -0.999136, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470103 [10.068100 -60.508900 0.010000] 0.041552 0.000000 0.000000 -0.999136 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147001, 24497, 0x61470103, 7.91207, -58.3475, 0.01, 0.382228, 0, 0, -0.924068, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470103 [7.912070 -58.347500 0.010000] 0.382228 0.000000 0.000000 -0.924068 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147002, 8138, 0x6147010E, 50.9078, -99.5767, 0.01, 0.261977, 0, 0, -0.965074, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147010E [50.907799 -99.576698 0.010000] 0.261977 0.000000 0.000000 -0.965074 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147003, 8138, 0x6147010E, 53.3758, -99.0639, 0.01, 0.338938, 0, 0, -0.940809, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147010E [53.375801 -99.063904 0.010000] 0.338938 0.000000 0.000000 -0.940809 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147004, 8138, 0x6147010E, 51.8016, -97.1626, 0.01, 0.338938, 0, 0, -0.940809, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147010E [51.801601 -97.162598 0.010000] 0.338938 0.000000 0.000000 -0.940809 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147005, 8138, 0x6147011C, 79.1465, -157.764, 0.01, 0.999444, 0, 0, 0.033327, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147011C [79.146500 -157.764008 0.010000] 0.999444 0.000000 0.000000 0.033327 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147006, 8138, 0x6147011C, 80.0071, -159.938, 0.01, 0.998349, 0, 0, -0.057442, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147011C [80.007103 -159.938004 0.010000] 0.998349 0.000000 0.000000 -0.057442 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147007, 8138, 0x6147012A, 96.1683, -130.987, 0.01, 0.805816, 0, 0, -0.592166, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147012A [96.168297 -130.987000 0.010000] 0.805816 0.000000 0.000000 -0.592166 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147008, 8138, 0x6147012A, 97.7839, -129.317, 0.01, 0.792861, 0, 0, -0.609402, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147012A [97.783897 -129.317001 0.010000] 0.792861 0.000000 0.000000 -0.609402 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147009, 8138, 0x61470132, 110.234, -49.5147, 0.01, 0.041263, 0, 0, -0.999148, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x61470132 [110.234001 -49.514702 0.010000] 0.041263 0.000000 0.000000 -0.999148 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614700A, 8138, 0x61470132, 108.999, -47.814, 0.01, 0.016274, 0, 0, -0.999868, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x61470132 [108.999001 -47.813999 0.010000] 0.016274 0.000000 0.000000 -0.999868 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614700B, 24497, 0x6147013B, 105.126, -170.875, 0.055, -0.712955, 0, 0, -0.70121, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147013B [105.125999 -170.875000 0.055000] -0.712955 0.000000 0.000000 -0.701210 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614700C, 24497, 0x6147013B, 107.11, -168.87, 0.01, -0.619968, 0, 0, -0.784627, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147013B [107.110001 -168.869995 0.010000] -0.619968 0.000000 0.000000 -0.784627 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614700D, 24497, 0x6147013C, 123.447, -39.1265, 0.01, 0.373304, 0, 0, 0.927709, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147013C [123.446999 -39.126499 0.010000] 0.373304 0.000000 0.000000 0.927709 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614700E, 24497, 0x6147013C, 124.848, -40.3904, 0.055, 0.243655, 0, 0, 0.969862, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147013C [124.848000 -40.390400 0.055000] 0.243655 0.000000 0.000000 0.969862 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614700F, 8138, 0x6147013E, 121.146, -78.8195, 0.01, 0.51961, 0, 0, -0.854404, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147013E [121.146004 -78.819504 0.010000] 0.519610 0.000000 0.000000 -0.854404 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147010, 8138, 0x6147013E, 123.181, -81.5521, 0.01, 0.703139, 0, 0, -0.711053, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147013E [123.181000 -81.552101 0.010000] 0.703139 0.000000 0.000000 -0.711053 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147011, 24497, 0x61470148, 138.115, -51.0459, 0.01, 0.603385, 0, 0, 0.79745, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470148 [138.115005 -51.045898 0.010000] 0.603385 0.000000 0.000000 0.797450 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147012, 24497, 0x61470148, 137.615, -48.9166, 0.01, 0.591368, 0, 0, 0.806402, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470148 [137.615005 -48.916599 0.010000] 0.591368 0.000000 0.000000 0.806402 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147013, 7923, 0x61470150, 140, -120, 0.005, 1, 0, 0, 0, False, '2005-02-09 10:00:00'); /* Linkable Monster Generator ( 3 Min.) */
/* @teleloc 0x61470150 [140.000000 -120.000000 0.005000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x76147013, 0x76147000, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147001, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147002, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147003, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147004, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147005, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147006, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147007, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147008, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147009, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614700A, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614700B, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614700C, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614700D, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614700E, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614700F, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147010, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147011, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147012, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147014, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147015, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147017, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147018, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147019, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614701A, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614701C, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614701D, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614701E, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614701F, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147020, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147021, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147022, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147023, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147024, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147025, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147026, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147027, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147028, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147029, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614702A, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614702B, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614702C, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614702D, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614702E, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614702F, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147030, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147031, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147032, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147033, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147034, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147035, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147036, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147037, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147038, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147039, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614703A, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614703B, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614703C, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614703D, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614703E, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614703F, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147040, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147041, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147042, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147043, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147044, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147045, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147046, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147047, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147048, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147049, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614704A, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614704B, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614704C, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614704D, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614704E, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614704F, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147050, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147051, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147052, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147053, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147054, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147055, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147056, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147057, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147058, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147059, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614705A, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614705B, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614705C, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614705D, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614705E, '2005-02-09 10:00:00')
     , (0x76147013, 0x7614705F, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147060, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147061, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147062, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147063, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147064, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147065, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147066, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147067, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147068, '2005-02-09 10:00:00')
     , (0x76147013, 0x76147069, '2005-02-09 10:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147014, 8138, 0x6147015A, 160.138, -67.2755, 0.01, 0.054737, 0, 0, 0.998501, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147015A [160.138000 -67.275497 0.010000] 0.054737 0.000000 0.000000 0.998501 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147015, 8138, 0x6147015A, 161.262, -66.4891, 0.01, 0.002933, 0, 0, 0.999996, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x6147015A [161.261993 -66.489098 0.010000] 0.002933 0.000000 0.000000 0.999996 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147016, 25282, 0x6147015F, 160, -126, 0.005, 0, 0, 0, -1, False, '2005-02-09 10:00:00'); /* Surface */
/* @teleloc 0x6147015F [160.000000 -126.000000 0.005000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147017, 24495, 0x61470162, 302.528, -129.099, 0.01, 0.544848, 0, 0, 0.838535, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470162 [302.528015 -129.098999 0.010000] 0.544848 0.000000 0.000000 0.838535 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147018, 24495, 0x61470162, 299.223, -131.351, 0.01, 0.664737, 0, 0, 0.747077, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470162 [299.222992 -131.350998 0.010000] 0.664737 0.000000 0.000000 0.747077 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147019, 24495, 0x61470164, 301.83, -149.808, 0.01, -0.998427, 0, 0, -0.056074, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470164 [301.829987 -149.807999 0.010000] -0.998427 0.000000 0.000000 -0.056074 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614701A, 24495, 0x61470164, 298.446, -149.889, 0.01, -0.98852, 0, 0, 0.151089, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470164 [298.446014 -149.889008 0.010000] -0.988520 0.000000 0.000000 0.151089 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614701B, 24476, 0x61470165, 306, -150, 0.005, 0.707107, 0, 0, -0.707107, False, '2005-02-09 10:00:00'); /* Sturdy Steel Chest */
/* @teleloc 0x61470165 [306.000000 -150.000000 0.005000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614701C, 24497, 0x61470177, 100.299, -217.63, 6.055, 0.99143, 0, 0, 0.130642, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470177 [100.299004 -217.630005 6.055000] 0.991430 0.000000 0.000000 0.130642 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614701D, 24497, 0x61470177, 100.769, -220.535, 6.01, 0.99672, 0, 0, 0.080928, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470177 [100.768997 -220.535004 6.010000] 0.996720 0.000000 0.000000 0.080928 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614701E, 24497, 0x61470177, 98.8922, -220.04, 6.01, 0.999518, 0, 0, -0.031049, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470177 [98.892197 -220.039993 6.010000] 0.999518 0.000000 0.000000 -0.031049 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614701F, 24497, 0x61470183, 130.935, -215.744, 6.01, 0.332076, 0, 0, 0.943253, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470183 [130.934998 -215.744003 6.010000] 0.332076 0.000000 0.000000 0.943253 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147020, 24497, 0x61470185, 130.203, -222.586, 6.055, 0.7745, 0, 0, 0.632573, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470185 [130.203003 -222.585999 6.055000] 0.774500 0.000000 0.000000 0.632573 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147021, 24497, 0x6147018D, 151.1, -216.341, 6.01, 0.607405, 0, 0, 0.794392, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147018D [151.100006 -216.341003 6.010000] 0.607405 0.000000 0.000000 0.794392 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147022, 24497, 0x6147018E, 150.078, -223.213, 6.055, 0.927183, 0, 0, 0.374608, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147018E [150.078003 -223.212997 6.055000] 0.927183 0.000000 0.000000 0.374608 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147023, 24497, 0x6147019D, 190.851, -2.91317, 6.01, 0.114821, 0, 0, 0.993386, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147019D [190.850998 -2.913170 6.010000] 0.114821 0.000000 0.000000 0.993386 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147024, 24497, 0x6147019D, 192.564, -1.25682, 6.01, 0.034912, 0, 0, 0.99939, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147019D [192.563995 -1.256820 6.010000] 0.034912 0.000000 0.000000 0.999390 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147025, 8138, 0x614701A0, 191.323, -27.0536, 6.01, 0.00611, 0, 0, -0.999981, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x614701A0 [191.322998 -27.053600 6.010000] 0.006110 0.000000 0.000000 -0.999981 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147026, 8138, 0x614701A0, 190.195, -25.8728, 6.01, -0.05476, 0, 0, -0.9985, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x614701A0 [190.195007 -25.872801 6.010000] -0.054760 0.000000 0.000000 -0.998500 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147027, 8138, 0x614701A2, 189.766, -45.2125, 6.055, -0.115418, 0, 0, 0.993317, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x614701A2 [189.766006 -45.212502 6.055000] -0.115418 0.000000 0.000000 0.993317 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147028, 8138, 0x614701A2, 190.103, -46.9792, 6.01, 0.059289, 0, 0, 0.998241, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x614701A2 [190.102997 -46.979198 6.010000] 0.059289 0.000000 0.000000 0.998241 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147029, 24497, 0x614701AD, 229.731, -9.24292, 6.01, 0.739207, 0, 0, 0.673478, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701AD [229.731003 -9.242920 6.010000] 0.739207 0.000000 0.000000 0.673478 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614702A, 24497, 0x614701AD, 228.976, -10.6045, 6.01, 0.653415, 0, 0, 0.757, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701AD [228.975998 -10.604500 6.010000] 0.653415 0.000000 0.000000 0.757000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614702B, 24497, 0x614701B4, 244.96, -99.2473, 6.01, 0.747482, 0, 0, -0.664282, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701B4 [244.960007 -99.247299 6.010000] 0.747482 0.000000 0.000000 -0.664282 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614702C, 24497, 0x614701B6, 238.996, -131.192, 6.01, 0.939373, 0, 0, -0.342898, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701B6 [238.996002 -131.192001 6.010000] 0.939373 0.000000 0.000000 -0.342898 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614702D, 24495, 0x614701BA, 250.052, -72.0316, 6.01, -0.810022, 0, 0, 0.586399, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x614701BA [250.052002 -72.031601 6.010000] -0.810022 0.000000 0.000000 0.586399 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614702E, 24497, 0x614701C3, 250, -110, 6.01, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701C3 [250.000000 -110.000000 6.010000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614702F, 24497, 0x614701C5, 250.036, -125.568, 6.01, 0.998762, 0, 0, -0.049739, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701C5 [250.035995 -125.568001 6.010000] 0.998762 0.000000 0.000000 -0.049739 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147030, 24495, 0x614701C6, 250, -141.169, 6.01, 1, 0, 0, 0, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x614701C6 [250.000000 -141.169006 6.010000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147031, 24497, 0x614701C7, 259.152, -20.6611, 6.01, 0.691891, 0, 0, 0.722002, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701C7 [259.152008 -20.661100 6.010000] 0.691891 0.000000 0.000000 0.722002 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147032, 24497, 0x614701C7, 259.991, -19.1111, 6.01, 0.69332, 0, 0, 0.72063, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701C7 [259.990997 -19.111099 6.010000] 0.693320 0.000000 0.000000 0.720630 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147033, 24497, 0x614701CB, 256.266, -101.546, 6.01, 0.866082, 0, 0, 0.499901, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701CB [256.265991 -101.545998 6.010000] 0.866082 0.000000 0.000000 0.499901 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147034, 24497, 0x614701CD, 261.32, -131.736, 6.01, 0.947651, 0, 0, 0.319309, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701CD [261.320007 -131.735992 6.010000] 0.947651 0.000000 0.000000 0.319309 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147035, 24497, 0x614701D1, 267.942, -40.2808, 6.01, 0.974994, 0, 0, 0.222232, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701D1 [267.941986 -40.280800 6.010000] 0.974994 0.000000 0.000000 0.222232 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147036, 24497, 0x614701D1, 271.354, -38.8888, 6.01, 0.981738, 0, 0, 0.190239, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701D1 [271.354004 -38.888802 6.010000] 0.981738 0.000000 0.000000 0.190239 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147037, 24497, 0x614701D1, 270.224, -43.5785, 6.01, 0.996234, 0, 0, 0.086703, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701D1 [270.223999 -43.578499 6.010000] 0.996234 0.000000 0.000000 0.086703 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147038, 24497, 0x614701D3, 269.577, -58.5768, 6.01, 0.999965, 0, 0, 0.008333, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701D3 [269.576996 -58.576801 6.010000] 0.999965 0.000000 0.000000 0.008333 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147039, 24497, 0x614701D3, 271.546, -60.1563, 6.01, 0.999872, 0, 0, -0.016025, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701D3 [271.545990 -60.156300 6.010000] 0.999872 0.000000 0.000000 -0.016025 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614703A, 24497, 0x614701DC, 141.288, -149.559, 12.01, 0.817966, 0, 0, -0.575266, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701DC [141.287994 -149.559006 12.010000] 0.817966 0.000000 0.000000 -0.575266 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614703B, 24497, 0x614701DC, 144.077, -150.313, 12.01, 0.728548, 0, 0, -0.684995, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701DC [144.076996 -150.313004 12.010000] 0.728548 0.000000 0.000000 -0.684995 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614703C, 24497, 0x614701DC, 138.765, -150.641, 12.01, 0.728548, 0, 0, -0.684995, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701DC [138.764999 -150.641006 12.010000] 0.728548 0.000000 0.000000 -0.684995 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614703D, 24497, 0x614701DD, 138.212, -159.922, 12.01, 0.978731, 0, 0, -0.205147, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701DD [138.212006 -159.921997 12.010000] 0.978731 0.000000 0.000000 -0.205147 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614703E, 24495, 0x614701DE, 138.026, -172.569, 12.01, 0.980067, 0, 0, -0.198669, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x614701DE [138.026001 -172.569000 12.010000] 0.980067 0.000000 0.000000 -0.198669 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614703F, 24495, 0x614701DE, 140.501, -173.393, 12.01, 0.984615, 0, 0, 0.174739, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x614701DE [140.501007 -173.393005 12.010000] 0.984615 0.000000 0.000000 0.174739 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147040, 24495, 0x614701DE, 141.953, -171.33, 12.01, 0.887403, 0, 0, 0.460995, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x614701DE [141.953003 -171.330002 12.010000] 0.887403 0.000000 0.000000 0.460995 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147041, 24497, 0x614701E0, 148.282, -110.055, 12.01, -0.090158, 0, 0, 0.995927, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701E0 [148.281998 -110.055000 12.010000] -0.090158 0.000000 0.000000 0.995927 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147042, 24497, 0x614701E0, 150.76, -110.872, 12.01, -0.216978, 0, 0, 0.976177, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701E0 [150.759995 -110.872002 12.010000] -0.216978 0.000000 0.000000 0.976177 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147043, 24497, 0x614701E0, 149.199, -107.533, 12.01, -0.216978, 0, 0, 0.976177, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701E0 [149.199005 -107.532997 12.010000] -0.216978 0.000000 0.000000 0.976177 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147044, 24497, 0x614701E5, 160.306, -133.073, 12.01, -0.023933, 0, 0, -0.999714, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701E5 [160.306000 -133.072998 12.010000] -0.023933 0.000000 0.000000 -0.999714 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147045, 24497, 0x614701E5, 157.992, -131.494, 12.01, 0.040157, 0, 0, -0.999193, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701E5 [157.992004 -131.494003 12.010000] 0.040157 0.000000 0.000000 -0.999193 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147046, 24497, 0x614701E5, 161.207, -129.597, 12.01, 0.002761, 0, 0, -0.999996, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701E5 [161.207001 -129.597000 12.010000] 0.002761 0.000000 0.000000 -0.999996 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147047, 24497, 0x614701F2, 171.028, -117.042, 12.01, -0.499562, 0, 0, -0.866278, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701F2 [171.028000 -117.042000 12.010000] -0.499562 0.000000 0.000000 -0.866278 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147048, 24497, 0x614701F2, 170.67, -119.901, 12.01, -0.40297, 0, 0, -0.915213, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701F2 [170.669998 -119.901001 12.010000] -0.402970 0.000000 0.000000 -0.915213 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147049, 24497, 0x614701F2, 172.65, -118.088, 12.01, -0.40297, 0, 0, -0.915213, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701F2 [172.649994 -118.087997 12.010000] -0.402970 0.000000 0.000000 -0.915213 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614704A, 24497, 0x614701FB, 180.553, -180.483, 12.01, -0.138616, 0, 0, 0.990346, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701FB [180.552994 -180.483002 12.010000] -0.138616 0.000000 0.000000 0.990346 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614704B, 24497, 0x614701FB, 178.705, -178.877, 12.01, -0.027521, 0, 0, 0.999621, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x614701FB [178.705002 -178.876999 12.010000] -0.027521 0.000000 0.000000 0.999621 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614704C, 24495, 0x61470208, 197.104, -158.286, 12.01, -0.438837, 0, 0, 0.898567, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470208 [197.104004 -158.285995 12.010000] -0.438837 0.000000 0.000000 0.898567 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614704D, 24495, 0x61470208, 200.746, -158.753, 12.01, 0.363135, 0, 0, 0.931737, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470208 [200.746002 -158.753006 12.010000] 0.363135 0.000000 0.000000 0.931737 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614704E, 24495, 0x61470208, 196.702, -161.483, 12.01, 0.843388, 0, 0, -0.537306, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470208 [196.701996 -161.483002 12.010000] 0.843388 0.000000 0.000000 -0.537306 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614704F, 24495, 0x61470208, 200.527, -161.961, 12.01, 0.386071, 0, 0, 0.922469, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470208 [200.526993 -161.960999 12.010000] 0.386071 0.000000 0.000000 0.922469 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147050, 24497, 0x6147020A, 200.76, -177.544, 12.01, -0.546899, 0, 0, -0.837199, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147020A [200.759995 -177.544006 12.010000] -0.546899 0.000000 0.000000 -0.837199 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147051, 24497, 0x6147020F, 209.944, -110.932, 12.01, -0.034951, 0, 0, -0.999389, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147020F [209.944000 -110.931999 12.010000] -0.034951 0.000000 0.000000 -0.999389 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147052, 24497, 0x6147020F, 208.762, -109.102, 12.01, -0.034311, 0, 0, -0.999411, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147020F [208.761993 -109.101997 12.010000] -0.034311 0.000000 0.000000 -0.999411 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147053, 24495, 0x61470214, 220, -90, 12.01, -0.438747, 0, 0, -0.898611, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470214 [220.000000 -90.000000 12.010000] -0.438747 0.000000 0.000000 -0.898611 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147054, 24497, 0x61470226, 277.331, -18.5713, 12.01, 0.392119, 0, 0, 0.919915, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470226 [277.330994 -18.571301 12.010000] 0.392119 0.000000 0.000000 0.919915 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147055, 24497, 0x61470226, 276.808, -16.843, 12.01, 0.546295, 0, 0, 0.837593, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470226 [276.808014 -16.843000 12.010000] 0.546295 0.000000 0.000000 0.837593 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147056, 24497, 0x61470227, 279.181, -26.0876, 12.01, 0.652936, 0, 0, 0.757413, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470227 [279.181000 -26.087601 12.010000] 0.652936 0.000000 0.000000 0.757413 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147057, 24497, 0x61470227, 279.38, -32.7154, 12.01, 0.80235, 0, 0, 0.596854, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470227 [279.380005 -32.715401 12.010000] 0.802350 0.000000 0.000000 0.596854 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147058, 24497, 0x61470228, 277.904, -41.813, 12.01, 0.78371, 0, 0, 0.621127, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470228 [277.903992 -41.813000 12.010000] 0.783710 0.000000 0.000000 0.621127 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147059, 24497, 0x61470228, 278.354, -38.0594, 12.01, 0.71592, 0, 0, 0.698182, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470228 [278.354004 -38.059399 12.010000] 0.715920 0.000000 0.000000 0.698182 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614705A, 24495, 0x61470233, 159.974, -102.499, 18.01, -0.008967, 0, 0, -0.99996, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470233 [159.973999 -102.499001 18.010000] -0.008967 0.000000 0.000000 -0.999960 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614705B, 24495, 0x61470234, 162.634, -111.961, 18.01, 0.159556, 0, 0, -0.987189, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470234 [162.634003 -111.960999 18.010000] 0.159556 0.000000 0.000000 -0.987189 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614705C, 24495, 0x61470234, 158.297, -110.656, 18.01, -0.175799, 0, 0, -0.984426, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470234 [158.296997 -110.655998 18.010000] -0.175799 0.000000 0.000000 -0.984426 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614705D, 24495, 0x61470234, 162.595, -107.066, 18.01, 0.05998, 0, 0, -0.9982, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470234 [162.595001 -107.066002 18.010000] 0.059980 0.000000 0.000000 -0.998200 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614705E, 24285, 0x61470234, 159.676, -106.917, 18.01, -0.175799, 0, 0, -0.984426, True, '2005-02-09 10:00:00'); /* Raider Juggernaut */
/* @teleloc 0x61470234 [159.675995 -106.917000 18.010000] -0.175799 0.000000 0.000000 -0.984426 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7614705F, 24497, 0x6147024B, 257.379, -91.6111, 18.01, 0.709181, 0, 0, 0.705026, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147024B [257.378998 -91.611099 18.010000] 0.709181 0.000000 0.000000 0.705026 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147060, 24497, 0x6147024B, 259.18, -88.8483, 18.01, 0.662561, 0, 0, 0.749008, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x6147024B [259.179993 -88.848297 18.010000] 0.662561 0.000000 0.000000 0.749008 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147061, 24495, 0x61470263, 220.606, -60.7367, 24.01, 0.751293, 0, 0, -0.659969, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470263 [220.606003 -60.736698 24.010000] 0.751293 0.000000 0.000000 -0.659969 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147062, 24285, 0x61470263, 221.795, -63.0557, 24.01, 0.953549, 0, 0, -0.301237, True, '2005-02-09 10:00:00'); /* Raider Juggernaut */
/* @teleloc 0x61470263 [221.794998 -63.055698 24.010000] 0.953549 0.000000 0.000000 -0.301237 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147063, 24285, 0x61470263, 221.867, -58.1314, 24.01, 0.223285, 0, 0, -0.974753, True, '2005-02-09 10:00:00'); /* Raider Juggernaut */
/* @teleloc 0x61470263 [221.867004 -58.131401 24.010000] 0.223285 0.000000 0.000000 -0.974753 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147064, 24495, 0x61470265, 227.908, -49.9789, 24.01, 0.476557, 0, 0, -0.879144, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470265 [227.908005 -49.978901 24.010000] 0.476557 0.000000 0.000000 -0.879144 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147065, 24495, 0x61470265, 232.084, -49.6016, 24.01, -0.350917, 0, 0, -0.936407, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470265 [232.084000 -49.601601 24.010000] -0.350917 0.000000 0.000000 -0.936407 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147066, 24495, 0x61470267, 230.304, -71.6212, 24.01, -0.911525, 0, 0, -0.411245, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470267 [230.304001 -71.621201 24.010000] -0.911525 0.000000 0.000000 -0.411245 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147067, 24495, 0x61470267, 226.729, -71.5334, 24.01, 0.933374, 0, 0, -0.358905, True, '2005-02-09 10:00:00'); /* Gotrok Juggernaut */
/* @teleloc 0x61470267 [226.729004 -71.533401 24.010000] 0.933374 0.000000 0.000000 -0.358905 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147068, 24497, 0x61470269, 242.057, -58.9161, 24.01, -0.692905, 0, 0, 0.721029, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470269 [242.057007 -58.916100 24.010000] -0.692905 0.000000 0.000000 0.721029 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x76147069, 24497, 0x61470269, 242.348, -60.9632, 24.01, -0.761842, 0, 0, 0.647763, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x61470269 [242.348007 -60.963200 24.010000] -0.761842 0.000000 0.000000 0.647763 */

-- 0x015D Mountain Cavern (Frore entrance)
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D000, 5114, 0x015D0100, 120, -5, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Magical Portal */
/* @teleloc 0x015D0100 [120.000000 -5.000000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D001, 269, 0x015D0101, 118.436, -10, -28.5, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Button */
/* @teleloc 0x015D0101 [118.435997 -10.000000 -28.500000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D002, 4999, 0x015D0101, 120, -10, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0101 [120.000000 -10.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D003, 4145, 0x015D0103, 120, -20, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x015D0103 [120.000000 -20.000000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D003, 0x7015D005, '2021-11-01 00:00:00')
     , (0x7015D003, 0x7015D0B2, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D004, 4999, 0x015D0103, 120, -20, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0103 [120.000000 -20.000000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D005, 2131, 0x015D0104, 120, -30, -30, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D0104 [120.000000 -30.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D006, 5000, 0x015D0104, 120, -30, -29.5452, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x015D0104 [120.000000 -30.000000 -29.545200] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D007, 5900, 0x015D0105, 120, -35.5, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Lost City of Frore Portal */
/* @teleloc 0x015D0105 [120.000000 -35.500000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D008, 4145, 0x015D0106, 130, -10, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x015D0106 [130.000000 -10.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D008, 0x7015D001, '2021-11-01 00:00:00')
     , (0x7015D008, 0x7015D0C4, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D009, 4999, 0x015D0106, 130, -10, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0106 [130.000000 -10.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D00A, 5113, 0x015D0107, 145, -10, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Magical Portal */
/* @teleloc 0x015D0107 [145.000000 -10.000000 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D00B, 269, 0x015D0107, 140, -8.435, -28.5, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Button */
/* @teleloc 0x015D0107 [140.000000 -8.435000 -28.500000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D00C, 4999, 0x015D0107, 140, -10, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0107 [140.000000 -10.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D00D, 4145, 0x015D0109, 140, -20, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x015D0109 [140.000000 -20.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D00D, 0x7015D00B, '2021-11-01 00:00:00')
     , (0x7015D00D, 0x7015D0C7, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D00E, 5112, 0x015D010A, 140, -35, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Magical Portal */
/* @teleloc 0x015D010A [140.000000 -35.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D00F, 4999, 0x015D010A, 140, -30, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D010A [140.000000 -30.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D010, 1292, 0x015D010E, 149.96, -30.0848, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x015D010E [149.960007 -30.084801 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D011, 4999, 0x015D010F, 160, -30, -29.9, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D010F [160.000000 -30.000000 -29.900000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D012, 4999, 0x015D010F, 164, -30, -29.9, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D010F [164.000000 -30.000000 -29.900000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D014, 5868, 0x015D0110, 171.217, -19.5171, -29.9925, -0.039913, 0, 0, -0.999203, True, '2021-11-01 00:00:00'); /* Gelidite Lord */
/* @teleloc 0x015D0110 [171.216995 -19.517099 -29.992500] -0.039913 0.000000 0.000000 -0.999203 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D015, 5000, 0x015D0111, 173, -30, -29.2362, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x015D0111 [173.000000 -30.000000 -29.236200] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D017, 4984, 0x015D0112, 171.004, -40.0419, -29.9925, 0.98951, 0, 0, -0.144464, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x015D0112 [171.003998 -40.041901 -29.992500] 0.989510 0.000000 0.000000 -0.144464 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D018, 4986, 0x015D0113, 178, -10, -29.9925, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D0113 [178.000000 -10.000000 -29.992500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D019, 4999, 0x015D0113, 178, -8, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0113 [178.000000 -8.000000 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D01A, 4999, 0x015D0113, 178, -12, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0113 [178.000000 -12.000000 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D01B, 4999, 0x015D0113, 182, -12, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0113 [182.000000 -12.000000 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D01C, 4999, 0x015D0113, 182, -8, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0113 [182.000000 -8.000000 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D01D, 4986, 0x015D0113, 182, -10, -29.9925, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D0113 [182.000000 -10.000000 -29.992500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D01E, 4999, 0x015D0114, 180, -20, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0114 [180.000000 -20.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D01F, 4999, 0x015D0114, 180, -17, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0114 [180.000000 -17.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D020, 4999, 0x015D0114, 180, -23, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0114 [180.000000 -23.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D021, 2131, 0x015D0114, 180, -20, -30, 0, 0, 0, -1, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D0114 [180.000000 -20.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D022, 4067, 0x015D0115, 180, -26, -29.067, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Frost Trap */
/* @teleloc 0x015D0115 [180.000000 -26.000000 -29.066999] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D022, 0x7015D021, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D024, 4999, 0x015D0115, 180, -26, -30, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0115 [180.000000 -26.000000 -30.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D025, 4999, 0x015D0116, 186, -30, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0116 [186.000000 -30.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D026, 4999, 0x015D0116, 192, -30, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0116 [192.000000 -30.000000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D027, 4999, 0x015D0116, 189, -30, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0116 [189.000000 -30.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D028, 4999, 0x015D0116, 195, -30, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0116 [195.000000 -30.000000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D029, 4999, 0x015D0118, 200.737, -21.7374, -29, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0118 [200.737000 -21.737400 -29.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D02A, 4999, 0x015D0119, 201, -26, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0119 [201.000000 -26.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D02B, 4999, 0x015D0119, 201, -34, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0119 [201.000000 -34.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D02C, 4999, 0x015D0119, 198, -30, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0119 [198.000000 -30.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D02D, 4999, 0x015D011A, 200.737, -38.263, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D011A [200.737000 -38.263000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D02E, 4999, 0x015D011E, 210, -8, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D011E [210.000000 -8.000000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D02F, 4999, 0x015D011E, 210, -10.25, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D011E [210.000000 -10.250000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D030, 5000, 0x015D011E, 210, -13.25, -30, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x015D011E [210.000000 -13.250000 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D031, 4999, 0x015D011F, 210, -22, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D011F [210.000000 -22.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D032, 4999, 0x015D011F, 210, -18, -29.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D011F [210.000000 -18.000000 -29.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D033, 4999, 0x015D011F, 206, -23, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D011F [206.000000 -23.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D034, 4999, 0x015D0120, 210, -29, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [210.000000 -29.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D035, 4999, 0x015D0120, 210, -25.5, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [210.000000 -25.500000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D036, 4999, 0x015D0120, 210, -33, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [210.000000 -33.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D037, 4999, 0x015D0120, 206, -31, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [206.000000 -31.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D038, 4999, 0x015D0120, 206, -27, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [206.000000 -27.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D039, 4999, 0x015D0120, 213.5, -29, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [213.500000 -29.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D03A, 4986, 0x015D0120, 206.216, -32.5368, -29.9925, 0.903241, 0, 0, -0.429133, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D0120 [206.216003 -32.536800 -29.992500] 0.903241 0.000000 0.000000 -0.429133 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D03B, 4984, 0x015D0120, 207.827, -34.8283, -29.9925, 0.96102, 0, 0, -0.276477, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x015D0120 [207.826996 -34.828300 -29.992500] 0.961020 0.000000 0.000000 -0.276477 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D03C, 4999, 0x015D0120, 206, -35, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0120 [206.000000 -35.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D03D, 2131, 0x015D0121, 213.859, -40.8996, -30, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D0121 [213.858994 -40.899601 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D03F, 2131, 0x015D0121, 209.084, -43.8684, -30, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D0121 [209.084000 -43.868401 -30.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D040, 4067, 0x015D0121, 205.203, -43.481, -27, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Frost Trap */
/* @teleloc 0x015D0121 [205.203003 -43.480999 -27.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D040, 0x7015D03D, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D041, 4067, 0x015D0121, 205.206, -43.4392, -28.1035, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Frost Trap */
/* @teleloc 0x015D0121 [205.205994 -43.439201 -28.103500] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D041, 0x7015D03F, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D042, 4999, 0x015D0121, 206, -39, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0121 [206.000000 -39.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D043, 4999, 0x015D0121, 210, -37, -29.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0121 [210.000000 -37.000000 -29.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D045, 5000, 0x015D0122, 222.921, -29.8292, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x015D0122 [222.921005 -29.829201 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D046, 4998, 0x015D0123, 220.135, -42.4771, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0123 [220.134995 -42.477100 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D047, 4998, 0x015D0123, 221.756, -39.8376, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0123 [221.755997 -39.837601 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D048, 4998, 0x015D0125, 223.719, -39.8512, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0125 [223.718994 -39.851200 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D049, 4998, 0x015D0126, 223.02, -50.2287, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0126 [223.020004 -50.228699 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D04A, 4998, 0x015D0126, 220.573, -48.5766, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0126 [220.572998 -48.576599 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D04B, 4998, 0x015D0128, 219.593, -45.2572, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0128 [219.593002 -45.257198 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D04C, 4999, 0x015D0129, 232.45, -30.1212, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0129 [232.449997 -30.121201 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D04D, 4999, 0x015D0129, 230, -30, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0129 [230.000000 -30.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D04E, 4999, 0x015D0129, 234.906, -30.0733, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0129 [234.906006 -30.073299 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D04F, 5000, 0x015D0129, 227.719, -29.9423, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* ChillyAirLevel3 */
/* @teleloc 0x015D0129 [227.718994 -29.942301 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D050, 4998, 0x015D012A, 231.115, -40.1473, -29.9, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D012A [231.115005 -40.147301 -29.900000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D051, 4998, 0x015D012A, 225.84, -40.0674, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D012A [225.839996 -40.067402 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D052, 4998, 0x015D012A, 227.863, -40.0538, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D012A [227.863007 -40.053799 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D053, 4998, 0x015D012A, 229.567, -39.8737, -30, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D012A [229.567001 -39.873699 -30.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D054, 4999, 0x015D012B, 244.566, -29.9893, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012B [244.565994 -29.989300 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D055, 4999, 0x015D012B, 241.427, -30.1667, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012B [241.427002 -30.166700 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D056, 4999, 0x015D012B, 237.195, -30.1428, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012B [237.195007 -30.142799 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D057, 4999, 0x015D012B, 239.134, -30.0429, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012B [239.134003 -30.042900 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D058, 4999, 0x015D012C, 239.292, -40.1434, -29.9, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012C [239.292007 -40.143398 -29.900000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D059, 4999, 0x015D012C, 240.156, -40.3528, -29.9, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012C [240.156006 -40.352798 -29.900000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D05A, 4999, 0x015D012C, 239.756, -40.5044, -29.9, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D012C [239.755997 -40.504398 -29.900000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D05C, 4999, 0x015D0131, 245.897, -30.0996, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0131 [245.897003 -30.099600 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D05D, 4999, 0x015D0131, 246.708, -30.4195, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0131 [246.707993 -30.419500 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D05E, 4999, 0x015D0132, 250, -35, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0132 [250.000000 -35.000000 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D05F, 4999, 0x015D0134, 249.35, -37.1107, -30, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0134 [249.350006 -37.110699 -30.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D060, 4999, 0x015D0135, 246.031, -39.793, -30, 0.707107, 0, 0, 0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 3 */
/* @teleloc 0x015D0135 [246.031006 -39.792999 -30.000000] 0.707107 0.000000 0.000000 0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D061, 4998, 0x015D0145, 229.482, -50.5236, -27.0542, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0145 [229.481995 -50.523602 -27.054199] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D063, 4998, 0x015D0145, 231.261, -49.2193, -25.9944, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0145 [231.261002 -49.219299 -25.994400] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D064, 4998, 0x015D0145, 227.867, -49.7016, -28.0306, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0145 [227.867004 -49.701599 -28.030600] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D066, 4998, 0x015D0146, 239.308, -51.3402, -23.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0146 [239.307999 -51.340199 -23.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D067, 4998, 0x015D0147, 236.68, -49.7599, -23.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0147 [236.679993 -49.759899 -23.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D068, 4998, 0x015D0148, 240.155, -54.3333, -23.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0148 [240.154999 -54.333302 -23.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D069, 4998, 0x015D0149, 237.617, -59.3583, -23.7324, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0149 [237.617004 -59.358299 -23.732401] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D06A, 4998, 0x015D014A, 239.745, -56.5267, -24, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D014A [239.744995 -56.526699 -24.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D06B, 4998, 0x015D014D, 221.494, -61.8164, -18, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D014D [221.494003 -61.816399 -18.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D06C, 4998, 0x015D014E, 218.971, -63.4339, -17.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D014E [218.970993 -63.433899 -17.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D06D, 4998, 0x015D014F, 224.437, -59.7838, -18, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D014F [224.436996 -59.783798 -18.000000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D06E, 4998, 0x015D0150, 221.811, -69.9663, -18, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0150 [221.811005 -69.966301 -18.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D06F, 4998, 0x015D0152, 219.845, -65.6667, -17.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0152 [219.845001 -65.666702 -17.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D070, 4998, 0x015D0153, 229.78, -60, -20.3671, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0153 [229.779999 -60.000000 -20.367100] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D071, 4998, 0x015D0153, 227.194, -59.785, -19.0671, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0153 [227.194000 -59.785000 -19.067101] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D072, 4998, 0x015D0153, 232.066, -60.1109, -21.99, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0153 [232.065994 -60.110901 -21.990000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D074, 4998, 0x015D0155, 230.582, -69.9511, -14.3671, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0155 [230.582001 -69.951103 -14.367100] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D075, 4998, 0x015D0155, 234.799, -69.6252, -11.8125, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0155 [234.798996 -69.625198 -11.812500] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D077, 4998, 0x015D0155, 225.021, -69.5176, -17.7343, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0155 [225.020996 -69.517601 -17.734301] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D078, 4998, 0x015D0156, 238.892, -72.6327, -11.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0156 [238.891998 -72.632698 -11.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D079, 4998, 0x015D0156, 237.473, -70.3811, -12, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0156 [237.473007 -70.381104 -12.000000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D07A, 4998, 0x015D0158, 239.875, -75, -11.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0158 [239.875000 -75.000000 -11.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D07B, 4998, 0x015D0159, 237.25, -80, -11.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0159 [237.250000 -80.000000 -11.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D07C, 4998, 0x015D0159, 239.37, -77.88, -11.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D0159 [239.369995 -77.879997 -11.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D07D, 4997, 0x015D015C, 70, -59, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015C [70.000000 -59.000000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D07E, 4997, 0x015D015C, 70, -62.5, -5.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015C [70.000000 -62.500000 -5.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D07F, 4997, 0x015D015D, 70.69, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015D [70.690002 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D080, 4997, 0x015D015D, 73.17, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015D [73.169998 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D081, 4997, 0x015D015E, 80, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015E [80.000000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D082, 4997, 0x015D015E, 76.5, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015E [76.500000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D083, 4997, 0x015D015E, 83.5, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015E [83.500000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D084, 4997, 0x015D015E, 78.25, -72.28, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015E [78.250000 -72.279999 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D085, 4997, 0x015D015E, 81.75, -72.28, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D015E [81.750000 -72.279999 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D086, 4997, 0x015D0162, 80, -75.31, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0162 [80.000000 -75.309998 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D087, 4997, 0x015D0164, 89.31, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0164 [89.309998 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D088, 4997, 0x015D0164, 86.83, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0164 [86.830002 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D089, 4997, 0x015D0166, 100, -59, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0166 [100.000000 -59.000000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D08A, 4997, 0x015D0166, 100, -62.5, -5.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0166 [100.000000 -62.500000 -5.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D08B, 4997, 0x015D0167, 100.69, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0167 [100.690002 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D08C, 4997, 0x015D0167, 103.17, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0167 [103.169998 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D08D, 4997, 0x015D0168, 110, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0168 [110.000000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D08E, 4997, 0x015D0168, 106.5, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0168 [106.500000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D08F, 4997, 0x015D0168, 113.5, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0168 [113.500000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D090, 4997, 0x015D0168, 108.25, -72.28, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0168 [108.250000 -72.279999 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D091, 4997, 0x015D0168, 111.75, -72.28, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0168 [111.750000 -72.279999 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D092, 4997, 0x015D016C, 110, -75.31, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D016C [110.000000 -75.309998 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D093, 4986, 0x015D016C, 111.155, -75.4735, -5.9925, -0.999932, 0, 0, -0.011672, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D016C [111.154999 -75.473503 -5.992500] -0.999932 0.000000 0.000000 -0.011672 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D094, 4997, 0x015D016E, 119.31, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D016E [119.309998 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D095, 4997, 0x015D016E, 116.83, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D016E [116.830002 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D096, 4997, 0x015D0170, 130, -59, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0170 [130.000000 -59.000000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D097, 4997, 0x015D0170, 130, -62.5, -5.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0170 [130.000000 -62.500000 -5.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D098, 4997, 0x015D0171, 130.69, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0171 [130.690002 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D099, 4997, 0x015D0171, 133.17, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0171 [133.169998 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D09A, 4997, 0x015D0172, 140, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0172 [140.000000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D09B, 4997, 0x015D0172, 136.5, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0172 [136.500000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D09C, 4997, 0x015D0172, 143.5, -69.25, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0172 [143.500000 -69.250000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D09D, 4997, 0x015D0172, 138.25, -72.28, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0172 [138.250000 -72.279999 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D09E, 4997, 0x015D0172, 141.75, -72.28, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0172 [141.750000 -72.279999 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D09F, 4997, 0x015D0176, 140, -75.31, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0176 [140.000000 -75.309998 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A0, 4997, 0x015D0178, 149.31, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0178 [149.309998 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A1, 4997, 0x015D0178, 146.83, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0178 [146.830002 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A2, 4986, 0x015D0178, 147.33, -65.9495, -5.9925, 0.327424, 0, 0, -0.944878, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D0178 [147.330002 -65.949501 -5.992500] 0.327424 0.000000 0.000000 -0.944878 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A3, 4997, 0x015D017A, 160, -59, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017A [160.000000 -59.000000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A4, 4997, 0x015D017A, 160, -62.5, -5.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017A [160.000000 -62.500000 -5.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A5, 4997, 0x015D017B, 160.69, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017B [160.690002 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A6, 4997, 0x015D017B, 163.17, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017B [163.169998 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A7, 4997, 0x015D017C, 170, -69.25, -5.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017C [170.000000 -69.250000 -5.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A8, 4997, 0x015D017C, 166.5, -69.25, -5.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017C [166.500000 -69.250000 -5.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0A9, 4997, 0x015D017C, 173.5, -69.25, -5.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017C [173.500000 -69.250000 -5.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0AA, 4997, 0x015D017C, 168.25, -72.28, -5.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017C [168.250000 -72.279999 -5.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0AB, 4997, 0x015D017C, 171.75, -72.28, -5.9, 0, 0, 0, -1, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D017C [171.750000 -72.279999 -5.900000] 0.000000 0.000000 0.000000 -1.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0AC, 4997, 0x015D0180, 170, -75.31, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0180 [170.000000 -75.309998 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0AD, 4986, 0x015D0180, 169.144, -76.5234, -5.9925, 1, 0, 0, 0, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D0180 [169.143997 -76.523399 -5.992500] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0AE, 4997, 0x015D0181, 180, -62.5, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0181 [180.000000 -62.500000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0AF, 4997, 0x015D0181, 180, -59.5, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0181 [180.000000 -59.500000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B0, 4997, 0x015D0182, 179.31, -65.82, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0182 [179.309998 -65.820000 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B1, 4997, 0x015D0182, 176.83, -68.3, -5.9, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D0182 [176.830002 -68.300003 -5.900000] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B2, 2131, 0x015D0187, 200, -75.836, -6, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D0187 [200.000000 -75.835999 -6.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B3, 4997, 0x015D018B, 220, -79.5, -5.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D018B [220.000000 -79.500000 -5.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B4, 4986, 0x015D018B, 218.08, -79.0137, -5.9925, -0.567574, 0, 0, -0.823322, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D018B [218.080002 -79.013702 -5.992500] -0.567574 0.000000 0.000000 -0.823322 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B5, 4997, 0x015D018B, 223.5, -80.5, -5.9, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 1 */
/* @teleloc 0x015D018B [223.500000 -80.500000 -5.900000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B6, 4998, 0x015D018C, 226.75, -79.5, -6.7, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D018C [226.750000 -79.500000 -6.700000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B7, 4998, 0x015D018C, 229.32, -80.5, -8.25, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D018C [229.320007 -80.500000 -8.250000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B8, 4998, 0x015D018C, 231.89, -79.5, -9.8, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D018C [231.889999 -79.500000 -9.800000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0B9, 4998, 0x015D018C, 234.46, -80.5, -11.35, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Chilly Air Level 2 */
/* @teleloc 0x015D018C [234.460007 -80.500000 -11.350000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0BA, 4986, 0x015D019C, 90, -30, 0.0075, -0.281191, 0, 0, -0.959652, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D019C [90.000000 -30.000000 0.007500] -0.281191 0.000000 0.000000 -0.959652 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0BB, 4986, 0x015D01A1, 88.6667, -59.7138, -2.74351, 0.701221, 0, 0, -0.712944, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01A1 [88.666702 -59.713799 -2.743510] 0.701221 0.000000 0.000000 -0.712944 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0BC, 4986, 0x015D01AB, 108.904, -34.8018, 0.0075, 0.383388, 0, 0, -0.923588, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01AB [108.903999 -34.801800 0.007500] 0.383388 0.000000 0.000000 -0.923588 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0BD, 4986, 0x015D01AD, 110, -40, 0.0075, -0.718733, 0, 0, -0.695286, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01AD [110.000000 -40.000000 0.007500] -0.718733 0.000000 0.000000 -0.695286 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0BE, 4986, 0x015D01B1, 115.884, -22.2442, 0.0075, 0.80985, 0, 0, -0.586637, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01B1 [115.884003 -22.244200 0.007500] 0.809850 0.000000 0.000000 -0.586637 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0BF, 4986, 0x015D01C0, 140, -30, 0.0075, 0.306732, 0, 0, -0.951796, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01C0 [140.000000 -30.000000 0.007500] 0.306732 0.000000 0.000000 -0.951796 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C0, 4986, 0x015D01D6, 170.035, -31.5608, 0.0075, 0.328868, 0, 0, -0.944376, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01D6 [170.035004 -31.560801 0.007500] 0.328868 0.000000 0.000000 -0.944376 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C1, 4986, 0x015D01D9, 170.88, -41.1389, 0.0075, -0.708418, 0, 0, -0.705793, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01D9 [170.880005 -41.138901 0.007500] -0.708418 0.000000 0.000000 -0.705793 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C2, 4986, 0x015D01E9, 196.643, -44.1972, 0.0075, 0.655894, 0, 0, -0.754853, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01E9 [196.643005 -44.197201 0.007500] 0.655894 0.000000 0.000000 -0.754853 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C3, 4984, 0x015D01E9, 203.442, -44.2055, 0.0075, -0.498488, 0, 0, -0.866897, True, '2021-11-01 00:00:00'); /* Gelidite Acolyte */
/* @teleloc 0x015D01E9 [203.442001 -44.205502 0.007500] -0.498488 0.000000 0.000000 -0.866897 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C4, 2131, 0x015D01EB, 200, -45.7, 0, -0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D01EB [200.000000 -45.700001 0.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C5, 4986, 0x015D01EB, 200.68, -49.3725, 0.0075, -0.992797, 0, 0, -0.119812, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D01EB [200.679993 -49.372501 0.007500] -0.992797 0.000000 0.000000 -0.119812 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C6, 4986, 0x015D020E, 120.162, -8.77135, 6.0075, -0.193807, 0, 0, -0.98104, True, '2021-11-01 00:00:00'); /* Gelidite Initiate */
/* @teleloc 0x015D020E [120.162003 -8.771350 6.007500] -0.193807 0.000000 0.000000 -0.981040 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C7, 2131, 0x015D022E, 200, -14, 6, 0.707107, 0, 0, -0.707107, True, '2021-11-01 00:00:00'); /* Pressure Plate */
/* @teleloc 0x015D022E [200.000000 -14.000000 6.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C8, 5110, 0x015D024C, 5.05777, -49.7693, 36, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Surface */
/* @teleloc 0x015D024C [5.057770 -49.769299 36.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0C9, 7923, 0x015D024D, 10.5617, -53.5662, 36, 0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 3 Min.) */
/* @teleloc 0x015D024D [10.561700 -53.566200 36.000000] 0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D0C9, 0x7015D018, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D01D, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D03A, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D03B, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D093, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0A2, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0AD, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0B4, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0BA, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0BB, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0BC, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0BD, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0BE, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0BF, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0C0, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0C1, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0C2, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0C3, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0C5, '2021-11-01 00:00:00')
     , (0x7015D0C9, 0x7015D0C6, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0CB, 6049, 0x015D0251, 16.5708, -56.3716, 36, -0.976296, 0, 0, -0.216439, False, '2021-11-01 00:00:00'); /* Memorial */
/* @teleloc 0x015D0251 [16.570801 -56.371601 36.000000] -0.976296 0.000000 0.000000 -0.216439 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0CC, 278, 0x015D025F, 54.757, -40, 36, -0.707107, 0, 0, -0.707107, False, '2021-11-01 00:00:00'); /* Door */
/* @teleloc 0x015D025F [54.757000 -40.000000 36.000000] -0.707107 0.000000 0.000000 -0.707107 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0CD, 7923, 0x015D024D, 11.0716, -46.7407, 36.005, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator ( 3 Min.) */
/* @teleloc 0x015D024D [11.071600 -46.740700 36.005001] 1.000000 0.000000 0.000000 0.000000 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D0CD, 0x7015D014, '2021-11-01 00:00:00')
     , (0x7015D0CD, 0x7015D017, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0CE, 43403, 0x015D0252, 28.8727, -43.1115, 36.0065, 0.368384, 0, 0, 0.929674, False, '2021-11-01 00:00:00'); /* Liam of Gelid */
/* @teleloc 0x015D0252 [28.872700 -43.111500 36.006500] 0.368384 0.000000 0.000000 0.929674 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0CF, 15759, 0x015D024F, 24.8842, -41.2833, 36.055, -0.120541, 0, 0, -0.992708, False, '2021-11-01 00:00:00'); /* Linkable Item Generator */
/* @teleloc 0x015D024F [24.884199 -41.283298 36.055000] -0.120541 0.000000 0.000000 -0.992708 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7015D0CF, 0x7015D0D0, '2021-11-01 00:00:00')
     , (0x7015D0CF, 0x7015D0D1, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0D0, 43424, 0x015D0252, 27.4164, -42.2772, 37.0417, 0.345029, 0, 0, 0.938592, True, '2021-11-01 00:00:00'); /* Dericost Token of the Aura of Retribution */
/* @teleloc 0x015D0252 [27.416401 -42.277199 37.041698] 0.345029 0.000000 0.000000 0.938592 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0D1, 43426, 0x015D0252, 26.4949, -42.2826, 37.6948, 0.345029, 0, 0, 0.938592, True, '2021-11-01 00:00:00'); /* Dericost Token of the Aura of Destruction */
/* @teleloc 0x015D0252 [26.494900 -42.282600 37.694801] 0.345029 0.000000 0.000000 0.938592 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7015D0D2, 43839, 0x015D0112, 165.737, -44.2338, -30, 0.388092, 0, 0, 0.921621, False, '2021-11-01 00:00:00'); /* Enchanted Mnemosyne */
/* @teleloc 0x015D0112 [165.737000 -44.233799 -30.000000] 0.388092 0.000000 0.000000 0.921621 */

-- 0x1B90 Black Spawn Den entrance
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x71B90000, 7242, 0x1B900000, 122.404, 87.4296, 30.005, 0.008428, 0, 0, 0.999964, False, '2005-02-09 10:00:00'); /* Black Spawn Den */
/* @teleloc 0x1B900000 [122.403999 87.429604 30.004999] 0.008428 0.000000 0.000000 0.999964 */

-- 0x2586 Mountain Citadel entrance
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586000, 25281, 0x25860000, 125.577, 26.2516, 103.829, -0.540186, 0, 0, -0.841546, False, '2005-02-09 10:00:00'); /* Mountain Citadel Portal */
/* @teleloc 0x25860000 [125.577003 26.251600 103.829002] -0.540186 0.000000 0.000000 -0.841546 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586001, 8138, 0x25860000, 161.568, 28.8701, 102.546, 0.999941, 0, 0, -0.010822, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x25860000 [161.567993 28.870100 102.545998] 0.999941 0.000000 0.000000 -0.010822 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586002, 8138, 0x25860000, 148.05, 42.0025, 102.51, -0.607738, 0, 0, 0.794137, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x25860000 [148.050003 42.002499 102.510002] -0.607738 0.000000 0.000000 0.794137 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586003, 8138, 0x25860000, 166.728, 46.3451, 102.116, -0.937115, 0, 0, 0.34902, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x25860000 [166.727997 46.345100 102.115997] -0.937115 0.000000 0.000000 0.349020 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586004, 7924, 0x25860000, 145.344, 47.5197, 102.11, -0.723914, 0, 0, 0.689891, False, '2005-02-09 10:00:00'); /* Linkable Monster Generator ( 5 Min.) */
/* @teleloc 0x25860000 [145.343994 47.519699 102.110001] -0.723914 0.000000 0.000000 0.689891 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x72586004, 0x72586001, '2005-02-09 10:00:00')
     , (0x72586004, 0x72586002, '2005-02-09 10:00:00')
     , (0x72586004, 0x72586003, '2005-02-09 10:00:00')
     , (0x72586004, 0x72586005, '2005-02-09 10:00:00')
     , (0x72586004, 0x72586006, '2005-02-09 10:00:00')
     , (0x72586004, 0x72586007, '2005-02-09 10:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586005, 24497, 0x25860000, 133.531, 29.0113, 103.669, -0.879468, 0, 0, 0.475959, True, '2005-02-09 10:00:00'); /* Gotrok Tiatus */
/* @teleloc 0x25860000 [133.531006 29.011299 103.668999] -0.879468 0.000000 0.000000 0.475959 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586006, 8138, 0x25860000, 177.345, 50.8105, 102.01, -0.940643, 0, 0, 0.339398, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x25860000 [177.345001 50.810501 102.010002] -0.940643 0.000000 0.000000 0.339398 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x72586007, 8138, 0x25860000, 174.902, 60.0795, 102.01, -0.889918, 0, 0, 0.456121, True, '2005-02-09 10:00:00'); /* Extas Raider */
/* @teleloc 0x25860000 [174.901993 60.079498 102.010002] -0.889918 0.000000 0.000000 0.456121 */

-- 0x4532 Halls of Metos entrance
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x74532000, 7295, 0x45320000, 15.858, 151.728, 69.9739, -0.751753, 0, 0, -0.659445, False, '2005-02-09 10:00:00'); /* Halls of Metos */
/* @teleloc 0x45320000 [15.858000 151.727997 69.973900] -0.751753 0.000000 0.000000 -0.659445 */

-- 0xC770 Gateway to the Halls of Metos
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770000, 948, 0xC7700113, 107.303, 154.241, 35.2055, 0.701533, 0, 0, -0.712637, True, '2021-11-01 00:00:00'); /* Mosswart Feeder */
/* @teleloc 0xC7700113 [107.303001 154.240997 35.205502] 0.701533 0.000000 0.000000 -0.712637 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770001, 1542, 0xC770011B, 110.274, 166.434, 30.005, -0.085134, 0, 0, 0.996369, False, '2021-11-01 00:00:00'); /* Linkable Item Generator */
/* @teleloc 0xC770011B [110.274002 166.434006 30.004999] -0.085134 0.000000 0.000000 0.996369 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7C770001, 0x7C770004, '2021-11-01 00:00:00')
     , (0x7C770001, 0x7C770011, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770002, 948, 0xC7700113, 106.819, 151.752, 35.2055, 0.941666, 0, 0, -0.336549, True, '2021-11-01 00:00:00'); /* Mosswart Feeder */
/* @teleloc 0xC7700113 [106.819000 151.751999 35.205502] 0.941666 0.000000 0.000000 -0.336549 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770003, 947, 0xC7700119, 99.4178, 169.617, 35.2055, 0.559275, 0, 0, -0.828982, True, '2021-11-01 00:00:00'); /* Barker Mosswart */
/* @teleloc 0xC7700119 [99.417801 169.617004 35.205502] 0.559275 0.000000 0.000000 -0.828982 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770004, 2654, 0xC770011B, 95.2919, 151.403, 30.0855, -0.733214, 0, 0, -0.679998, True, '2021-11-01 00:00:00'); /* Scroll of Endurance Other II */
/* @teleloc 0xC770011B [95.291901 151.403000 30.085501] -0.733214 0.000000 0.000000 -0.679998 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770005, 892, 0xC7700108, 191.82, 164.639, 39.205, -0.864727, 0, 0, -0.502242, False, '2021-11-01 00:00:00'); /* Drudge Prowler Generator */
/* @teleloc 0xC7700108 [191.820007 164.639008 39.205002] -0.864727 0.000000 0.000000 -0.502242 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770006, 893, 0xC7700108, 191.841, 169.729, 39.205, -0.290364, 0, 0, -0.956916, False, '2021-11-01 00:00:00'); /* Drudge Skulker Generator */
/* @teleloc 0xC7700108 [191.841003 169.729004 39.205002] -0.290364 0.000000 0.000000 -0.956916 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770007, 954, 0xC7700108, 188.165, 170.846, 39.205, 0.179416, 0, 0, -0.983773, False, '2021-11-01 00:00:00'); /* Drudge Sneaker Generator */
/* @teleloc 0xC7700108 [188.164993 170.845993 39.205002] 0.179416 0.000000 0.000000 -0.983773 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770008, 961, 0xC7700105, 180.461, 168.846, 39.205, -0.160576, 0, 0, -0.987023, False, '2021-11-01 00:00:00'); /* Mosswart Barker Generator */
/* @teleloc 0xC7700105 [180.460999 168.845993 39.205002] -0.160576 0.000000 0.000000 -0.987023 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770009, 947, 0xC770011B, 114.007, 155.914, 30.0055, 0.901381, 0, 0, 0.433027, True, '2021-11-01 00:00:00'); /* Barker Mosswart */
/* @teleloc 0xC770011B [114.007004 155.914001 30.005501] 0.901381 0.000000 0.000000 0.433027 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C77000A, 1154, 0xC770011B, 112.894, 160.587, 30.005, 0.763454, 0, 0, -0.645862, False, '2021-11-01 00:00:00'); /* Linkable Monster Generator */
/* @teleloc 0xC770011B [112.893997 160.587006 30.004999] 0.763454 0.000000 0.000000 -0.645862 */

INSERT IGNORE INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7C77000A, 0x7C770000, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770002, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770003, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770009, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C77000B, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C77000C, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C77000D, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C77000E, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C77000F, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770012, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770013, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770014, '2021-11-01 00:00:00')
     , (0x7C77000A, 0x7C770015, '2021-11-01 00:00:00');

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C77000B, 211, 0xC770011B, 116.116, 165.85, 30.0055, -0.658524, 0, 0, -0.75256, True, '2021-11-01 00:00:00'); /* Mudlurk Mosswart */
/* @teleloc 0xC770011B [116.115997 165.850006 30.005501] -0.658524 0.000000 0.000000 -0.752560 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C77000C, 211, 0xC770011B, 95.8549, 169.834, 30.0055, 0.143151, 0, 0, -0.989701, True, '2021-11-01 00:00:00'); /* Mudlurk Mosswart */
/* @teleloc 0xC770011B [95.854897 169.834000 30.005501] 0.143151 0.000000 0.000000 -0.989701 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C77000D, 4249, 0xC770011B, 111.328, 162.477, 30.0055, -0.851508, 0, 0, -0.524341, True, '2021-11-01 00:00:00'); /* Young Mosswart */
/* @teleloc 0xC770011B [111.328003 162.477005 30.005501] -0.851508 0.000000 0.000000 -0.524341 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C77000E, 4249, 0xC770011B, 106.612, 161.151, 30.0055, -0.82659, 0, 0, -0.562804, True, '2021-11-01 00:00:00'); /* Young Mosswart */
/* @teleloc 0xC770011B [106.612000 161.151001 30.005501] -0.826590 0.000000 0.000000 -0.562804 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C77000F, 1619, 0xC770011B, 112.246, 164.266, 30.0055, -0.92969, 0, 0, 0.368342, True, '2021-11-01 00:00:00'); /* Mosswart Shaman */
/* @teleloc 0xC770011B [112.246002 164.266006 30.005501] -0.929690 0.000000 0.000000 0.368342 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770010, 4014, 0xC770011B, 113.255, 166.604, 30.005, -0.398827, 0, 0, 0.917026, False, '2021-11-01 00:00:00'); /* Cheap Magic Generator */
/* @teleloc 0xC770011B [113.254997 166.604004 30.004999] -0.398827 0.000000 0.000000 0.917026 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770011, 1670, 0xC770011B, 114.482, 167.186, 30.0855, -0.159553, 0, 0, 0.987189, True, '2021-11-01 00:00:00'); /* Scroll of Light Weapon Mastery Other */
/* @teleloc 0xC770011B [114.482002 167.186005 30.085501] -0.159553 0.000000 0.000000 0.987189 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770012, 947, 0xC770011C, 119.34, 171.94, 35.2055, 0.376098, 0, 0, 0.92658, True, '2021-11-01 00:00:00'); /* Barker Mosswart */
/* @teleloc 0xC770011C [119.339996 171.940002 35.205502] 0.376098 0.000000 0.000000 0.926580 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770013, 948, 0xC7700121, 109.705, 181.989, 40.431, 0.939808, 0, 0, 0.341704, True, '2021-11-01 00:00:00'); /* Mosswart Feeder */
/* @teleloc 0xC7700121 [109.705002 181.988998 40.431000] 0.939808 0.000000 0.000000 0.341704 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770014, 947, 0xC7700000, 61.9826, 177.104, 53.2055, 0.724504, 0, 0, 0.689271, True, '2021-11-01 00:00:00'); /* Barker Mosswart */
/* @teleloc 0xC7700000 [61.982601 177.104004 53.205502] 0.724504 0.000000 0.000000 0.689271 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770015, 947, 0xC7700000, 57.0194, 178.194, 53.2055, 0.996835, 0, 0, -0.079494, True, '2021-11-01 00:00:00'); /* Barker Mosswart */
/* @teleloc 0xC7700000 [57.019402 178.194000 53.205502] 0.996835 0.000000 0.000000 -0.079494 */

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7C770016, 34438, 0xC770010D, 170.316, 185.421, 39.137, 1, 0, 0, 0, False, '2021-11-01 00:00:00'); /* Gateway to the Halls of Metos */
/* @teleloc 0xC770010D [170.315994 185.421005 39.137001] 1.000000 0.000000 0.000000 0.000000 */

-- 0xD33F Golem Burial Ground entrance
INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7D33F000, 2078, 0xD33F0000, 110.466, 149.099, 201.525, -0.81995, 0, 0, -0.572435, False, '2005-02-09 10:00:00'); /* Golem Burial Ground */
/* @teleloc 0xD33F0000 [110.466003 149.098999 201.524994] -0.819950 0.000000 0.000000 -0.572435 */

INSERT IGNORE INTO `jt_world_migration` (`name`) SELECT 'instanced-t9-dungeons' FROM DUAL WHERE EXISTS (SELECT 1 FROM `jt_t9_run`);

COMMIT;

DROP TEMPORARY TABLE IF EXISTS `jt_t9_run`;
DROP TEMPORARY TABLE IF EXISTS `jt_t9_inst`;
DROP TEMPORARY TABLE IF EXISTS `jt_t9_link`;
