DELETE FROM `weenie` WHERE `class_Id` = 32205;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (32205, 'ace32205-pumpkinbuffer', 10, '2022-08-22 03:09:27') /* Creature */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (32205,   1,         16) /* ItemType - Creature */
     , (32205,   2,         40) /* CreatureType - Unknown */
     , (32205,   6,         -1) /* ItemsCapacity */
     , (32205,   7,         -1) /* ContainersCapacity */
     , (32205,  16,         32) /* ItemUseable - Remote */
     , (32205,  25,         42) /* Level */
     , (32205,  27,          0) /* ArmorType - None */
     , (32205,  68,          3) /* TargetingTactic - Random, Focused */
     , (32205,  93,       1032) /* PhysicsState - ReportCollisions, Gravity */
     , (32205, 133,          2) /* ShowableOnRadar - ShowMovement */
     , (32205, 140,          1) /* AiOptions - CanOpenDoors */
     , (32205, 146,          0) /* XpOverride */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (32205,   1, True ) /* Stuck */
     , (32205,   6, False) /* AiUsesMana */
     , (32205,  11, False) /* IgnoreCollisions */
     , (32205,  12, True ) /* ReportCollisions */
     , (32205,  13, False) /* Ethereal */
     , (32205,  14, True ) /* GravityStatus */
     , (32205,  19, False) /* Attackable */
     , (32205,  29, True ) /* NoCorpse */
     , (32205,  50, True ) /* NeverFailCasting */
     , (32205,  52, True ) /* AiImmobile */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (32205,   1,       5) /* HeartbeatInterval */
     , (32205,   2,       0) /* HeartbeatTimestamp */
     , (32205,   3,     0.5) /* HealthRate */
     , (32205,   4,     0.5) /* StaminaRate */
     , (32205,   5,       2) /* ManaRate */
     , (32205,  13,       1) /* ArmorModVsSlash */
     , (32205,  14,       1) /* ArmorModVsPierce */
     , (32205,  15,       1) /* ArmorModVsBludgeon */
     , (32205,  16,    0.72) /* ArmorModVsCold */
     , (32205,  17,       1) /* ArmorModVsFire */
     , (32205,  18,       1) /* ArmorModVsAcid */
     , (32205,  19,    0.72) /* ArmorModVsElectric */
     , (32205,  31,      32) /* VisualAwarenessRange */
     , (32205,  34,       1) /* PowerupTime */
     , (32205,  36,       1) /* ChargeSpeed */
     , (32205,  39,     1.7) /* DefaultScale */
     , (32205,  64,       1) /* ResistSlash */
     , (32205,  65,       1) /* ResistPierce */
     , (32205,  66,       1) /* ResistBludgeon */
     , (32205,  67,       1) /* ResistFire */
     , (32205,  68,     0.5) /* ResistCold */
     , (32205,  69,       1) /* ResistAcid */
     , (32205,  70,     0.5) /* ResistElectric */
     , (32205,  71,       1) /* ResistHealthBoost */
     , (32205,  72,       1) /* ResistStaminaDrain */
     , (32205,  73,       1) /* ResistStaminaBoost */
     , (32205,  74,       1) /* ResistManaDrain */
     , (32205,  75,       1) /* ResistManaBoost */
     , (32205,  80,       1) /* AiUseMagicDelay */
     , (32205, 104,      10) /* ObviousRadarRange */
     , (32205, 122,       2) /* AiAcquireHealth */
     , (32205, 125,       1) /* ResistHealthDrain */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (32205,   1, 'Pumpkin Buffer') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (32205,   1, 0x020014E0) /* Setup */
     , (32205,   2, 0x09000028) /* MotionTable */
     , (32205,   3, 0x20000012) /* SoundTable */
     , (32205,   4, 0x3000001D) /* CombatTable */
     , (32205,   8, 0x060022A8) /* Icon */
     , (32205,  22, 0x34000029) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_attribute` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`)
VALUES (32205,   1,  10, 0, 0) /* Strength */
     , (32205,   2,  10, 0, 0) /* Endurance */
     , (32205,   3,  10, 0, 0) /* Quickness */
     , (32205,   4,  10, 0, 0) /* Coordination */
     , (32205,   5, 100, 0, 0) /* Focus */
     , (32205,   6, 100, 0, 0) /* Self */;

