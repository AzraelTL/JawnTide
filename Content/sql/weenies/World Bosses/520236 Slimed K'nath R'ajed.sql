/* JawnTide: Goop Scoop's helper, the look of 38010 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520236;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520236, 'goopscoopslimedknathrajed', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520236,   1,         16) /* ItemType - Creature */
     , (520236,   2,         21) /* CreatureType - Knathtead */
     , (520236,   6,         -1) /* ItemsCapacity */
     , (520236,   7,         -1) /* ContainersCapacity */
     , (520236,  16,          1) /* ItemUseable - No */
     , (520236,  25,        265) /* Level */
     , (520236,  27,          0) /* ArmorType - None */
     , (520236,  40,          1) /* CombatMode - NonCombat */
     , (520236,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520236,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520236, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520236, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520236,   1, True ) /* Stuck */
     , (520236,  19, True ) /* Attackable */
     , (520236,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520236,   1,       5) /* HeartbeatInterval */
     , (520236,   2,       0) /* HeartbeatTimestamp */
     , (520236,   3,     100) /* HealthRate */
     , (520236,   4,       4) /* StaminaRate */
     , (520236,   5,       2) /* ManaRate */
     , (520236,  13,    2.25) /* ArmorModVsSlash */
     , (520236,  14,    1.75) /* ArmorModVsPierce */
     , (520236,  15,    1.12) /* ArmorModVsBludgeon */
     , (520236,  16,     3.5) /* ArmorModVsCold */
     , (520236,  17,     3.5) /* ArmorModVsFire */
     , (520236,  18,       4) /* ArmorModVsAcid */
     , (520236,  19,     3.5) /* ArmorModVsElectric */
     , (520236,  31,      50) /* VisualAwarenessRange */
     , (520236,  34,       1) /* PowerupTime */
     , (520236,  36,       1) /* ChargeSpeed */
     , (520236,  39,     1.8) /* DefaultScale */
     , (520236,  55,     110) /* HomeRadius */
     , (520236,  64,       1) /* ResistSlash */
     , (520236,  65,    0.95) /* ResistPierce */
     , (520236,  66,       1) /* ResistBludgeon */
     , (520236,  67,    0.75) /* ResistFire */
     , (520236,  68,     0.5) /* ResistCold */
     , (520236,  69,     0.5) /* ResistAcid */
     , (520236,  70,    0.75) /* ResistElectric */
     , (520236,  77,       1) /* PhysicsScriptIntensity */
     , (520236, 104,      40) /* ObviousRadarRange */
     , (520236, 125,       1) /* ResistHealthDrain */
     , (520236, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520236,   1, 'Slimed K''nath R''ajed') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520236,   1, 0x02001832) /* Setup */
     , (520236,   2, 0x09000032) /* MotionTable */
     , (520236,   3, 0x20000048) /* SoundTable */
     , (520236,   4, 0x3000001A) /* CombatTable */
     , (520236,   8, 0x0600141B) /* Icon */
     , (520236,  22, 0x3400001D) /* PhysicsEffectTable */
     , (520236,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520236,   1, 400, 0, 0) /* Strength */
     , (520236,   2, 500, 0, 0) /* Endurance */
     , (520236,   3, 500, 0, 0) /* Quickness */
     , (520236,   4, 350, 0, 0) /* Coordination */
     , (520236,   5, 490, 0, 0) /* Focus */
     , (520236,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520236,   1, 14750, 0, 0, 15000) /* MaxHealth */
     , (520236,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520236,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520236,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520236,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520236, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520236, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520236, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520236, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520236, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520236, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520236, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520236, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520236, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520236, 0, 4, 400, 0.3, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520236, 2, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Abdomen */
     , (520236, 6, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* UpperLeg */
     , (520236, 16, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520236,  4448,    2.5)  /* Incantation of Frost Streak */
     , (520236,  4449,    2.2)  /* Incantation of Frost Volley */
     , (520236,  4312,   2.15)  /* Incantation of Imperil Other */
     , (520236,  4477,   2.08)  /* Incantation of Bludgeoning Vulnerability Other */;
