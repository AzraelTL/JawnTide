/* JawnTide: Xa'thrix, K'nath Brood Empress, a mid-level town world boss tuned for level 250. Look: the stock K'nath Mother (38012) */

DELETE FROM `weenie` WHERE `class_Id` = 520250;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520250, 'worldbossxathrix', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520250, 1, 16)
     , (520250, 2, 94) /* CreatureType - Energy (JawnTide: a type no slayer weapon targets) */
     , (520250, 6, -1)
     , (520250, 7, -1)
     , (520250, 16, 1)
     , (520250, 25, 250) /* Level */
     , (520250, 40, 1)
     , (520250, 68, 13)
     , (520250, 81, 9) /* MaxGeneratedObjects */
     , (520250, 82, 9) /* InitGeneratedObjects */
     , (520250, 93, 1032)
     , (520250, 101, 1)
     , (520250, 103, 3)
     , (520250, 133, 2)
     , (520250, 146, 400000000) /* XpOverride */
     , (520250, 386, 10) /* Overpower */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520250, 1, 1)
     , (520250, 6, 0)
     , (520250, 11, 0)
     , (520250, 12, 1)
     , (520250, 13, 0)
     , (520250, 29, 1)
     , (520250, 52, 0)
     , (520250, 65, 1)
     , (520250, 66, 1);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520250, 1, 5)
     , (520250, 2, 0)
     , (520250, 3, 50)
     , (520250, 4, 100)
     , (520250, 5, 2)
     , (520250, 13, 1)
     , (520250, 14, 0.95)
     , (520250, 15, 1.05)
     , (520250, 16, 1)
     , (520250, 17, 0.95)
     , (520250, 18, 0.85)
     , (520250, 19, 1.2)
     , (520250, 31, 35)
     , (520250, 34, 1)
     , (520250, 36, 1)
     , (520250, 39, 4.5)
     , (520250, 41, 600)
     , (520250, 43, 20)
     , (520250, 55, 110)
     , (520250, 64, 0.55)
     , (520250, 65, 0.55)
     , (520250, 66, 0.6)
     , (520250, 67, 0.5)
     , (520250, 68, 0.5)
     , (520250, 69, 0.85)
     , (520250, 70, 0.3)
     , (520250, 77, 1)
     , (520250, 80, 3)
     , (520250, 104, 35)
     , (520250, 125, 1)
     , (520250, 151, 0.5)
     , (520250, 166, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520250, 1, 'Xa''thrix')
     , (520250, 5, 'K''nath Brood Empress') /* Template - shown under the name when assessed */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520250, 1, 0x02001834)
     , (520250, 2, 0x09000032)
     , (520250, 3, 0x20000048)
     , (520250, 4, 0x3000001A)
     , (520250, 8, 0x0600141B)
     , (520250, 22, 0x3400001D);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520250, 1, 520, 0, 0) /* Strength */
     , (520250, 2, 520, 0, 0) /* Endurance */
     , (520250, 3, 440, 0, 0) /* Quickness */
     , (520250, 4, 500, 0, 0) /* Coordination */
     , (520250, 5, 460, 0, 0) /* Focus */
     , (520250, 6, 460, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520250, 1, 299740, 0, 0, 300000) /* MaxHealth */
     , (520250, 3, 59480, 0, 0, 60000) /* MaxStamina */
     , (520250, 5, 59540, 0, 0, 60000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520250, 6, 0, 2, 0, 220, 0, 0) /* MeleeDefense */
     , (520250, 7, 0, 2, 0, 260, 0, 0) /* MissileDefense */
     , (520250, 15, 0, 2, 0, 300, 0, 0) /* MagicDefense */
     , (520250, 16, 0, 2, 0, 200, 0, 0) /* ManaConversion */
     , (520250, 31, 0, 2, 0, 420, 0, 0) /* CreatureEnchantment */
     , (520250, 33, 0, 2, 0, 420, 0, 0) /* LifeMagic */
     , (520250, 34, 0, 2, 0, 440, 0, 0) /* WarMagic */
     , (520250, 44, 0, 2, 0, 480, 0, 0) /* HeavyWeapons */
     , (520250, 45, 0, 2, 0, 480, 0, 0) /* LightWeapons */
     , (520250, 46, 0, 2, 0, 480, 0, 0) /* FinesseWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520250, 0, 64, 110, 0.5, 550, 550, 522, 578, 550, 522, 468, 660, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520250, 2, 4, 0, 0, 550, 550, 522, 578, 550, 522, 468, 660, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Abdomen */
     , (520250, 6, 4, 0, 0, 550, 550, 522, 578, 550, 522, 468, 660, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* UpperLeg */
     , (520250, 16, 4, 0, 0, 550, 550, 522, 578, 550, 522, 468, 660, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520250, 4451, 2.05) /* Incantation of Lightning Bolt */
     , (520250, 4426, 2.1) /* Incantation of Lightning Arc */
     , (520250, 4452, 2.1) /* Incantation of Lightning Streak */
     , (520250, 4483, 2.2) /* Incantation of Lightning Vulnerability Other */
     , (520250, 4312, 2.2) /* Incantation of Imperil Other */;

INSERT INTO `weenie_properties_event_filter` (`object_Id`, `event`)
VALUES (520250, 414);

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (520250, 9, 520252, 0, 0, 1, False);

INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520250, -1, 520253, 1, 3, 3, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
     , (520250, -1, 520254, 1, 3, 3, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
     , (520250, -1, 520255, 1, 3, 3, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520250, 3 /* Death */, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 16 /* WorldBroadcast */, 0, 1, NULL, '%s has slain Xa''thrix! The Brood Empress shrieks one last time and the crackling storm around her dies away.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* Specials: Taunt emotes run after each of the boss's attacks. Probabilities are cumulative thresholds (ACE picks the lowest one above a random roll), so each special's own chance per attack is in its comment. */
/* Call the Brood (4%) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520250, 14 /* Taunt */, 0.04, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Xa''thrix lets out a piercing shriek and her brood swarms to her side!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 72 /* Generate */, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* Lightning Barrage (3%) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520250, 14 /* Taunt */, 0.07, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Xa''thrix''s carapace crackles as the sky splits open! Lightning rains down! TAKE COVER!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1837 /* Lightning Barrage */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* Storm Ring (5%) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (520250, 14 /* Taunt */, 0.12, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id, 0, 17 /* LocalBroadcast */, 0, 1, NULL, 'Static arcs across Xa''thrix''s shell, building to a deafening hum! GET BACK!', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 1, 19 /* CastSpellInstant */, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1788 /* Eye of the Storm */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
