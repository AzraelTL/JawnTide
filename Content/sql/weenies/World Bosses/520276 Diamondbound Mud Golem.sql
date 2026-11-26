/* JawnTide: mid-level world boss underling, the stock Ancient Mud Golem (46934) at level 250 strength (was 240) */

DELETE FROM `weenie` WHERE `class_Id` = 520276;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520276, 'midbossdiamondmudgolem', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520276, 1, 16)
     , (520276, 2, 13)
     , (520276, 3, 4)
     , (520276, 6, -1)
     , (520276, 7, -1)
     , (520276, 16, 1)
     , (520276, 25, 250)
     , (520276, 27, 0)
     , (520276, 40, 2)
     , (520276, 68, 9)
     , (520276, 93, 1032)
     , (520276, 133, 2)
     , (520276, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520276, 1, True)
     , (520276, 6, True)
     , (520276, 11, False)
     , (520276, 12, True)
     , (520276, 13, False)
     , (520276, 14, True)
     , (520276, 19, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520276, 1, 5)
     , (520276, 2, 0)
     , (520276, 3, 0.15)
     , (520276, 4, 5)
     , (520276, 5, 2)
     , (520276, 12, 0.5)
     , (520276, 13, 0.79)
     , (520276, 14, 0.79)
     , (520276, 15, 0.79)
     , (520276, 16, 0.8)
     , (520276, 17, 0.7)
     , (520276, 18, 0.17)
     , (520276, 19, 0.79)
     , (520276, 31, 13)
     , (520276, 34, 2)
     , (520276, 36, 1)
     , (520276, 39, 1.1)
     , (520276, 64, 0.83)
     , (520276, 65, 0.83)
     , (520276, 66, 0.83)
     , (520276, 67, 1)
     , (520276, 68, 1)
     , (520276, 69, 0.33)
     , (520276, 70, 0.83)
     , (520276, 71, 1)
     , (520276, 72, 1)
     , (520276, 73, 1)
     , (520276, 74, 1)
     , (520276, 75, 1)
     , (520276, 80, 3)
     , (520276, 104, 10)
     , (520276, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520276, 1, 'Diamondbound Mud Golem');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520276, 1, 0x020007CA)
     , (520276, 2, 0x09000081)
     , (520276, 3, 0x20000099)
     , (520276, 4, 0x30000008)
     , (520276, 6, 0x04000F46)
     , (520276, 7, 0x1000020E)
     , (520276, 8, 0x06001224)
     , (520276, 22, 0x3400005E)
     , (520276, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520276, 1, 380, 0, 0) /* Strength */
     , (520276, 2, 380, 0, 0) /* Endurance */
     , (520276, 3, 360, 0, 0) /* Quickness */
     , (520276, 4, 380, 0, 0) /* Coordination */
     , (520276, 5, 360, 0, 0) /* Focus */
     , (520276, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520276, 1, 11810, 0, 0, 12000) /* MaxHealth */
     , (520276, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520276, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520276, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520276, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520276, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520276, 20, 0, 2, 0, 100, 0, 0) /* Deception */
     , (520276, 24, 0, 2, 0, 200, 0, 0) /* Run */
     , (520276, 31, 0, 3, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520276, 33, 0, 3, 0, 380, 0, 0) /* LifeMagic */
     , (520276, 34, 0, 3, 0, 400, 0, 0) /* WarMagic */
     , (520276, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520276, 0, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520276, 1, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520276, 2, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520276, 3, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520276, 4, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520276, 5, 4, 110, 0.75, 500, 396, 396, 396, 400, 350, 250, 396, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520276, 6, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520276, 7, 4, 0, 0, 500, 396, 396, 396, 400, 350, 250, 396, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520276, 8, 4, 110, 0.75, 500, 396, 396, 396, 400, 350, 250, 396, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520276, 3880, 2.08) /* Galvanic Strike */
     , (520276, 4081, 2.04) /* Eye of the Tempest */
     , (520276, 4292, 2.05) /* Incantation of Bafflement Other */
     , (520276, 4426, 2.05) /* Incantation of Lightning Arc */
     , (520276, 4483, 2.05) /* Incantation of Lightning Vulnerability Other */;
