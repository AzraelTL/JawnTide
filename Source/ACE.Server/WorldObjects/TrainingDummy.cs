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


        public int Armor = 0;
        public int MeleeDef = 0;
        public int MissileDef = 0;
        public int MagicDef = 0;
        public int Drr = 0;
        public int Cdr = 0;
        public int Pkdr = 0;
        public List<uint> Buffs = new List<uint>();

        private class SourceStats
        {
            public int Attacks, Hits, Misses, Crits;
            public long Damage;
            public uint Min = uint.MaxValue, Max;
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

            var guid = Guid.Full;
            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery(
                    "SELECT armor, melee_Defense, missile_Defense, magic_Defense, damage_Resist_Rating, crit_Damage_Resist_Rating, pk_Damage_Resist_Rating, spells FROM training_dummy WHERE dummy_Guid = @g;",
                    ("@g", guid));

                if (rows == null || rows.Count == 0)
                    return;

                var r = rows[0];
                EnqueueAction(new ActionEventDelegate(() =>
                {
                    Armor = Convert.ToInt32(r[0]);
                    MeleeDef = Convert.ToInt32(r[1]);
                    MissileDef = Convert.ToInt32(r[2]);
                    MagicDef = Convert.ToInt32(r[3]);
                    Drr = Convert.ToInt32(r[4]);
                    Cdr = Convert.ToInt32(r[5]);
                    Pkdr = Convert.ToInt32(r[6]);
                    Buffs = (r[7]?.ToString() ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries).Select(s => uint.TryParse(s, out var id) ? id : 0).Where(id => id != 0).ToList();
                    ApplySetup();
                }));
            });

            return true;
        }

        // ---------------------------------------------------------------- setup

        /// <summary>Applies armor, defenses and ratings (buffs are kept up by the heartbeat).</summary>
        public void ApplySetup()
        {
            foreach (var part in Biota.PropertiesBodyPart.Values)
            {
                part.BaseArmor = Armor;
                part.ArmorVsSlash = part.ArmorVsPierce = part.ArmorVsBludgeon = part.ArmorVsCold = part.ArmorVsFire = part.ArmorVsAcid = part.ArmorVsElectric = part.ArmorVsNether = Armor;
            }

            SetDefense(Skill.MeleeDefense, MeleeDef);
            SetDefense(Skill.MissileDefense, MissileDef);
            SetDefense(Skill.MagicDefense, MagicDef);

            DamageResistRating = Drr;
            CritDamageResistRating = Cdr;
            PKDamageResistRating = Pkdr;

            RefreshBuffs();
        }

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
                if (EnchantmentManager.HasSpell(id))
                    continue;

                var spell = new Spell(id);
                if (!spell.NotFound)
                    CreateEnchantment(this, this, null, spell);
            }
        }

        public void SaveSetup()
        {
            var guid = Guid.Full;
            var (armor, mel, mis, mag, drr, cdr, pkdr, spells) = (Armor, MeleeDef, MissileDef, MagicDef, Drr, Cdr, Pkdr, string.Join(",", Buffs));

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                @"INSERT INTO training_dummy (dummy_Guid, armor, melee_Defense, missile_Defense, magic_Defense, damage_Resist_Rating, crit_Damage_Resist_Rating, pk_Damage_Resist_Rating, spells, updated_At)
                  VALUES (@g, @a, @me, @mi, @ma, @d, @c, @p, @s, @t)
                  ON DUPLICATE KEY UPDATE armor = @a, melee_Defense = @me, missile_Defense = @mi, magic_Defense = @ma, damage_Resist_Rating = @d,
                      crit_Damage_Resist_Rating = @c, pk_Damage_Resist_Rating = @p, spells = @s, updated_At = @t;",
                ("@g", guid), ("@a", armor), ("@me", mel), ("@mi", mis), ("@ma", mag), ("@d", drr), ("@c", cdr), ("@p", pkdr), ("@s", spells), ("@t", DateTime.UtcNow)));
        }

        public static string SpellName(uint id) => new Spell(id) is var s && !s.NotFound ? s.Name : $"spell {id}";

        public string DescribeSetup()
        {
            var buffs = Buffs.Count == 0 ? "none" : string.Join(", ", Buffs.Select(SpellName));
            return $"armor {Armor}, melee defense {MeleeDef}, missile defense {MissileDef}, magic defense {MagicDef}, " +
                   $"damage resist rating {Drr}, crit damage resist rating {Cdr}, PK damage resist rating {Pkdr}, buffs: {buffs}";
        }

        /// <summary>Finds a spell by id or exact name (case does not matter).</summary>
        public static uint? FindSpell(string text)
        {
            text = text.Trim();
            if (uint.TryParse(text, out var id))
                return new Spell(id).NotFound ? null : id;

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
                var weapon = de.Weapon?.Name ?? "Unarmed";
                var st = Src(s, $"{weapon} ({de.DamageType})");
                s.Attacks++; st.Attacks++;

                if (de.Evaded)
                {
                    s.Evaded++; st.Misses++;
                }
                else if (de.HasDamage)
                    AddHit(s, st, (uint)Math.Round(de.Damage), de.IsCritical);
            }

            SetMaxVitals();
        }

        /// <summary>A war, void or life projectile (hit or resisted).</summary>
        public void RecordSpell(Player p, Spell spell, uint amount, bool crit, bool resisted)
        {
            if (p == null || spell == null)
                return;

            lock (sessionLock)
            {
                var s = SessionFor(p);
                var st = Src(s, spell.Name);
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
                var st = Src(s, $"DoT ({damageType})");
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
            return $"  {kv.Key}: {st.Damage:N0} damage, {st.Hits} hits" +
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
            var settings = JsonSerializer.Serialize(PvpSettingsSnapshot());
            var guid = Guid.Full;
            var (start, end, secs, dps) = (s.Start, s.Last, Seconds(s), Dps(s));

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                @"INSERT INTO training_dummy_session (started_At, ended_At, dummy_Guid, character_Id, character_Name, character_Level, seconds, attacks, hits, evaded, resisted, crits, damage, dps, dummy_Setup, sources, settings)
                  VALUES (@s, @e, @g, @ci, @cn, @cl, @sec, @a, @h, @ev, @r, @c, @d, @dps, @setup, @src, @set);",
                ("@s", start), ("@e", end), ("@g", guid), ("@ci", s.CharacterId), ("@cn", s.Name), ("@cl", s.Level), ("@sec", secs),
                ("@a", s.Attacks), ("@h", s.Hits), ("@ev", s.Evaded), ("@r", s.Resisted), ("@c", s.Crits), ("@d", s.Damage), ("@dps", dps),
                ("@setup", setup.Length > 1024 ? setup.Substring(0, 1024) : setup), ("@src", sources), ("@set", settings)));
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
