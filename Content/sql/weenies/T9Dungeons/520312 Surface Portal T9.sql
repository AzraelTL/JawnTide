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
