/* JawnTide: Goop Scoop's helper, the look of 40129 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520240;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520240, 'goopscoopslimedvoltaicwisp', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520240,   1,         16) /* ItemType - Creature */
     , (520240,   2,         20) /* CreatureType - Wisp */
     , (520240,   6,         -1) /* ItemsCapacity */
     , (520240,   7,         -1) /* ContainersCapacity */
     , (520240,  16,          1) /* ItemUseable - No */
     , (520240,  25,        265) /* Level */
     , (520240,  40,          2) /* CombatMode - Melee */
     , (520240,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520240,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520240, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520240, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520240,   1, True ) /* Stuck */
     , (520240,  19, True ) /* Attackable */
     , (520240,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520240,   1,       5) /* HeartbeatInterval */
     , (520240,   2,       0) /* HeartbeatTimestamp */
     , (520240,   3,     100) /* HealthRate */
     , (520240,   4,       4) /* StaminaRate */
     , (520240,   5,       2) /* ManaRate */
     , (520240,  13,    2.25) /* ArmorModVsSlash */
     , (520240,  14,    1.75) /* ArmorModVsPierce */
     , (520240,  15,    1.12) /* ArmorModVsBludgeon */
     , (520240,  16,     3.5) /* ArmorModVsCold */
     , (520240,  17,     3.5) /* ArmorModVsFire */
     , (520240,  18,       4) /* ArmorModVsAcid */
     , (520240,  19,     3.5) /* ArmorModVsElectric */
     , (520240,  31,      50) /* VisualAwarenessRange */
     , (520240,  34,       1) /* PowerupTime */
     , (520240,  36,       1) /* ChargeSpeed */
     , (520240,  39,     1.3) /* DefaultScale */
     , (520240,  55,     110) /* HomeRadius */
     , (520240,  64,       1) /* ResistSlash */
     , (520240,  65,    0.95) /* ResistPierce */
     , (520240,  66,       1) /* ResistBludgeon */
     , (520240,  67,    0.75) /* ResistFire */
     , (520240,  68,     0.5) /* ResistCold */
     , (520240,  69,     0.5) /* ResistAcid */
     , (520240,  70,    0.75) /* ResistElectric */
     , (520240,  77,       1) /* PhysicsScriptIntensity */
     , (520240, 104,      40) /* ObviousRadarRange */
     , (520240, 125,       1) /* ResistHealthDrain */
     , (520240, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520240,   1, 'Slimed Voltaic Wisp') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520240,   1, 0x020009F3) /* Setup */
     , (520240,   2, 0x0900008F) /* MotionTable */
     , (520240,   3, 0x20000049) /* SoundTable */
     , (520240,   4, 0x30000000) /* CombatTable */
     , (520240,   8, 0x0600207C) /* Icon */
     , (520240,  22, 0x3400002A) /* PhysicsEffectTable */
     , (520240,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520240,   1, 400, 0, 0) /* Strength */
     , (520240,   2, 500, 0, 0) /* Endurance */
     , (520240,   3, 500, 0, 0) /* Quickness */
     , (520240,   4, 350, 0, 0) /* Coordination */
     , (520240,   5, 490, 0, 0) /* Focus */
     , (520240,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520240,   1, 9750, 0, 0, 10000) /* MaxHealth */
     , (520240,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520240,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520240,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520240,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520240, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520240, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520240, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520240, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520240, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520240, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520240, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520240, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520240, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520240, 0, 4, 400, 0.5, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Head */
     , (520240, 16, 64, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4) /* Torso */
     , (520240, 17, 64, 400, 0.75, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Tail */
     , (520240, 21, 64, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2) /* Wings */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520240,  4451,    2.1)  /* Incantation of Lightning Bolt */
     , (520240,  4453,   2.06)  /* Incantation of Lightning Volley */
     , (520240,  4483,   2.05)  /* Incantation of Lightning Vulnerability Other */;
