/* JawnTide: mid-level world boss underling, the stock Bound Crystal Golem (19426) at level 250 strength (was 200) */

DELETE FROM `weenie` WHERE `class_Id` = 520275;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520275, 'midbossdiamondcrystalgolem', 10, '2026-11-26 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520275, 1, 16)
     , (520275, 2, 13)
     , (520275, 3, 2)
     , (520275, 6, -1)
     , (520275, 7, -1)
     , (520275, 16, 1)
     , (520275, 25, 250)
     , (520275, 27, 0)
     , (520275, 40, 2)
     , (520275, 68, 3)
     , (520275, 93, 1032)
     , (520275, 133, 2)
     , (520275, 146, 2000000);

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520275, 1, True)
     , (520275, 6, True)
     , (520275, 11, False)
     , (520275, 12, True)
     , (520275, 13, False)
     , (520275, 50, True);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520275, 1, 5)
     , (520275, 2, 0)
     , (520275, 3, 1)
     , (520275, 4, 100)
     , (520275, 5, 10)
     , (520275, 12, 0.5)
     , (520275, 13, 1)
     , (520275, 14, 1)
     , (520275, 15, 1)
     , (520275, 16, 1)
     , (520275, 17, 1)
     , (520275, 18, 1)
     , (520275, 19, 1)
     , (520275, 31, 15)
     , (520275, 34, 3)
     , (520275, 39, 1)
     , (520275, 64, 0.05)
     , (520275, 65, 0.05)
     , (520275, 66, 0.05)
     , (520275, 67, 0.05)
     , (520275, 68, 0.05)
     , (520275, 69, 0.05)
     , (520275, 70, 0.05)
     , (520275, 71, 1)
     , (520275, 72, 0)
     , (520275, 73, 1)
     , (520275, 74, 0)
     , (520275, 75, 1)
     , (520275, 76, 0.3)
     , (520275, 80, 3)
     , (520275, 104, 10)
     , (520275, 125, 0)
     , (520275, 127, 2);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520275, 1, 'Diamondbound Crystal Golem');

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520275, 1, 0x020007D7)
     , (520275, 2, 0x09000081)
     , (520275, 3, 0x20000015)
     , (520275, 4, 0x30000008)
     , (520275, 6, 0x04000F68)
     , (520275, 7, 0x1000020F)
     , (520275, 8, 0x06001224)
     , (520275, 22, 0x3400005A)
     , (520275, 35, 0x0000083F);

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520275, 1, 380, 0, 0) /* Strength */
     , (520275, 2, 380, 0, 0) /* Endurance */
     , (520275, 3, 360, 0, 0) /* Quickness */
     , (520275, 4, 380, 0, 0) /* Coordination */
     , (520275, 5, 360, 0, 0) /* Focus */
     , (520275, 6, 360, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520275, 1, 11810, 0, 0, 12000) /* MaxHealth */
     , (520275, 3, 4620, 0, 0, 5000) /* MaxStamina */
     , (520275, 5, 4640, 0, 0, 5000) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520275, 6, 0, 3, 0, 380, 0, 1119.7577) /* MeleeDefense */
     , (520275, 7, 0, 3, 0, 360, 0, 1119.7577) /* MissileDefense */
     , (520275, 13, 0, 3, 0, 450, 0, 1119.7577) /* UnarmedCombat */
     , (520275, 14, 0, 2, 0, 150, 0, 1119.7577) /* ArcaneLore */
     , (520275, 15, 0, 3, 0, 360, 0, 1119.7577) /* MagicDefense */
     , (520275, 20, 0, 3, 0, 400, 0, 1119.7577) /* Deception */
     , (520275, 22, 0, 3, 0, 10, 0, 1119.7577) /* Jump */
     , (520275, 24, 0, 3, 0, 10, 0, 1119.7577) /* Run */
     , (520275, 31, 0, 3, 0, 380, 0, 1119.7577) /* CreatureEnchantment */
     , (520275, 33, 0, 3, 0, 380, 0, 1119.7577) /* LifeMagic */
     , (520275, 34, 0, 3, 0, 400, 0, 1119.7577) /* WarMagic */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520275, 0, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520275, 1, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520275, 2, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520275, 3, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520275, 4, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520275, 5, 4, 110, 0.25, 500, 500, 500, 500, 500, 500, 500, 500, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520275, 6, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520275, 7, 4, 0, 0, 500, 500, 500, 500, 500, 500, 500, 500, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520275, 8, 4, 110, 0.25, 500, 500, 500, 500, 500, 500, 500, 500, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520275, 4433, 2.01) /* Incantation of Acid Stream */
     , (520275, 4455, 2.01) /* Incantation of Shock Wave */
     , (520275, 4447, 2.01) /* Incantation of Frost Bolt */
     , (520275, 4451, 2.01) /* Incantation of Lightning Bolt */
     , (520275, 4439, 2.01) /* Incantation of Flame Bolt */
     , (520275, 4443, 2.01) /* Incantation of Force Bolt */
     , (520275, 4457, 2.01) /* Incantation of Whirling Blade */
     , (520275, 4596, 2) /* Incantation of Magic Resistance Self */
     , (520275, 4460, 2) /* Incantation of Acid Protection Self */
     , (520275, 4464, 2) /* Incantation of Bludgeoning Protection Self */
     , (520275, 4466, 2) /* Incantation of Cold Protection Self */
     , (520275, 4470, 2) /* Incantation of Lightning Protection Self */
     , (520275, 4468, 2) /* Incantation of Fire Protection Self */
     , (520275, 4462, 2) /* Incantation of Blade Protection Self */
     , (520275, 4472, 2) /* Incantation of Piercing Protection Self */
     , (520275, 4308, 2.01) /* Incantation of Harm Other */
     , (520275, 4291, 2) /* Incantation of Armor Self */;
