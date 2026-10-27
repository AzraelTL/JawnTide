DELETE FROM `weenie` WHERE `class_Id` = 520210;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520210, 'worldbosskhaz', 10, '2026-10-27 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520210,   1,         16) /* ItemType - Creature */
     , (520210,   2,          5) /* CreatureType - Lugian */
     , (520210,   3,         13) /* PaletteTemplate - Purple */
     , (520210,   6,         -1) /* ItemsCapacity */
     , (520210,   7,         -1) /* ContainersCapacity */
     , (520210,  16,          1) /* ItemUseable - No */
     , (520210,  25,        150) /* Level */
     , (520210,  40,          1) /* CombatMode - NonCombat */
     , (520210,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520210,  81,          9) /* MaxGeneratedObjects */
     , (520210,  82,          9) /* InitGeneratedObjects */
     , (520210,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520210, 101,          1) /* AiAllowedCombatStyle - Unarmed */
     , (520210, 103,          3) /* GeneratorDestructionType - Destroy */
     , (520210, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (520210, 146,  400000000) /* XpOverride */
     , (520210, 386,         10) /* Overpower */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520210,   1, True) /* Stuck */
     , (520210,   6, False) /* AiUsesMana */
     , (520210,  11, False) /* IgnoreCollisions */
     , (520210,  12, True) /* ReportCollisions */
     , (520210,  13, False) /* Ethereal */
     , (520210,  29, True) /* NoCorpse */
     , (520210,  52, False) /* AiImmobile */
     , (520210,  65, True) /* IgnoreMagicResist */
     , (520210,  66, True) /* IgnoreMagicArmor */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520210,   1,        5) /* HeartbeatInterval */
     , (520210,   2,        0) /* HeartbeatTimestamp */
     , (520210,   3,       50) /* HealthRate */
     , (520210,   4,      100) /* StaminaRate */
     , (520210,   5,        2) /* ManaRate */
     , (520210,  13,      1.1) /* ArmorModVsSlash */
     , (520210,  14,      1.1) /* ArmorModVsPierce */
     , (520210,  15,      0.9) /* ArmorModVsBludgeon */
     , (520210,  16,      1.0) /* ArmorModVsCold */
     , (520210,  17,      0.9) /* ArmorModVsFire */
     , (520210,  18,      1.0) /* ArmorModVsAcid */
     , (520210,  19,      0.9) /* ArmorModVsElectric */
     , (520210,  31,       35) /* VisualAwarenessRange */
     , (520210,  34,        1) /* PowerupTime */
     , (520210,  36,        1) /* ChargeSpeed */
     , (520210,  39,      1.6) /* DefaultScale */
     , (520210,  41,      600) /* RegenerationInterval */
     , (520210,  43,       20) /* GeneratorRadius */
     , (520210,  55,      110) /* HomeRadius */
     , (520210,  64,      0.6) /* ResistSlash */
     , (520210,  65,      0.6) /* ResistPierce */
     , (520210,  66,      0.9) /* ResistBludgeon */
     , (520210,  67,      0.6) /* ResistFire */
     , (520210,  68,      0.6) /* ResistCold */
     , (520210,  69,      0.7) /* ResistAcid */
     , (520210,  70,      0.6) /* ResistElectric */
     , (520210,  77,        1) /* PhysicsScriptIntensity */
     , (520210,  80,        3) /* AiUseMagicDelay */
     , (520210, 104,       35) /* ObviousRadarRange */
     , (520210, 125,        1) /* ResistHealthDrain */
     , (520210, 151,      0.5) /* IgnoreShield */
     , (520210, 166,        1) /* ResistNether */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520210,   1, 'Khaz''') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520210,   1, 0x02000A0B) /* Setup */
     , (520210,   2, 0x09000006) /* MotionTable */
     , (520210,   3, 0x2000000A) /* SoundTable */
     , (520210,   4, 0x30000003) /* CombatTable */
     , (520210,   6, 0x040010C6) /* PaletteBase */
     , (520210,   7, 0x100002BA) /* ClothingBase */
     , (520210,   8, 0x06001037) /* Icon */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520210,   1, 380, 0, 0) /* Strength */
     , (520210,   2, 360, 0, 0) /* Endurance */
     , (520210,   3, 200, 0, 0) /* Quickness */
     , (520210,   4, 280, 0, 0) /* Coordination */
     , (520210,   5, 180, 0, 0) /* Focus */
     , (520210,   6, 180, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520210,   1, 159820, 0, 0, 160000) /* MaxHealth */
     , (520210,   3, 49640, 0, 0, 50000) /* MaxStamina */
     , (520210,   5, 29820, 0, 0, 30000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520210,  6, 0, 2, 0, 210, 0, 0) /* MeleeDefense        Trained */
     , (520210,  7, 0, 2, 0, 240, 0, 0) /* MissileDefense      Trained */
     , (520210, 15, 0, 2, 0, 300, 0, 0) /* MagicDefense        Trained */
     , (520210, 16, 0, 2, 0, 150, 0, 0) /* ManaConversion      Trained */
     , (520210, 31, 0, 2, 0, 270, 0, 0) /* CreatureEnchantment Trained */
     , (520210, 33, 0, 2, 0, 270, 0, 0) /* LifeMagic           Trained */
     , (520210, 34, 0, 2, 0, 280, 0, 0) /* WarMagic            Trained */
     , (520210, 44, 0, 2, 0, 260, 0, 0) /* HeavyWeapons        Trained */
     , (520210, 45, 0, 2, 0, 260, 0, 0) /* LightWeapons        Trained */
     , (520210, 46, 0, 2, 0, 260, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520210,  0,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (520210,  1,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (520210,  2,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (520210,  3,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (520210,  4,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (520210,  5,  4,  85,  0.5,  420, 462, 462, 378, 420, 378, 420, 378,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (520210,  6,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (520210,  7,  4,   0,    0,  420, 462, 462, 378, 420, 378, 420, 378,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (520210,  8,  4,  70,  0.5,  420, 462, 462, 378, 420, 378, 420, 378,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520210,  2144,  2.05)  /* Shock Wave VII */
     , (520210,  2126,  2.05)  /* Bludgeoning Volley VII */
     , (520210,  2166,  2.15)  /* Bludgeon Vulnerability Other VII */
     , (520210,  2084,   2.1)  /* Slowness Other VII */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520210, 414) /* PLAYER_DEATH_EVENT */;

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520210, 3 /* Death */, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 16 /* WorldBroadcast */, 0, 1, NULL, '%s has struck down Khaz''! The Lugian Titan topples like a falling mountain, and the earth is still once more.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520210, 14 /* Taunt */, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Khaz'' raises both fists high above his head, ready to shatter the very ground! WATCH OUT!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1789 /* Shockwave Ring */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520210, 9, 520212,  0, 0, 1, False) /* Create Khaz's Knucklebone Gen (520212) for ContainTreasure */;

INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520210, -1, 7101, 1, 6, 6, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Tiatus Lugian (7101) (x6 up to max of 6) - Regenerate upon Destruction - Location to (re)Generate: Scatter */
     , (520210, -1, 29348, 1, 3, 3, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Bokrok Lugian (29348) (x3 up to max of 3) - Regenerate upon Destruction - Location to (re)Generate: Scatter */;
