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
