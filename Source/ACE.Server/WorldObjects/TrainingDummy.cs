using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;

using ACE.Database;
using ACE.DatLoader;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Entity.Models;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Managers;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide Target Drudge: an unkillable, non-attacking target for measuring PvP damage.
    /// - A player's attacks on it take the PvP damage path (every pvp_* setting, PK ratings, the PvP damage cap),
    ///   against the armor level, defense skills, damage resist ratings and buffs set with /dummy.
    /// - Each attacker gets a session: a short line every 10 seconds while attacking, and a full report 15 seconds after
    ///   the last hit, which is also saved to training_dummy_session (with every pvp_* setting in effect) for the LAN admin page.
    /// - It heals to full after every hit and gives no skill training.
    /// Its setup is saved in training_dummy by guid, so one placed with @createinst keeps it across restarts.
    /// </summary>
    public class TrainingDummy : Creature
    {
        public const uint DummyWcid = 4290001;

        /// <summary>Dummies in the world, by guid (for changes made on the LAN admin page).</summary>
        public static readonly System.Collections.Concurrent.ConcurrentDictionary<uint, TrainingDummy> Placed = new System.Collections.Concurrent.ConcurrentDictionary<uint, TrainingDummy>();


        public int Armor = 0;
        public int ArmorExtremities = 0; // head, hands and feet
        public int MeleeDef = 0;
        public int MissileDef = 0;
        public int MagicDef = 0;
        public int Drr = 0;
        public int Cdr = 0;
        public int Pkdr = 0;
        public List<uint> Buffs = new List<uint>();

        /// <summary>Each worn copy and the guid of the real item it copies (/dummy wear), so the copies come back after a restart.</summary>
        private readonly Dictionary<ObjectGuid, uint> wornFrom = new Dictionary<ObjectGuid, uint>();
        public List<uint> WornSources => wornFrom.Values.ToList();

        private class SourceStats
        {
            public int Attacks, Hits, Misses, Crits;
            public long Damage;
            public uint Min = uint.MaxValue, Max;

            /// <summary>What did the damage: weapon / spell / launcher stats and the attacker's skill, taken at the first attack.</summary>
            public Dictionary<string, object> Info;
            public string Label;
            public readonly Dictionary<string, int> DamageTypes = new Dictionary<string, int>();
        }

        // ---------------------------------------------------------------- weapon stats for the session record

        private static void AddItemStats(Dictionary<string, object> d, string prefix, WorldObject wo)
        {
            if (wo == null)
                return;

            d[prefix + "name"] = wo.NameWithMaterial ?? wo.Name;
            d[prefix + "wcid"] = wo.WeenieClassId;
            void I(string name, PropertyInt p) { var v = wo.GetProperty(p); if (v != null) d[prefix + name] = v.Value; }
            void F(string name, PropertyFloat p) { var v = wo.GetProperty(p); if (v != null) d[prefix + name] = Math.Round(v.Value, 4); }

            if (wo.WeaponSkill != Skill.None) d[prefix + "skill"] = wo.WeaponSkill.ToString();
            if (wo.W_WeaponType != WeaponType.Undef) d[prefix + "weapon_type"] = wo.W_WeaponType.ToString();
            if (wo.W_AttackType != AttackType.Undef) d[prefix + "attack_type"] = wo.W_AttackType.ToString();
            if (wo.DefaultCombatStyle != null) d[prefix + "combat_style"] = wo.DefaultCombatStyle.ToString();
            if (wo.ImbuedEffect != ImbuedEffectType.Undef) d[prefix + "imbue"] = wo.ImbuedEffect.ToString();
            if (wo.W_DamageType != DamageType.Undef) d[prefix + "damage_type"] = wo.W_DamageType.ToString();
            I("damage", PropertyInt.Damage);
            F("variance", PropertyFloat.DamageVariance);
            F("damage_mod", PropertyFloat.DamageMod);
            F("elemental_damage_mod", PropertyFloat.ElementalDamageMod);
            I("speed", PropertyInt.WeaponTime);
            F("offense", PropertyFloat.WeaponOffense);
            F("melee_defense", PropertyFloat.WeaponDefense);
            F("missile_defense", PropertyFloat.WeaponMissileDefense);
            F("magic_defense", PropertyFloat.WeaponMagicDefense);
            F("crit_frequency", PropertyFloat.CriticalFrequency);
            F("crit_multiplier", PropertyFloat.CriticalMultiplier);
            F("ignore_armor", PropertyFloat.IgnoreArmor);
            if (wo.SlayerCreatureType != null) d[prefix + "slayer"] = wo.SlayerCreatureType.ToString();
            F("slayer_bonus", PropertyFloat.SlayerDamageBonus);
            I("workmanship", PropertyInt.ItemWorkmanship);
            I("tinkers", PropertyInt.NumTimesTinkered);
            I("wield_requirement", PropertyInt.WieldDifficulty);
            if (wo.ProcSpell != null) d[prefix + "cast_on_strike"] = SpellName(wo.ProcSpell.Value);

            var cantrips = wo.Biota.GetKnownSpellsIds(wo.BiotaDatabaseLock);
            if (cantrips.Count > 0) d[prefix + "spells"] = string.Join(", ", cantrips.Select(id => SpellName((uint)id)));

            var buffs = wo.Biota.PropertiesEnchantmentRegistry?.Clone(wo.BiotaDatabaseLock);
            if (buffs != null && buffs.Count > 0) d[prefix + "buffs"] = string.Join(", ", buffs.Select(e => SpellName((uint)e.SpellId)));
        }

        private static void AddSkill(Dictionary<string, object> d, Player p, Skill skill)
        {
            if (skill == Skill.None)
                return;
            var cs = p.GetCreatureSkill(skill, false);
            if (cs == null)
                return;
            d["attacker_skill"] = skill.ToString();
            d["attacker_skill_current"] = cs.Current;
            d["attacker_skill_base"] = cs.Base;
        }

        private class DummySession
        {
            public uint CharacterId;
            public string Name;
            public int Level;
            public DateTime Start, Last, LastReport;
            public int Attacks, Hits, Evaded, Resisted, Crits, HitsAtLastReport;
            public long Damage;
            public string Attacker;
            public readonly Dictionary<string, SourceStats> Sources = new Dictionary<string, SourceStats>();
        }

        private readonly object sessionLock = new object();
        private readonly Dictionary<uint, DummySession> sessions = new Dictionary<uint, DummySession>();

        public TrainingDummy(Weenie weenie, ObjectGuid guid) : base(weenie, guid) { Init(); }

        public TrainingDummy(Biota biota) : base(biota) { Init(); }

        private void Init()
        {
            // its own copy of the body parts, so changing its armor doesn't change the cached weenie
            Biota.PropertiesBodyPart = Biota.PropertiesBodyPart.ToDictionary(kv => kv.Key, kv => kv.Value.Clone());
            ApplySetup();
        }

        public override bool EnterWorld()
        {
            if (!base.EnterWorld())
                return false;

            Placed[Guid.Full] = this;

            var guid = Guid.Full;
            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                // its own saved setup, or (first time in the world) the defaults row, dummy_Guid 0, set on the LAN admin page
                var rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery(
                    "SELECT armor, armor_Extremities, melee_Defense, missile_Defense, magic_Defense, damage_Resist_Rating, crit_Damage_Resist_Rating, pk_Damage_Resist_Rating, spells, worn_Items, dummy_Guid FROM training_dummy WHERE dummy_Guid IN (@g, 0) ORDER BY dummy_Guid DESC;",
                    ("@g", guid));

                if (rows == null)
                    return;

                if (rows.Count == 0)
                {
                    // first time in the world and no defaults: save its setup so it shows on the LAN admin page
                    EnqueueAction(new ActionEventDelegate(SaveSetup));
                    return;
                }

                var r = rows[0];
                var fromDefaults = Convert.ToUInt32(r[10]) == 0;
                if (fromDefaults)
                    r[9] = null;   // worn copies aren't part of the defaults

                // the worn items, read from the database here (off the game thread)
                var wornIds = ParseIds(r[9]?.ToString());
                var wornBiotas = new List<ACE.Entity.Models.Biota>();
                foreach (var id in wornIds)
                {
                    var b = DatabaseManager.Shard.BaseDatabase.GetBiota(id, true);
                    if (b != null)
                        wornBiotas.Add(ACE.Database.Adapter.BiotaConverter.ConvertToEntityBiota(b));
                }

                EnqueueAction(new ActionEventDelegate(() =>
                {
                    Armor = Convert.ToInt32(r[0]);
                    ArmorExtremities = Convert.ToInt32(r[1]);
                    MeleeDef = Convert.ToInt32(r[2]);
                    MissileDef = Convert.ToInt32(r[3]);
                    MagicDef = Convert.ToInt32(r[4]);
                    Drr = Convert.ToInt32(r[5]);
                    Cdr = Convert.ToInt32(r[6]);
                    Pkdr = Convert.ToInt32(r[7]);
                    Buffs = ParseIds(r[8]?.ToString());
                    StripAll();
                    foreach (var b in wornBiotas)
                        WearCopy(b, new System.Threading.ReaderWriterLockSlim());
                    ApplySetup();
                    if (fromDefaults)
                        SaveSetup();
                }));
            });

            return true;
        }

        // ---------------------------------------------------------------- setup

        /// <summary>Applies armor, defenses and ratings (buffs are kept up by the heartbeat).</summary>
        public void ApplySetup()
        {
            foreach (var (key, part) in Biota.PropertiesBodyPart)
            {
                var al = IsExtremity(key) ? ArmorExtremities : Armor;
                part.BaseArmor = al;
                part.ArmorVsSlash = part.ArmorVsPierce = part.ArmorVsBludgeon = part.ArmorVsCold = part.ArmorVsFire = part.ArmorVsAcid = part.ArmorVsElectric = part.ArmorVsNether = al;
            }

            SetDefense(Skill.MeleeDefense, MeleeDef);
            SetDefense(Skill.MissileDefense, MissileDef);
            SetDefense(Skill.MagicDefense, MagicDef);

            DamageResistRating = Drr;
            CritDamageResistRating = Cdr;
            PKDamageResistRating = Pkdr;

            RefreshBuffs();
        }

        public static bool IsExtremity(CombatBodyPart part) => part == CombatBodyPart.Head || part == CombatBodyPart.Hand || part == CombatBodyPart.Foot;

        /// <summary>Sets a defense skill's unbuffed value (the part from attributes is taken off).</summary>
        private void SetDefense(Skill skill, int value)
        {
            var cs = GetCreatureSkill(skill);
            cs.AdvancementClass = SkillAdvancementClass.Trained;
            cs.InitLevel = 0;
            var fromAttributes = (int)cs.Base;
            cs.InitLevel = (uint)Math.Max(0, value - fromAttributes);
        }

        public uint DefenseBase(Skill skill) => GetCreatureSkill(skill).Base;
        public uint DefenseCurrent(Skill skill) => GetCreatureSkill(skill).Current;

        /// <summary>Casts any configured buff it doesn't have (they wear off like any buff).</summary>
        public void RefreshBuffs()
        {
            if (CurrentLandblock == null)
                return;

            foreach (var id in Buffs)
            {
                var spell = new Spell(id);
                if (spell.NotFound)
                    continue;

                if (spell.IsImpenBaneType)
                {
                    // armor spells (Impenetrability, banes) go on every piece of armor/clothing it wears, like on a player
                    foreach (var item in WornItems())
                        if (!item.EnchantmentManager.HasSpell(id))
                            CreateEnchantment(item, this, null, spell);
                }
                else if (!EnchantmentManager.HasSpell(id))
                    CreateEnchantment(this, this, null, spell);
            }
        }

        public static List<uint> ParseIds(string csv) =>
            (csv ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries).Select(s => uint.TryParse(s, out var id) ? id : 0).Where(id => id != 0).ToList();

        // ---------------------------------------------------------------- worn items

        /// <summary>Slots a copied item may take: armor, underclothes, jewelry, cloak. Not weapons, shields or held items
        /// (a shield only counts in combat mode, and the dummy never enters it).</summary>
        private const EquipMask WearableSlots = EquipMask.HeadWear | EquipMask.ChestWear | EquipMask.AbdomenWear | EquipMask.UpperArmWear | EquipMask.LowerArmWear |
            EquipMask.HandWear | EquipMask.UpperLegWear | EquipMask.LowerLegWear | EquipMask.FootWear | EquipMask.ChestArmor | EquipMask.AbdomenArmor |
            EquipMask.UpperArmArmor | EquipMask.LowerArmArmor | EquipMask.UpperLegArmor | EquipMask.LowerLegArmor | EquipMask.NeckWear | EquipMask.WristWearLeft |
            EquipMask.WristWearRight | EquipMask.FingerWearLeft | EquipMask.FingerWearRight | EquipMask.TrinketOne | EquipMask.Cloak | EquipMask.SigilOne |
            EquipMask.SigilTwo | EquipMask.SigilThree;

        /// <summary>Underclothes: shirts and pants (chest, abdomen, arm and leg wear slots only).</summary>
        public const EquipMask UnderclothesSlots = EquipMask.ChestWear | EquipMask.AbdomenWear | EquipMask.UpperArmWear | EquipMask.LowerArmWear | EquipMask.UpperLegWear | EquipMask.LowerLegWear;

        public static bool CanCopy(WorldObject item, bool underclothesOnly)
        {
            var loc = item.CurrentWieldedLocation ?? EquipMask.None;
            if (loc == EquipMask.None || (loc & ~WearableSlots) != 0)
                return false;
            return !underclothesOnly || (loc & ~UnderclothesSlots) == 0;
        }

        public List<WorldObject> WornItems() => EquippedObjects.Values.ToList();

        /// <summary>Puts on a copy of an item (every property and spell of the original, so its armor level, resistances,
        /// ratings and cantrips all count). The copy is not saved; the original's guid is kept in WornSources.</summary>
        public bool WearCopy(ACE.Entity.Models.Biota src, System.Threading.ReaderWriterLockSlim srcLock)
        {
            var copy = Factories.WorldObjectFactory.CreateNewWorldObject(src.WeenieClassId);
            if (copy == null)
                return false;

            var sourceGuid = src.Id;

            EquipMask loc;
            srcLock.EnterReadLock();
            try
            {
                if (src.PropertiesInt != null)
                    foreach (var kv in src.PropertiesInt)
                        copy.SetProperty(kv.Key, kv.Value);
                if (src.PropertiesInt64 != null)
                    foreach (var kv in src.PropertiesInt64)
                        copy.SetProperty(kv.Key, kv.Value);
                if (src.PropertiesBool != null)
                    foreach (var kv in src.PropertiesBool)
                        copy.SetProperty(kv.Key, kv.Value);
                if (src.PropertiesFloat != null)
                    foreach (var kv in src.PropertiesFloat)
                        copy.SetProperty(kv.Key, kv.Value);
                if (src.PropertiesString != null)
                    foreach (var kv in src.PropertiesString)
                        copy.SetProperty(kv.Key, kv.Value);
                if (src.PropertiesDID != null)
                    foreach (var kv in src.PropertiesDID)
                        copy.SetProperty(kv.Key, kv.Value);
                if (src.PropertiesSpellBook != null)
                    foreach (var spellId in src.PropertiesSpellBook.Keys)
                        copy.Biota.GetOrAddKnownSpell(spellId, copy.BiotaDatabaseLock, out _);

                loc = (EquipMask)(src.PropertiesInt != null && src.PropertiesInt.TryGetValue(PropertyInt.CurrentWieldedLocation, out var l) ? l : 0);
            }
            finally
            {
                srcLock.ExitReadLock();
            }

            copy.RemoveProperty(PropertyInt.CurrentWieldedLocation);

            // whatever it already wears in those slots comes off first
            foreach (var old in WornItems().Where(w => ((w.CurrentWieldedLocation ?? EquipMask.None) & loc) != 0))
                TakeOff(old);

            if (loc == EquipMask.None || !TryWieldObject(copy, loc))
            {
                copy.Destroy();
                return false;
            }

            wornFrom[copy.Guid] = sourceGuid;
            return true;
        }

        private void TakeOff(WorldObject item)
        {
            wornFrom.Remove(item.Guid);
            if (TryDequipObject(item.Guid, out var wo, out _))
                wo.Destroy();
        }

        /// <summary>Takes off and deletes the worn copies in these slots (all of them when null).</summary>
        public int Strip(EquipMask? slots = null)
        {
            var items = WornItems().Where(w => slots == null || ((w.CurrentWieldedLocation ?? EquipMask.None) & slots.Value) != 0).ToList();
            foreach (var item in items)
                TakeOff(item);
            return items.Count;
        }

        public string DescribeWorn()
        {
            var items = WornItems();
            if (items.Count == 0)
                return "nothing";
            return string.Join(", ", items.Select(i => $"{i.Name}{(i.ArmorLevel > 0 ? $" (AL {i.ArmorLevel})" : "")}")) +
                   $"; gear ratings: damage resist {GetEquippedItemsRatingSum(PropertyInt.GearDamageResist)}, crit damage resist {GetEquippedItemsRatingSum(PropertyInt.GearCritDamageResist)}, " +
                   $"crit resist {GetEquippedItemsRatingSum(PropertyInt.GearCritResist)}, PK damage resist {GetEquippedItemsRatingSum(PropertyInt.GearPKDamageResistRating)}";
        }

        public int StripAll() => Strip(null);

        public void SaveSetup()
        {
            var guid = Guid.Full;
            var (armor, ext, mel, mis, mag, drr, cdr, pkdr, spells) = (Armor, ArmorExtremities, MeleeDef, MissileDef, MagicDef, Drr, Cdr, Pkdr, string.Join(",", Buffs));
            var worn = string.Join(",", WornSources);
            var description = DescribeSetup();
            if (description.Length > 2000) description = description.Substring(0, 2000);

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                @"INSERT INTO training_dummy (dummy_Guid, armor, armor_Extremities, melee_Defense, missile_Defense, magic_Defense, damage_Resist_Rating, crit_Damage_Resist_Rating, pk_Damage_Resist_Rating, spells, worn_Items, description, updated_At)
                  VALUES (@g, @a, @x, @me, @mi, @ma, @d, @c, @p, @s, @w, @desc, @t)
                  ON DUPLICATE KEY UPDATE armor = @a, armor_Extremities = @x, melee_Defense = @me, missile_Defense = @mi, magic_Defense = @ma, damage_Resist_Rating = @d,
                      crit_Damage_Resist_Rating = @c, pk_Damage_Resist_Rating = @p, spells = @s, worn_Items = @w, description = @desc, updated_At = @t;",
                ("@g", guid), ("@a", armor), ("@x", ext), ("@me", mel), ("@mi", mis), ("@ma", mag), ("@d", drr), ("@c", cdr), ("@p", pkdr), ("@s", spells), ("@w", worn), ("@desc", description), ("@t", DateTime.UtcNow)));
        }

        /// <summary>Spells from a comma-separated list of names, ids and presets (pvp7, pvp8, armor7, armor8).</summary>
        public static List<uint> ResolveBuffs(string text, List<string> missing)
        {
            var ids = new List<uint>();
            foreach (var part in (text ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                var names = ACE.Server.Command.Handlers.TrainingDummyCommands.Preset(part) ?? new[] { part };
                foreach (var n in names)
                {
                    var id = FindSpell(n);
                    if (id == null) missing.Add(n);
                    else if (!ids.Contains(id.Value)) ids.Add(id.Value);
                }
            }
            return ids;
        }

        /// <summary>A change from the LAN admin page (on this dummy's thread). Returns what happened.</summary>
        public string ApplyWebRequest(JsonElement req, List<uint> buffs, bool replaceBuffs)
        {
            int Int(string name, int current) => req.TryGetProperty(name, out var v) && v.TryGetInt32(out var i) && i >= 0 ? i : current;

            Armor = Int("armor", Armor);
            ArmorExtremities = Int("armor_extremities", ArmorExtremities);
            MeleeDef = Int("melee_defense", MeleeDef);
            MissileDef = Int("missile_defense", MissileDef);
            MagicDef = Int("magic_defense", MagicDef);
            Drr = Int("damage_resist_rating", Drr);
            Cdr = Int("crit_damage_resist_rating", Cdr);
            Pkdr = Int("pk_damage_resist_rating", Pkdr);

            if (buffs != null)
            {
                if (replaceBuffs)
                {
                    foreach (var id in Buffs.Where(b => !buffs.Contains(b)).ToList())
                    {
                        var e = EnchantmentManager.GetEnchantment(id);
                        if (e != null) EnchantmentManager.Remove(e);
                        foreach (var item in WornItems())
                        {
                            var ie = item.EnchantmentManager.GetEnchantment(id);
                            if (ie != null) item.EnchantmentManager.Remove(ie);
                        }
                    }
                    Buffs = buffs;
                }
                else
                    foreach (var id in buffs.Where(b => !Buffs.Contains(b)))
                        Buffs.Add(id);
            }

            var worn = req.TryGetProperty("worn", out var w) ? w.GetString() : "keep";
            if (worn == "strip") StripAll();
            else if (worn == "strip_under") Strip(UnderclothesSlots);

            if (req.TryGetProperty("clean", out var c) && c.ValueKind == JsonValueKind.True)
                EnchantmentManager.RemoveAllBadEnchantments();

            ApplySetup();
            SaveSetup();
            return "applied";
        }

        public static string SpellName(uint id) => new Spell(id) is var s && !s.NotFound ? s.Name : $"spell {id}";

        /// <summary>What a player sees in chat when they ID it: buffed armor level per body part, defenses and active buffs.</summary>
        public string DescribeForAppraisal()
        {
            var al = new ACE.Server.Network.Structure.ArmorLevel(this);
            static string A(uint v) => v >= 9999 ? $"{v - 9999}*" : v.ToString();
            var active = Buffs.Where(id => EnchantmentManager.GetEnchantment(id) != null).Select(SpellName).ToList();
            return $"{Name} armor (buffed): head {A(al.Head)}, chest {A(al.Chest)}, abdomen {A(al.Abdomen)}, upper arm {A(al.UpperArm)}, lower arm {A(al.LowerArm)}, " +
                   $"hands {A(al.Hand)}, upper leg {A(al.UpperLeg)}, lower leg {A(al.LowerLeg)}, feet {A(al.Foot)}. " +
                   $"Defense (buffed): melee {DefenseCurrent(Skill.MeleeDefense)}, missile {DefenseCurrent(Skill.MissileDefense)}, magic {DefenseCurrent(Skill.MagicDefense)}. " +
                   $"Ratings: damage resist {Drr}, crit damage resist {Cdr}, PK damage resist {Pkdr}. " +
                   $"Buffs on it: {(active.Count == 0 ? "none" : string.Join(", ", active))}.";
        }

        public string DescribeSetup()
        {
            var buffs = Buffs.Count == 0 ? "none" : string.Join(", ", Buffs.Select(SpellName));
            return $"armor {Armor} (head, hands, feet {ArmorExtremities}), melee defense {MeleeDef}, missile defense {MissileDef}, magic defense {MagicDef}, " +
                   $"damage resist rating {Drr}, crit damage resist rating {Cdr}, PK damage resist rating {Pkdr}, buffs: {buffs}; wearing: {DescribeWorn()}";
        }

        /// <summary>Finds a spell by id or exact name (case does not matter).</summary>
        public static uint? FindSpell(string text)
        {
            text = text.Trim();
            if (uint.TryParse(text, out var id))
                return new Spell(id).NotFound ? null : id;

            // SpellId names too (e.g. Impenetrability8)
            if (Enum.TryParse<SpellId>(text, true, out var named) && !int.TryParse(text, out _) && !new Spell((uint)named).NotFound)
                return (uint)named;

            foreach (var kv in DatManager.PortalDat.SpellTable.Spells)
                if (string.Equals(kv.Value.Name, text, StringComparison.OrdinalIgnoreCase))
                    return kv.Key;

            return null;
        }

        // ---------------------------------------------------------------- recording

        private DummySession SessionFor(Player p)
        {
            var now = DateTime.UtcNow;
            if (!sessions.TryGetValue(p.Guid.Full, out var s))
            {
                s = new DummySession { CharacterId = p.Guid.Full, Name = p.Name, Level = p.Level ?? 0, Start = now, LastReport = now };
                sessions[p.Guid.Full] = s;
                p.Session?.Network.EnqueueSend(new GameMessageSystemChat($"[{Name}] Recording your damage. Setup: {DescribeSetup()}. Report 15 seconds after your last hit.", ChatMessageType.Broadcast));
            }
            s.Last = now;
            s.Attacker = AttackerSkills(p);
            return s;
        }

        private static string AttackerSkills(Player p)
        {
            var parts = new List<string>();
            var weaponSkill = p.GetCurrentWeaponSkill();
            if (weaponSkill != Skill.None)
                parts.Add($"{weaponSkill} {p.GetCreatureSkill(weaponSkill).Current}");
            foreach (var sk in new[] { Skill.WarMagic, Skill.VoidMagic })
            {
                var cs = p.GetCreatureSkill(sk, false);
                if (cs != null && cs.AdvancementClass >= SkillAdvancementClass.Trained)
                    parts.Add($"{sk} {cs.Current}");
            }
            return string.Join(", ", parts);
        }

        private static SourceStats Src(DummySession s, string key)
        {
            if (!s.Sources.TryGetValue(key, out var st))
                s.Sources[key] = st = new SourceStats();
            return st;
        }

        private static void AddHit(DummySession s, SourceStats st, uint amount, bool crit)
        {
            s.Hits++; st.Hits++;
            s.Damage += amount; st.Damage += amount;
            st.Min = Math.Min(st.Min, amount); st.Max = Math.Max(st.Max, amount);
            if (crit) { s.Crits++; st.Crits++; }
        }

        /// <summary>A melee or missile attack (hit or evaded).</summary>
        public void RecordAttack(Player p, DamageEvent de, WorldObject damageSource)
        {
            if (p == null || de == null || de.GeneralFailure)
                return;

            lock (sessionLock)
            {
                var s = SessionFor(p);
                var weapon = de.Weapon;
                var ammo = damageSource != null && damageSource != weapon && damageSource != p ? damageSource : null;
                var st = Src(s, $"w{weapon?.Guid.Full ?? 0}:{ammo?.WeenieClassId ?? 0}");

                if (st.Info == null)
                {
                    st.Label = (weapon?.Name ?? "Unarmed") + (ammo != null ? $" + {ammo.Name}" : "");
                    st.Info = new Dictionary<string, object> { ["kind"] = weapon == null ? "unarmed" : ammo != null ? "missile" : "melee" };
                    AddItemStats(st.Info, "", weapon);
                    AddItemStats(st.Info, "ammo_", ammo);
                    AddSkill(st.Info, p, weapon?.WeaponSkill ?? p.GetCurrentWeaponSkill());
                    st.Info["combat_mode"] = p.CombatMode.ToString();
                }

                s.Attacks++; st.Attacks++;

                if (de.Evaded)
                {
                    s.Evaded++; st.Misses++;
                }
                else if (de.HasDamage)
                {
                    AddHit(s, st, (uint)Math.Round(de.Damage), de.IsCritical);
                    var dt = de.DamageType.ToString();
                    st.DamageTypes[dt] = st.DamageTypes.TryGetValue(dt, out var n) ? n + 1 : 1;
                }
            }

            SetMaxVitals();
        }

        /// <summary>A war, void or life projectile (hit or resisted).</summary>
        public void RecordSpell(Player p, Spell spell, uint amount, bool crit, bool resisted, WorldObject launcher = null)
        {
            if (p == null || spell == null)
                return;

            lock (sessionLock)
            {
                var s = SessionFor(p);
                var st = Src(s, $"s{spell.Id}:{launcher?.Guid.Full ?? 0}");

                if (st.Info == null)
                {
                    st.Label = spell.Name + (launcher != null && launcher != p ? $" ({launcher.Name})" : "");
                    st.Info = new Dictionary<string, object>
                    {
                        ["kind"] = spell.School.ToString(),
                        ["spell"] = spell.Name,
                        ["spell_id"] = spell.Id,
                        ["spell_level"] = spell.Level,
                        ["spell_shape"] = SpellProjectile.GetProjectileSpellType(spell.Id).ToString(),
                        ["damage_type"] = spell.DamageType.ToString(),
                    };
                    if (launcher != null && launcher != p)
                        AddItemStats(st.Info, "caster_", launcher);
                    AddSkill(st.Info, p, spell.School switch
                    {
                        MagicSchool.WarMagic => Skill.WarMagic,
                        MagicSchool.VoidMagic => Skill.VoidMagic,
                        MagicSchool.LifeMagic => Skill.LifeMagic,
                        MagicSchool.CreatureEnchantment => Skill.CreatureEnchantment,
                        _ => Skill.None
                    });
                }

                s.Attacks++; st.Attacks++;

                if (resisted) { s.Resisted++; st.Misses++; }
                else AddHit(s, st, amount, crit);
            }

            SetMaxVitals();
        }

        /// <summary>A damage-over-time tick (counted as damage, not as an attack).</summary>
        public void RecordDot(Player p, DamageType damageType, float amount)
        {
            if (p == null)
                return;

            lock (sessionLock)
            {
                if (!sessions.ContainsKey(p.Guid.Full))
                    return; // only while that player is attacking

                var s = SessionFor(p);
                var st = Src(s, $"dot:{damageType}");
                if (st.Info == null)
                {
                    st.Label = $"DoT ({damageType})";
                    st.Info = new Dictionary<string, object> { ["kind"] = "dot", ["damage_type"] = damageType.ToString() };
                    if (damageType == DamageType.Nether)
                        AddSkill(st.Info, p, Skill.VoidMagic);
                }
                var a = (uint)Math.Round(amount);
                st.Hits++; st.Damage += a; s.Damage += a;
                st.Min = Math.Min(st.Min, a); st.Max = Math.Max(st.Max, a);
            }

            SetMaxVitals();
        }

        public bool ResetSession(uint characterId)
        {
            lock (sessionLock)
                return sessions.Remove(characterId);
        }

        // ---------------------------------------------------------------- reports

        public override void Heartbeat(double currentUnixTime)
        {
            base.Heartbeat(currentUnixTime);

            RefreshBuffs();

            if (Health.Current < Health.MaxValue)
                SetMaxVitals();

            var now = DateTime.UtcNow;
            var finished = new List<DummySession>();
            var interim = new List<(DummySession s, string line)>();

            lock (sessionLock)
            {
                foreach (var s in sessions.Values.ToList())
                {
                    if ((now - s.Last).TotalSeconds >= 15)
                    {
                        finished.Add(s);
                        sessions.Remove(s.CharacterId);
                    }
                    else if ((now - s.LastReport).TotalSeconds >= 10 && s.Hits > s.HitsAtLastReport)
                    {
                        s.LastReport = now;
                        s.HitsAtLastReport = s.Hits;
                        interim.Add((s, $"[{Name}] {Seconds(s):0}s: {s.Damage:N0} damage, {Dps(s):N1} DPS, {s.Hits} hits, crits {Pct(s.Crits, s.Hits)}, evaded {Pct(s.Evaded, s.Attacks)}, resisted {Pct(s.Resisted, s.Attacks)}"));
                    }
                }
            }

            foreach (var (s, line) in interim)
                PlayerManager.GetOnlinePlayer(s.CharacterId)?.Session?.Network.EnqueueSend(new GameMessageSystemChat(line, ChatMessageType.Broadcast));

            foreach (var s in finished)
                Finish(s);
        }

        private static double Seconds(DummySession s) => Math.Max(1.0, (s.Last - s.Start).TotalSeconds);
        private static double Dps(DummySession s) => s.Damage / Seconds(s);
        private static string Pct(int n, int of) => of == 0 ? "0%" : $"{100.0 * n / of:0.#}%";

        private string SourceLines(DummySession s) => string.Join("\n", s.Sources.OrderByDescending(kv => kv.Value.Damage).Select(kv =>
        {
            var st = kv.Value;
            var avg = st.Hits > 0 ? st.Damage / (double)st.Hits : 0;
            return $"  {st.Label ?? kv.Key}: {st.Damage:N0} damage, {st.Hits} hits" +
                   (st.Hits > 0 ? $", avg {avg:N1} (min {st.Min:N0}, max {st.Max:N0})" : "") +
                   (st.Crits > 0 ? $", {st.Crits} crits" : "") +
                   (st.Misses > 0 ? $", {st.Misses} evaded/resisted" : "");
        }));

        private void Finish(DummySession s)
        {
            if (s.Attacks == 0 && s.Damage == 0)
                return;

            var sources = SourceLines(s);
            var report = $"[{Name}] Final: {s.Damage:N0} damage in {Seconds(s):0.0}s = {Dps(s):N1} DPS. {s.Attacks} attacks, {s.Hits} hits, " +
                         $"crits {Pct(s.Crits, s.Hits)}, evaded {Pct(s.Evaded, s.Attacks)}, resisted {Pct(s.Resisted, s.Attacks)}.\n{sources}";

            PlayerManager.GetOnlinePlayer(s.CharacterId)?.Session?.Network.EnqueueSend(new GameMessageSystemChat(report, ChatMessageType.Broadcast));

            var setup = $"{DescribeSetup()}; attacker: {s.Attacker}";
            var sourcesJson = JsonSerializer.Serialize(s.Sources.Values.OrderByDescending(v => v.Damage).Select(v =>
            {
                var row = new Dictionary<string, object>(v.Info ?? new Dictionary<string, object>())
                {
                    ["label"] = v.Label,
                    ["attacks"] = v.Attacks,
                    ["hits"] = v.Hits,
                    ["misses"] = v.Misses,
                    ["crits"] = v.Crits,
                    ["damage_total"] = v.Damage,
                    ["min"] = v.Hits > 0 ? v.Min : 0,
                    ["max"] = v.Max,
                    ["avg"] = v.Hits > 0 ? Math.Round(v.Damage / (double)v.Hits, 2) : 0,
                    ["damage_types"] = v.DamageTypes,
                };
                return row;
            }).ToList());
            var settings = JsonSerializer.Serialize(PvpSettingsSnapshot());
            var guid = Guid.Full;
            var (start, end, secs, dps) = (s.Start, s.Last, Seconds(s), Dps(s));

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                @"INSERT INTO training_dummy_session (started_At, ended_At, dummy_Guid, character_Id, character_Name, character_Level, seconds, attacks, hits, evaded, resisted, crits, damage, dps, dummy_Setup, sources, settings, sources_json)
                  VALUES (@s, @e, @g, @ci, @cn, @cl, @sec, @a, @h, @ev, @r, @c, @d, @dps, @setup, @src, @set, @sj);",
                ("@s", start), ("@e", end), ("@g", guid), ("@ci", s.CharacterId), ("@cn", s.Name), ("@cl", s.Level), ("@sec", secs),
                ("@a", s.Attacks), ("@h", s.Hits), ("@ev", s.Evaded), ("@r", s.Resisted), ("@c", s.Crits), ("@d", s.Damage), ("@dps", dps),
                ("@setup", setup.Length > 1024 ? setup.Substring(0, 1024) : setup), ("@src", sources), ("@set", settings), ("@sj", sourcesJson)));
        }

        /// <summary>Every PvP setting in effect right now (doubles, longs and bools whose name has "pvp").</summary>
        public static SortedDictionary<string, object> PvpSettingsSnapshot()
        {
            var d = new SortedDictionary<string, object>();
            foreach (var k in DefaultPropertyManager.DefaultDoubleProperties.Keys.Where(k => k.Contains("pvp")))
                d[k] = PropertyManager.GetDouble(k).Item;
            foreach (var k in DefaultPropertyManager.DefaultLongProperties.Keys.Where(k => k.Contains("pvp")))
                d[k] = PropertyManager.GetLong(k).Item;
            foreach (var k in DefaultPropertyManager.DefaultBooleanProperties.Keys.Where(k => k.Contains("pvp")))
                d[k] = PropertyManager.GetBool(k).Item;
            return d;
        }
    }
}
