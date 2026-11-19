/* JawnTide: Goop Scoop's helper, the look of 35118 with stats like the Olthoi King's Royal Olthoi helpers */
DELETE FROM `weenie` WHERE `class_Id` = 520242;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520242, 'goopscoopslimedsentientcrystalshard', 10, '2026-11-19 00:00:00') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520242,   1,         16) /* ItemType - Creature */
     , (520242,   2,         47) /* CreatureType - Crystal */
     , (520242,   3,         39) /* PaletteTemplate - Black */
     , (520242,   6,         -1) /* ItemsCapacity */
     , (520242,   7,         -1) /* ContainersCapacity */
     , (520242,  16,          1) /* ItemUseable - No */
     , (520242,  25,        265) /* Level */
     , (520242,  27,          0) /* ArmorType - None */
     , (520242,  40,          2) /* CombatMode - Melee */
     , (520242,  68,         13) /* TargetingTactic - Random, LastDamager, TopDamager */
     , (520242,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (520242, 133,          4) /* ShowableOnRadar - ShowAlways */
     , (520242, 146,    2500000) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520242,   1, True ) /* Stuck */
     , (520242,  19, True ) /* Attackable */
     , (520242,  65, True ) /* IgnoreMagicResist */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520242,   1,       5) /* HeartbeatInterval */
     , (520242,   2,       0) /* HeartbeatTimestamp */
     , (520242,   3,     100) /* HealthRate */
     , (520242,   4,       4) /* StaminaRate */
     , (520242,   5,       2) /* ManaRate */
     , (520242,  13,    2.25) /* ArmorModVsSlash */
     , (520242,  14,    1.75) /* ArmorModVsPierce */
     , (520242,  15,    1.12) /* ArmorModVsBludgeon */
     , (520242,  16,     3.5) /* ArmorModVsCold */
     , (520242,  17,     3.5) /* ArmorModVsFire */
     , (520242,  18,       4) /* ArmorModVsAcid */
     , (520242,  19,     3.5) /* ArmorModVsElectric */
     , (520242,  31,      50) /* VisualAwarenessRange */
     , (520242,  34,       1) /* PowerupTime */
     , (520242,  36,       1) /* ChargeSpeed */
     , (520242,  39,     1.5) /* DefaultScale */
     , (520242,  55,     110) /* HomeRadius */
     , (520242,  64,       1) /* ResistSlash */
     , (520242,  65,    0.95) /* ResistPierce */
     , (520242,  66,       1) /* ResistBludgeon */
     , (520242,  67,    0.75) /* ResistFire */
     , (520242,  68,     0.5) /* ResistCold */
     , (520242,  69,     0.5) /* ResistAcid */
     , (520242,  70,    0.75) /* ResistElectric */
     , (520242,  77,       1) /* PhysicsScriptIntensity */
     , (520242, 104,      40) /* ObviousRadarRange */
     , (520242, 125,       1) /* ResistHealthDrain */
     , (520242, 151,       1) /* IgnoreShield */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520242,   1, 'Slimed Sentient Crystal Shard') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520242,   1, 0x020008FC) /* Setup */
     , (520242,   2, 0x090000A3) /* MotionTable */
     , (520242,   3, 0x20000059) /* SoundTable */
     , (520242,   4, 0x30000027) /* CombatTable */
     , (520242,   6, 0x04000BEF) /* PaletteBase */
     , (520242,   7, 0x10000193) /* ClothingBase */
     , (520242,   8, 0x06001B4B) /* Icon */
     , (520242,  22, 0x34000073) /* PhysicsEffectTable */
     , (520242,  35,       2111) /* DeathTreasureType (the Royal Olthoi helpers' loot) */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (520242,   1, 400, 0, 0) /* Strength */
     , (520242,   2, 500, 0, 0) /* Endurance */
     , (520242,   3, 500, 0, 0) /* Quickness */
     , (520242,   4, 350, 0, 0) /* Coordination */
     , (520242,   5, 490, 0, 0) /* Focus */
     , (520242,   6, 490, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (520242,   1, 24750, 0, 0, 25000) /* MaxHealth */
     , (520242,   3,  5000, 0, 0, 5500) /* MaxStamina */
     , (520242,   5,  5000, 0, 0, 5490) /* MaxMana */;

INSERT INTO `weenie_properties_skill` (`object_Id`, `type`, `level_From_P_P`, `s_a_c`, `p_p`, `init_Level`, `resistance_At_Last_Check`, `last_Used_Time`)
VALUES (520242,  6, 0, 2, 0, 460, 0, 0) /* MeleeDefense        Trained */
     , (520242,  7, 0, 2, 0, 420, 0, 0) /* MissileDefense      Trained */
     , (520242, 15, 0, 2, 0, 400, 0, 0) /* MagicDefense        Trained */
     , (520242, 31, 0, 2, 0, 430, 0, 0) /* CreatureEnchantment Trained */
     , (520242, 33, 0, 2, 0, 430, 0, 0) /* LifeMagic           Trained */
     , (520242, 34, 0, 2, 0, 430, 0, 0) /* WarMagic            Trained */
     , (520242, 41, 0, 2, 0, 519, 0, 0) /* TwoHandedCombat     Trained */
     , (520242, 43, 0, 2, 0, 430, 0, 0) /* VoidMagic           Trained */
     , (520242, 44, 0, 2, 0, 919, 0, 0) /* HeavyWeapons        Trained */
     , (520242, 45, 0, 2, 0, 519, 0, 0) /* LightWeapons        Trained */
     , (520242, 46, 0, 2, 0, 519, 0, 0) /* FinesseWeapons      Trained */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (520242, 0, 4, 400, 0.75, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 1, 0.5, 0.2, 0, 0.5, 0.2, 0, 0, 0, 0, 0, 0, 0) /* Head */
     , (520242, 10, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.2, 0.4, 0.5, 0.2, 0.4, 0.5, 0, 0, 0, 0, 0, 0) /* FrontLeg */
     , (520242, 12, 4, 400, 0.75, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0, 0, 0.25, 0, 0, 0.25, 0, 0, 0, 0, 0, 0) /* FrontFoot */
     , (520242, 13, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0, 0, 0, 0, 0, 0, 0.3, 0.4, 0.5, 0.3, 0.4, 0.5) /* RearLeg */
     , (520242, 15, 4, 400, 0.75, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 0, 0.25) /* RearFoot */
     , (520242, 16, 4, 0, 0, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0.3, 0.4, 0.25, 0.3, 0.4, 0.25, 0.6, 0.5, 0.25, 0.6, 0.5, 0.25) /* Torso */
     , (520242, 17, 4, 400, 0.75, 700, 1575, 1225, 784, 2450, 2450, 2800, 2450, 0, 2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0, 0.1, 0.1, 0) /* Tail */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520242,  2056,  2.083)  /* Ataxia */
     , (520242,  2064,  2.083)  /* Self Loathing */
     , (520242,  2073,  2.083)  /* Adja's Intervention */
     , (520242,  2162,  2.083)  /* Olthoi's Gift */
     , (520242,  2168,  2.083)  /* Gelidite's Gift */
     , (520242,  2170,  2.083)  /* Inferno's Gift */
     , (520242,  2172,  2.083)  /* Astyrrian's Gift */
     , (520242,  2185,  2.083)  /* Robustify */
     , (520242,  2328,  2.083)  /* Vitality Siphon */;
