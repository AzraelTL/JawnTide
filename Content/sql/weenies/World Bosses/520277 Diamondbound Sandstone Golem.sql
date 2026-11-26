/* JawnTide: mid-level world boss underling, the stock Ancient Sandstone Golem (46935) at level 250 strength (was 240) */

DELETE FROM `weenie` WHERE `class_Id` = 520277;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520277, 'midbossdiamondsandstonegolem', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520277, 1, 16)
     , (520277, 2, 13)
     , (520277, 3, 17)
     , (520277, 6, -1)
     , (520277, 7, -1)
     , (520277, 16, 1)
     , (520277, 25, 250)
     , (520277, 27, 0)
     , (520277, 40, 2)
     , (520277, 68, 9)
     , (520277, 93, 1032)
     , (520277, 133, 2)
     , (520277, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520277, 1, True)
     , (520277, 6, True)
     , (520277, 11, False)
     , (520277, 12, True)
     , (520277, 13, False)
     , (520277, 14, True)
     , (520277, 19, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520277, 1, 5)
     , (520277, 2, 0)
     , (520277, 3, 0.35)
     , (520277, 4, 0.5)
     , (520277, 5, 2)
     , (520277, 6, 0.1)
     , (520277, 7, 0.25)
     , (520277, 8, 0.3)
     , (520277, 12, 0.5)
     , (520277, 13, 0.44)
     , (520277, 14, 0.58)
     , (520277, 15, 1)
     , (520277, 16, 0.33)
     , (520277, 17, 0.33)
     , (520277, 18, 1)
     , (520277, 19, 0.86)
     , (520277, 31, 13)
     , (520277, 34, 2.5)
     , (520277, 64, 0.33)
     , (520277, 65, 0.5)
     , (520277, 66, 1)
     , (520277, 67, 0.2)
     , (520277, 68, 0.2)
     , (520277, 69, 1)
     , (520277, 70, 0.83)
     , (520277, 71, 1)
     , (520277, 72, 1)
     , (520277, 73, 1)
     , (520277, 74, 1)
     , (520277, 75, 1)
     , (520277, 80, 3)
     , (520277, 104, 10)
     , (520277, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520277, 1, 'Diamondbound Sandstone Golem');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520277, 1, 0x020007CA)
     , (520277, 2, 0x09000081)
     , (520277, 3, 0x20000015)
     , (520277, 4, 0x30000008)
     , (520277, 6, 0x04000F47)
     , (520277, 7, 0x10000210)
     , (520277, 8, 0x06001224)
     , (520277, 22, 0x34000061)
     , (520277, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520277, 1, 380, 0, 0) /* Strength */
     , (520277, 2, 380, 0, 0) /* Endurance */
     , (520277, 3, 360, 0, 0) /* Quickness */
     , (520277, 4, 380, 0, 0) /* Coordination */
     , (520277, 5, 360, 0, 0) /* Focus */
     , (520277, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520277, 1, 11810, 0, 0, 12000) /* MaxHealth */
     , (520277, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520277, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520277, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520277, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520277, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520277, 20, 0, 2, 0, 100, 0, 0) /* Deception */
     , (520277, 24, 0, 2, 0, 200, 0, 0) /* Run */
     , (520277, 31, 0, 3, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520277, 33, 0, 3, 0, 380, 0, 0) /* LifeMagic */
     , (520277, 34, 0, 3, 0, 400, 0, 0) /* WarMagic */
     , (520277, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520277, 0, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520277, 1, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520277, 2, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520277, 3, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520277, 4, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520277, 5, 4, 110, 0.75, 500, 250, 290, 500, 250, 250, 500, 430, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520277, 6, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520277, 7, 4, 0, 0, 500, 250, 290, 500, 250, 250, 500, 430, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520277, 8, 4, 110, 0.75, 500, 250, 290, 500, 250, 250, 500, 430, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520277, 3877, 2.08) /* Corrosive Strike */
     , (520277, 4473, 2.04) /* Incantation of Acid Vulnerability Other */
     , (520277, 4643, 2.05) /* Incantation of Drain Health Other */
     , (520277, 4644, 2.05) /* Incantation of Drain Mana Other */
     , (520277, 4645, 2.05) /* Incantation of Drain Stamina Other */;
