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
