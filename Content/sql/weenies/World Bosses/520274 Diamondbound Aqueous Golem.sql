/* JawnTide: mid-level world boss underling, the stock Aqueous Golem (31920) at level 250 strength (was 220) */

DELETE FROM `weenie` WHERE `class_Id` = 520274;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520274, 'midbossdiamondaqueousgolem', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520274, 1, 16)
     , (520274, 2, 13)
     , (520274, 6, -1)
     , (520274, 7, -1)
     , (520274, 16, 1)
     , (520274, 25, 250)
     , (520274, 27, 0)
     , (520274, 40, 2)
     , (520274, 68, 8)
     , (520274, 93, 1032)
     , (520274, 133, 2)
     , (520274, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520274, 1, True)
     , (520274, 6, True)
     , (520274, 11, False)
     , (520274, 12, True)
     , (520274, 13, False);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520274, 1, 5)
     , (520274, 2, 0)
     , (520274, 3, 0.25)
     , (520274, 4, 5)
     , (520274, 5, 2)
     , (520274, 13, 0.17)
     , (520274, 14, 0.38)
     , (520274, 15, 0.17)
     , (520274, 16, 1)
     , (520274, 17, 0.5)
     , (520274, 18, 0.79)
     , (520274, 19, 0.3)
     , (520274, 31, 13)
     , (520274, 34, 2.4)
     , (520274, 36, 1)
     , (520274, 39, 1.1)
     , (520274, 64, 0.33)
     , (520274, 65, 0.5)
     , (520274, 66, 0.33)
     , (520274, 67, 1)
     , (520274, 68, 1)
     , (520274, 69, 0.83)
     , (520274, 70, 1)
     , (520274, 71, 1)
     , (520274, 72, 1)
     , (520274, 73, 1)
     , (520274, 74, 1)
     , (520274, 75, 1)
     , (520274, 76, 0.2)
     , (520274, 80, 2)
     , (520274, 104, 10)
     , (520274, 125, 1);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520274, 1, 'Diamondbound Aqueous Golem');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520274, 1, 0x020007E6)
     , (520274, 2, 0x09000081)
     , (520274, 3, 0x2000009B)
     , (520274, 4, 0x30000008)
     , (520274, 8, 0x06001224)
     , (520274, 22, 0x34000062)
     , (520274, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520274, 1, 380, 0, 0) /* Strength */
     , (520274, 2, 380, 0, 0) /* Endurance */
     , (520274, 3, 360, 0, 0) /* Quickness */
     , (520274, 4, 380, 0, 0) /* Coordination */
     , (520274, 5, 360, 0, 0) /* Focus */
     , (520274, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520274, 1, 11810, 0, 0, 12000) /* MaxHealth */
     , (520274, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520274, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520274, 6, 0, 3, 0, 380, 0, 0) /* MeleeDefense */
     , (520274, 7, 0, 3, 0, 360, 0, 0) /* MissileDefense */
     , (520274, 15, 0, 3, 0, 360, 0, 0) /* MagicDefense */
     , (520274, 20, 0, 2, 0, 100, 0, 0) /* Deception */
     , (520274, 24, 0, 2, 0, 200, 0, 0) /* Run */
     , (520274, 31, 0, 3, 0, 380, 0, 0) /* CreatureEnchantment */
     , (520274, 33, 0, 3, 0, 380, 0, 0) /* LifeMagic */
     , (520274, 34, 0, 3, 0, 400, 0, 0) /* WarMagic */
     , (520274, 45, 0, 3, 0, 450, 0, 0) /* LightWeapons */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520274, 0, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520274, 1, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520274, 2, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520274, 3, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520274, 4, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520274, 5, 4, 104, 0.6, 500, 250, 250, 250, 500, 250, 396, 250, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520274, 6, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520274, 7, 4, 0, 0, 500, 250, 250, 250, 500, 250, 396, 250, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520274, 8, 4, 110, 0.6, 500, 250, 250, 250, 500, 250, 396, 250, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520274, 1839, 2.13) /* Blistering Creeper */
     , (520274, 2074, 2.15) /* Gossamer Flesh */
     , (520274, 2162, 2.16) /* Olthoi's Gift */
     , (520274, 2168, 2.16) /* Gelidite's Gift */
     , (520274, 4425, 2.15) /* Incantation of Frost Arc */
     , (520274, 4431, 2.15) /* Incantation of Acid Blast */
     , (520274, 4432, 2.15) /* Incantation of Acid Streak */
     , (520274, 4433, 2.15) /* Incantation of Acid Stream */
     , (520274, 4421, 2.15) /* Incantation of Acid Arc */
     , (520274, 4446, 2.15) /* Incantation of Frost Blast */
     , (520274, 4448, 2.15) /* Incantation of Frost Streak */;
