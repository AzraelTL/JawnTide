/* JawnTide: Mule Imprint Token NPC for Holtburg (Aluvian).
   The three Imprinters (8143001, 8143002, 8143003) all work the same way: the logic is in
   Player_MuleImprint.cs (HandleMuleImprinterNpc), keyed on these class ids in MuleImprintToken.ImprinterNpcs.
   Placed by Content/sql/zz-jawntide-patches/04-mule-imprinters.sql */

DELETE FROM `weenie` WHERE `class_Id` = 8143001;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8143001, 'muleimprinter-holtburg', 10, '2026-11-01 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8143001,   1,         16) /* ItemType - Creature */
     , (8143001,   2,         31) /* CreatureType - Human */
     , (8143001,   6,         -1) /* ItemsCapacity */
     , (8143001,   7,         -1) /* ContainersCapacity */
     , (8143001,  16,         32) /* ItemUseable - Remote */
     , (8143001,  25,        100) /* Level */
     , (8143001,  93,    6292504) /* PhysicsState - ReportCollisions, IgnoreCollisions, Gravity, ReportCollisionsAsEnvironment, EdgeSlide */
     , (8143001,  95,          8) /* RadarBlipColor - Yellow */
     , (8143001, 113,          1) /* Gender - Male */
     , (8143001, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (8143001, 134,         16) /* PlayerKillerStatus - RubberGlue */
     , (8143001, 188,          1) /* HeritageGroup - Aluvian */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8143001,   1, True ) /* Stuck */
     , (8143001,  12, True ) /* ReportCollisions */
     , (8143001,  13, False) /* Ethereal */
     , (8143001,  14, True ) /* GravityStatus */
     , (8143001,  19, False) /* Attackable */
     , (8143001,  41, True ) /* ReportCollisionsAsEnvironment */
     , (8143001,  42, True ) /* AllowEdgeSlide */
     , (8143001,  52, True ) /* AiImmobile */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8143001,  54,       3) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8143001,   1, 'Imprinter Aldric Hale') /* Name */
     , (8143001,   5, 'Imprinter') /* Template */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8143001,   1, 0x02000001) /* Setup */
     , (8143001,   2, 0x09000001) /* MotionTable */
     , (8143001,   3, 0x20000001) /* SoundTable */
     , (8143001,   6, 0x0400007E) /* PaletteBase */
     , (8143001,   8, 0x06001036) /* Icon */
     , (8143001,   9, 0x05001141) /* EyesTexture */
     , (8143001,  10, 0x05001182) /* NoseTexture */
     , (8143001,  11, 0x050011C9) /* MouthTexture */
     , (8143001,  15, 0x04001FDF) /* HairPalette */
     , (8143001,  16, 0x040004B1) /* EyesPalette */
     , (8143001,  17, 0x040002B7) /* SkinPalette */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (8143001,   1,  70, 0, 0) /* Strength */
     , (8143001,   2,  70, 0, 0) /* Endurance */
     , (8143001,   3,  60, 0, 0) /* Quickness */
     , (8143001,   4,  65, 0, 0) /* Coordination */
     , (8143001,   5,  50, 0, 0) /* Focus */
     , (8143001,   6,  50, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (8143001,   1,    75, 0, 0, 110) /* MaxHealth */
     , (8143001,   3,   110, 0, 0, 180) /* MaxStamina */
     , (8143001,   5,    55, 0, 0, 105) /* MaxMana */;

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (8143001, 2,  2587, 1, 4, 0.6, False) /* Create Shirt (2587) for Wield */
     , (8143001, 2,   127, 1, 8, 0.7, False) /* Create Pants (127) for Wield */
     , (8143001, 2,   132, 1, 4, 1, False) /* Create Shoes (132) for Wield */;
