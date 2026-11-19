/* JawnTide: Goop Scoop's helper, the look of 38011 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520237;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520237, 'goopscoopslimedknathynda', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520237,   1,         16) /* ItemType - Creature */
     , (520237,   2,         21) /* CreatureType - Knathtead */
     , (520237,   6,         -1) /* ItemsCapacity */
     , (520237,   7,         -1) /* ContainersCapacity */
     , (520237,  16,          1) /* ItemUseable - No */
     , (520237,  25,        265) /* Level */
     , (520237,  27,          0) /* ArmorType - None */
     , (520237,  40,          1) /* CombatMode - NonCombat */
     , (520237,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520237,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520237, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520237, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520237,   1, True ) /* Stuck */
     , (520237,  19, True ) /* Attackable */
     , (520237,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520237,   1,       5) /* HeartbeatInterval */
     , (520237,   2,       0) /* HeartbeatTimestamp */
     , (520237,   3,     100) /* HealthRate */
     , (520237,   4,       4) /* StaminaRate */
     , (520237,   5,       2) /* ManaRate */
     , (520237,  13,    2.25) /* ArmorModVsSlash */
     , (520237,  14,    1.75) /* ArmorModVsPierce */
     , (520237,  15,    1.12) /* ArmorModVsBludgeon */
     , (520237,  16,     3.5) /* ArmorModVsCold */
     , (520237,  17,     3.5) /* ArmorModVsFire */
     , (520237,  18,       4) /* ArmorModVsAcid */
     , (520237,  19,     3.5) /* ArmorModVsElectric */
     , (520237,  31,      50) /* VisualAwarenessRange */
     , (520237,  34,       1) /* PowerupTime */
     , (520237,  36,       1) /* ChargeSpeed */
     , (520237,  39,     1.8) /* DefaultScale */
     , (520237,  55,     110) /* HomeRadius */
     , (520237,  64,       1) /* ResistSlash */
     , (520237,  65,    0.95) /* ResistPierce */
     , (520237,  66,       1) /* ResistBludgeon */
     , (520237,  67,    0.75) /* ResistFire */
     , (520237,  68,     0.5) /* ResistCold */
     , (520237,  69,     0.5) /* ResistAcid */
     , (520237,  70,    0.75) /* ResistElectric */
     , (520237,  77,       1) /* PhysicsScriptIntensity */
     , (520237, 104,      40) /* ObviousRadarRange */
     , (520237, 125,       1) /* ResistHealthDrain */
     , (520237, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520237,   1, 'Slimed K''nath Y''nda') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520237,   1, 0x02001833) /* Setup */
     , (520237,   2, 0x09000032) /* MotionTable */
     , (520237,   3, 0x20000048) /* SoundTable */
     , (520237,   4, 0x3000001A) /* CombatTable */
     , (520237,   8, 0x0600141B) /* Icon */
     , (520237,  22, 0x3400001D) /* PhysicsEffectTable */
     , (520237,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520237,   1, 400, 0, 0) /* Strength */
     , (520237,   2, 500, 0, 0) /* Endurance */
     , (520237,   3, 500, 0, 0) /* Quickness */
     , (520237,   4, 350, 0, 0) /* Coordination */
     , (520237,   5, 490, 0, 0) /* Focus */
     , (520237,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520237,   1, 14750, 0, 0, 15000) /* MaxHealth */
     , (520237,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520237,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520237,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520237,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520237, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520237, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520237, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520237, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520237, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520237, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520237, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520237, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520237, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520237, 0, 4, 400, 0.3, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520237, 2, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Abdomen */
     , (520237, 6, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* UpperLeg */
     , (520237, 16, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520237,  4432,    2.5)  /* Incantation of Acid Streak */
     , (520237,  4434,    2.2)  /* Incantation of Acid Volley */
     , (520237,  4312,   2.15)  /* Incantation of Imperil Other */
     , (520237,  4473,   2.08)  /* Incantation of Acid Vulnerability Other */;
