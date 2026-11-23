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
