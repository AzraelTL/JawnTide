/* JawnTide: Shadow Phantom for Death (520220), a copy of stock 23089 that casts only Flame Chain (4096) and Impious Curse (2814) and fights with fire:  melee (Flaming Tachi 47675), fire unarmed hits */
DELETE FROM `weenie` WHERE `class_Id` = 520223;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520223, 'jawntide-death-shadowphantom', 10, '2021-11-29 06:19:28') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520223,   1,         16) /* ItemType - Creature */
     , (520223,   2,         22) /* CreatureType - Shadow */
     , (520223,   3,         39) /* PaletteTemplate - Black */
     , (520223,   6,         -1) /* ItemsCapacity */
     , (520223,   7,         -1) /* ContainersCapacity */
     , (520223,   8,         90) /* Mass */
     , (520223,  16,          1) /* ItemUseable - No */
     , (520223,  25,        115) /* Level */
     , (520223,  27,          0) /* ArmorType - None */
     , (520223,  68,          3) /* TargetingTactic - Random, Focused */
     , (520223,  93,    4195336) /* PhysicsState - ReportCollisions, Gravity, EdgeSlide */
     , (520223, 101,        183) /* AiAllowedCombatStyle - Unarmed, OneHanded, OneHandedAndShield, Bow, Crossbow, ThrownWeapon */
     , (520223, 113,          1) /* Gender - Male */
     , (520223, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (520223, 140,          1) /* AiOptions - CanOpenDoors */
     , (520223, 146,     125000) /* XpOverride */
     , (520223, 188,          1) /* HeritageGroup - Aluvian */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520223,   1, True ) /* Stuck */
     , (520223,   6, True ) /* AiUsesMana */
     , (520223,  11, False) /* IgnoreCollisions */
     , (520223,  12, True ) /* ReportCollisions */
     , (520223,  13, False) /* Ethereal */
     , (520223,  14, True ) /* GravityStatus */
     , (520223,  19, True ) /* Attackable */
     , (520223,  42, True ) /* AllowEdgeSlide */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520223,   1,       5) /* HeartbeatInterval */
     , (520223,   2,       0) /* HeartbeatTimestamp */
     , (520223,   3,     0.7) /* HealthRate */
     , (520223,   4,     2.5) /* StaminaRate */
     , (520223,   5,       1) /* ManaRate */
     , (520223,  12,     0.5) /* Shade */
     , (520223,  13,       1) /* ArmorModVsSlash */
     , (520223,  14,     0.8) /* ArmorModVsPierce */
     , (520223,  15,    0.85) /* ArmorModVsBludgeon */
     , (520223,  16,     0.6) /* ArmorModVsCold */
     , (520223,  17,     1.1) /* ArmorModVsFire */
     , (520223,  18,     0.7) /* ArmorModVsAcid */
     , (520223,  19,    0.75) /* ArmorModVsElectric */
     , (520223,  31,      25) /* VisualAwarenessRange */
     , (520223,  34,     1.2) /* PowerupTime */
     , (520223,  36,       1) /* ChargeSpeed */
     , (520223,  39,       1) /* DefaultScale */
     , (520223,  64,       1) /* ResistSlash */
     , (520223,  65,     0.5) /* ResistPierce */
     , (520223,  66,     0.7) /* ResistBludgeon */
     , (520223,  67,       1) /* ResistFire */
     , (520223,  68,     0.1) /* ResistCold */
     , (520223,  69,     0.2) /* ResistAcid */
     , (520223,  70,     0.5) /* ResistElectric */
     , (520223,  71,       1) /* ResistHealthBoost */
     , (520223,  72,       1) /* ResistStaminaDrain */
     , (520223,  73,       1) /* ResistStaminaBoost */
     , (520223,  74,       1) /* ResistManaDrain */
     , (520223,  75,       1) /* ResistManaBoost */
     , (520223,  76,     0.5) /* Translucency */
     , (520223,  80,       3) /* AiUseMagicDelay */
     , (520223, 104,      10) /* ObviousRadarRange */
     , (520223, 122,       2) /* AiAcquireHealth */
     , (520223, 125,       1) /* ResistHealthDrain */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520223,   1, 'Shadow Phantom') /* Name */
     , (520223,   3, 'Male') /* Sex */
     , (520223,   4, 'Aluvian') /* HeritageGroup */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520223,   1, 0x02000001) /* Setup */
     , (520223,   2, 0x09000001) /* MotionTable */
     , (520223,   3, 0x20000001) /* SoundTable */
     , (520223,   4, 0x30000000) /* CombatTable */
     , (520223,   6, 0x0400007E) /* PaletteBase */
     , (520223,   7, 0x100000B0) /* ClothingBase */
     , (520223,   8, 0x06001BBD) /* Icon */
     , (520223,   9, 0x0500114C) /* EyesTexture */
     , (520223,  10, 0x05001180) /* NoseTexture */
     , (520223,  11, 0x050011CB) /* MouthTexture */
     , (520223,  15, 0x04001FBA) /* HairPalette */
     , (520223,  16, 0x040002BE) /* EyesPalette */
     , (520223,  17, 0x040002B8) /* SkinPalette */
     , (520223,  22, 0x34000063) /* PhysicsEffectTable */
     , (520223,  35,        464) /* DeathTreasureType - Loot Tier: 5 */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520223,   1, 150, 0, 0) /* Strength */
     , (520223,   2, 170, 0, 0) /* Endurance */
     , (520223,   3, 210, 0, 0) /* Quickness */
     , (520223,   4, 190, 0, 0) /* Coordination */
     , (520223,   5, 170, 0, 0) /* Focus */
     , (520223,   6, 120, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520223,   1,   395, 0, 0, 480) /* MaxHealth */
     , (520223,   3,   450, 0, 0, 620) /* MaxStamina */
     , (520223,   5,   470, 0, 0, 590) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520223,  6, 0, 3, 0, 310, 0, 0) /* MeleeDefense        Specialized */
     , (520223,  7, 0, 3, 0, 410, 0, 0) /* MissileDefense      Specialized */
     , (520223, 14, 0, 3, 0, 200, 0, 0) /* ArcaneLore          Specialized */
     , (520223, 15, 0, 3, 0, 243, 0, 0) /* MagicDefense        Specialized */
     , (520223, 20, 0, 3, 0,  90, 0, 0) /* Deception           Specialized */
     , (520223, 31, 0, 3, 0, 225, 0, 0) /* CreatureEnchantment Specialized */
     , (520223, 33, 0, 3, 0, 225, 0, 0) /* LifeMagic           Specialized */
     , (520223, 34, 0, 3, 0, 225, 0, 0) /* WarMagic            Specialized */
     , (520223, 43, 0, 3, 0, 225, 0, 0) /* VoidMagic           Specialized (JawnTide) */
     , (520223, 44, 0, 3, 0, 308, 0, 0) /* HeavyWeapons        Specialized */
     , (520223, 45, 0, 3, 0, 308, 0, 0) /* LightWeapons        Specialized */
     , (520223, 46, 0, 3, 0, 293, 0, 0) /* FinesseWeapons      Specialized */
     , (520223, 47, 0, 3, 0, 220, 0, 0) /* MissileWeapons      Specialized */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520223,  0,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (520223,  1,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (520223,  2,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (520223,  3,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (520223,  4,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (520223,  5, 16, 50, 0.75,  500,  500,  400,  425,  300,  550,  350,  375,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (520223,  6,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (520223,  7,  4,  0,    0,  500,  500,  400,  425,  300,  550,  350,  375,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (520223,  8, 16, 60, 0.75,   60,   60,   48,   51,   36,   66,   42,   45,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520223,  4096,   2.15)  /* Flame Chain (JawnTide: Death's minions) */
     , (520223,  2814,   2.15)  /* Impious Curse (JawnTide: Death's minions) */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520223,  94) /* ATTACK_NOTIFICATION_EVENT */
     , (520223, 414) /* PLAYER_DEATH_EVENT */;

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520223, 9,  6058,  0, 0, 0.04, False) /* Create Dark Shard (6058) for ContainTreasure */
     , (520223, 9,     0,  0, 0, 0.96, False) /* Create nothing for ContainTreasure */
     , (520223, 9,  6876,  0, 0, 0.04, False) /* Create Sturdy Iron Key (6876) for ContainTreasure */
     , (520223, 9,     0,  0, 0, 0.96, False) /* Create nothing for ContainTreasure */
     , (520223, 9, 27388,  0, 0, 0.005, False) /* Create Dark Towers (27388) for ContainTreasure */
     , (520223, 9,     0,  0, 0, 0.995, False) /* Create nothing for ContainTreasure */
     , (520223, 2, 47675, 1, 0, 0, False) /* Create Flaming Tachi (47675) for Wield */;
