/* JawnTide: mid-level world boss underling, the stock Burun Ruuk Shaman (26020) at level 250 strength (was 135) */

DELETE FROM `weenie` WHERE `class_Id` = 520294;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520294, 'midbosswarbandburunshaman', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520294, 1, 16)
     , (520294, 2, 75)
     , (520294, 3, 2)
     , (520294, 6, -1)
     , (520294, 7, -1)
     , (520294, 16, 1)
     , (520294, 25, 250)
     , (520294, 27, 0)
     , (520294, 40, 2)
     , (520294, 68, 13)
     , (520294, 93, 1032)
     , (520294, 101, 131)
     , (520294, 133, 2)
     , (520294, 140, 1)
     , (520294, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520294, 1, True)
     , (520294, 6, True)
     , (520294, 11, False)
     , (520294, 12, True)
     , (520294, 13, False)
     , (520294, 14, True)
     , (520294, 19, True)
     , (520294, 50, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520294, 1, 5)
     , (520294, 2, 0)
     , (520294, 3, 0.15)
     , (520294, 4, 5)
     , (520294, 5, 2)
     , (520294, 12, 0.5)
     , (520294, 13, 0.85)
     , (520294, 14, 1.05)
     , (520294, 15, 1)
     , (520294, 16, 1)
     , (520294, 17, 0.6)
     , (520294, 18, 1.25)
     , (520294, 19, 0.9)
     , (520294, 31, 18)
     , (520294, 34, 1.1)
     , (520294, 36, 1)
     , (520294, 39, 1.4)
     , (520294, 64, 0.75)
     , (520294, 65, 0.95)
     , (520294, 66, 0.6)
     , (520294, 67, 0.75)
     , (520294, 68, 0.9)
     , (520294, 69, 0.1)
     , (520294, 70, 0.4)
     , (520294, 71, 1)
     , (520294, 72, 1)
     , (520294, 73, 1)
     , (520294, 74, 1)
     , (520294, 75, 1)
     , (520294, 80, 3)
     , (520294, 104, 10)
     , (520294, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520294, 1, 'Warband Burun Shaman');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520294, 1, 0x02001036)
     , (520294, 2, 0x09000148)
     , (520294, 3, 0x200000AB)
     , (520294, 4, 0x3000003B)
     , (520294, 6, 0x040017A7)
     , (520294, 7, 0x10000535)
     , (520294, 8, 0x060030B1)
     , (520294, 22, 0x340000AA)
     , (520294, 32, 0x000001D7)
     , (520294, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520294, 1, 380, 0, 0) /* Strength */
     , (520294, 2, 380, 0, 0) /* Endurance */
     , (520294, 3, 360, 0, 0) /* Quickness */
     , (520294, 4, 380, 0, 0) /* Coordination */
     , (520294, 5, 360, 0, 0) /* Focus */
     , (520294, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520294, 1, 9810, 0, 0, 10000) /* MaxHealth */
     , (520294, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520294, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520294, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520294, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520294, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520294, 20, 0, 3, 0, 50, 0, 0) /* Deception */
     , (520294, 24, 0, 3, 0, 50, 0, 0) /* Run */
     , (520294, 31, 0, 3, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520294, 33, 0, 3, 0, 380, 0, 0) /* LifeMagic */
     , (520294, 34, 0, 3, 0, 400, 0, 0) /* WarMagic */
     , (520294, 44, 0, 3, 0, 450, 0, 0) /* HeavyWeapons */
     , (520294, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */
     , (520294, 46, 0, 3, 0, 450, 0, 0) /* FinesseWeapons */
     , (520294, 47, 0, 3, 0, 450, 0, 0) /* MissileWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520294, 0, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520294, 1, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520294, 2, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520294, 3, 4, 0, 0, 500, 426, 526, 500, 500, 300, 626, 450, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520294, 4, 4, 0, 0, 500, 426, 526, 500, 500, 300, 626, 450, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520294, 5, 4, 102, 0.75, 500, 425, 525, 500, 500, 300, 625, 451, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520294, 6, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520294, 7, 4, 0, 0, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520294, 8, 4, 110, 0.5, 500, 425, 525, 500, 500, 300, 625, 451, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520294, 4433, 2.07) /* Incantation of Acid Stream */
     , (520294, 4455, 2.07) /* Incantation of Shock Wave */
     , (520294, 4451, 2.07) /* Incantation of Lightning Bolt */
     , (520294, 4443, 2.07) /* Incantation of Force Bolt */
     , (520294, 4457, 2.07) /* Incantation of Whirling Blade */
     , (520294, 4489, 2.02) /* Incantation of Fester Other */
     , (520294, 4473, 2.02) /* Incantation of Acid Vulnerability Other */
     , (520294, 4477, 2.02) /* Incantation of Bludgeoning Vulnerability Other */
     , (520294, 4483, 2.02) /* Incantation of Lightning Vulnerability Other */
     , (520294, 4475, 2.02) /* Incantation of Blade Vulnerability Other */
     , (520294, 4485, 2.02) /* Incantation of Piercing Vulnerability Other */
     , (520294, 4311, 2.08) /* Incantation of Heal Self */;
