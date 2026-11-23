using System;
using System.Collections.Generic;

using ACE.DatLoader;
using ACE.Entity.Enum;
using ACE.Entity.Models;
using ACE.Server.Factories;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.WorldObjects;

using log4net;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: /testchar turns the admin's own character into a fully built level 275 for damage testing:
    /// every skill specialized and fully raised, all six attributes at 100 innate and fully raised (290 base), and the
    /// three vitals fully raised. That is the ceiling a player's numbers can reach in any one build, all at once,
    /// unlike /god (which goes far past it).
    /// </summary>
    public static class TestCharCommands
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// Total XP of a level 275 character
        /// </summary>
        private const long MaxLevelXp = 191226310247;

        /// <summary>
        /// Every level 8 spell random loot can put on armor, jewelry and weapons (not banes, which only protect the item they are on). The weapon ones are auras, so they work from a charm.
        /// </summary>
        private static readonly SpellId[] CharmSpells =
        {
            SpellId.StrengthSelf8, SpellId.EnduranceSelf8, SpellId.CoordinationSelf8, SpellId.QuicknessSelf8,
            SpellId.FocusSelf8, SpellId.WillpowerSelf8, SpellId.HeavyWeaponsMasterySelf8, SpellId.LightWeaponsMasterySelf8,
            SpellId.FinesseWeaponsMasterySelf8, SpellId.MissileWeaponsMasterySelf8, SpellId.TwoHandedMasterySelf8, SpellId.InvulnerabilitySelf8,
            SpellId.ImpregnabilitySelf8, SpellId.MagicResistanceSelf8, SpellId.CreatureEnchantmentMasterySelf8, SpellId.ItemEnchantmentMasterySelf8,
            SpellId.LifeMagicMasterySelf8, SpellId.WarMagicMasterySelf8, SpellId.VoidMagicMasterySelf8, SpellId.SummoningMasterySelf8,
            SpellId.ArcaneEnlightenmentSelf8, SpellId.DeceptionMasterySelf8, SpellId.HealingMasterySelf8, SpellId.JumpingMasterySelf8,
            SpellId.LockpickMasterySelf8, SpellId.ManaMasterySelf8, SpellId.SprintSelf8, SpellId.DirtyFightingMasterySelf8,
            SpellId.RecklessnessMasterySelf8, SpellId.SneakAttackMasterySelf8, SpellId.DualWieldMasterySelf8, SpellId.ShieldMasterySelf8,
            SpellId.AlchemyMasterySelf8, SpellId.CookingMasterySelf8, SpellId.FletchingMasterySelf8, SpellId.LeadershipMasterySelf8,
            SpellId.FealtySelf8, SpellId.ArcanumSalvagingSelf8, SpellId.ArmorExpertiseSelf8, SpellId.ItemExpertiseSelf8,
            SpellId.MagicItemExpertiseSelf8, SpellId.WeaponExpertiseSelf8, SpellId.MonsterAttunementSelf8, SpellId.PersonAttunementSelf8,
            SpellId.ArmorSelf8, SpellId.BladeProtectionSelf8, SpellId.PiercingProtectionSelf8, SpellId.BludgeonProtectionSelf8,
            SpellId.FireProtectionSelf8, SpellId.ColdProtectionSelf8, SpellId.AcidProtectionSelf8, SpellId.LightningProtectionSelf8,
            SpellId.RegenerationSelf8, SpellId.RejuvenationSelf8, SpellId.ManaRenewalSelf8, SpellId.BloodDrinkerSelf8,
            SpellId.DefenderSelf8, SpellId.HeartSeekerSelf8, SpellId.SwiftKillerSelf8, SpellId.HermeticLinkSelf8,
            SpellId.SpiritDrinkerSelf8,
        };

        /// <summary>
        /// The Epic version of every cantrip random loot can put on armor and jewelry (not banes). Weapon cantrips are on the weapon.
        /// </summary>
        private static readonly SpellId[] CharmCantrips =
        {
            SpellId.CANTRIPSTRENGTH3, SpellId.CANTRIPENDURANCE3, SpellId.CANTRIPCOORDINATION3, SpellId.CANTRIPQUICKNESS3,
            SpellId.CANTRIPFOCUS3, SpellId.CANTRIPWILLPOWER3, SpellId.CANTRIPHEAVYWEAPONSAPTITUDE3, SpellId.CANTRIPLIGHTWEAPONSAPTITUDE3,
            SpellId.CANTRIPFINESSEWEAPONSAPTITUDE3, SpellId.CANTRIPMISSILEWEAPONSAPTITUDE3, SpellId.CANTRIPTWOHANDEDAPTITUDE3, SpellId.CANTRIPINVULNERABILITY3,
            SpellId.CANTRIPIMPREGNABILITY3, SpellId.CANTRIPMAGICRESISTANCE3, SpellId.CANTRIPCREATUREENCHANTMENTAPTITUDE3, SpellId.CANTRIPITEMENCHANTMENTAPTITUDE3,
            SpellId.CANTRIPLIFEMAGICAPTITUDE3, SpellId.CANTRIPWARMAGICAPTITUDE3, SpellId.CantripVoidMagicAptitude3, SpellId.CantripSummoningProwess3,
            SpellId.CANTRIPARCANEPROWESS3, SpellId.CANTRIPDECEPTIONPROWESS3, SpellId.CANTRIPHEALINGPROWESS3, SpellId.CANTRIPJUMPINGPROWESS3,
            SpellId.CANTRIPMANACONVERSIONPROWESS3, SpellId.CANTRIPLOCKPICKPROWESS3, SpellId.CANTRIPSPRINT3, SpellId.CantripDirtyFightingProwess3,
            SpellId.CantripDualWieldAptitude3, SpellId.CantripRecklessnessProwess3, SpellId.CantripSneakAttackProwess3, SpellId.CantripShieldAptitude3,
            SpellId.CANTRIPALCHEMICALPROWESS3, SpellId.CANTRIPCOOKINGPROWESS3, SpellId.CANTRIPFLETCHINGPROWESS3, SpellId.CANTRIPLEADERSHIP3,
            SpellId.CANTRIPFEALTY3, SpellId.CANTRIPSALVAGING3, SpellId.CANTRIPARMOREXPERTISE3, SpellId.CANTRIPITEMEXPERTISE3,
            SpellId.CANTRIPMAGICITEMEXPERTISE3, SpellId.CANTRIPWEAPONEXPERTISE3, SpellId.CANTRIPMONSTERATTUNEMENT3, SpellId.CANTRIPPERSONATTUNEMENT3,
            SpellId.CANTRIPARMOR3, SpellId.CANTRIPACIDWARD3, SpellId.CANTRIPBLUDGEONINGWARD3, SpellId.CANTRIPFROSTWARD3,
            SpellId.CANTRIPSTORMWARD3, SpellId.CANTRIPFLAMEWARD3, SpellId.CANTRIPSLASHINGWARD3, SpellId.CANTRIPPIERCINGWARD3,
        };

        /// <summary>
        /// Armor sets whose five-piece bonus the charm carries. A real suit can hold one five-piece set (plus four of
        /// another), so all six at once is more than any player has: it is there to test each set's effect.
        /// </summary>
        private static readonly EquipmentSet[] CharmSets =
        {
            EquipmentSet.Adepts, EquipmentSet.Wise, EquipmentSet.Soldiers,
            EquipmentSet.Dexterous, EquipmentSet.Defenders, EquipmentSet.Hearty,
        };

        private const uint CharmSetPieces = 5;

        /// <summary>
        /// The bonus spells a set gives for this many pieces, read from the game data (the same table the server uses
        /// when set pieces are worn)
        /// </summary>
        private static List<uint> SetSpells(EquipmentSet set, uint pieces)
        {
            if (!DatManager.PortalDat.SpellTable.SpellSet.TryGetValue((uint)set, out var spellSet))
                return new List<uint>();

            if (spellSet.SpellSetTiersNoGaps.TryGetValue(pieces, out var tier) || spellSet.SpellSetTiers.TryGetValue(pieces, out tier))
                return tier.Spells;

            return new List<uint>();
        }

        /// <summary>
        /// Crit damage rating a full suit could add in Stage 2: nine armor pieces, each with the best rating (2).
        /// Tier 7 armor rolls either Crit Damage or Crit Damage Resist; for damage testing all nine are Crit Damage.
        /// </summary>
        private const int CharmCritDamageRating = 18;

        [CommandHandler("testcharm", AccessLevel.Admin, CommandHandlerFlag.RequiresWorld, 0,
            "Puts a TEST charm in your pack: a trinket that casts every level 8 item spell and every Epic armor and jewelry cantrip on you, gives the five-piece bonus of the Adept's, Wise, Soldier's, Dexterous, Defender's and Hearty sets, and carries the crit damage rating of a full rated suit.",
            "No parameters. Wear it in the trinket slot. It is attuned, weightless and can't be traded.")]
        public static void HandleTestCharm(Session session, params string[] parameters)
        {
            var player = session.Player;

            try
            {
                // built on the Trinket of Tinkering: a trinket-slot item that already holds spells and mana
                var wo = WorldObjectFactory.CreateNewWorldObject(Player.TinkeringTrinketWcid);
                if (wo == null)
                {
                    CommandHandlerHelper.WriteOutputInfo(session, "Couldn't create the charm: the Trinket of Tinkering (8142017) isn't in the world database.");
                    return;
                }

                wo.Biota.ClearSpells(wo.BiotaDatabaseLock);
                foreach (var spell in CharmSpells)
                    wo.Biota.GetOrAddKnownSpell((int)spell, wo.BiotaDatabaseLock, out _);
                foreach (var cantrip in CharmCantrips)
                    wo.Biota.GetOrAddKnownSpell((int)cantrip, wo.BiotaDatabaseLock, out _);

                var setNotes = new List<string>();
                foreach (var set in CharmSets)
                {
                    var setSpells = SetSpells(set, CharmSetPieces);
                    foreach (var spell in setSpells)
                        wo.Biota.GetOrAddKnownSpell((int)spell, wo.BiotaDatabaseLock, out _);
                    setNotes.Add($"{set} {setSpells.Count}");
                }

                wo.Name = "TEST Charm of Everything";
                wo.LongDesc = "A test item made with /testcharm: every level 8 item spell, every Epic armor and jewelry cantrip, the five-piece bonus of six armor sets, and the crit damage rating of a full rated suit. Not for play.";
                wo.GearCritDamage = CharmCritDamageRating;
                wo.ItemDifficulty = null;
                wo.ItemMaxMana = 1000000;
                wo.ItemCurMana = 1000000;
                wo.ManaRate = -0.001;
                wo.EncumbranceVal = 0;
                wo.Value = 0;
                wo.Attuned = AttunedStatus.Attuned;
                wo.Bonded = BondedStatus.Bonded;

                if (!player.TryCreateInInventoryWithNetworking(wo))
                {
                    wo.Destroy();
                    CommandHandlerHelper.WriteOutputInfo(session, "Your pack is full.");
                    return;
                }

                CommandHandlerHelper.WriteOutputInfo(session, $"TEST Charm of Everything is in your pack: {CharmSpells.Length} level 8 spells, {CharmCantrips.Length} Epic cantrips, +{CharmCritDamageRating} crit damage rating. Wear it in the trinket slot.");
                CommandHandlerHelper.WriteOutputInfo(session, $"Five-piece set bonuses on it (set and number of bonus spells): {string.Join(", ", setNotes)}. A set showing 0 has no five-piece bonus in the game data.");
                log.Info($"[TESTCHARM] {player.Name} used /testcharm.");
            }
            catch (Exception ex)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"testcharm failed: {ex.GetType().Name}: {ex.Message}");
            }
        }

        [CommandHandler("testchar", AccessLevel.Admin, CommandHandlerFlag.RequiresWorld, 0,
            "Makes your own character a fully built level 275 for damage testing: every skill specialized and maxed, all six attributes 100 innate and maxed (290 base), vitals maxed.",
            "No parameters. It changes the character you are on, for good.")]
        public static void HandleTestChar(Session session, params string[] parameters)
        {
            var player = session.Player;

            try
            {
                // level 275 first, so the level and skill credits match a finished character
                var missingXp = MaxLevelXp - (player.TotalExperience ?? 0);
                if (missingXp > 0)
                    player.GrantXP(missingXp, XpType.Admin, ShareType.None, bypassSeasonCap: true);

                var xpTable = DatManager.PortalDat.XpTable;
                var maxSpecXp = xpTable.SpecializedSkillXpList[xpTable.SpecializedSkillXpList.Count - 1];
                var maxAttrXp = xpTable.AttributeXpList[xpTable.AttributeXpList.Count - 1];
                var maxVitalXp = xpTable.VitalXpList[xpTable.VitalXpList.Count - 1];

                var skills = 0;
                foreach (var skill in SkillHelper.ValidSkills)
                {
                    var cs = player.GetCreatureSkill(skill);
                    if (cs == null)
                        continue;

                    cs.AdvancementClass = SkillAdvancementClass.Specialized;
                    cs.InitLevel = 10;
                    cs.ExperienceSpent = maxSpecXp;
                    cs.Ranks = (ushort)Player.CalcSkillRank(SkillAdvancementClass.Specialized, maxSpecXp);

                    session.Network.EnqueueSend(new GameMessagePrivateUpdateSkill(player, cs));
                    skills++;
                }

                foreach (var attr in player.Attributes.Values)
                {
                    // 100 innate in all six (creation allows at most three); never lowered
                    if (attr.StartingValue < 100)
                        attr.StartingValue = 100;

                    attr.ExperienceSpent = maxAttrXp;
                    attr.Ranks = (ushort)Player.CalcAttributeRank(maxAttrXp);

                    session.Network.EnqueueSend(new GameMessagePrivateUpdateAttribute(player, attr));
                }

                foreach (var vital in player.Vitals.Values)
                {
                    vital.ExperienceSpent = maxVitalXp;
                    vital.Ranks = (ushort)Player.CalcVitalRank(maxVitalXp);
                }

                player.SetMaxVitals();

                session.Network.EnqueueSend(
                    new GameMessagePrivateUpdateVital(player, player.Health),
                    new GameMessagePrivateUpdateVital(player, player.Stamina),
                    new GameMessagePrivateUpdateVital(player, player.Mana));

                player.SaveBiotaToDatabase();

                CommandHandlerHelper.WriteOutputInfo(session, $"{player.Name} is now a fully built level {player.Level}: {skills} skills specialized and maxed, all six attributes 100 innate and maxed, vitals maxed. Log out and back in if the skill panel looks out of date.");
                log.Info($"[TESTCHAR] {player.Name} used /testchar.");
            }
            catch (Exception ex)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"testchar failed: {ex.GetType().Name}: {ex.Message}");
            }
        }
    }
}
