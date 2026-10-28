DELETE FROM `weenie` WHERE `class_Id` = 520220;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520220, 'worldbossdeath', 10, '2026-10-27 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520220,   1,         16) /* ItemType - Creature */
     , (520220,   2,         22) /* CreatureType - Shadow */
     , (520220,   3,         39) /* PaletteTemplate - Black */
     , (520220,   6,         -1) /* ItemsCapacity */
     , (520220,   7,         -1) /* ContainersCapacity */
     , (520220,  16,          1) /* ItemUseable - No */
     , (520220,  25,        150) /* Level */
     , (520220,  40,          1) /* CombatMode - NonCombat */
     , (520220,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520220,  81,          9) /* MaxGeneratedObjects */
     , (520220,  82,          9) /* InitGeneratedObjects */
     , (520220,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520220, 101,          1) /* AiAllowedCombatStyle - Unarmed */
     , (520220, 103,          3) /* GeneratorDestructionType - Destroy */
     , (520220, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (520220, 146,  400000000) /* XpOverride */
     , (520220, 386,         10) /* Overpower */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520220,   1, True) /* Stuck */
     , (520220,   6, False) /* AiUsesMana */
     , (520220,  11, False) /* IgnoreCollisions */
     , (520220,  12, True) /* ReportCollisions */
     , (520220,  13, False) /* Ethereal */
     , (520220,  29, True) /* NoCorpse */
     , (520220,  52, False) /* AiImmobile */
     , (520220,  65, True) /* IgnoreMagicResist */
     , (520220,  66, True) /* IgnoreMagicArmor */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520220,   1,        5) /* HeartbeatInterval */
     , (520220,   2,        0) /* HeartbeatTimestamp */
     , (520220,   3,       50) /* HealthRate */
     , (520220,   4,      100) /* StaminaRate */
     , (520220,   5,        2) /* ManaRate */
     , (520220,  13,      1.0) /* ArmorModVsSlash */
     , (520220,  14,      1.0) /* ArmorModVsPierce */
     , (520220,  15,      1.0) /* ArmorModVsBludgeon */
     , (520220,  16,      1.2) /* ArmorModVsCold */
     , (520220,  17,      0.8) /* ArmorModVsFire */
     , (520220,  18,      1.0) /* ArmorModVsAcid */
     , (520220,  19,      1.0) /* ArmorModVsElectric */
     , (520220,  31,       35) /* VisualAwarenessRange */
     , (520220,  34,        1) /* PowerupTime */
     , (520220,  36,        1) /* ChargeSpeed */
     , (520220,  39,      3.0) /* DefaultScale */
     , (520220,  41,      600) /* RegenerationInterval */
     , (520220,  43,       20) /* GeneratorRadius */
     , (520220,  55,      110) /* HomeRadius */
     , (520220,  64,      0.7) /* ResistSlash */
     , (520220,  65,      0.7) /* ResistPierce */
     , (520220,  66,      0.7) /* ResistBludgeon */
     , (520220,  67,      0.4) /* ResistFire */
     , (520220,  68,      0.8) /* ResistCold */
     , (520220,  69,      0.6) /* ResistAcid */
     , (520220,  70,      0.6) /* ResistElectric */
     , (520220,  77,        1) /* PhysicsScriptIntensity */
     , (520220,  80,        3) /* AiUseMagicDelay */
     , (520220, 104,       35) /* ObviousRadarRange */
     , (520220, 125,        1) /* ResistHealthDrain */
     , (520220, 151,      0.5) /* IgnoreShield */
     , (520220, 166,        1) /* ResistNether */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520220,   1, 'Death') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520220,   1, 0x0200071B) /* Setup */
     , (520220,   2, 0x09000093) /* MotionTable */
     , (520220,   3, 0x20000002) /* SoundTable */
     , (520220,   4, 0x30000028) /* CombatTable */
     , (520220,   6, 0x0400007E) /* PaletteBase */
     , (520220,   7, 0x1000019F) /* ClothingBase */
     , (520220,   8, 0x06001BBE) /* Icon */
     , (520220,   9, 0x05001055) /* EyesTexture */
     , (520220,  10, 0x0500106E) /* NoseTexture */
     , (520220,  11, 0x050010B1) /* MouthTexture */
     , (520220,  15, 0x04001FB5) /* HairPalette */
     , (520220,  16, 0x040004B1) /* EyesPalette */
     , (520220,  17, 0x040002B8) /* SkinPalette */
     , (520220,  22, 0x34000063) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520220,   1, 220, 0, 0) /* Strength */
     , (520220,   2, 260, 0, 0) /* Endurance */
     , (520220,   3, 300, 0, 0) /* Quickness */
     , (520220,   4, 300, 0, 0) /* Coordination */
     , (520220,   5, 340, 0, 0) /* Focus */
     , (520220,   6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520220,   1, 99870, 0, 0, 100000) /* MaxHealth */
     , (520220,   3, 39740, 0, 0, 40000) /* MaxStamina */
     , (520220,   5, 149640, 0, 0, 150000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520220,  6, 0, 2, 0, 200, 0, 0) /* MeleeDefense        Trained */
     , (520220,  7, 0, 2, 0, 260, 0, 0) /* MissileDefense      Trained */
     , (520220, 15, 0, 2, 0, 320, 0, 0) /* MagicDefense        Trained */
     , (520220, 16, 0, 2, 0, 200, 0, 0) /* ManaConversion      Trained */
     , (520220, 31, 0, 2, 0, 250, 0, 0) /* CreatureEnchantment Trained */
     , (520220, 33, 0, 2, 0, 250, 0, 0) /* LifeMagic           Trained */
     , (520220, 34, 0, 2, 0, 270, 0, 0) /* WarMagic            Trained */
     , (520220, 43, 0, 2, 0, 270, 0, 0) /* VoidMagic           Trained */
     , (520220, 44, 0, 2, 0, 230, 0, 0) /* HeavyWeapons        Trained */
     , (520220, 45, 0, 2, 0, 230, 0, 0) /* LightWeapons        Trained */
     , (520220, 46, 0, 2, 0, 230, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520220,  0,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (520220,  1,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 2, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (520220,  2,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 3,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0,    0, 0.17,    0) /* Abdomen */
     , (520220,  3,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 1, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (520220,  4,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 2,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0,    0,  0.3,    0) /* LowerArm */
     , (520220,  5,  8,  50,  0.5,  300, 300, 300, 300, 360, 240, 300, 300,    0, 2,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (520220,  6,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 3,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18,    0, 0.13, 0.18) /* UpperLeg */
     , (520220,  7,  4,   0,    0,  300, 300, 300, 300, 360, 240, 300, 300,    0, 3,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6,    0,    0,  0.6) /* LowerLeg */
     , (520220,  8,  8,  40,  0.5,  300, 300, 300, 300, 360, 240, 300, 300,    0, 3,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22,    0,    0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520220,  5355,   2.1)  /* Nether Bolt VII */
     , (520220,  5367,   2.1)  /* Nether Arc VII */
     , (520220,  5377,  2.15)  /* Curse of Festering VII */
     , (520220,  2328,   2.1)  /* Drain Health Other VII */
     , (520220,  2070,  2.05)  /* Harm Other VII */
     , (520220,  2178,  2.15)  /* Fester Other VII */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520220, 414) /* PLAYER_DEATH_EVENT */;

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520220, 3 /* Death */, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 16 /* WorldBroadcast */, 0, 1, NULL, '%s has struck down Death! The Umbris Shadow unravels into nothing, and for a moment the whole world seems a little brighter.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520220, 14 /* Taunt */, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Death draws the light out of the air around it. The shadows begin to scream! RUN!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5361 /* Nether Ring */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520220, 9, 520222,  0, 0, 1, False) /* Create Death's Shroud Gen (520222) for ContainTreasure */;

INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520220, -1, 23089, 1, 5, 5, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Shadow Phantom (23089) (x5 up to max of 5) - Regenerate upon Destruction - Location to (re)Generate: Scatter */
     , (520220, -1, 23090, 1, 4, 4, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Shadow Spectre (23090) (x4 up to max of 4) - Regenerate upon Destruction - Location to (re)Generate: Scatter */;
