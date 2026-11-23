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
