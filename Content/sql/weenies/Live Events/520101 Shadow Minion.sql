/* JawnTide live events: summoned by the event boss's /minions. Copy of the stock Umbris Shadow (4254, level 80) with no XP; its only loot is one Shadow Essence (520120). */
DELETE FROM `weenie` WHERE `class_Id` = 520101;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520101, 'jawntide-eventbossminion', 10, '2021-11-29 06:19:28') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520101,   1,         16) /* ItemType - Creature */
     , (520101,   2,         22) /* CreatureType - Shadow */
     , (520101,   3,         39) /* PaletteTemplate - Black */
     , (520101,   6,         -1) /* ItemsCapacity */
     , (520101,   7,         -1) /* ContainersCapacity */
     , (520101,   8,         90) /* Mass */
     , (520101,  16,          1) /* ItemUseable - No */
     , (520101,  25,         80) /* Level */
     , (520101,  27,          0) /* ArmorType - None */
     , (520101,  68,          3) /* TargetingTactic - Random, Focused */
     , (520101,  93,    4195336) /* PhysicsState - ReportCollisions, Gravity, EdgeSlide */
     , (520101, 101,        183) /* AiAllowedCombatStyle - Unarmed, OneHanded, OneHandedAndShield, Bow, Crossbow, ThrownWeapon */
     , (520101, 113,          2) /* Gender - Female */
     , (520101, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (520101, 140,          1) /* AiOptions - CanOpenDoors */
     , (520101, 146,          0) /* XpOverride */
     , (520101, 188,          1) /* HeritageGroup - Aluvian */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520101,   1, True ) /* Stuck */
     , (520101,   6, True ) /* AiUsesMana */
     , (520101,  11, False) /* IgnoreCollisions */
     , (520101,  12, True ) /* ReportCollisions */
     , (520101,  13, False) /* Ethereal */
     , (520101,  14, True ) /* GravityStatus */
     , (520101,  19, True ) /* Attackable */
     , (520101,  42, True ) /* AllowEdgeSlide */
     , (520101,  50, True ) /* NeverFailCasting */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520101,   1,       5) /* HeartbeatInterval */
     , (520101,   2,       0) /* HeartbeatTimestamp */
     , (520101,   3,     0.7) /* HealthRate */
     , (520101,   4,     2.5) /* StaminaRate */
     , (520101,   5,       1) /* ManaRate */
     , (520101,  12,     0.5) /* Shade */
     , (520101,  13,       1) /* ArmorModVsSlash */
     , (520101,  14,    0.86) /* ArmorModVsPierce */
     , (520101,  15,    0.91) /* ArmorModVsBludgeon */
     , (520101,  16,    0.76) /* ArmorModVsCold */
     , (520101,  17,       1) /* ArmorModVsFire */
     , (520101,  18,    0.78) /* ArmorModVsAcid */
     , (520101,  19,    0.86) /* ArmorModVsElectric */
     , (520101,  31,      28) /* VisualAwarenessRange */
     , (520101,  34,     1.1) /* PowerupTime */
     , (520101,  36,       1) /* ChargeSpeed */
     , (520101,  39,     0.8) /* DefaultScale */
     , (520101,  64,       1) /* ResistSlash */
     , (520101,  65,     0.5) /* ResistPierce */
     , (520101,  66,    0.67) /* ResistBludgeon */
     , (520101,  67,       1) /* ResistFire */
     , (520101,  68,     0.1) /* ResistCold */
     , (520101,  69,     0.2) /* ResistAcid */
     , (520101,  70,     0.5) /* ResistElectric */
     , (520101,  71,       1) /* ResistHealthBoost */
     , (520101,  72,       1) /* ResistStaminaDrain */
     , (520101,  73,       1) /* ResistStaminaBoost */
     , (520101,  74,       1) /* ResistManaDrain */
     , (520101,  75,       1) /* ResistManaBoost */
     , (520101,  76,     0.5) /* Translucency */
     , (520101,  80,       3) /* AiUseMagicDelay */
     , (520101, 104,      10) /* ObviousRadarRange */
     , (520101, 109,       1) /* BondWieldedTreasure */
     , (520101, 122,       5) /* AiAcquireHealth */
     , (520101, 125,       1) /* ResistHealthDrain */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520101,   1, 'Shadow Minion') /* Name */
     , (520101,   3, 'Female') /* Sex */
     , (520101,   4, 'Aluvian') /* HeritageGroup */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520101,   1, 0x0200071B) /* Setup */
     , (520101,   2, 0x09000093) /* MotionTable */
     , (520101,   3, 0x20000002) /* SoundTable */
     , (520101,   4, 0x30000028) /* CombatTable */
     , (520101,   6, 0x0400007E) /* PaletteBase */
     , (520101,   7, 0x1000019F) /* ClothingBase */
     , (520101,   8, 0x06001BBE) /* Icon */
     , (520101,   9, 0x05001055) /* EyesTexture */
     , (520101,  10, 0x0500106E) /* NoseTexture */
     , (520101,  11, 0x050010B1) /* MouthTexture */
     , (520101,  15, 0x04001FB5) /* HairPalette */
     , (520101,  16, 0x040004B1) /* EyesPalette */
     , (520101,  17, 0x040002B8) /* SkinPalette */
     , (520101,  22, 0x34000063) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520101,   1, 100, 0, 0) /* Strength */
     , (520101,   2, 120, 0, 0) /* Endurance */
     , (520101,   3, 160, 0, 0) /* Quickness */
     , (520101,   4, 140, 0, 0) /* Coordination */
     , (520101,   5, 120, 0, 0) /* Focus */
     , (520101,   6,  70, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520101,   1,   195, 0, 0, 255) /* MaxHealth */
     , (520101,   3,   250, 0, 0, 370) /* MaxStamina */
     , (520101,   5,   260, 0, 0, 330) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520101,  6, 0, 3, 0, 235, 0, 0) /* MeleeDefense        Specialized */
     , (520101,  7, 0, 3, 0, 345, 0, 0) /* MissileDefense      Specialized */
     , (520101, 14, 0, 2, 0, 320, 0, 0) /* ArcaneLore          Trained */
     , (520101, 15, 0, 3, 0, 205, 0, 0) /* MagicDefense        Specialized */
     , (520101, 20, 0, 2, 0, 150, 0, 0) /* Deception           Trained */
     , (520101, 31, 0, 3, 0, 110, 0, 0) /* CreatureEnchantment Specialized */
     , (520101, 33, 0, 3, 0, 110, 0, 0) /* LifeMagic           Specialized */
     , (520101, 34, 0, 3, 0, 110, 0, 0) /* WarMagic            Specialized */
     , (520101, 44, 0, 3, 0, 225, 0, 0) /* HeavyWeapons        Specialized */
     , (520101, 45, 0, 3, 0, 225, 0, 0) /* LightWeapons        Specialized */
     , (520101, 46, 0, 3, 0, 180, 0, 0) /* FinesseWeapons      Specialized */
     , (520101, 47, 0, 3, 0, 220, 0, 0) /* MissileWeapons      Specialized */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520101,  0,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (520101,  1,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (520101,  2,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (520101,  3,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (520101,  4,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (520101,  5,  4, 45, 0.75,  230,  230,  198,  209,  175,  230,  179,  198,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (520101,  6,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (520101,  7,  4,  0,    0,  230,  230,  198,  209,  175,  230,  179,  198,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (520101,  8,  4, 45, 0.75,  230,  230,  198,  209,  175,  230,  179,  198,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520101,    72,  2.032)  /* Frost Bolt IV */
     , (520101,    78,  2.032)  /* Lightning Bolt IV */
     , (520101,    83,  2.032)  /* Flame Bolt IV */
     , (520101,    89,  2.032)  /* Force Bolt IV */
     , (520101,    95,  2.032)  /* Whirling Blade IV */
     , (520101,   136,  2.003)  /* Frost Volley IV */
     , (520101,   140,  2.003)  /* Lightning Volley IV */
     , (520101,   144,  2.003)  /* Flame Volley IV */
     , (520101,   148,  2.003)  /* Force Volley IV */
     , (520101,   152,  2.003)  /* Blade Volley IV */
     , (520101,   232,  2.023)  /* Vulnerability Other IV */
     , (520101,   277,  2.006)  /* Magic Resistance Self IV */
     , (520101,   283,  2.023)  /* Magic Yield Other IV */
     , (520101,   608,  2.006)  /* Life Magic Mastery Self IV */
     , (520101,   626,  2.023)  /* Life Magic Ineptitude Other IV */
     , (520101,   656,  2.006)  /* Mana Conversion Mastery Self IV */
     , (520101,  1159,   2.02)  /* Heal Self IV */
     , (520101,  1174,  2.023)  /* Harm Other IV */
     , (520101,  1240,  2.023)  /* Drain Health Other IV */
     , (520101,  1310,  2.006)  /* Armor Self IV */
     , (520101,  1418,  2.023)  /* Slowness Other IV */
     , (520101,  1466,  2.023)  /* Feeblemind Other IV */;

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520101, 9, 520120,  1, 0, 1, False) /* Create Shadow Essence (520120) for ContainTreasure */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520101,  94) /* ATTACK_NOTIFICATION_EVENT */
     , (520101, 414) /* PLAYER_DEATH_EVENT */;
