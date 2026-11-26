/* JawnTide: mid-level world boss underling, the stock K'nath Y'bot (38016) at level 250 strength (was 220) */

DELETE FROM `weenie` WHERE `class_Id` = 520255;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520255, 'midbossbroodknathybot', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520255, 1, 16)
     , (520255, 2, 21)
     , (520255, 6, -1)
     , (520255, 7, -1)
     , (520255, 16, 1)
     , (520255, 25, 250)
     , (520255, 27, 0)
     , (520255, 40, 1)
     , (520255, 68, 9)
     , (520255, 93, 1032)
     , (520255, 133, 2)
     , (520255, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520255, 1, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520255, 1, 5)
     , (520255, 2, 0)
     , (520255, 3, 0.067)
     , (520255, 4, 0.5)
     , (520255, 5, 2)
     , (520255, 13, 0.85)
     , (520255, 14, 1)
     , (520255, 15, 1)
     , (520255, 16, 1)
     , (520255, 17, 1)
     , (520255, 18, 1)
     , (520255, 19, 1)
     , (520255, 31, 18)
     , (520255, 34, 1.8)
     , (520255, 36, 1)
     , (520255, 39, 1.8)
     , (520255, 64, 0.7)
     , (520255, 65, 0.4)
     , (520255, 66, 0.4)
     , (520255, 67, 0.4)
     , (520255, 68, 0.4)
     , (520255, 69, 0.4)
     , (520255, 70, 0.4)
     , (520255, 76, 0.5)
     , (520255, 80, 3)
     , (520255, 104, 10)
     , (520255, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520255, 1, 'Brood K''nath Y''bot');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520255, 1, 0x02001837)
     , (520255, 2, 0x09000032)
     , (520255, 3, 0x20000048)
     , (520255, 4, 0x3000001A)
     , (520255, 8, 0x0600141B)
     , (520255, 22, 0x3400001D)
     , (520255, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520255, 1, 380, 0, 0) /* Strength */
     , (520255, 2, 380, 0, 0) /* Endurance */
     , (520255, 3, 360, 0, 0) /* Quickness */
     , (520255, 4, 380, 0, 0) /* Coordination */
     , (520255, 5, 360, 0, 0) /* Focus */
     , (520255, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520255, 1, 9810, 0, 0, 10000) /* MaxHealth */
     , (520255, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520255, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520255, 6, 0, 2, 0, 380, 0, 0) /* MeleeDefense */
     , (520255, 7, 0, 2, 0, 360, 0, 0) /* MissileDefense */
     , (520255, 15, 0, 2, 0, 360, 0, 0) /* MagicDefense */
     , (520255, 16, 0, 2, 0, 250, 0, 0) /* ManaConversion */
     , (520255, 31, 0, 2, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520255, 33, 0, 2, 0, 380, 0, 0) /* LifeMagic */
     , (520255, 34, 0, 2, 0, 400, 0, 0) /* WarMagic */
     , (520255, 41, 0, 2, 0, 450, 0, 0) /* TwoHandedCombat */
     , (520255, 43, 0, 2, 0, 400, 0, 0) /* VoidMagic */
     , (520255, 44, 0, 2, 0, 450, 0, 0) /* HeavyWeapons */
     , (520255, 45, 0, 2, 0, 450, 0, 0) /* LightWeapons */
     , (520255, 46, 0, 2, 0, 450, 0, 0) /* FinesseWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520255, 0, 4, 110, 0.3, 500, 426, 500, 500, 500, 500, 500, 500, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520255, 2, 4, 0, 0, 500, 426, 500, 500, 500, 500, 500, 500, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Abdomen */
     , (520255, 6, 4, 0, 0, 500, 426, 500, 500, 500, 500, 500, 500, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* UpperLeg */
     , (520255, 16, 4, 0, 0, 500, 426, 500, 500, 500, 500, 500, 500, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520255, 4312, 2.15) /* Incantation of Imperil Other */
     , (520255, 4422, 2.2) /* Incantation of Blade Arc */
     , (520255, 4458, 2.5) /* Incantation of Whirling Blade Streak */
     , (520255, 4475, 2.08) /* Incantation of Blade Vulnerability Other */;
