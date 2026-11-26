/* JawnTide: mid-level world boss underling, the stock Platinum Golem (11530) at level 250 strength (was 300) */

DELETE FROM `weenie` WHERE `class_Id` = 520278;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520278, 'midbossdiamondplatinumgolem', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520278, 1, 16)
     , (520278, 2, 13)
     , (520278, 3, 20)
     , (520278, 6, -1)
     , (520278, 7, -1)
     , (520278, 16, 1)
     , (520278, 25, 250)
     , (520278, 27, 0)
     , (520278, 40, 2)
     , (520278, 68, 9)
     , (520278, 93, 1032)
     , (520278, 133, 2)
     , (520278, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520278, 1, True)
     , (520278, 6, True)
     , (520278, 11, False)
     , (520278, 12, True)
     , (520278, 13, False);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520278, 1, 5)
     , (520278, 2, 0)
     , (520278, 3, 8)
     , (520278, 4, 0.5)
     , (520278, 5, 2)
     , (520278, 6, 0.1)
     , (520278, 7, 0.25)
     , (520278, 8, 0.3)
     , (520278, 12, 0.5)
     , (520278, 13, 1)
     , (520278, 14, 0.7)
     , (520278, 15, 1.1)
     , (520278, 16, 1)
     , (520278, 17, 0.7)
     , (520278, 18, 0.7)
     , (520278, 19, 1)
     , (520278, 31, 17)
     , (520278, 34, 2.3)
     , (520278, 64, 0.65)
     , (520278, 65, 0.65)
     , (520278, 66, 0.2)
     , (520278, 67, 0.8)
     , (520278, 68, 0.4)
     , (520278, 69, 0.7)
     , (520278, 70, 0.1)
     , (520278, 71, 1)
     , (520278, 72, 0)
     , (520278, 73, 1)
     , (520278, 74, 0)
     , (520278, 75, 1)
     , (520278, 80, 3)
     , (520278, 104, 10)
     , (520278, 122, 2)
     , (520278, 125, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520278, 1, 'Diamondbound Platinum Golem');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520278, 1, 0x020007CA)
     , (520278, 2, 0x09000081)
     , (520278, 3, 0x20000015)
     , (520278, 4, 0x30000008)
     , (520278, 6, 0x04000F47)
     , (520278, 7, 0x1000020D)
     , (520278, 8, 0x06001224)
     , (520278, 22, 0x3400005D)
     , (520278, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520278, 1, 380, 0, 0) /* Strength */
     , (520278, 2, 380, 0, 0) /* Endurance */
     , (520278, 3, 360, 0, 0) /* Quickness */
     , (520278, 4, 380, 0, 0) /* Coordination */
     , (520278, 5, 360, 0, 0) /* Focus */
     , (520278, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520278, 1, 11810, 0, 0, 12000) /* MaxHealth */
     , (520278, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520278, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520278, 6, 0, 3, 0, 380, 0, 750.4102) /* MeleeDefense */
     , (520278, 7, 0, 3, 0, 360, 0, 750.4102) /* MissileDefense */
     , (520278, 13, 0, 3, 0, 450, 0, 750.4102) /* UnarmedCombat */
     , (520278, 15, 0, 3, 0, 360, 0, 750.4102) /* MagicDefense */
     , (520278, 20, 0, 2, 0, 100, 0, 750.4102) /* Deception */
     , (520278, 24, 0, 2, 0, 40, 0, 750.4102) /* Run */
     , (520278, 31, 0, 2, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520278, 33, 0, 2, 0, 380, 0, 0) /* LifeMagic */
     , (520278, 34, 0, 3, 0, 400, 0, 750.4102) /* WarMagic */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520278, 0, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520278, 1, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520278, 2, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520278, 3, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520278, 4, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520278, 5, 4, 110, 0.75, 500, 500, 350, 550, 500, 350, 350, 500, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520278, 6, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520278, 7, 4, 0, 0, 500, 500, 350, 550, 500, 350, 350, 500, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520278, 8, 4, 110, 0.75, 500, 500, 350, 550, 500, 350, 350, 500, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520278, 2122, 2.02) /* Disintegration */
     , (520278, 2128, 2.02) /* Ilservian's Flame */
     , (520278, 2136, 2.02) /* Icy Torment */
     , (520278, 2140, 2.02) /* Alset's Coil */;
