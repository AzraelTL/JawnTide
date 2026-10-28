/* JawnTide: Shadow Spectre for Death (520220), a copy of stock 23090 that also casts Flame Chain (4096) and Impious Curse (2814) */
DELETE FROM `weenie` WHERE `class_Id` = 520224;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520224, 'jawntide-death-shadowspecter', 10, '2021-11-29 06:19:28') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520224,   1,         16) /* ItemType - Creature */
     , (520224,   2,         22) /* CreatureType - Shadow */
     , (520224,   3,         39) /* PaletteTemplate - Black */
     , (520224,   6,         -1) /* ItemsCapacity */
     , (520224,   7,         -1) /* ContainersCapacity */
     , (520224,   8,         90) /* Mass */
     , (520224,  16,          1) /* ItemUseable - No */
     , (520224,  25,        115) /* Level */
     , (520224,  27,          0) /* ArmorType - None */
     , (520224,  68,          3) /* TargetingTactic - Random, Focused */
     , (520224,  93,    4195336) /* PhysicsState - ReportCollisions, Gravity, EdgeSlide */
     , (520224, 101,        183) /* AiAllowedCombatStyle - Unarmed, OneHanded, OneHandedAndShield, Bow, Crossbow, ThrownWeapon */
     , (520224, 113,          2) /* Gender - Female */
     , (520224, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (520224, 140,          1) /* AiOptions - CanOpenDoors */
     , (520224, 146,     125000) /* XpOverride */
     , (520224, 188,          1) /* HeritageGroup - Aluvian */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520224,   1, True ) /* Stuck */
     , (520224,   6, True ) /* AiUsesMana */
     , (520224,  11, False) /* IgnoreCollisions */
     , (520224,  12, True ) /* ReportCollisions */
     , (520224,  13, False) /* Ethereal */
     , (520224,  14, True ) /* GravityStatus */
     , (520224,  19, True ) /* Attackable */
     , (520224,  42, True ) /* AllowEdgeSlide */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520224,   1,       5) /* HeartbeatInterval */
     , (520224,   2,       0) /* HeartbeatTimestamp */
     , (520224,   3,     0.7) /* HealthRate */
     , (520224,   4,     2.5) /* StaminaRate */
     , (520224,   5,       1) /* ManaRate */
     , (520224,  12,     0.5) /* Shade */
     , (520224,  13,       1) /* ArmorModVsSlash */
     , (520224,  14,     0.8) /* ArmorModVsPierce */
     , (520224,  15,    0.85) /* ArmorModVsBludgeon */
     , (520224,  16,     0.6) /* ArmorModVsCold */
     , (520224,  17,     1.1) /* ArmorModVsFire */
     , (520224,  18,     0.7) /* ArmorModVsAcid */
     , (520224,  19,    0.75) /* ArmorModVsElectric */
     , (520224,  31,      18) /* VisualAwarenessRange */
     , (520224,  34,     1.1) /* PowerupTime */
     , (520224,  36,       1) /* ChargeSpeed */
     , (520224,  39,       1) /* DefaultScale */
     , (520224,  64,       1) /* ResistSlash */
     , (520224,  65,     0.5) /* ResistPierce */
     , (520224,  66,     0.7) /* ResistBludgeon */
     , (520224,  67,       1) /* ResistFire */
     , (520224,  68,     0.1) /* ResistCold */
     , (520224,  69,     0.2) /* ResistAcid */
     , (520224,  70,     0.5) /* ResistElectric */
     , (520224,  71,       1) /* ResistHealthBoost */
     , (520224,  72,       1) /* ResistStaminaDrain */
     , (520224,  73,       1) /* ResistStaminaBoost */
     , (520224,  74,       1) /* ResistManaDrain */
     , (520224,  75,       1) /* ResistManaBoost */
     , (520224,  76,     0.5) /* Translucency */
     , (520224,  80,       3) /* AiUseMagicDelay */
     , (520224, 104,      10) /* ObviousRadarRange */
     , (520224, 122,       2) /* AiAcquireHealth */
     , (520224, 125,       1) /* ResistHealthDrain */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520224,   1, 'Shadow Spectre') /* Name */
     , (520224,   3, 'Female') /* Sex */
     , (520224,   4, 'Aluvian') /* HeritageGroup */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520224,   1, 0x0200071B) /* Setup */
     , (520224,   2, 0x09000093) /* MotionTable */
     , (520224,   3, 0x20000002) /* SoundTable */
     , (520224,   4, 0x30000028) /* CombatTable */
     , (520224,   6, 0x0400007E) /* PaletteBase */
     , (520224,   7, 0x1000019F) /* ClothingBase */
     , (520224,   8, 0x06001BBE) /* Icon */
     , (520224,   9, 0x05001068) /* EyesTexture */
     , (520224,  10, 0x05001071) /* NoseTexture */
     , (520224,  11, 0x050010AA) /* MouthTexture */
     , (520224,  15, 0x04001FDB) /* HairPalette */
     , (520224,  16, 0x040002BC) /* EyesPalette */
     , (520224,  17, 0x040002BA) /* SkinPalette */
     , (520224,  22, 0x34000063) /* PhysicsEffectTable */
     , (520224,  35,        452) /* DeathTreasureType - Loot Tier: 5 */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520224,   1, 150, 0, 0) /* Strength */
     , (520224,   2, 170, 0, 0) /* Endurance */
     , (520224,   3, 210, 0, 0) /* Quickness */
     , (520224,   4, 190, 0, 0) /* Coordination */
     , (520224,   5, 170, 0, 0) /* Focus */
     , (520224,   6, 120, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520224,   1,   395, 0, 0, 480) /* MaxHealth */
     , (520224,   3,   450, 0, 0, 620) /* MaxStamina */
     , (520224,   5,   470, 0, 0, 590) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520224,  6, 0, 3, 0, 300, 0, 0) /* MeleeDefense        Specialized */
     , (520224,  7, 0, 3, 0, 403, 0, 0) /* MissileDefense      Specialized */
     , (520224, 14, 0, 3, 0, 320, 0, 0) /* ArcaneLore          Specialized */
     , (520224, 15, 0, 3, 0, 230, 0, 0) /* MagicDefense        Specialized */
     , (520224, 20, 0, 3, 0, 150, 0, 0) /* Deception           Specialized */
     , (520224, 31, 0, 3, 0, 225, 0, 0) /* CreatureEnchantment Specialized */
     , (520224, 33, 0, 3, 0, 225, 0, 0) /* LifeMagic           Specialized */
     , (520224, 34, 0, 3, 0, 225, 0, 0) /* WarMagic            Specialized */
     , (520224, 43, 0, 3, 0, 225, 0, 0) /* VoidMagic           Specialized (JawnTide) */
     , (520224, 44, 0, 3, 0, 303, 0, 0) /* HeavyWeapons        Specialized */
     , (520224, 45, 0, 3, 0, 303, 0, 0) /* LightWeapons        Specialized */
     , (520224, 46, 0, 3, 0, 303, 0, 0) /* FinesseWeapons      Specialized */
     , (520224, 47, 0, 3, 0, 220, 0, 0) /* MissileWeapons      Specialized */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520224,  0,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (520224,  1,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (520224,  2,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (520224,  3,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (520224,  4,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (520224,  5,  4, 50, 0.75,  460,  460,  368,  391,  276,  506,  322,  345,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (520224,  6,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (520224,  7,  4,  0,    0,  460,  460,  368,  391,  276,  506,  322,  345,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (520224,  8,  4, 60, 0.75,  460,  460,  368,  391,  276,  506,  322,  345,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520224,    74,  2.032)  /* Frost Bolt VI */
     , (520224,    80,  2.032)  /* Lightning Bolt VI */
     , (520224,    85,  2.032)  /* Flame Bolt VI */
     , (520224,    91,  2.032)  /* Force Bolt VI */
     , (520224,    97,  2.032)  /* Whirling Blade VI */
     , (520224,   138,  2.003)  /* Frost Volley VI */
     , (520224,   142,  2.003)  /* Lightning Volley VI */
     , (520224,   146,  2.003)  /* Flame Volley VI */
     , (520224,   154,  2.003)  /* Blade Volley VI */
     , (520224,   234,  2.023)  /* Vulnerability Other VI */
     , (520224,   267,  2.023)  /* Defenselessness Other VI */
     , (520224,   285,  2.023)  /* Magic Yield Other VI */
     , (520224,   628,  2.023)  /* Life Magic Ineptitude Other VI */
     , (520224,  1161,   2.02)  /* Heal Self VI */
     , (520224,  1242,  2.011)  /* Drain Health Other VI */
     , (520224,  1254,  2.011)  /* Drain Stamina Other VI */
     , (520224,  1265,  2.011)  /* Drain Mana Other VI */
     , (520224,  1312,  2.006)  /* Armor Self VI */
     , (520224,  1420,  2.023)  /* Slowness Other VI */
     , (520224,  1468,  2.023)  /* Feeblemind Other VI */
     , (520224,  4096,   2.05)  /* Flame Chain (JawnTide: Death's minions) */
     , (520224,  2814,   2.05)  /* Impious Curse (JawnTide: Death's minions) */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520224,  94) /* ATTACK_NOTIFICATION_EVENT */
     , (520224, 414) /* PLAYER_DEATH_EVENT */;

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520224, 9,  6058,  0, 0, 0.04, False) /* Create Dark Shard (6058) for ContainTreasure */
     , (520224, 9,     0,  0, 0, 0.96, False) /* Create nothing for ContainTreasure */
     , (520224, 9,  6876,  0, 0, 0.04, False) /* Create Sturdy Iron Key (6876) for ContainTreasure */
     , (520224, 9,     0,  0, 0, 0.96, False) /* Create nothing for ContainTreasure */
     , (520224, 9, 23108,  0, 0, 0.01, False) /* Create Twisted Dark Key (23108) for ContainTreasure */
     , (520224, 9,     0,  0, 0, 0.99, False) /* Create nothing for ContainTreasure */
     , (520224, 9, 27388,  0, 0, 0.005, False) /* Create Dark Towers (27388) for ContainTreasure */
     , (520224, 9,     0,  0, 0, 0.995, False) /* Create nothing for ContainTreasure */;
