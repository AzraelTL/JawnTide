/* JawnTide: Goop Scoop's helper, the look of 38009 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520235;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520235, 'goopscoopslimedknathnda', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520235,   1,         16) /* ItemType - Creature */
     , (520235,   2,         21) /* CreatureType - Knathtead */
     , (520235,   6,         -1) /* ItemsCapacity */
     , (520235,   7,         -1) /* ContainersCapacity */
     , (520235,  16,          1) /* ItemUseable - No */
     , (520235,  25,        265) /* Level */
     , (520235,  27,          0) /* ArmorType - None */
     , (520235,  40,          1) /* CombatMode - NonCombat */
     , (520235,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520235,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520235, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520235, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520235,   1, True ) /* Stuck */
     , (520235,  19, True ) /* Attackable */
     , (520235,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520235,   1,       5) /* HeartbeatInterval */
     , (520235,   2,       0) /* HeartbeatTimestamp */
     , (520235,   3,     100) /* HealthRate */
     , (520235,   4,       4) /* StaminaRate */
     , (520235,   5,       2) /* ManaRate */
     , (520235,  13,    2.25) /* ArmorModVsSlash */
     , (520235,  14,    1.75) /* ArmorModVsPierce */
     , (520235,  15,    1.12) /* ArmorModVsBludgeon */
     , (520235,  16,     3.5) /* ArmorModVsCold */
     , (520235,  17,     3.5) /* ArmorModVsFire */
     , (520235,  18,       4) /* ArmorModVsAcid */
     , (520235,  19,     3.5) /* ArmorModVsElectric */
     , (520235,  31,      50) /* VisualAwarenessRange */
     , (520235,  34,       1) /* PowerupTime */
     , (520235,  36,       1) /* ChargeSpeed */
     , (520235,  39,     1.8) /* DefaultScale */
     , (520235,  55,     110) /* HomeRadius */
     , (520235,  64,       1) /* ResistSlash */
     , (520235,  65,    0.95) /* ResistPierce */
     , (520235,  66,       1) /* ResistBludgeon */
     , (520235,  67,    0.75) /* ResistFire */
     , (520235,  68,     0.5) /* ResistCold */
     , (520235,  69,     0.5) /* ResistAcid */
     , (520235,  70,    0.75) /* ResistElectric */
     , (520235,  77,       1) /* PhysicsScriptIntensity */
     , (520235, 104,      40) /* ObviousRadarRange */
     , (520235, 125,       1) /* ResistHealthDrain */
     , (520235, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520235,   1, 'Slimed K''nath N''da') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520235,   1, 0x02001831) /* Setup */
     , (520235,   2, 0x09000032) /* MotionTable */
     , (520235,   3, 0x20000048) /* SoundTable */
     , (520235,   4, 0x3000001A) /* CombatTable */
     , (520235,   8, 0x0600141B) /* Icon */
     , (520235,  22, 0x3400001D) /* PhysicsEffectTable */
     , (520235,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520235,   1, 400, 0, 0) /* Strength */
     , (520235,   2, 500, 0, 0) /* Endurance */
     , (520235,   3, 500, 0, 0) /* Quickness */
     , (520235,   4, 350, 0, 0) /* Coordination */
     , (520235,   5, 490, 0, 0) /* Focus */
     , (520235,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520235,   1, 14750, 0, 0, 15000) /* MaxHealth */
     , (520235,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520235,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520235,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520235,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520235, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520235, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520235, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520235, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520235, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520235, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520235, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520235, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520235, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520235, 0, 4, 400, 0.3, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520235, 2, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Abdomen */
     , (520235, 6, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* UpperLeg */
     , (520235, 16, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520235,  4456,    2.5)  /* Incantation of Shock Wave Streak */
     , (520235,  4454,    2.2)  /* Incantation of Shock Blast */
     , (520235,  4312,   2.15)  /* Incantation of Imperil Other */
     , (520235,  4477,   2.08)  /* Incantation of Bludgeoning Vulnerability Other */;
