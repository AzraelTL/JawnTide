DELETE FROM `weenie` WHERE `class_Id` = 520200;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520200, 'worldbossmoloch', 10, '2026-10-27 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520200,   1,         16) /* ItemType - Creature */
     , (520200,   2,          3) /* CreatureType - Drudge */
     , (520200,   3,         39) /* PaletteTemplate - Black */
     , (520200,   6,         -1) /* ItemsCapacity */
     , (520200,   7,         -1) /* ContainersCapacity */
     , (520200,  16,          1) /* ItemUseable - No */
     , (520200,  25,        150) /* Level */
     , (520200,  40,          1) /* CombatMode - NonCombat */
     , (520200,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520200,  81,          9) /* MaxGeneratedObjects */
     , (520200,  82,          9) /* InitGeneratedObjects */
     , (520200,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520200, 101,          1) /* AiAllowedCombatStyle - Unarmed */
     , (520200, 103,          3) /* GeneratorDestructionType - Destroy */
     , (520200, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (520200, 146,  400000000) /* XpOverride */
     , (520200, 386,         10) /* Overpower */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520200,   1, True) /* Stuck */
     , (520200,   6, False) /* AiUsesMana */
     , (520200,  11, False) /* IgnoreCollisions */
     , (520200,  12, True) /* ReportCollisions */
     , (520200,  13, False) /* Ethereal */
     , (520200,  29, True) /* NoCorpse */
     , (520200,  52, False) /* AiImmobile */
     , (520200,  65, True) /* IgnoreMagicResist */
     , (520200,  66, True) /* IgnoreMagicArmor */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520200,   1,        5) /* HeartbeatInterval */
     , (520200,   2,        0) /* HeartbeatTimestamp */
     , (520200,   3,       50) /* HealthRate */
     , (520200,   4,      100) /* StaminaRate */
     , (520200,   5,        2) /* ManaRate */
     , (520200,  13,      1.0) /* ArmorModVsSlash */
     , (520200,  14,      1.0) /* ArmorModVsPierce */
     , (520200,  15,      1.1) /* ArmorModVsBludgeon */
     , (520200,  16,      0.9) /* ArmorModVsCold */
     , (520200,  17,      0.9) /* ArmorModVsFire */
     , (520200,  18,      1.0) /* ArmorModVsAcid */
     , (520200,  19,      1.0) /* ArmorModVsElectric */
     , (520200,  31,       35) /* VisualAwarenessRange */
     , (520200,  34,        1) /* PowerupTime */
     , (520200,  36,        1) /* ChargeSpeed */
     , (520200,  39,      4.0) /* DefaultScale */
     , (520200,  41,      600) /* RegenerationInterval */
     , (520200,  43,       20) /* GeneratorRadius */
     , (520200,  55,      110) /* HomeRadius */
     , (520200,  64,      0.6) /* ResistSlash */
     , (520200,  65,      0.7) /* ResistPierce */
     , (520200,  66,      0.8) /* ResistBludgeon */
     , (520200,  67,      0.5) /* ResistFire */
     , (520200,  68,      0.5) /* ResistCold */
     , (520200,  69,      0.6) /* ResistAcid */
     , (520200,  70,      0.6) /* ResistElectric */
     , (520200,  77,        1) /* PhysicsScriptIntensity */
     , (520200,  80,        3) /* AiUseMagicDelay */
     , (520200, 104,       35) /* ObviousRadarRange */
     , (520200, 125,        1) /* ResistHealthDrain */
     , (520200, 151,      0.5) /* IgnoreShield */
     , (520200, 166,        1) /* ResistNether */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520200,   1, 'Moloch') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520200,   1, 0x020007DD) /* Setup */
     , (520200,   2, 0x09000008) /* MotionTable */
     , (520200,   3, 0x20000007) /* SoundTable */
     , (520200,   4, 0x30000004) /* CombatTable */
     , (520200,   6, 0x04000F6C) /* PaletteBase */
     , (520200,   7, 0x10000209) /* ClothingBase */
     , (520200,   8, 0x06001035) /* Icon */
     , (520200,  22, 0x3400001A) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520200,   1, 320, 0, 0) /* Strength */
     , (520200,   2, 320, 0, 0) /* Endurance */
     , (520200,   3, 260, 0, 0) /* Quickness */
     , (520200,   4, 300, 0, 0) /* Coordination */
     , (520200,   5, 200, 0, 0) /* Focus */
     , (520200,   6, 220, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520200,   1, 119840, 0, 0, 120000) /* MaxHealth */
     , (520200,   3, 39680, 0, 0, 40000) /* MaxStamina */
     , (520200,   5, 39780, 0, 0, 40000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520200,  6, 0, 2, 0, 220, 0, 0) /* MeleeDefense        Trained */
     , (520200,  7, 0, 2, 0, 250, 0, 0) /* MissileDefense      Trained */
     , (520200, 15, 0, 2, 0, 320, 0, 0) /* MagicDefense        Trained */
     , (520200, 16, 0, 2, 0, 150, 0, 0) /* ManaConversion      Trained */
     , (520200, 31, 0, 2, 0, 280, 0, 0) /* CreatureEnchantment Trained */
     , (520200, 33, 0, 2, 0, 280, 0, 0) /* LifeMagic           Trained */
     , (520200, 34, 0, 2, 0, 300, 0, 0) /* WarMagic            Trained */
     , (520200, 44, 0, 2, 0, 250, 0, 0) /* HeavyWeapons        Trained */
     , (520200, 45, 0, 2, 0, 250, 0, 0) /* LightWeapons        Trained */
     , (520200, 46, 0, 2, 0, 250, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520200,  0,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (520200,  1,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (520200,  2,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (520200,  3,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (520200,  4,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (520200,  5,  4,  75,  0.5,  350, 350, 350, 385, 315, 315, 350, 350,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (520200,  6,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (520200,  7,  4,   0,    0,  350, 350, 350, 385, 315, 315, 350, 350,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (520200,  8,  4,  60,  0.5,  350, 350, 350, 385, 315, 315, 350, 350,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520200,  2132,  2.05)  /* Force Bolt VII */
     , (520200,  2146,  2.05)  /* Whirling Blade VII */
     , (520200,  2759,   2.1)  /* Blade Arc VII */
     , (520200,  2164,   2.2)  /* Blade Vulnerability Other VII */
     , (520200,  2074,   2.2)  /* Imperil Other VII */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520200, 414) /* PLAYER_DEATH_EVENT */;

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520200, 3 /* Death */, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 16 /* WorldBroadcast */, 0, 1, NULL, '%s has struck down Moloch! The Drudge Warlord crashes to the earth, and his howling horde scatters into the hills.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520200, 14 /* Taunt */, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Moloch howls and begins to spin, his blades a whirling storm of steel! GET BACK!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1784 /* Blade Ring */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520200, 9, 520202,  0, 0, 1, False) /* Create Moloch's Fang Gen (520202) for ContainTreasure */;

INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520200, -1, 7091, 1, 6, 6, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Ascendant Drudge (7091) (x6 up to max of 6) - Regenerate upon Destruction - Location to (re)Generate: Scatter */
     , (520200, -1, 24281, 1, 3, 3, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Drudge Mystic (24281) (x3 up to max of 3) - Regenerate upon Destruction - Location to (re)Generate: Scatter */;
