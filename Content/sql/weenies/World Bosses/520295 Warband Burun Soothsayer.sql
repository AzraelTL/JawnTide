/* JawnTide: mid-level world boss underling, the stock Burun Ruuk Soothsayer (26021) at level 250 strength (was 135) */

DELETE FROM `weenie` WHERE `class_Id` = 520295;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520295, 'midbosswarbandburunsoothsayer', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520295, 1, 16)
     , (520295, 2, 75)
     , (520295, 3, 39)
     , (520295, 6, -1)
     , (520295, 7, -1)
     , (520295, 16, 1)
     , (520295, 25, 250)
     , (520295, 27, 0)
     , (520295, 40, 2)
     , (520295, 68, 13)
     , (520295, 93, 1032)
     , (520295, 101, 131)
     , (520295, 133, 2)
     , (520295, 140, 1)
     , (520295, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520295, 1, True)
     , (520295, 6, True)
     , (520295, 11, False)
     , (520295, 12, True)
     , (520295, 13, False)
     , (520295, 14, True)
     , (520295, 19, True)
     , (520295, 50, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520295, 1, 5)
     , (520295, 2, 0)
     , (520295, 3, 0.15)
     , (520295, 4, 5)
     , (520295, 5, 2)
     , (520295, 12, 0.5)
     , (520295, 13, 0.85)
     , (520295, 14, 1.05)
     , (520295, 15, 1)
     , (520295, 16, 1)
     , (520295, 17, 0.6)
     , (520295, 18, 1.25)
     , (520295, 19, 0.9)
     , (520295, 31, 18)
     , (520295, 34, 1.1)
     , (520295, 36, 1)
     , (520295, 39, 1.3)
     , (520295, 64, 0.75)
     , (520295, 65, 0.95)
     , (520295, 66, 0.6)
     , (520295, 67, 0.75)
     , (520295, 68, 0.9)
     , (520295, 69, 0.1)
     , (520295, 70, 0.4)
     , (520295, 71, 1)
     , (520295, 72, 1)
     , (520295, 73, 1)
     , (520295, 74, 1)
     , (520295, 75, 1)
     , (520295, 80, 3)
     , (520295, 104, 10)
     , (520295, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520295, 1, 'Warband Burun Soothsayer');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520295, 1, 0x02001036)
     , (520295, 2, 0x09000148)
     , (520295, 3, 0x200000AB)
     , (520295, 4, 0x3000003B)
     , (520295, 6, 0x040017A7)
     , (520295, 7, 0x10000535)
     , (520295, 8, 0x060030B1)
     , (520295, 22, 0x340000AA)
     , (520295, 32, 0x000001D3)
     , (520295, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520295, 1, 380, 0, 0) /* Strength */
     , (520295, 2, 380, 0, 0) /* Endurance */
     , (520295, 3, 360, 0, 0) /* Quickness */
     , (520295, 4, 380, 0, 0) /* Coordination */
     , (520295, 5, 360, 0, 0) /* Focus */
     , (520295, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520295, 1, 9810, 0, 0, 10000) /* MaxHealth */
     , (520295, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520295, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520295, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520295, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520295, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520295, 20, 0, 3, 0, 50, 0, 0) /* Deception */
     , (520295, 24, 0, 3, 0, 50, 0, 0) /* Run */
     , (520295, 31, 0, 3, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520295, 33, 0, 3, 0, 380, 0, 0) /* LifeMagic */
     , (520295, 34, 0, 3, 0, 400, 0, 0) /* WarMagic */
     , (520295, 44, 0, 3, 0, 450, 0, 0) /* HeavyWeapons */
     , (520295, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */
     , (520295, 46, 0, 3, 0, 450, 0, 0) /* FinesseWeapons */
     , (520295, 47, 0, 3, 0, 450, 0, 0) /* MissileWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520295, 0, 4, 0, 0, 500, 426, 526, 500, 500, 300, 626, 450, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520295, 1, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 450, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520295, 2, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 450, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520295, 3, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520295, 4, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520295, 5, 4, 100, 0.75, 500, 425, 525, 500, 500, 300, 625, 450, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520295, 6, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520295, 7, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520295, 8, 4, 110, 0.75, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520295, 4433, 2.07) /* Incantation of Acid Stream */
     , (520295, 4455, 2.07) /* Incantation of Shock Wave */
     , (520295, 4451, 2.07) /* Incantation of Lightning Bolt */
     , (520295, 4443, 2.07) /* Incantation of Force Bolt */
     , (520295, 4457, 2.07) /* Incantation of Whirling Blade */
     , (520295, 4489, 2.02) /* Incantation of Fester Other */
     , (520295, 4473, 2.02) /* Incantation of Acid Vulnerability Other */
     , (520295, 4477, 2.02) /* Incantation of Bludgeoning Vulnerability Other */
     , (520295, 4483, 2.02) /* Incantation of Lightning Vulnerability Other */
     , (520295, 4475, 2.02) /* Incantation of Blade Vulnerability Other */
     , (520295, 4485, 2.02) /* Incantation of Piercing Vulnerability Other */
     , (520295, 4311, 2.08) /* Incantation of Heal Self */;
