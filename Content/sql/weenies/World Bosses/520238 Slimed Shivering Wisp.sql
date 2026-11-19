/* JawnTide: Goop Scoop's helper, the look of 40127 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520238;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520238, 'goopscoopslimedshiveringwisp', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520238,   1,         16) /* ItemType - Creature */
     , (520238,   2,         20) /* CreatureType - Wisp */
     , (520238,   6,         -1) /* ItemsCapacity */
     , (520238,   7,         -1) /* ContainersCapacity */
     , (520238,  16,          1) /* ItemUseable - No */
     , (520238,  25,        265) /* Level */
     , (520238,  40,          2) /* CombatMode - Melee */
     , (520238,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520238,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520238, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520238, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520238,   1, True ) /* Stuck */
     , (520238,  19, True ) /* Attackable */
     , (520238,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520238,   1,       5) /* HeartbeatInterval */
     , (520238,   2,       0) /* HeartbeatTimestamp */
     , (520238,   3,     100) /* HealthRate */
     , (520238,   4,       4) /* StaminaRate */
     , (520238,   5,       2) /* ManaRate */
     , (520238,  13,    2.25) /* ArmorModVsSlash */
     , (520238,  14,    1.75) /* ArmorModVsPierce */
     , (520238,  15,    1.12) /* ArmorModVsBludgeon */
     , (520238,  16,     3.5) /* ArmorModVsCold */
     , (520238,  17,     3.5) /* ArmorModVsFire */
     , (520238,  18,       4) /* ArmorModVsAcid */
     , (520238,  19,     3.5) /* ArmorModVsElectric */
     , (520238,  31,      50) /* VisualAwarenessRange */
     , (520238,  34,       1) /* PowerupTime */
     , (520238,  36,       1) /* ChargeSpeed */
     , (520238,  39,     1.3) /* DefaultScale */
     , (520238,  55,     110) /* HomeRadius */
     , (520238,  64,       1) /* ResistSlash */
     , (520238,  65,    0.95) /* ResistPierce */
     , (520238,  66,       1) /* ResistBludgeon */
     , (520238,  67,    0.75) /* ResistFire */
     , (520238,  68,     0.5) /* ResistCold */
     , (520238,  69,     0.5) /* ResistAcid */
     , (520238,  70,    0.75) /* ResistElectric */
     , (520238,  77,       1) /* PhysicsScriptIntensity */
     , (520238, 104,      40) /* ObviousRadarRange */
     , (520238, 125,       1) /* ResistHealthDrain */
     , (520238, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520238,   1, 'Slimed Shivering Wisp') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520238,   1, 0x02000A29) /* Setup */
     , (520238,   2, 0x0900008F) /* MotionTable */
     , (520238,   3, 0x20000049) /* SoundTable */
     , (520238,   4, 0x30000000) /* CombatTable */
     , (520238,   8, 0x06001F97) /* Icon */
     , (520238,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520238,   1, 400, 0, 0) /* Strength */
     , (520238,   2, 500, 0, 0) /* Endurance */
     , (520238,   3, 500, 0, 0) /* Quickness */
     , (520238,   4, 350, 0, 0) /* Coordination */
     , (520238,   5, 490, 0, 0) /* Focus */
     , (520238,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520238,   1, 9750, 0, 0, 10000) /* MaxHealth */
     , (520238,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520238,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520238,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520238,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520238, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520238, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520238, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520238, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520238, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520238, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520238, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520238, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520238, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520238, 0, 4, 400, 0.5, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520238, 16, 8, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */
     , (520238, 17, 8, 400, 0.75, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Tail */
     , (520238, 21, 8, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Wings */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520238,  4447,    2.1)  /* Incantation of Frost Bolt */
     , (520238,  4425,   2.06)  /* Incantation of Frost Arc */
     , (520238,  4479,   2.05)  /* Incantation of Cold Vulnerability Other */;
