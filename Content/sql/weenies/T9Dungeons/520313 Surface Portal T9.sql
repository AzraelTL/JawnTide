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
