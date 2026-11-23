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
