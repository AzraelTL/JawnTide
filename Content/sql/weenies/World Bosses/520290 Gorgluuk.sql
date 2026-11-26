/* JawnTide: Gorgluuk, Burun Warking, a mid-level town world boss tuned for level 250. Look: the stock Morgluuk (27661) */

DELETE FROM `weenie` WHERE `class_Id` = 520290;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520290, 'worldbossgorgluuk', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520290, 1, 16)
     , (520290, 2, 93) /* CreatureType - Harvest (JawnTide: a type no slayer weapon targets) */
     , (520290, 3, 70)
     , (520290, 6, -1)
     , (520290, 7, -1)
     , (520290, 16, 1)
     , (520290, 25, 250) /* Level */
     , (520290, 40, 1)
     , (520290, 68, 13)
     , (520290, 81, 9) /* MaxGeneratedObjects */
     , (520290, 82, 9) /* InitGeneratedObjects */
     , (520290, 93, 1032)
     , (520290, 101, 131)
     , (520290, 103, 3)
     , (520290, 133, 2)
     , (520290, 140, 1)
     , (520290, 146, 400000000) /* XpOverride */
     , (520290, 386, 10) /* Overpower */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520290, 1, 1)
     , (520290, 6, 0)
     , (520290, 11, 0)
     , (520290, 12, 1)
     , (520290, 13, 0)
     , (520290, 29, 1)
     , (520290, 52, 0)
     , (520290, 65, 1)
     , (520290, 66, 1);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520290, 1, 5)
     , (520290, 2, 0)
     , (520290, 3, 50)
     , (520290, 4, 100)
     , (520290, 5, 2)
     , (520290, 13, 1)
     , (520290, 14, 1)
     , (520290, 15, 1)
     , (520290, 16, 1.05)
     , (520290, 17, 0.85)
     , (520290, 18, 1.2)
     , (520290, 19, 1)
     , (520290, 31, 35)
     , (520290, 34, 1)
     , (520290, 36, 1)
     , (520290, 39, 3)
     , (520290, 41, 600)
     , (520290, 43, 20)
     , (520290, 55, 110)
     , (520290, 64, 0.6)
     , (520290, 65, 0.6)
     , (520290, 66, 0.6)
     , (520290, 67, 0.85)
     , (520290, 68, 0.55)
     , (520290, 69, 0.3)
     , (520290, 70, 0.55)
     , (520290, 77, 1)
     , (520290, 80, 3)
     , (520290, 104, 35)
     , (520290, 125, 1)
     , (520290, 151, 0.5)
     , (520290, 166, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520290, 1, 'Gorgluuk')
     , (520290, 5, 'Burun Warking') /* Template - shown under the name when assessed */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520290, 1, 0x020010DB)
     , (520290, 2, 0x09000148)
     , (520290, 3, 0x200000AB)
     , (520290, 4, 0x3000003B)
     , (520290, 6, 0x040017A7)
     , (520290, 7, 0x10000535)
     , (520290, 8, 0x060030B1)
     , (520290, 22, 0x34000020);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520290, 1, 520, 0, 0) /* Strength */
     , (520290, 2, 520, 0, 0) /* Endurance */
     , (520290, 3, 440, 0, 0) /* Quickness */
     , (520290, 4, 500, 0, 0) /* Coordination */
     , (520290, 5, 460, 0, 0) /* Focus */
     , (520290, 6, 460, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520290, 1, 349740, 0, 0, 350000) /* MaxHealth */
     , (520290, 3, 59480, 0, 0, 60000) /* MaxStamina */
     , (520290, 5, 59540, 0, 0, 60000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520290, 6, 0, 2, 0, 220, 0, 0) /* MeleeDefense */
     , (520290, 7, 0, 2, 0, 260, 0, 0) /* MissileDefense */
     , (520290, 15, 0, 2, 0, 300, 0, 0) /* MagicDefense */
     , (520290, 16, 0, 2, 0, 200, 0, 0) /* ManaConversion */
     , (520290, 31, 0, 2, 0, 420, 0, 0) /* CreatureEnchantment */
     , (520290, 33, 0, 2, 0, 420, 0, 0) /* LifeMagic */
     , (520290, 34, 0, 2, 0, 440, 0, 0) /* WarMagic */
     , (520290, 44, 0, 2, 0, 480, 0, 0) /* HeavyWeapons */
     , (520290, 45, 0, 2, 0, 480, 0, 0) /* LightWeapons */
     , (520290, 46, 0, 2, 0, 480, 0, 0) /* FinesseWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520290, 0, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520290, 1, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520290, 2, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520290, 3, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520290, 4, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520290, 5, 32, 110, 0.5, 550, 550, 550, 550, 578, 468, 660, 550, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520290, 6, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520290, 7, 4, 0, 0, 550, 550, 550, 550, 578, 468, 660, 550, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520290, 8, 32, 95, 0.5, 550, 550, 550, 550, 578, 468, 660, 550, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520290, 4433, 2.05) /* Incantation of Acid Stream */
     , (520290, 4421, 2.1) /* Incantation of Acid Arc */
     , (520290, 4432, 2.1) /* Incantation of Acid Streak */
     , (520290, 4473, 2.2) /* Incantation of Acid Vulnerability Other */
     , (520290, 4489, 2.2) /* Incantation of Fester Other */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520290, 414);

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520290, 9, 520292, 0, 0, 1, False);

INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520290, -1, 520293, 1, 3, 3, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
     , (520290, -1, 520294, 1, 2, 2, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
     , (520290, -1, 520295, 1, 2, 2, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
     , (520290, -1, 520296, 1, 2, 2, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520290, 3 /* Death */, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 16 /* WorldBroadcast */, 0, 1, NULL, '%s has brought down Gorgluuk! The Burun Warking topples into the mud, and his warband scatters into the marshes.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* Specials: Taunt emotes run after each of the boss's attacks. Probabilities are cumulative thresholds (ACE picks the lowest one above a random roll), so each special's own chance per attack is in its comment. */
/* Call the Warband (4%) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520290, 14 /* Taunt */, 0.04, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Gorgluuk pounds his chest and bellows for his warband! The buruns answer!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 72 /* Generate */, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* Torrential Acid (3%) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520290, 14 /* Taunt */, 0.07, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Gorgluuk howls to the sky and the clouds turn green! Acid pours down! TAKE COVER!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1832 /* Torrential Acid */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* Acid Ring (5%) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520290, 14 /* Taunt */, 0.12, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Gorgluuk''s hide bubbles and hisses with caustic venom! GET BACK!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3805 /* Acid Ring */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
