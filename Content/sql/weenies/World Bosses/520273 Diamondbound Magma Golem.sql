/* JawnTide: mid-level world boss underling, the stock Ancient Magma Golem (40267) at level 250 strength (was 220) */

DELETE FROM `weenie` WHERE `class_Id` = 520273;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520273, 'midbossdiamondmagmagolem', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520273, 1, 16)
     , (520273, 2, 13)
     , (520273, 6, -1)
     , (520273, 7, -1)
     , (520273, 16, 1)
     , (520273, 25, 250)
     , (520273, 40, 2)
     , (520273, 68, 9)
     , (520273, 93, 1032)
     , (520273, 133, 2)
     , (520273, 146, 2000000)
     , (520273, 307, 2);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520273, 1, True)
     , (520273, 6, True)
     , (520273, 11, False)
     , (520273, 12, True)
     , (520273, 13, False)
     , (520273, 14, True)
     , (520273, 19, True)
     , (520273, 50, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520273, 1, 5)
     , (520273, 2, 0)
     , (520273, 3, 0.5)
     , (520273, 4, 0.5)
     , (520273, 5, 2)
     , (520273, 6, 0.1)
     , (520273, 7, 0.25)
     , (520273, 8, 0.3)
     , (520273, 13, 0.44)
     , (520273, 14, 0.58)
     , (520273, 15, 0.86)
     , (520273, 16, 0.33)
     , (520273, 17, 0.33)
     , (520273, 18, 0.8)
     , (520273, 19, 1)
     , (520273, 31, 25)
     , (520273, 34, 2.5)
     , (520273, 39, 1.2)
     , (520273, 64, 0.33)
     , (520273, 65, 0.5)
     , (520273, 66, 0.83)
     , (520273, 67, 0.2)
     , (520273, 68, 0.2)
     , (520273, 69, 0.73)
     , (520273, 70, 0.65)
     , (520273, 71, 1)
     , (520273, 72, 1)
     , (520273, 73, 1)
     , (520273, 74, 1)
     , (520273, 75, 1)
     , (520273, 80, 3)
     , (520273, 104, 10)
     , (520273, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520273, 1, 'Diamondbound Magma Golem');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520273, 1, 0x020007CB)
     , (520273, 2, 0x09000081)
     , (520273, 3, 0x20000015)
     , (520273, 4, 0x30000008)
     , (520273, 8, 0x06001224)
     , (520273, 22, 0x3400005D)
     , (520273, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520273, 1, 380, 0, 0) /* Strength */
     , (520273, 2, 380, 0, 0) /* Endurance */
     , (520273, 3, 360, 0, 0) /* Quickness */
     , (520273, 4, 380, 0, 0) /* Coordination */
     , (520273, 5, 360, 0, 0) /* Focus */
     , (520273, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520273, 1, 11810, 0, 0, 12000) /* MaxHealth */
     , (520273, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520273, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520273, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520273, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520273, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520273, 20, 0, 2, 0, 100, 0, 0) /* Deception */
     , (520273, 24, 0, 2, 0, 200, 0, 0) /* Run */
     , (520273, 31, 0, 3, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520273, 33, 0, 3, 0, 380, 0, 0) /* LifeMagic */
     , (520273, 34, 0, 3, 0, 400, 0, 0) /* WarMagic */
     , (520273, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520273, 0, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520273, 1, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520273, 2, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520273, 3, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520273, 4, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520273, 5, 4, 104, 0.6, 500, 250, 290, 430, 250, 250, 400, 500, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520273, 6, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520273, 7, 4, 0, 0, 500, 250, 290, 430, 250, 250, 400, 500, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520273, 8, 4, 110, 0.6, 500, 250, 290, 430, 250, 250, 400, 500, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520273, 2074, 2.16) /* Gossamer Flesh */
     , (520273, 2162, 2.16) /* Olthoi's Gift */
     , (520273, 2170, 2.16) /* Inferno's Gift */
     , (520273, 2329, 2.15) /* Essence Void */
     , (520273, 4431, 2.14) /* Incantation of Acid Blast */
     , (520273, 4433, 2.16) /* Incantation of Acid Stream */
     , (520273, 4421, 2.14) /* Incantation of Acid Arc */
     , (520273, 4438, 2.15) /* Incantation of Flame Blast */
     , (520273, 4440, 2.15) /* Incantation of Flame Streak */
     , (520273, 4423, 2.15) /* Incantation of Flame Arc */;
