/* JawnTide: mid-level world boss underling, the stock Burun Ruuk Fiend (26014) at level 250 strength (was 115) */

DELETE FROM `weenie` WHERE `class_Id` = 520296;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520296, 'midbosswarbandburunfiend', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520296, 1, 16)
     , (520296, 2, 75)
     , (520296, 3, 67)
     , (520296, 6, -1)
     , (520296, 7, -1)
     , (520296, 16, 1)
     , (520296, 25, 250)
     , (520296, 27, 0)
     , (520296, 40, 2)
     , (520296, 68, 13)
     , (520296, 93, 1032)
     , (520296, 101, 131)
     , (520296, 133, 2)
     , (520296, 140, 1)
     , (520296, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520296, 1, True)
     , (520296, 11, False)
     , (520296, 12, True)
     , (520296, 13, False)
     , (520296, 14, True)
     , (520296, 19, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520296, 1, 5)
     , (520296, 2, 0)
     , (520296, 3, 0.15)
     , (520296, 4, 5)
     , (520296, 5, 2)
     , (520296, 12, 0.5)
     , (520296, 13, 0.95)
     , (520296, 14, 1.05)
     , (520296, 15, 1)
     , (520296, 16, 1)
     , (520296, 17, 0.75)
     , (520296, 18, 1.25)
     , (520296, 19, 0.95)
     , (520296, 31, 18)
     , (520296, 34, 1.1)
     , (520296, 36, 1)
     , (520296, 39, 1.3)
     , (520296, 64, 0.65)
     , (520296, 65, 0.8)
     , (520296, 66, 0.5)
     , (520296, 67, 0.65)
     , (520296, 68, 0.8)
     , (520296, 69, 0.1)
     , (520296, 70, 0.4)
     , (520296, 71, 1)
     , (520296, 72, 1)
     , (520296, 73, 1)
     , (520296, 74, 1)
     , (520296, 75, 1)
     , (520296, 104, 10)
     , (520296, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520296, 1, 'Warband Burun Fiend');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520296, 1, 0x02001036)
     , (520296, 2, 0x09000148)
     , (520296, 3, 0x200000AB)
     , (520296, 4, 0x3000003B)
     , (520296, 6, 0x040017A7)
     , (520296, 7, 0x10000535)
     , (520296, 8, 0x060030B1)
     , (520296, 22, 0x340000AA)
     , (520296, 32, 0x000001D3)
     , (520296, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520296, 1, 380, 0, 0) /* Strength */
     , (520296, 2, 380, 0, 0) /* Endurance */
     , (520296, 3, 360, 0, 0) /* Quickness */
     , (520296, 4, 380, 0, 0) /* Coordination */
     , (520296, 5, 360, 0, 0) /* Focus */
     , (520296, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520296, 1, 9810, 0, 0, 10000) /* MaxHealth */
     , (520296, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520296, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520296, 4, 0, 3, 0, 158, 0, 0) /* 4 */
     , (520296, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520296, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520296, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520296, 20, 0, 3, 0, 50, 0, 0) /* Deception */
     , (520296, 24, 0, 3, 0, 50, 0, 0) /* Run */
     , (520296, 44, 0, 3, 0, 450, 0, 0) /* HeavyWeapons */
     , (520296, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */
     , (520296, 47, 0, 3, 0, 450, 0, 0) /* MissileWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520296, 0, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520296, 1, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520296, 2, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520296, 3, 4, 0, 0, 500, 476, 526, 500, 500, 376, 626, 476, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520296, 4, 4, 0, 0, 500, 476, 526, 500, 500, 376, 626, 476, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520296, 5, 4, 104, 0.75, 500, 475, 525, 500, 500, 375, 625, 475, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520296, 6, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520296, 7, 4, 0, 0, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520296, 8, 4, 110, 0.75, 500, 475, 525, 500, 500, 375, 625, 475, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;
