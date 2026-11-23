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
