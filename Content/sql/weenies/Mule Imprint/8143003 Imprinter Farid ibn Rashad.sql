/* JawnTide: Mule Imprint Token NPC for Yaraq (Gharundim).
   The three Imprinters (8143001, 8143002, 8143003) all work the same way: the logic is in
   Player_MuleImprint.cs (HandleMuleImprinterNpc), keyed on these class ids in MuleImprintToken.ImprinterNpcs.
   Placed by Content/sql/zz-jawntide-patches/04-mule-imprinters.sql */

DELETE FROM `weenie` WHERE `class_Id` = 8143003;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8143003, 'muleimprinter-yaraq', 10, '2026-11-01 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8143003,   1,         16) /* ItemType - Creature */
     , (8143003,   2,         31) /* CreatureType - Human */
     , (8143003,   6,         -1) /* ItemsCapacity */
     , (8143003,   7,         -1) /* ContainersCapacity */
     , (8143003,  16,         32) /* ItemUseable - Remote */
     , (8143003,  25,        100) /* Level */
     , (8143003,  93,    6292504) /* PhysicsState - ReportCollisions, IgnoreCollisions, Gravity, ReportCollisionsAsEnvironment, EdgeSlide */
     , (8143003,  95,          8) /* RadarBlipColor - Yellow */
     , (8143003, 113,          1) /* Gender - Male */
     , (8143003, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (8143003, 134,         16) /* PlayerKillerStatus - RubberGlue */
     , (8143003, 188,          2) /* HeritageGroup - Gharundim */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8143003,   1, True ) /* Stuck */
     , (8143003,  12, True ) /* ReportCollisions */
     , (8143003,  13, False) /* Ethereal */
     , (8143003,  14, True ) /* GravityStatus */
     , (8143003,  19, False) /* Attackable */
     , (8143003,  41, True ) /* ReportCollisionsAsEnvironment */
     , (8143003,  42, True ) /* AllowEdgeSlide */
     , (8143003,  52, True ) /* AiImmobile */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8143003,  54,       3) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8143003,   1, 'Imprinter Farid ibn Rashad') /* Name */
     , (8143003,   5, 'Imprinter') /* Template */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8143003,   1, 0x02000001) /* Setup */
     , (8143003,   2, 0x09000001) /* MotionTable */
     , (8143003,   3, 0x20000001) /* SoundTable */
     , (8143003,   6, 0x0400007E) /* PaletteBase */
     , (8143003,   8, 0x06001036) /* Icon */
     , (8143003,   9, 0x05001115) /* EyesTexture */
     , (8143003,  10, 0x0500116A) /* NoseTexture */
     , (8143003,  11, 0x050011B8) /* MouthTexture */
     , (8143003,  15, 0x04002013) /* HairPalette */
     , (8143003,  16, 0x040002BF) /* EyesPalette */
     , (8143003,  17, 0x040002AF) /* SkinPalette */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (8143003,   1,  70, 0, 0) /* Strength */
     , (8143003,   2,  70, 0, 0) /* Endurance */
     , (8143003,   3,  60, 0, 0) /* Quickness */
     , (8143003,   4,  65, 0, 0) /* Coordination */
     , (8143003,   5,  50, 0, 0) /* Focus */
     , (8143003,   6,  50, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (8143003,   1,    75, 0, 0, 110) /* MaxHealth */
     , (8143003,   3,   110, 0, 0, 180) /* MaxStamina */
     , (8143003,   5,    55, 0, 0, 105) /* MaxMana */;

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (8143003, 2,  2587, 1, 9, 0.9, False) /* Create Shirt (2587) for Wield */
     , (8143003, 2,   127, 1, 4, 0.5, False) /* Create Pants (127) for Wield */
     , (8143003, 2,   132, 1, 9, 0.6, False) /* Create Shoes (132) for Wield */;
