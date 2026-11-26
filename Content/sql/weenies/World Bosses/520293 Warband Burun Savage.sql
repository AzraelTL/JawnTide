/* JawnTide: mid-level world boss underling, the stock Burun Ruuk Savage (26017) at level 250 strength (was 135) */

DELETE FROM `weenie` WHERE `class_Id` = 520293;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520293, 'midbosswarbandburunsavage', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520293, 1, 16)
     , (520293, 2, 75)
     , (520293, 3, 70)
     , (520293, 6, -1)
     , (520293, 7, -1)
     , (520293, 16, 1)
     , (520293, 25, 250)
     , (520293, 27, 0)
     , (520293, 40, 2)
     , (520293, 68, 13)
     , (520293, 93, 1032)
     , (520293, 101, 131)
     , (520293, 133, 2)
     , (520293, 140, 1)
     , (520293, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520293, 1, True)
     , (520293, 11, False)
     , (520293, 12, True)
     , (520293, 13, False)
     , (520293, 14, True)
     , (520293, 19, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520293, 1, 5)
     , (520293, 2, 0)
     , (520293, 3, 0.15)
     , (520293, 4, 5)
     , (520293, 5, 2)
     , (520293, 12, 0.5)
     , (520293, 13, 0.95)
     , (520293, 14, 1.05)
     , (520293, 15, 1)
     , (520293, 16, 1)
     , (520293, 17, 0.75)
     , (520293, 18, 1.25)
     , (520293, 19, 0.95)
     , (520293, 31, 18)
     , (520293, 34, 1.1)
     , (520293, 36, 1)
     , (520293, 39, 1.4)
     , (520293, 64, 0.65)
     , (520293, 65, 0.8)
     , (520293, 66, 0.5)
     , (520293, 67, 0.65)
     , (520293, 68, 0.8)
     , (520293, 69, 0.1)
     , (520293, 70, 0.4)
     , (520293, 71, 1)
     , (520293, 72, 1)
     , (520293, 73, 1)
     , (520293, 74, 1)
     , (520293, 75, 1)
     , (520293, 104, 10)
     , (520293, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520293, 1, 'Warband Burun Savage');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520293, 1, 0x02001036)
     , (520293, 2, 0x09000148)
     , (520293, 3, 0x200000AB)
     , (520293, 4, 0x3000003B)
     , (520293, 6, 0x040017A7)
     , (520293, 7, 0x10000535)
     , (520293, 8, 0x060030B1)
     , (520293, 22, 0x340000AA)
     , (520293, 32, 0x000001D7)
     , (520293, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520293, 1, 380, 0, 0) /* Strength */
     , (520293, 2, 380, 0, 0) /* Endurance */
     , (520293, 3, 360, 0, 0) /* Quickness */
     , (520293, 4, 380, 0, 0) /* Coordination */
     , (520293, 5, 360, 0, 0) /* Focus */
     , (520293, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520293, 1, 9810, 0, 0, 10000) /* MaxHealth */
     , (520293, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520293, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520293, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520293, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520293, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520293, 20, 0, 3, 0, 50, 0, 0) /* Deception */
     , (520293, 24, 0, 3, 0, 50, 0, 0) /* Run */
     , (520293, 44, 0, 3, 0, 450, 0, 0) /* HeavyWeapons */
     , (520293, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */
     , (520293, 46, 0, 3, 0, 450, 0, 0) /* FinesseWeapons */
     , (520293, 47, 0, 3, 0, 450, 0, 0) /* MissileWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520293, 0, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520293, 1, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520293, 2, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520293, 3, 4, 0, 0, 500, 476, 526, 500, 500, 376, 626, 476, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520293, 4, 4, 0, 0, 500, 476, 526, 500, 500, 376, 626, 476, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520293, 5, 4, 101, 0.5, 500, 475, 525, 500, 500, 375, 625, 475, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520293, 6, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520293, 7, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520293, 8, 4, 110, 0.5, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;
