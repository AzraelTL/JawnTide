using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using ACE.Database.Models.World;
using ACE.Entity.Enum;
using ACE.Entity.Models;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Factories.Enum;
using ACE.Server.Factories.Tables.Wcids;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.WorldObjects;

using log4net;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: /maxweapons makes "perfect" test weapons for damage balancing.
    ///
    /// It rolls thousands of weapons with the real loot code at every loot tier that can drop right now (up to
    /// loot_max_tier), sorts them by weapon kind and wield requirement, and remembers the best value seen for each
    /// stat. A test weapon is a real roll of that kind and wield requirement with every stat set to the best seen,
    /// then given 9 damage tinkers, an imbue (Armor Rending, Critical Strike or Crippling Blow) and Epic cantrips.
    /// So it is the best weapon that loot could possibly produce in the current stage, never better.
    ///
    /// Melee weapons get the mix of Iron (+1 damage) and Granite (variance x 0.8) that gives the highest average
    /// damage per hit for that weapon and imbue; see BestIron.
    ///
    /// The weapons are attuned, bonded and worth nothing, so they can't be traded or sold.
    ///
    /// All the rolling happens on a background thread, so the game doesn't pause; only handing the finished weapons
    /// to the admin runs on the game thread. One request runs at a time.
    ///
    /// Each use is written to the server log ([MAXWEAPONS]), not to the Audit channel.
    /// </summary>
    public static class MaxWeaponCommands
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private const int RollsPerTier = 4000;
        private const int TinkerCount = 9;

        /// <summary>
        /// Flat damage a buffed tester has on top of the weapon (Blood Drinker VIII +24, Epic Blood Thirst +7).
        /// It matters to the Iron / Granite choice: the more flat damage, the less each Iron adds.
        /// </summary>
        private const int BuffDamage = 31;

        /// <summary>
        /// How many of the 9 tinkers should be Iron (the rest Granite) for the highest average damage per hit.
        /// Average hit = (damage + buffs + iron) x [normal share x (1 - variance x 0.8^granite / 2) + crit share x crit multiplier]:
        /// a normal hit is spread evenly from the minimum to the maximum, and a crit always uses the maximum.
        /// Imbues at full strength: Critical Strike 50% crits, Crippling Blow 7x crits; otherwise 10% crits at 2x.
        /// </summary>
        private static int BestIron(int damage, double variance, ImbuedEffectType imbue)
        {
            var critChance = imbue == ImbuedEffectType.CriticalStrike ? 0.5 : 0.1;
            var critMultiplier = imbue == ImbuedEffectType.CripplingBlow ? 7.0 : 2.0;

            var bestIron = TinkerCount;
            var bestAverage = 0.0;

            for (var iron = TinkerCount; iron >= 0; iron--)
            {
                var tinkered = variance * Math.Pow(0.8, TinkerCount - iron);
                var average = (damage + BuffDamage + iron) * ((1 - critChance) * (1 - tinkered / 2) + critChance * critMultiplier);

                // ties go to more Iron (the loop starts there)
                if (average > bestAverage + 1e-9)
                {
                    bestAverage = average;
                    bestIron = iron;
                }
            }
            return bestIron;
        }

        private class Best
        {
            public int Tier;                 // a loot tier this kind and wield requirement was seen at
            public int Seen;
            public int Damage;
            public double Variance = double.MaxValue;
            public double DamageMod;
            public int ElementalBonus;
            public double ElementalMod;
            public double ManaConversion;
            public double Offense;
            public double Defense;
            public double MissileDefense;
            public double MagicDefense;
            public int Speed = int.MaxValue;
        }

        /// <summary>
        /// category + tier cap -> weapon kind -> wield requirement -> the best stats seen
        /// </summary>
        private static readonly Dictionary<string, SortedDictionary<string, SortedDictionary<int, Best>>> cache = new Dictionary<string, SortedDictionary<string, SortedDictionary<int, Best>>>();

        /// <summary>
        /// 1 while a request is being worked on in the background
        /// </summary>
        private static int busy;

        private static readonly string[] Categories = { "heavy", "light", "finesse", "twohanded", "missile", "caster" };

        private static readonly (string code, ImbuedEffectType effect, MaterialType material, string label)[] Imbues =
        {
            ("ar", ImbuedEffectType.ArmorRending, MaterialType.Sunstone, "Armor Rending"),
            ("cs", ImbuedEffectType.CriticalStrike, MaterialType.BlackOpal, "Critical Strike"),
            ("cb", ImbuedEffectType.CripplingBlow, MaterialType.FireOpal, "Crippling Blow"),
        };

        [CommandHandler("maxweapons", AccessLevel.Admin, CommandHandlerFlag.RequiresWorld, 1,
            "Makes perfect test weapons (best stats loot can roll in the current stage, the best 9 damage tinkers, AR / CS / CB, Epic cantrips) for damage testing.",
            "<heavy|light|finesse|twohanded|missile|caster> [wield requirement] [kind]\n" +
            "With only a category: lists every weapon kind and wield requirement with the best stats, and makes nothing.\n" +
            "With a wield requirement: puts three weapons (AR, CS, CB) of every kind at that wield requirement in your pack.\n" +
            "Add a kind (for example sword) to make only that kind. The first use of a category takes a few seconds; the game keeps running meanwhile.")]
        public static void HandleMaxWeapons(Session session, params string[] parameters)
        {
            if (Interlocked.CompareExchange(ref busy, 1, 0) != 0)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "maxweapons is still working on the last request. Try again in a few seconds.");
                return;
            }

            // free pack slots are read here, on the game thread; the rolling then runs in the background
            var freeSlots = session.Player.GetFreeInventorySlots();

            Task.Run(() =>
            {
                try
                {
                    Run(session, parameters, freeSlots);
                }
                catch (Exception ex)
                {
                    CommandHandlerHelper.WriteOutputInfo(session, $"maxweapons failed: {ex.GetType().Name}: {ex.Message}");
                }
                finally
                {
                    Interlocked.Exchange(ref busy, 0);
                }
            });
        }

        private static void Run(Session session, string[] parameters, int freeSlots)
        {
            var category = parameters[0].ToLowerInvariant().Replace("-", "").Replace("_", "");
            if (category == "2h" || category == "twohand")
                category = "twohanded";
            if (!Categories.Contains(category))
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Usage: /maxweapons <heavy|light|finesse|twohanded|missile|caster> [wield requirement] [kind]");
                return;
            }

            var maxTier = (int)PropertyManager.GetLong("loot_max_tier").Item;
            if (maxTier < 1 || maxTier > 8)
                maxTier = 8;

            var kinds = GetBest(session, category, maxTier);
            if (kinds.Count == 0)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"No {category} weapons came out of the loot code.");
                return;
            }

            if (parameters.Length < 2)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"Best {category} weapons loot can roll up to Tier {maxTier}, before tinkering:");
                foreach (var kind in kinds)
                    foreach (var wield in kind.Value)
                        CommandHandlerHelper.WriteOutputInfo(session, $"  {kind.Key}, wield {wield.Key}: {Describe(category, wield.Value)}");
                CommandHandlerHelper.WriteOutputInfo(session, $"To make them: /maxweapons {category} <wield requirement> [kind]");
                return;
            }

            if (!int.TryParse(parameters[1], out var wieldWanted))
            {
                CommandHandlerHelper.WriteOutputInfo(session, "The wield requirement must be a number, for example 400. Use /maxweapons with only the category to list them.");
                return;
            }

            var kindFilter = parameters.Length > 2 ? string.Join("", parameters.Skip(2)).ToLowerInvariant() : null;

            var wanted = kinds.Where(k => k.Value.ContainsKey(wieldWanted) && (kindFilter == null || k.Key.ToLowerInvariant().Replace(" ", "").Contains(kindFilter))).ToList();
            if (wanted.Count == 0)
            {
                var wields = string.Join(", ", kinds.SelectMany(k => k.Value.Keys).Distinct().OrderBy(w => w));
                CommandHandlerHelper.WriteOutputInfo(session, $"Nothing matches. {category} wield requirements: {wields}. Kinds: {string.Join(", ", kinds.Keys)}.");
                return;
            }

            var player = session.Player;
            var needed = wanted.Count * Imbues.Length;
            if (freeSlots < needed)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"That is {needed} weapons and you have {freeSlots} free pack slots. Free some space, or add a kind to make fewer.");
                return;
            }

            var weapons = new List<WorldObject>();
            foreach (var kind in wanted)
            {
                var best = kind.Value[wieldWanted];
                foreach (var imbue in Imbues)
                {
                    var wo = RollOne(category, kind.Key, wieldWanted, best);
                    if (wo == null)
                    {
                        CommandHandlerHelper.WriteOutputInfo(session, $"Couldn't roll a {kind.Key} at wield {wieldWanted} again; skipped.");
                        break;
                    }

                    Perfect(wo, category, best, imbue.effect, imbue.material, imbue.code.ToUpperInvariant());
                    weapons.Add(wo);
                }
            }

            // hand them over on the game thread
            var kindCount = wanted.Count;
            var actionChain = new ActionChain();
            actionChain.AddAction(player, () =>
            {
                var made = 0;
                foreach (var wo in weapons)
                {
                    if (player.TryCreateInInventoryWithNetworking(wo))
                        made++;
                    else
                        wo.Destroy();
                }

                CommandHandlerHelper.WriteOutputInfo(session, $"Made {made} test weapons: {category}, wield {wieldWanted}, {kindCount} kind(s), each with AR, CS and CB."
                    + (made < weapons.Count ? $" {weapons.Count - made} didn't fit in your pack." : "")
                    + (category == "missile" || category == "caster" ? "" : " Each name shows its tinkers, for example 2I/7G is 2 Iron and 7 Granite."));
                // recorded in the server log only: not the in-game Audit channel or its Discord webhook
                log.Info($"[MAXWEAPONS] {player.Name} made {made} max test weapons ({category}, wield {wieldWanted}).");
            });
            actionChain.EnqueueChain();
        }

        private static string Describe(string category, Best b)
        {
            if (category == "missile")
                return $"damage mod +{(b.DamageMod - 1) * 100:0.#}%, elemental bonus +{b.ElementalBonus}, defense +{(b.Defense - 1) * 100:0.#}% (from {b.Seen:N0} rolls)";
            if (category == "caster")
                return $"elemental damage +{(b.ElementalMod - 1) * 100:0.#}%, mana conversion +{b.ManaConversion * 100:0.#}%, defense +{(b.Defense - 1) * 100:0.#}% (from {b.Seen:N0} rolls)";

            var variance = b.Variance == double.MaxValue ? 0 : b.Variance;
            return $"damage {b.Damage * (1 - variance):0.##} - {b.Damage}, attack +{(b.Offense - 1) * 100:0.#}%, defense +{(b.Defense - 1) * 100:0.#}%, speed {b.Speed} (from {b.Seen:N0} rolls)";
        }

        private static WorldObject Roll(string category, TreasureDeath profile)
        {
            switch (category)
            {
                case "heavy": return LootGenerationFactory.CreateMeleeWeapon(profile, true, MeleeWeaponSkill.HeavyWeapons);
                case "light": return LootGenerationFactory.CreateMeleeWeapon(profile, true, MeleeWeaponSkill.LightWeapons);
                case "finesse": return LootGenerationFactory.CreateMeleeWeapon(profile, true, MeleeWeaponSkill.FinesseWeapons);
                case "twohanded": return LootGenerationFactory.CreateMeleeWeapon(profile, true, MeleeWeaponSkill.TwoHandedCombat);
                case "missile": return LootGenerationFactory.CreateMissileWeapon(profile, true);
                default: return LootGenerationFactory.CreateCaster(profile, true);
            }
        }

        /// <summary>
        /// The kind a rolled weapon is filed under, or null to leave it out
        /// </summary>
        private static string KindOf(string category, WorldObject wo)
        {
            if (category == "caster")
            {
                // plain casters have no elemental damage bonus, so there is nothing to compare
                if ((wo.ElementalDamageMod ?? 0) <= 0)
                    return null;
                return wo.W_DamageType == DamageType.Nether ? "Void caster" : "War caster";
            }

            if (category == "missile")
                return wo.W_WeaponType == WeaponType.Thrown ? "Atlatl" : wo.W_WeaponType.ToString();

            var wcid = (ACE.Server.Factories.Enum.WeenieClassName)wo.WeenieClassId;
            if (HeavyWeaponWcids.TryGetValue(wcid, out var type) || LightWeaponWcids.TryGetValue(wcid, out type)
                || FinesseWeaponWcids.TryGetValue(wcid, out type) || TwoHandedWeaponWcids.TryGetValue(wcid, out type))
            {
                switch (type)
                {
                    case TreasureWeaponType.DaggerMS: return "Dagger (multi-strike)";
                    case TreasureWeaponType.SwordMS: return "Sword (multi-strike)";
                    case TreasureWeaponType.MaceJitte: return "Mace (jitte)";
                    case TreasureWeaponType.TwoHandedAxe: return "Two Handed Axe";
                    case TreasureWeaponType.TwoHandedMace: return "Two Handed Mace";
                    case TreasureWeaponType.TwoHandedSpear: return "Two Handed Spear";
                    case TreasureWeaponType.TwoHandedSword: return "Two Handed Sword";
                    default: return type.ToString();
                }
            }
            return wo.W_WeaponType.ToString();
        }

        private static SortedDictionary<string, SortedDictionary<int, Best>> GetBest(Session session, string category, int maxTier)
        {
            var key = $"{category}:{maxTier}";
            SortedDictionary<string, SortedDictionary<int, Best>> kinds;
            lock (cache)
            {
                if (cache.TryGetValue(key, out kinds))
                    return kinds;
            }

            CommandHandlerHelper.WriteOutputInfo(session, $"Working out the best {category} weapons up to Tier {maxTier}. This runs in the background and takes a few seconds the first time.");
            var timer = Stopwatch.StartNew();
            kinds = new SortedDictionary<string, SortedDictionary<int, Best>>();

            for (var tier = 1; tier <= maxTier; tier++)
            {
                var profile = new TreasureDeath { Tier = tier, LootQualityMod = 0 };

                for (var i = 0; i < RollsPerTier; i++)
                {
                    var wo = Roll(category, profile);
                    if (wo == null)
                        continue;

                    var kind = KindOf(category, wo);
                    if (kind != null)
                    {
                        if (!kinds.TryGetValue(kind, out var wields))
                            kinds[kind] = wields = new SortedDictionary<int, Best>();

                        var wield = wo.WieldDifficulty ?? 0;
                        if (!wields.TryGetValue(wield, out var b))
                            wields[wield] = b = new Best();

                        b.Tier = tier;
                        b.Seen++;
                        b.Damage = Math.Max(b.Damage, wo.Damage ?? 0);
                        if (wo.DamageVariance != null)
                            b.Variance = Math.Min(b.Variance, wo.DamageVariance.Value);
                        b.DamageMod = Math.Max(b.DamageMod, wo.DamageMod ?? 0);
                        b.ElementalBonus = Math.Max(b.ElementalBonus, wo.ElementalDamageBonus ?? 0);
                        b.ElementalMod = Math.Max(b.ElementalMod, wo.ElementalDamageMod ?? 0);
                        b.ManaConversion = Math.Max(b.ManaConversion, wo.ManaConversionMod ?? 0);
                        b.Offense = Math.Max(b.Offense, wo.WeaponOffense ?? 1);
                        b.Defense = Math.Max(b.Defense, wo.WeaponDefense ?? 1);
                        b.MissileDefense = Math.Max(b.MissileDefense, wo.WeaponMissileDefense ?? 1);
                        b.MagicDefense = Math.Max(b.MagicDefense, wo.WeaponMagicDefense ?? 1);
                        if (wo.WeaponTime != null)
                            b.Speed = Math.Min(b.Speed, wo.WeaponTime.Value);
                    }

                    wo.Destroy();
                }
            }

            lock (cache)
                cache[key] = kinds;
            CommandHandlerHelper.WriteOutputInfo(session, $"Rolled {RollsPerTier * maxTier:N0} {category} weapons across Tiers 1-{maxTier} in {timer.Elapsed.TotalSeconds:0.0} seconds.");
            return kinds;
        }

        /// <summary>
        /// Rolls until a weapon of this kind and wield requirement comes up. Prefers one that has spells (so it can hold
        /// cantrips) and, for missile weapons, one that has an elemental bonus when the best roll had one.
        /// </summary>
        private static WorldObject RollOne(string category, string kind, int wield, Best best)
        {
            var profile = new TreasureDeath { Tier = best.Tier, LootQualityMod = 0 };

            for (var attempt = 0; attempt < 40000; attempt++)
            {
                var wo = Roll(category, profile);
                if (wo == null)
                    continue;

                var fussy = attempt < 8000;
                if (KindOf(category, wo) == kind && (wo.WieldDifficulty ?? 0) == wield
                    && (!fussy || wo.ItemMaxMana != null)
                    && (!fussy || category != "missile" || best.ElementalBonus == 0 || (wo.ElementalDamageBonus ?? 0) > 0))
                    return wo;

                wo.Destroy();
            }
            return null;
        }

        private static void Perfect(WorldObject wo, string category, Best b, ImbuedEffectType imbue, MaterialType imbueMaterial, string tag)
        {
            MaterialType tinker;
            var iron = TinkerCount;       // for melee: how many of the tinkers are Iron, the rest are Granite

            if (category == "missile")
            {
                // Mahogany: +4% damage modifier each
                wo.DamageMod = b.DamageMod + 0.04 * TinkerCount;
                if (b.ElementalBonus > 0 && (wo.ElementalDamageBonus ?? 0) > 0)
                    wo.ElementalDamageBonus = b.ElementalBonus;
                tinker = MaterialType.Mahogany;
            }
            else if (category == "caster")
            {
                // Green Garnet: +1% elemental damage each
                wo.ElementalDamageMod = b.ElementalMod + 0.01 * TinkerCount;
                if (b.ManaConversion > 0)
                    wo.ManaConversionMod = b.ManaConversion;
                tinker = MaterialType.GreenGarnet;
            }
            else
            {
                // Iron: +1 damage each. Granite: variance x 0.8 each. The mix is the best one for this weapon and imbue.
                var variance = b.Variance != double.MaxValue ? b.Variance : wo.DamageVariance ?? 0;
                iron = BestIron(b.Damage, variance, imbue);

                wo.Damage = b.Damage + iron;
                wo.DamageVariance = variance * Math.Pow(0.8, TinkerCount - iron);
                if (b.Offense > 1)
                    wo.WeaponOffense = b.Offense;
                tinker = MaterialType.Iron;
                tag += $" {iron}I/{TinkerCount - iron}G";
            }

            if (b.Defense > 1)
                wo.WeaponDefense = b.Defense;
            if (b.MissileDefense > 1)
                wo.WeaponMissileDefense = b.MissileDefense;
            if (b.MagicDefense > 1)
                wo.WeaponMagicDefense = b.MagicDefense;
            if (b.Speed != int.MaxValue && category != "caster")
                wo.WeaponTime = b.Speed;

            wo.ImbuedEffect = imbue;
            if (RecipeManager.IconUnderlay.TryGetValue(imbue, out var underlay))
                wo.IconUnderlayId = underlay;
            wo.NumTimesTinkered = TinkerCount + 1;
            wo.TinkerLog = string.Join(",", Enumerable.Repeat((int)tinker, iron)
                .Concat(Enumerable.Repeat((int)MaterialType.Granite, TinkerCount - iron)).Append((int)imbueMaterial));

            // Epic cantrips, the best Tier 7 loot gives. Only on a weapon that already holds spells, so its mana is set up.
            if (wo.ItemMaxMana != null)
            {
                wo.Biota.ClearSpells(wo.BiotaDatabaseLock);

                var cantrips = category == "caster"
                    ? new[] { SpellId.CANTRIPSPIRITTHIRST3, SpellId.CANTRIPDEFENDER3 }
                    : new[] { SpellId.CANTRIPBLOODTHIRST3, SpellId.CANTRIPHEARTTHIRST3, SpellId.CANTRIPDEFENDER3, SpellId.CANTRIPSWIFTHUNTER3 };

                foreach (var cantrip in cantrips)
                    wo.Biota.GetOrAddKnownSpell((int)cantrip, wo.BiotaDatabaseLock, out _);

                wo.ItemCurMana = wo.ItemMaxMana;
            }

            // no arcane lore needed, and it can't leave the tester's hands
            wo.ItemDifficulty = null;
            wo.Attuned = AttunedStatus.Attuned;
            wo.Bonded = BondedStatus.Bonded;
            wo.Value = 0;
            wo.Name = $"{wo.Name} (Max {tag})";
            wo.LongDesc = "A test weapon made with /maxweapons: the best stats loot can roll in the current stage, fully tinkered. Not for play.";
        }
    }
}
