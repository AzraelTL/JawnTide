/* JawnTide: Goop Scoop's helper, the look of 29345 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520233;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520233, 'goopscoopslimedmaniacalfiun', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520233,   1,         16) /* ItemType - Creature */
     , (520233,   2,         78) /* CreatureType - Fiun */
     , (520233,   3,         14) /* PaletteTemplate - Red */
     , (520233,   6,         -1) /* ItemsCapacity */
     , (520233,   7,         -1) /* ContainersCapacity */
     , (520233,  16,          1) /* ItemUseable - No */
     , (520233,  25,        265) /* Level */
     , (520233,  27,          0) /* ArmorType - None */
     , (520233,  40,          2) /* CombatMode - Melee */
     , (520233,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520233,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520233, 101,        131) /* AiAllowedCombatStyle - Unarmed, OneHanded, ThrownWeapon */
     , (520233, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520233, 140,          1) /* AiOptions - CanOpenDoors */
     , (520233, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520233,   1, True ) /* Stuck */
     , (520233,  19, True ) /* Attackable */
     , (520233,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520233,   1,       5) /* HeartbeatInterval */
     , (520233,   2,       0) /* HeartbeatTimestamp */
     , (520233,   3,     100) /* HealthRate */
     , (520233,   4,       4) /* StaminaRate */
     , (520233,   5,       2) /* ManaRate */
     , (520233,  13,    2.25) /* ArmorModVsSlash */
     , (520233,  14,    1.75) /* ArmorModVsPierce */
     , (520233,  15,    1.12) /* ArmorModVsBludgeon */
     , (520233,  16,     3.5) /* ArmorModVsCold */
     , (520233,  17,     3.5) /* ArmorModVsFire */
     , (520233,  18,       4) /* ArmorModVsAcid */
     , (520233,  19,     3.5) /* ArmorModVsElectric */
     , (520233,  31,      50) /* VisualAwarenessRange */
     , (520233,  34,       1) /* PowerupTime */
     , (520233,  36,       1) /* ChargeSpeed */
     , (520233,  39,     1.2) /* DefaultScale */
     , (520233,  55,     110) /* HomeRadius */
     , (520233,  64,       1) /* ResistSlash */
     , (520233,  65,    0.95) /* ResistPierce */
     , (520233,  66,       1) /* ResistBludgeon */
     , (520233,  67,    0.75) /* ResistFire */
     , (520233,  68,     0.5) /* ResistCold */
     , (520233,  69,     0.5) /* ResistAcid */
     , (520233,  70,    0.75) /* ResistElectric */
     , (520233,  77,       1) /* PhysicsScriptIntensity */
     , (520233, 104,      40) /* ObviousRadarRange */
     , (520233, 125,       1) /* ResistHealthDrain */
     , (520233, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520233,   1, 'Slimed Maniacal Fiun') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520233,   1, 0x020012A2) /* Setup */
     , (520233,   2, 0x0900017E) /* MotionTable */
     , (520233,   3, 0x200000BC) /* SoundTable */
     , (520233,   4, 0x30000042) /* CombatTable */
     , (520233,   6, 0x040019D8) /* PaletteBase */
     , (520233,   7, 0x100005CE) /* ClothingBase */
     , (520233,   8, 0x060036FC) /* Icon */
     , (520233,  22, 0x340000B4) /* PhysicsEffectTable */
     , (520233,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520233,   1, 400, 0, 0) /* Strength */
     , (520233,   2, 500, 0, 0) /* Endurance */
     , (520233,   3, 500, 0, 0) /* Quickness */
     , (520233,   4, 350, 0, 0) /* Coordination */
     , (520233,   5, 490, 0, 0) /* Focus */
     , (520233,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520233,   1, 14750, 0, 0, 15000) /* MaxHealth */
     , (520233,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520233,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520233,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520233,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520233, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520233, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520233, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520233, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520233, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520233, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520233, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520233, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520233, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520233, 0, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0, 0.33, 0, 0) /* Head */
     , (520233, 1, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0, 0.44, 0.17, 0) /* Chest */
     , (520233, 2, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0, 0, 0.17, 0) /* Abdomen */
     , (520233, 3, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0, 0.23, 0.03, 0) /* UpperArm */
     , (520233, 4, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0, 0, 0.3, 0) /* LowerArm */
     , (520233, 5, 4, 400, 0.4, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0, 0, 0.2, 0) /* Hand */
     , (520233, 6, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18, 0, 0.13, 0.18) /* UpperLeg */
     , (520233, 7, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6, 0, 0, 0.6) /* LowerLeg */
     , (520233, 8, 4, 400, 0.4, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22, 0, 0, 0.22) /* Foot */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520233,  4439,   2.08)  /* Incantation of Flame Bolt */
     , (520233,  4457,   2.08)  /* Incantation of Whirling Blade */
     , (520233,  4448,   2.05)  /* Incantation of Frost Streak */
     , (520233,  4452,   2.05)  /* Incantation of Lightning Streak */
     , (520233,  4312,   2.04)  /* Incantation of Imperil Other */
     , (520233,  4475,   2.04)  /* Incantation of Blade Vulnerability Other */;
