/* JawnTide: template for the "Ghost of [Mule]" passive pet. Code: WorldObjects/MuleGhost.cs.
   WeenieType 69 = Pet. At summon time the server copies the body, face, colours and visible
   clothing onto it, renames it "Ghost of <mule>", and makes it translucent. */

DELETE FROM `weenie` WHERE `class_Id` = 8143005;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8143005, 'muleghost', 69, '2026-11-01 00:00:00') /* Pet */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8143005,   1,         16) /* ItemType - Creature */
     , (8143005,   2,         31) /* CreatureType - Human */
     , (8143005,   6,         -1) /* ItemsCapacity */
     , (8143005,   7,         -1) /* ContainersCapacity */
     , (8143005,  16,         32) /* ItemUseable - Remote */
     , (8143005,  25,          1) /* Level */
     , (8143005,  27,          0) /* ArmorType - None */
     , (8143005,  93,    2098196) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity, ReportCollisionsAsEnvironment */
     , (8143005,  95,          8) /* RadarBlipColor - Yellow */
     , (8143005, 113,          1) /* Gender - Male */
     , (8143005, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (8143005, 134,         16) /* PlayerKillerStatus - RubberGlue */
     , (8143005, 188,          1) /* HeritageGroup - Aluvian */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8143005,   1, True ) /* Stuck */
     , (8143005,   8, True ) /* AllowGive */
     , (8143005,  19, False) /* Attackable */
     , (8143005,  98, True ) /* Invincible */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8143005,   1,       5) /* HeartbeatInterval */
     , (8143005,   2,       0) /* HeartbeatTimestamp */
     , (8143005,  31,      50) /* VisualAwarenessRange */
     , (8143005,  54,       3) /* UseRadius */
     , (8143005,  76,    0.45) /* Translucency */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8143005,   1, 'Ghost of a Mule') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8143005,   1, 0x02000001) /* Setup */
     , (8143005,   2, 0x09000001) /* MotionTable */
     , (8143005,   3, 0x20000001) /* SoundTable */
     , (8143005,   6, 0x0400007E) /* PaletteBase */
     , (8143005,   8, 0x06001036) /* Icon */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (8143005,   1, 100, 0, 0) /* Strength */
     , (8143005,   2, 100, 0, 0) /* Endurance */
     , (8143005,   3, 300, 0, 0) /* Quickness */
     , (8143005,   4, 100, 0, 0) /* Coordination */
     , (8143005,   5, 100, 0, 0) /* Focus */
     , (8143005,   6, 100, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (8143005,   1,   100, 0, 0, 150) /* MaxHealth */
     , (8143005,   3,   500, 0, 0, 600) /* MaxStamina */
     , (8143005,   5,     0, 0, 0, 100) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (8143005, 24, 0, 3, 0, 300, 0, 0) /* Run Specialized */;
