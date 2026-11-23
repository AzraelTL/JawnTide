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