INSERT INTO `weenie_properties_attribute_2nd` (`object_Id`, `type`, `init_Level`, `level_From_C_P`, `c_P_Spent`, `current_Level`)
VALUES (32205,   1,    25, 0, 0, 25) /* MaxHealth */
     , (32205,   3,   210, 0, 0, 210) /* MaxStamina */
     , (32205,   5,   400, 0, 0, 400) /* MaxMana */;

INSERT INTO `weenie_properties_body_part` (`object_Id`, `key`, `d_Type`, `d_Val`, `d_Var`, `base_Armor`, `armor_Vs_Slash`, `armor_Vs_Pierce`, `armor_Vs_Bludgeon`, `armor_Vs_Cold`, `armor_Vs_Fire`, `armor_Vs_Acid`, `armor_Vs_Electric`, `armor_Vs_Nether`, `b_h`, `h_l_f`, `m_l_f`, `l_l_f`, `h_r_f`, `m_r_f`, `l_r_f`, `h_l_b`, `m_l_b`, `l_l_b`, `h_r_b`, `m_r_b`, `l_r_b`)
VALUES (32205,  0,  1,  0,    0,  120,  120,  120,  120,   86,  120,  120,   86,    0, 1, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0, 0.33,    0,    0) /* Head */
     , (32205,  1,  1,  0,    0,  120,  120,  120,  120,   86,  120,  120,   86,    0, 2, 0.44, 0.23,    0, 0.44, 0.23,    0, 0.44, 0.17,    0, 0.44, 0.17,    0) /* Chest */
     , (32205,  2,  1,  0,    0,  120,  120,  120,  120,   86,  120,  120,   86,    0, 3,    0, 0.23,  0.1,    0, 0.23,  0.2,    0, 0.17, 0.45,    0, 0.17, 0.45) /* Abdomen */
     , (32205,  3,  1,  0,    0,  100,  100,  100,  100,   72,  100,  100,   72,    0, 1, 0.23, 0.04,  0.2, 0.23, 0.04,  0.1, 0.23, 0.03,    0, 0.23, 0.03,    0) /* UpperArm */
     , (32205,  4,  1,  0,    0,  100,  100,  100,  100,   72,  100,  100,   72,    0, 2,    0,  0.3,  0.3,    0,  0.3,  0.4,    0,  0.3,  0.1,    0,  0.3,  0.1) /* LowerArm */
     , (32205,  5,  1, 15, 0.75,  100,  100,  100,  100,   72,  100,  100,   72,    0, 2,    0,  0.2,  0.3,    0,  0.2,  0.2,    0,  0.2,    0,    0,  0.2,    0) /* Hand */
     , (32205, 17,  1,  0,    0,  100,  100,  100,  100,   72,  100,  100,   72,    0, 3,    0,    0,  0.1,    0,    0,  0.1,    0, 0.13, 0.45,    0, 0.13, 0.45) /* Tail */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (32205,  1315,    2.1)  /* ArmorOther4 (was Incantation of Armor Other) */
     , (32205,  1382,    2.1)  /* CoordinationOther4 (was Incantation of Coordination Other) */
     , (32205,  1358,    2.1)  /* EnduranceOther4 (was Incantation of Endurance Other) */
     , (32205,  1430,    2.1)  /* FocusOther4 (was Incantation of Focus Other) */
     , (32205,  1406,    2.1)  /* QuicknessOther4 (was Incantation of Quickness Other) */
     , (32205,  1335,    2.1)  /* StrengthOther4 (was Incantation of Strength Other) */
     , (32205,  1454,    2.1)  /* WillpowerOther4 (was Incantation of Willpower Other) */
     , (32205,   512,    2.1)  /* AcidProtectionOther4 (was Incantation of Acid Protection Other) */
     , (32205,  1118,    2.1)  /* BladeProtectionOther4 (was Incantation of Blade Protection Other) */
     , (32205,  1027,    2.1)  /* BludgeonProtectionOther4 (was Incantation of Bludgeoning Protection Other) */
     , (32205,  1039,    2.1)  /* ColdProtectionOther4 (was Incantation of Cold Protection Other) */
     , (32205,   849,    2.1)  /* FireProtectionOther4 (was Incantation of Fire Protection Other) */
     , (32205,  1075,    2.1)  /* LightningProtectionOther4 (was Incantation of Lightning Protection Other) */
     , (32205,  1142,    2.1)  /* PiercingProtectionOther4 (was Incantation of Piercing Protection Other) */
     , (32205,   209,    2.1)  /* ManaRenewalOther4 (was Incantation of Mana Renewal Other) */
     , (32205,   162,    2.1)  /* RegenerationOther4 (was Incantation of Regeneration Other) */
     , (32205,  1760,    2.1)  /* AlchemyMasteryOther4 (was Incantation of Alchemy Mastery Other) */
     , (32205,   687,    2.1)  /* ArcaneEnlightenmentOther4 (was Incantation of Arcane Enlightenment Other) */
     , (32205,   711,    2.1)  /* ArmorExpertiseOther4 (was Incantation of Armor Tinkering Expertise Other) */
     , (32205,   295,    2.1)  /* LightWeaponsMasteryOther4 (was Incantation of Light Weapon Mastery Other) */
     , (32205,   464,    2.1)  /* MissileWeaponsMasteryOther4 (was Incantation of Missile Weapon Mastery Other) */
     , (32205,  1712,    2.1)  /* CookingMasteryOther4 (was Incantation of Cooking Mastery Other) */
     , (32205,   566,    2.1)  /* CreatureEnchantmentMasteryOther4 (was Incantation of Creature Enchantment Mastery Other) */
     , (32205,   488,    2.1)  /* CrossbowMasteryOther4 (was Incantation of Missile Weapon Mastery Other) */
     , (32205,   319,    2.1)  /* FinesseWeaponsMasteryOther4 (was Incantation of Finesse Weapon Mastery Other) */
     , (32205,   859,    2.1)  /* DeceptionMasteryOther4 (was Incantation of Deception Mastery Other) */
     , (32205,   955,    2.1)  /* FealtyOther4 (was Incantation of Fealty Other) */
     , (32205,  1736,    2.1)  /* FletchingMasteryOther4 (was Incantation of Fletching Mastery Other) */
     , (32205,   883,    2.1)  /* HealingMasteryOther4 (was Incantation of Healing Mastery Other) */
     , (32205,   253,    2.1)  /* ImpregnabilityOther4 (was Incantation of Impregnability Other) */
     , (32205,   242,    2.1)  /* InvulnerabilityOther4 (was Incantation of Invulnerability Other) */
     , (32205,   590,    2.1)  /* ItemEnchantmentMasteryOther4 (was Incantation of Item Enchantment Mastery Other) */
     , (32205,   735,    2.1)  /* ItemExpertiseOther4 (was Incantation of Item Tinkering Expertise Other) */
     , (32205,   979,    2.1)  /* JumpingMasteryOther4 (was Incantation of Jumping Mastery Other) */
     , (32205,   907,    2.1)  /* LeadershipMasteryOther4 (was Incantation of Leadership Mastery Other) */
     , (32205,   614,    2.1)  /* LifeMagicMasteryOther4 (was Incantation of Life Magic Mastery Other) */
     , (32205,   931,    2.1)  /* LockpickMasteryOther4 (was Incantation of Lockpick Mastery Other) */
     , (32205,   343,    2.1)  /* MaceMasteryOther4 (was Incantation of Light Weapon Mastery Other) */
     , (32205,   759,    2.1)  /* MagicItemExpertiseOther4 (was Incantation of Magic Item Tinkering Expertise Other) */
     , (32205,   271,    2.1)  /* MagicResistanceOther4 (was Incantation of Magic Resistance Other) */
     , (32205,   662,    2.1)  /* ManaMasteryOther4 (was Incantation of Mana Conversion Mastery Other) */
     , (32205,   807,    2.1)  /* MonsterAttunementOther4 (was Incantation of Monster Attunement Other) */
     , (32205,   833,    2.1)  /* PersonAttunementOther4 (was Incantation of Person Attunement Other) */
     , (32205,   367,    2.1)  /* SpearMasteryOther4 (was Incantation of Light Weapon Mastery Other) */
     , (32205,   991,    2.1)  /* SprintOther4 (was Incantation of Sprint Other) */
     , (32205,   391,    2.1)  /* StaffMasteryOther4 (was Incantation of Light Weapon Mastery Other) */
     , (32205,   415,    2.1)  /* HeavyWeaponsMasteryOther4 (was Incantation of Heavy Weapon Mastery Other) */
     , (32205,   536,    2.1)  /* ThrownWeaponMasteryOther4 (was Incantation of Missile Weapon Mastery Other) */
     , (32205,   440,    2.1)  /* UnarmedCombatMasteryOther4 (was Incantation of Light Weapon Mastery Other) */
     , (32205,   638,    2.1)  /* WarMagicMasteryOther4 (was Incantation of War Magic Mastery Other) */
     , (32205,   783,    2.1)  /* WeaponExpertiseOther4 (was Incantation of Weapon Tinkering Expertise Other) */
     , (32205,  5056,    2.1)  /* GearcraftMastery4 (was Incantation of Item Tinkering Expertise Other) */
     , (32205,  5094,    2.1)  /* TwoHandedMasteryOther4 (was Incantation of Two Handed Combat Mastery Other) */
     , (32205,  5406,    2.1)  /* VoidMagicMasteryOther4 (was Incantation of Void Magic Mastery Other) */
     , (32205,  5774,    2.1)  /* DirtyFightingMasteryOther4 (was Incantation of Dirty Fighting Mastery Other) */
     , (32205,  5798,    2.1)  /* DualWieldMasteryOther4 (was Incantation of Dual Wield Mastery Other) */
     , (32205,  5822,    2.1)  /* RecklessnessMasteryOther4 (was Incantation of Recklessness Mastery Other) */
     , (32205,  5846,    2.1)  /* ShieldMasteryOther4 (was Incantation of Shield Mastery Other) */
     , (32205,  5870,    2.1)  /* SneakAttackMasteryOther4 (was Incantation of Sneak Attack Mastery Other) */;

INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (32205,  3 /* Death */,      1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0,  17 /* LocalBroadcast */, 0, 0, NULL, 'The Pumpkin Buffer bursts open spraying treats.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

/* JawnTide: double-click the Pumpkin Buffer for every level 4 buff it knows (it can no longer be attacked) */
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`, `style`, `substyle`, `quest`, `vendor_Type`, `min_Health`, `max_Health`)
VALUES (32205,  7 /* Use */,      1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET @parent_id = LAST_INSERT_ID();

INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `motion`, `message`, `test_String`, `min`, `max`, `min_64`, `max_64`, `min_Dbl`, `max_Dbl`, `stat`, `display`, `amount`, `amount_64`, `hero_X_P_64`, `percent`, `spell_Id`, `wealth_Rating`, `treasure_Class`, `treasure_Type`, `p_Script`, `sound`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (@parent_id,  0, 12 /* TurnToTarget */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  1, 10 /* Tell */, 0, 1, NULL, 'Happy Hallowe''en! Let me fill you with festive energy.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  2, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1315 /* ArmorOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  3, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1382 /* CoordinationOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  4, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1358 /* EnduranceOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  5, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1430 /* FocusOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  6, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1406 /* QuicknessOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  7, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1335 /* StrengthOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  8, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1454 /* WillpowerOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id,  9, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 512 /* AcidProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 10, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1118 /* BladeProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 11, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1027 /* BludgeonProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 12, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1039 /* ColdProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 13, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 849 /* FireProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 14, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1075 /* LightningProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 15, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1142 /* PiercingProtectionOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 16, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 209 /* ManaRenewalOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 17, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 162 /* RegenerationOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 18, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1760 /* AlchemyMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 19, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 687 /* ArcaneEnlightenmentOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 20, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 711 /* ArmorExpertiseOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 21, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 295 /* LightWeaponsMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 22, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 464 /* MissileWeaponsMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 23, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1712 /* CookingMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 24, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 566 /* CreatureEnchantmentMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 25, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 488 /* CrossbowMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 26, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 319 /* FinesseWeaponsMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 27, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 859 /* DeceptionMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 28, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 955 /* FealtyOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 29, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1736 /* FletchingMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 30, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 883 /* HealingMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 31, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 253 /* ImpregnabilityOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 32, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 242 /* InvulnerabilityOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 33, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 590 /* ItemEnchantmentMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 34, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 735 /* ItemExpertiseOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 35, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 979 /* JumpingMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 36, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 907 /* LeadershipMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 37, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 614 /* LifeMagicMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 38, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 931 /* LockpickMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 39, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 343 /* MaceMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 40, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 759 /* MagicItemExpertiseOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 41, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 271 /* MagicResistanceOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 42, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 662 /* ManaMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 43, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 807 /* MonsterAttunementOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 44, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 833 /* PersonAttunementOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 45, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 367 /* SpearMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 46, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 991 /* SprintOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 47, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 391 /* StaffMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 48, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 415 /* HeavyWeaponsMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 49, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 536 /* ThrownWeaponMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 50, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 440 /* UnarmedCombatMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 51, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 638 /* WarMagicMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 52, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 783 /* WeaponExpertiseOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 53, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5056 /* GearcraftMastery4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 54, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5094 /* TwoHandedMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 55, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5406 /* VoidMagicMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 56, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5774 /* DirtyFightingMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 57, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5798 /* DualWieldMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 58, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5822 /* RecklessnessMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 59, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5846 /* ShieldMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
     , (@parent_id, 60, 19 /* CastSpellInstant */, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5870 /* SneakAttackMasteryOther4 */, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `weenie_properties_create_list` (`object_Id`, `destination_Type`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`, `try_To_Bond`)
