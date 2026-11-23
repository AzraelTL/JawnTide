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
