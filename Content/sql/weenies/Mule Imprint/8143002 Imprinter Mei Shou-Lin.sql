/* JawnTide: Mule Imprint Token NPC for Shoushi (Sho).
   The three Imprinters (8143001, 8143002, 8143003) all work the same way: the logic is in
   Player_MuleImprint.cs (HandleMuleImprinterNpc), keyed on these class ids in MuleImprintToken.ImprinterNpcs.
   Placed by Content/sql/zz-jawntide-patches/04-mule-imprinters.sql */

DELETE FROM `weenie` WHERE `class_Id` = 8143002;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8143002, 'muleimprinter-shoushi', 10, '2026-11-01 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8143002,   1,         16) /* ItemType - Creature */
     , (8143002,   2,         31) /* CreatureType - Human */
     , (8143002,   6,         -1) /* ItemsCapacity */
     , (8143002,   7,         -1) /* ContainersCapacity */
     , (8143002,  16,         32) /* ItemUseable - Remote */
     , (8143002,  25,        100) /* Level */
     , (8143002,  93,    6292504) /* PhysicsState - ReportCollisions, IgnoreCollisions, Gravity, ReportCollisionsAsEnvironment, EdgeSlide */
     , (8143002,  95,          8) /* RadarBlipColor - Yellow */
     , (8143002, 113,          2) /* Gender - Female */
     , (8143002, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (8143002, 134,         16) /* PlayerKillerStatus - RubberGlue */
     , (8143002, 188,          3) /* HeritageGroup - Sho */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8143002,   1, True ) /* Stuck */
     , (8143002,  12, True ) /* ReportCollisions */
     , (8143002,  13, False) /* Ethereal */
     , (8143002,  14, True ) /* GravityStatus */
     , (8143002,  19, False) /* Attackable */
     , (8143002,  41, True ) /* ReportCollisionsAsEnvironment */
     , (8143002,  42, True ) /* AllowEdgeSlide */
     , (8143002,  52, True ) /* AiImmobile */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8143002,  54,       3) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8143002,   1, 'Imprinter Mei Shou-Lin') /* Name */
     , (8143002,   5, 'Imprinter') /* Template */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8143002,   1, 0x0200004E) /* Setup */
     , (8143002,   2, 0x09000001) /* MotionTable */
     , (8143002,   3, 0x20000002) /* SoundTable */
     , (8143002,   6, 0x0400007E) /* PaletteBase */
     , (8143002,   8, 0x06001036) /* Icon */
     , (8143002,   9, 0x05001054) /* EyesTexture */
     , (8143002,  10, 0x05001073) /* NoseTexture */
     , (8143002,  11, 0x0500108F) /* MouthTexture */
     , (8143002,  15, 0x04001FE0) /* HairPalette */
     , (8143002,  16, 0x040002BD) /* EyesPalette */
     , (8143002,  17, 0x0400049D) /* SkinPalette */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (8143002,   1,  70, 0, 0) /* Strength */
     , (8143002,   2,  70, 0, 0) /* Endurance */
     , (8143002,   3,  60, 0, 0) /* Quickness */
     , (8143002,   4,  65, 0, 0) /* Coordination */
     , (8143002,   5,  50, 0, 0) /* Focus */
     , (8143002,   6,  50, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (8143002,   1,    75, 0, 0, 110) /* MaxHealth */
     , (8143002,   3,   110, 0, 0, 180) /* MaxStamina */
     , (8143002,   5,    55, 0, 0, 105) /* MaxMana */;

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (8143002, 2,  2587, 1, 14, 0.5, False) /* Create Shirt (2587) for Wield */
     , (8143002, 2,   127, 1, 14, 0.3, False) /* Create Pants (127) for Wield */
     , (8143002, 2,   132, 1, 2, 0.8, False) /* Create Shoes (132) for Wield */;
