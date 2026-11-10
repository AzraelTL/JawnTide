/* JawnTide Target Drudge (TrainingDummy.cs): an unkillable target for measuring PvP damage. Set it up in game with /dummy. */
DELETE FROM `weenie` WHERE `class_Id` = 4290001;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (4290001, 'ace4290001-targetdrudge', 10, '2026-11-10 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (4290001,   1,         16) /* ItemType - Creature */
     , (4290001,   2,          3) /* CreatureType - Drudge */
     , (4290001,   3,         80) /* PaletteTemplate - Iron */
     , (4290001,   6,         -1) /* ItemsCapacity */
     , (4290001,   7,         -1) /* ContainersCapacity */
     , (4290001,   8,        120) /* Mass */
     , (4290001,  16,          1) /* ItemUseable - No */
     , (4290001,  25,        200) /* Level */
     , (4290001,  27,          0) /* ArmorType - None */
     , (4290001,  67,          1) /* Tolerance - NoAttack */
     , (4290001,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (4290001, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (4290001, 146,          0) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (4290001,   1, True ) /* Stuck */
     , (4290001,   8, False) /* AllowGive */
     , (4290001,  19, True ) /* Attackable */
     , (4290001,  52, True ) /* AiImmobile */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (4290001,   1,       5) /* HeartbeatInterval */
     , (4290001,   2,       0) /* HeartbeatTimestamp */
     , (4290001,   3,       0) /* HealthRate */
     , (4290001,   4,       0) /* StaminaRate */
     , (4290001,   5,       0) /* ManaRate */
     , (4290001,  13,       1) /* ArmorModVsSlash */
     , (4290001,  14,       1) /* ArmorModVsPierce */
     , (4290001,  15,       1) /* ArmorModVsBludgeon */
     , (4290001,  16,       1) /* ArmorModVsCold */
     , (4290001,  17,       1) /* ArmorModVsFire */
     , (4290001,  18,       1) /* ArmorModVsAcid */
     , (4290001,  19,       1) /* ArmorModVsElectric */
     , (4290001,  39,     1.3) /* DefaultScale */
     , (4290001,  64,       1) /* ResistSlash */
     , (4290001,  65,       1) /* ResistPierce */
     , (4290001,  66,       1) /* ResistBludgeon */
     , (4290001,  67,       1) /* ResistFire */
     , (4290001,  68,       1) /* ResistCold */
     , (4290001,  69,       1) /* ResistAcid */
     , (4290001,  70,       1) /* ResistElectric */
     , (4290001,  71,       1) /* ResistHealthBoost */
     , (4290001,  72,       1) /* ResistStaminaDrain */
     , (4290001,  73,       1) /* ResistStaminaBoost */
     , (4290001,  74,       1) /* ResistManaDrain */
     , (4290001,  75,       1) /* ResistManaBoost */
     , (4290001, 104,      10) /* ObviousRadarRange */
     , (4290001, 125,       1) /* ResistHealthDrain */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (4290001,   1, 'Target Drudge') /* Name */
     , (4290001,  16, 'A training target. Attack it to measure your PvP damage; a report follows 15 seconds after your last hit.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (4290001,   1, 0x020007DD) /* Setup */
     , (4290001,   2, 0x09000008) /* MotionTable */
     , (4290001,   3, 0x20000007) /* SoundTable */
     , (4290001,   4, 0x30000004) /* CombatTable */
     , (4290001,   6, 0x04000F6C) /* PaletteBase */
     , (4290001,   7, 0x10000207) /* ClothingBase */
     , (4290001,   8, 0x06001035) /* Icon */
     , (4290001,  22, 0x3400001A) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (4290001,   1, 10, 0, 0) /* Strength */
     , (4290001,   2, 10, 0, 0) /* Endurance */
     , (4290001,   3, 10, 0, 0) /* Quickness */
     , (4290001,   4, 10, 0, 0) /* Coordination */
     , (4290001,   5, 10, 0, 0) /* Focus */
     , (4290001,   6, 10, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (4290001,   1, 1000000, 0, 0, 1000005) /* MaxHealth */
     , (4290001,   3,    1000, 0, 0,    1010) /* MaxStamina */
     , (4290001,   5,    1000, 0, 0,    1010) /* MaxMana */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (4290001,  0,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (4290001,  1,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (4290001,  2,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (4290001,  3,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (4290001,  4,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (4290001,  5,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (4290001,  6,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (4290001,  7,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (4290001,  8,  4,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;