VALUES (32205, 9,   273,  0, 0, 0.05, False) /* Create Pyreal (273) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9,  4721,  0, 0, 0.05, False) /* Create Cookie (4721) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14763,  0, 0, 0.05, False) /* Create Peppermint Cookie (14763) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14759,  0, 0, 0.05, False) /* Create Chocolate Cookie (14759) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14864,  0, 0, 0.05, False) /* Create Peppermint Chocolate Cookie (14864) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9,  7830,  0, 0, 0.05, False) /* Create Bar of Dark Chocolate (7830) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9,  7832,  0, 0, 0.05, False) /* Create Bar of Milk Chocolate (7832) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 12233,  0, 0, 0.05, False) /* Create Dark Chocolate Candy Bar (12233) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 12234,  0, 0, 0.05, False) /* Create Milk Chocolate Candy Bar (12234) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14758,  0, 0, 0.05, False) /* Create Peppermint Chocolate Bar (14758) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9,   258,  0, 0, 0.05, False) /* Create Apple (258) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9,  5670,  0, 0, 0.05, False) /* Create Tempting Apple (5670) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 12227,  0, 0, 0.05, False) /* Create Candied Apple (12227) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9,  2453,  0, 0, 0.05, False) /* Create Cider (2453) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 13222,  0, 0, 0.2, False) /* Create Peppermint Stick (13222) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.8, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14772,  0, 0, 0.05, False) /* Create Peppermint Monougat Chew (14772) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14761,  0, 0, 0.05, False) /* Create Ginger Bread Lugian (14761) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14760,  0, 0, 0.05, False) /* Create Ginger Bread Drudge (14760) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 14762,  0, 0, 0.05, False) /* Create Ginger Bread Man (14762) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 32210,  0, 0, 0.05, False) /* Create Ginger Bread Pumpkin (32210) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 32201,  0, 0, 0.05, False) /* Create Pumpkin Cookie Cutter (32201) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 34089,  0, 0, 0.05, False) /* Create Floating Candle (34089) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 43242,  0, 0, 0.05, False) /* Create Wooden Scarecrow Guise (43242) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 32188,  0, 0, 0.05, False) /* Create Festival Shirt (32188) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */
     , (32205, 9, 36440,  0, 0, 0.05, False) /* Create Festival Shirt (36440) for ContainTreasure */
     , (32205, 9,     0,  0, 0, 0.95, False) /* Create nothing for ContainTreasure */;
