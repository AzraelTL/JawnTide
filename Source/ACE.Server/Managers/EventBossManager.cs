using System;
using System.Collections.Generic;
using System.Linq;

using log4net;

using ACE.Common;
using ACE.Database;
using ACE.DatLoader;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Server.Command.Handlers;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.Network.Handlers;
using ACE.Server.WorldObjects;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide live events: an admin plays the boss. "@eventboss on" turns the admin's current (dedicated)
    /// character into the event boss: every skill specialized and maxed, attributes maxed, boss-sized health and mana,
    /// every spell known, no spell components needed, scaled up. "/minions" summons server-controlled helpers that
    /// never attack the boss. When the boss dies: everyone in the landblock gets a participation reward, the top
    /// damager gets a corpse full of loot only they can open, and reward boxes drop around the body for the box NPC.
    /// See Ops/events/README.md.
    /// </summary>
    public static class EventBossManager
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static readonly object locker = new object();

        private static uint? bossGuid;
        private static float? bossOriginalScale;
        private static DateTime lastSummon = DateTime.MinValue;
        private static readonly List<Creature> minions = new List<Creature>();
        private static readonly HashSet<uint> rewardLoot = new HashSet<uint>();

        public static bool IsActive { get { lock (locker) return bossGuid.HasValue; } }

        public static bool IsBoss(Player player)
        {
            if (player == null) return false;
            lock (locker) return bossGuid == player.Guid.Full;
        }

        /// <summary>
        /// True if this guid is the current event boss. Used so a player killed by the boss dies like a monster kill:
        /// no PK respite (stays red), no PK Trophy drop, no PK kill broadcast or PvP stats
        /// </summary>
        public static bool IsBossGuid(uint? guid)
        {
            if (!guid.HasValue) return false;
            lock (locker) return bossGuid == guid.Value;
        }

        private static long L(string key) => PropertyManager.GetLong(key).Item;

        /// <summary>
        /// A reward box dropped by the event boss, lying in the world (its Quest property limits pickups per character)
        /// </summary>
        public static bool IsRewardBox(WorldObject item) => item != null && item.WeenieClassId == (uint)L("event_boss_reward_box_wcid");

        /// <summary>
        /// True if this item is part of the loot an event boss scattered on the ground when it died
        /// </summary>
        public static bool IsRewardLoot(WorldObject item)
        {
            if (item == null) return false;
            lock (locker) return rewardLoot.Contains(item.Guid.Full);
        }

        /// <summary>
        /// Event prizes (Shadow Spoils Boxes and the boss's loot lying on the ground) can only be
        /// claimed by a player who is red (PK) right now, so not while white during the PK respite timer
        /// </summary>
        public static bool CanClaimPrize(Player player, WorldObject item, Container rootOwner)
        {
            if (player == null || player.IsPK) return true;

            var isPrize = rootOwner != player && (IsRewardBox(item) || IsRewardLoot(item));

            return !isPrize;
        }

        // ---- permanent boss characters (event_boss_characters): they become the event boss whenever they log in ----

        private static HashSet<uint> PermanentBosses()
        {
            var set = new HashSet<uint>();
            foreach (var part in (PropertyManager.GetString("event_boss_characters").Item ?? "").Split(','))
                if (uint.TryParse(part.Trim(), out var guid))
                    set.Add(guid);
            return set;
        }

        private static void SavePermanentBosses(HashSet<uint> set)
        {
            PropertyManager.ModifyString("event_boss_characters", string.Join(",", set.OrderBy(g => g)));
        }

        public static bool IsPermanentBoss(Player player) => player != null && PermanentBosses().Contains(player.Guid.Full);

        /// <summary>
        /// @eventboss make: this character is a boss character from now on (it becomes the event boss on every login)
        /// </summary>
        public static void MakePermanent(Player boss)
        {
            var set = PermanentBosses();
            set.Add(boss.Guid.Full);
            SavePermanentBosses(set);
            boss.Session.Network.EnqueueSend(new GameMessageSystemChat($"{boss.Name} is now a permanent event boss character: it becomes the event boss every time it logs in.", ChatMessageType.Broadcast));
            Start(boss);
        }

        /// <summary>
        /// @eventboss unmake: back to an ordinary character (its boss stats stay)
        /// </summary>
        public static void UnmakePermanent(Player boss)
        {
            var set = PermanentBosses();
            if (set.Remove(boss.Guid.Full))
                SavePermanentBosses(set);
            boss.Session.Network.EnqueueSend(new GameMessageSystemChat($"{boss.Name} is no longer a permanent event boss character.", ChatMessageType.Broadcast));
            if (IsBoss(boss))
                Stop(boss, true);
        }

        public static string ListPermanent()
        {
            var names = PermanentBosses().Select(g => PlayerManager.FindByGuid(g)?.Name ?? $"0x{g:X8}");
            var list = string.Join(", ", names);
            return string.IsNullOrEmpty(list) ? "No permanent event boss characters." : $"Permanent event boss characters: {list}";
        }

        /// <summary>
        /// Called on login: a permanent boss character is reminded how to start the event (it no longer starts by itself,
        /// so the boss can get into position first)
        /// </summary>
        public static void OnLogin(Player player)
        {
            if (!IsPermanentBoss(player))
                return;

            var chain = new ActionChain();
            chain.AddDelaySeconds(5.0f);
            chain.AddAction(player, () =>
            {
                if (player.IsLoggingOut || player.Session == null)
                    return;
                player.Session.Network.EnqueueSend(new GameMessageSystemChat("You are a boss character. Get into position, then type /startevent to begin (/endevent to stop without rewards).", ChatMessageType.Broadcast));
            });
            chain.EnqueueChain();
        }

        /// <summary>
        /// /startevent: a permanent boss character starts the event where it stands
        /// </summary>
        public static void StartEventCommand(Player player)
        {
            if (IsBoss(player))
            {
                player.Session.Network.EnqueueSend(new GameMessageSystemChat("The event is already running.", ChatMessageType.Broadcast));
                return;
            }
            if (IsActive)
            {
                player.Session.Network.EnqueueSend(new GameMessageSystemChat("Another event boss is already active.", ChatMessageType.Broadcast));
                return;
            }
            if (!IsPermanentBoss(player))
            {
                player.Session.Network.EnqueueSend(new GameMessageSystemChat("This is not a boss character. Use @eventboss make first (or @eventboss on for a one-off).", ChatMessageType.Broadcast));
                return;
            }
            Start(player, true);
        }

        /// <summary>
        /// Called on logout: the event ends without rewards
        /// </summary>
        public static void OnLogout(Player player)
        {
            if (IsBoss(player))
                Stop(player, true);
        }

        public static void Start(Player boss, bool fromLogin = false)
        {
            lock (locker)
            {
                if (bossGuid.HasValue && bossGuid != boss.Guid.Full)
                {
                    boss.Session.Network.EnqueueSend(new GameMessageSystemChat("Another character is already the event boss. Use @eventboss off on it first.", ChatMessageType.Broadcast));
                    return;
                }
                bossGuid = boss.Guid.Full;
                lastSummon = DateTime.MinValue;
            }

            MakeBossStats(boss);

            if (!bossOriginalScale.HasValue)
                bossOriginalScale = boss.ObjScale ?? 1.0f;
            boss.ObjScale = (float)PropertyManager.GetDouble("event_boss_scale").Item;
            // others see the new size right away; the boss's own client is refreshed by the relog below
            // (re-sending a player's own object to its client is what left wields and inventory moves stuck)
            boss.EnqueueBroadcast(false, new GameMessageUpdateObject(boss));

            boss.SetMaxVitals();
            boss.PlayParticleEffect(PlayScript.BaelZharonSmite, boss.Guid);

            if (!fromLogin)
                boss.Session.Network.EnqueueSend(new GameMessageSystemChat("You are the event boss. Log out and back in now so your client picks up all your new skills and spells, then start the fight.", ChatMessageType.Broadcast));
            else
                boss.Session.Network.EnqueueSend(new GameMessageSystemChat("You are the event boss.", ChatMessageType.Broadcast));

            Announce($"{boss.Name} has appeared! Gather your allies and bring it down. Everyone nearby when it falls will be rewarded.");
            log.Info($"[EVENTBOSS] {boss.Name} (0x{boss.Guid}) is now the event boss");
        }

        /// <summary>
        /// Every skill trained and specialized with event_boss_skill_ranks ranks; all attributes 100 innate plus
        /// event_boss_attribute_ranks ranks; boss health and mana.
        /// Permanent on the character, so use a dedicated boss character.
        /// </summary>
        private static void MakeBossStats(Player boss)
        {
            // how strong: ranks bought in every skill (max 226) and attribute (max 190); settings, so each boss type
            // can be tuned live (use @eventboss on again to apply)
            var specXpList = DatManager.PortalDat.XpTable.SpecializedSkillXpList;
            var skillRanks = (int)Math.Clamp(L("event_boss_skill_ranks"), 0, specXpList.Count - 1);
            var skillXp = specXpList[skillRanks];
            var attrXpList = DatManager.PortalDat.XpTable.AttributeXpList;
            var attrRanks = (int)Math.Clamp(L("event_boss_attribute_ranks"), 0, attrXpList.Count - 1);
            var attrXp = attrXpList[attrRanks];
            var vitalXpList = DatManager.PortalDat.XpTable.VitalXpList;
            var maxVitalXp = vitalXpList[vitalXpList.Count - 1];

            foreach (var skill in SkillHelper.ValidSkills)
            {
                var cs = boss.GetCreatureSkill(skill);
                cs.AdvancementClass = SkillAdvancementClass.Specialized;
                cs.InitLevel = 10;
                cs.ExperienceSpent = skillXp;
                cs.Ranks = (ushort)skillRanks;
                boss.Session.Network.EnqueueSend(new GameMessagePrivateUpdateSkill(boss, cs));
            }

            foreach (var attr in boss.Attributes.Values)
            {
                if (attr.StartingValue < 100)
                    attr.StartingValue = 100;
                attr.ExperienceSpent = attrXp;
                attr.Ranks = (uint)attrRanks;
                boss.Session.Network.EnqueueSend(new GameMessagePrivateUpdateAttribute(boss, attr));
            }

            foreach (var kvp in boss.Vitals)
            {
                var vital = kvp.Value;
                vital.ExperienceSpent = maxVitalXp;
                vital.Ranks = 196u;
                vital.StartingValue = kvp.Key == PropertyAttribute2nd.MaxHealth ? (uint)Math.Max(1, L("event_boss_health")) : (uint)Math.Max(1, L("event_boss_mana"));
                boss.Session.Network.EnqueueSend(new GameMessagePrivateUpdateVital(boss, vital));
            }

            ApplyLook(boss);

            // the level players see when they appraise the boss
            var level = (int)Math.Clamp(L("event_boss_level"), 1, 999);
            boss.Level = level;
            boss.Session.Network.EnqueueSend(new GameMessagePrivateUpdatePropertyInt(boss, PropertyInt.Level, level));

            boss.SpellComponentsRequired = false;
            boss.Session.Network.EnqueueSend(new GameMessagePrivateUpdatePropertyBool(boss, PropertyBool.SpellComponentsRequired, false));

            // every spell, the first time only (re-learning thousands of spells on every login floods the client)
            if ((boss.Biota.PropertiesSpellBook?.Count ?? 0) < 1000)
                DeveloperCommands.HandleAddAllSpells(boss.Session);
        }

        /// <summary>
        /// The boss's look: a creature's body (setup, clothing table, palette) instead of its own, from the
        /// event_boss_look_* settings (default: the Sinister Shadow). Saved on the character, which is a dedicated boss
        /// character. Equipment is not drawn on top of it (Creature.CalculateObjDesc). event_boss_look_clothing_base 0 keeps
        /// the character's own look.
        /// </summary>
        private static void ApplyLook(Player boss)
        {
            var clothingBase = (uint)L("event_boss_look_clothing_base");
            if (clothingBase == 0)
                return;

            boss.SetupTableId = (uint)L("event_boss_look_setup");
            boss.ClothingBase = clothingBase;
            boss.PaletteBaseDID = (uint)L("event_boss_look_palette_base");
            boss.PaletteTemplate = (int)L("event_boss_look_palette_template");
            boss.Shade = PropertyManager.GetDouble("event_boss_look_shade").Item;
        }

        /// <summary>
        /// Ends the event without rewards (or after the rewards on death): scale back, minions gone.
        /// The character keeps its boss stats.
        /// </summary>
        public static void Stop(Player boss, bool announce)
        {
            lock (locker)
            {
                if (!bossGuid.HasValue || bossGuid != boss.Guid.Full)
                    return;
                bossGuid = null;
            }

            boss.ObjScale = bossOriginalScale ?? 1.0f;
            bossOriginalScale = null;
            boss.EnqueueBroadcast(false, new GameMessageUpdateObject(boss));

            DespawnMinions();

            if (announce)
                Announce($"{boss.Name} has retreated into the shadows. The event is over.");
            log.Info($"[EVENTBOSS] {boss.Name} is no longer the event boss");
        }

        /// <summary>
        /// /minions: the boss calls helpers in a ring around itself.
        /// </summary>
        public static void SummonMinions(Player boss)
        {
            var cooldown = TimeSpan.FromSeconds(Math.Max(0, L("event_boss_summon_cooldown_seconds")));
            lock (locker)
            {
                if (bossGuid != boss.Guid.Full)
                {
                    boss.Session.Network.EnqueueSend(new GameMessageSystemChat("Only the event boss can do that.", ChatMessageType.Broadcast));
                    return;
                }
                var wait = lastSummon + cooldown - DateTime.UtcNow;
                if (wait > TimeSpan.Zero)
                {
                    boss.Session.Network.EnqueueSend(new GameMessageSystemChat($"Your shadows answer again in {(int)Math.Ceiling(wait.TotalSeconds)} seconds.", ChatMessageType.Broadcast));
                    return;
                }
                lastSummon = DateTime.UtcNow;
                minions.RemoveAll(m => m == null || m.IsDestroyed || m.IsDead);
            }

            var wcid = (uint)L("event_boss_minion_wcid");
            var count = (int)Math.Clamp(L("event_boss_minion_count"), 0, 30);
            var lifespan = (int)Math.Max(30, L("event_boss_minion_lifespan_seconds"));

            boss.PlayParticleEffect(PlayScript.BaelZharonSmite, boss.Guid);
            boss.EnqueueBroadcast(new GameMessageSystemChat($"{boss.Name} calls the shadows to its side!", ChatMessageType.Broadcast));

            var spawned = 0;
            foreach (var pos in Ring(boss.Location, count, 6.0f))
            {
                if (WorldObjectFactory.CreateNewWorldObject(wcid) is not Creature minion)
                {
                    log.Warn($"[EVENTBOSS] event_boss_minion_wcid {wcid} is not a creature");
                    break;
                }
                minion.Location = pos;
                minion.IsEventBossMinion = true;
                minion.Lifespan = lifespan;
                if (minion.EnterWorld())
                {
                    spawned++;
                    lock (locker) minions.Add(minion);
                }
                else
                    minion.Destroy();
            }
            log.Info($"[EVENTBOSS] {boss.Name} summoned {spawned} minions");
        }

        private static void DespawnMinions()
        {
            List<Creature> list;
            lock (locker)
            {
                list = minions.ToList();
                minions.Clear();
            }
            foreach (var m in list)
            {
                if (m == null || m.IsDestroyed) continue;
                var lb = m.CurrentLandblock;
                if (lb != null)
                    lb.EnqueueAction(new ActionEventDelegate(() => { if (!m.IsDestroyed) m.Destroy(); }));
                else
                    m.Destroy();
            }
        }

        /// <summary>
        /// Called from Player.Die for the event boss, instead of the normal player death
        /// (no vitae, no items dropped, no PK Trophy).
        /// </summary>
        public static void OnBossDeath(Player boss, DamageHistoryInfo topDamager)
        {
            try
            {
                var topName = topDamager?.Name?.TrimStart('+') ?? "no one";
                Announce($"{boss.Name} has been slain by {topName}! Its treasure lies scattered on the ground for any player killer to claim.");

                // everyone in the landblock (except the boss) gets the participation reward
                var trophies = (int)Math.Max(0, L("event_boss_participation_trophies"));
                var landblockPlayers = boss.CurrentLandblock?.GetCurrentLandblockPlayers() ?? new List<Player>();
                if (trophies > 0)
                {
                    foreach (var player in landblockPlayers)
                    {
                        if (player == boss) continue;
                        var pkTrophy = WorldObjectFactory.CreateNewWorldObject(1000002); // PK Trophy
                        pkTrophy.SetStackSize(trophies);
                        if (player.TryCreateInInventoryWithNetworking(pkTrophy))
                            player.Session.Network.EnqueueSend(new GameMessageSystemChat($"You have received {trophies} PK Trophies for taking part in the fall of {boss.Name}.", ChatMessageType.Broadcast));
                    }
                }

                // no corpse: the loot of one pull of the event_boss_loot_chest_wcid chest (Darkbeat's Storage Locker)
                // lands on the ground around the body, first come first served (red players only)
                DropChestPull(boss);

                // reward boxes on the ground around the body, first come first served
                var boxWcid = (uint)L("event_boss_reward_box_wcid");
                var boxes = (int)Math.Clamp(L("event_boss_reward_boxes"), 0, 30);
                foreach (var pos in Scatter(boss.Location, boxes, 2.0f, (float)Math.Max(2, L("event_boss_reward_box_radius"))))
                {
                    var box = WorldObjectFactory.CreateNewWorldObject(boxWcid);
                    if (box == null) break;
                    box.Location = pos;
                    if (!box.EnterWorld())
                        box.Destroy();
                }
            }
            catch (Exception ex)
            {
                log.Error($"[EVENTBOSS] OnBossDeath: {ex}");
            }
            finally
            {
                Stop(boss, false);
            }
        }

        /// <summary>
        /// Rolls one pull of a chest's generator table (like opening the chest once) and drops the items on the ground
        /// around the boss. Same rules as the chest: every always-spawn (-1) entry once (the treasure profile),
        /// then random picks from the rest by their probabilities until InitGeneratedObjects is reached,
        /// each entry limited by its own max_Create.
        /// </summary>
        private static void DropChestPull(Player boss)
        {
            var chestWcid = (uint)L("event_boss_loot_chest_wcid");
            var items = RollChestPull(chestWcid, boss.CurrentLandblock?.Id.Landblock);

            if (items.Count == 0)
            {
                log.Warn($"[EVENTBOSS] event_boss_loot_chest_wcid {chestWcid} produced no loot");
                return;
            }

            var seconds = Math.Max(60, L("event_boss_loot_minutes") * 60);
            var positions = Scatter(boss.Location, items.Count, 1.0f, (float)Math.Max(2, L("event_boss_reward_box_radius"))).ToList();

            for (var i = 0; i < items.Count; i++)
            {
                var item = items[i];
                item.Location = positions[i];
                item.TimeToRot = seconds;

                lock (locker)
                {
                    if (rewardLoot.Count > 5000) rewardLoot.Clear();   // items rot after event_boss_loot_minutes; keep the list small
                    rewardLoot.Add(item.Guid.Full);
                }

                if (!item.EnterWorld())
                    item.Destroy();
            }

            log.Info($"[EVENTBOSS] {boss.Name} dropped {items.Count} items from a pull of chest {chestWcid}");
        }

        private static List<WorldObject> RollChestPull(uint chestWcid, ushort? landblock)
        {
            var results = new List<WorldObject>();

            var weenie = DatabaseManager.World.GetCachedWeenie(chestWcid);
            if (weenie?.PropertiesGenerator == null || weenie.PropertiesGenerator.Count == 0)
                return results;

            var profiles = weenie.PropertiesGenerator.ToList();

            var initObjects = 1;
            if (weenie.PropertiesInt != null && weenie.PropertiesInt.TryGetValue(PropertyInt.InitGeneratedObjects, out var init) && init > 0)
                initObjects = init;

            var created = new int[profiles.Count];
            var total = 0;

            bool IsMaxed(int i) => profiles[i].MaxCreate > 0 && created[i] >= profiles[i].MaxCreate;

            void Spawn(int i)
            {
                var p = profiles[i];

                if (p.WhereCreate.HasFlag(RegenLocationType.Treasure))
                {
                    var deathTreasure = DatabaseManager.World.GetCachedDeathTreasure(p.WeenieClassId);
                    if (deathTreasure != null)
                    {
                        // same whitelist handling as a chest (GeneratorProfile.TreasureGenerator), using the boss's landblock
                        deathTreasure.DisableRatings = PropertyManager.GetBool("ratings_whitelist_enabled").Item && !Whitelist.IsRatingsWhitelistedChestWeenie(chestWcid)
                            && (!landblock.HasValue || !Whitelist.IsRatingsWhitelistedLandblock(landblock.Value));
                        deathTreasure.DisableSets = PropertyManager.GetBool("equipmentset_whitelist_enabled").Item && (!landblock.HasValue || !Whitelist.IsEquipmentSetWhitelistedLandblock(landblock.Value));
                        deathTreasure.DisableEpicCantrips = PropertyManager.GetBool("epic_whitelist_enabled").Item && (!landblock.HasValue || !Whitelist.IsEpicWhitelistedLandblock(landblock.Value));
                        deathTreasure.DisableLegendaryCantrips = PropertyManager.GetBool("legendary_whitelist_enabled").Item && (!landblock.HasValue || !Whitelist.IsLegendaryWhitelistedLandblock(landblock.Value));
                        deathTreasure.DisableAetheria = PropertyManager.GetBool("aetheria_whitelist_enabled").Item && (!landblock.HasValue || !Whitelist.IsAetheriaWhitelistedLandblock(landblock.Value));
                        deathTreasure.DisableHighLevelAetheria = PropertyManager.GetBool("aetheria_highlevel_whitelist_enabled").Item && (!landblock.HasValue || !Whitelist.IsAetheriaWhitelistedLandblock(landblock.Value));

                        results.AddRange(LootGenerationFactory.CreateRandomLootObjects(deathTreasure).Where(o => o != null));
                    }
                    else
                        log.Warn($"[EVENTBOSS] chest {chestWcid}: treasure profile {p.WeenieClassId} not found");

                    created[i]++;
                    total++;    // a treasure roll counts as one generated object, like on the chest
                    return;
                }

                var count = p.InitCreate > 0 ? p.InitCreate : 1;
                if (p.MaxCreate > 0) count = Math.Min(count, p.MaxCreate - created[i]);
                count = Math.Min(count, Math.Max(1, initObjects - total));

                for (var n = 0; n < count; n++)
                {
                    var wo = WorldObjectFactory.CreateNewWorldObject(p.WeenieClassId);
                    if (wo == null) break;

                    if (p.StackSize.HasValue && p.StackSize.Value > 1 && wo.MaxStackSize.HasValue)
                        wo.SetStackSize(Math.Min(p.StackSize.Value, wo.MaxStackSize.Value));

                    results.Add(wo);
                }
                created[i] += count;
                total += count;
            }

            // always-spawn entries first
            for (var i = 0; i < profiles.Count; i++)
            {
                if (profiles[i].Probability == -1 && !IsMaxed(i))
                    Spawn(i);
            }

            // then random picks, using the generator's cumulative probabilities over entries that aren't maxed yet
            for (var guard = 0; total < initObjects && guard < 50; guard++)
            {
                var cumulative = new List<(int index, float upTo)>();
                var sum = 0.0f;
                var last = 0.0f;

                for (var i = 0; i < profiles.Count; i++)
                {
                    var prob = profiles[i].Probability;
                    if (prob == -1) continue;

                    if (!IsMaxed(i))
                    {
                        if (last > prob) last = 0.0f;
                        sum += prob - last;
                        cumulative.Add((i, sum));
                    }
                    last = prob;
                }

                if (cumulative.Count == 0 || sum <= 0) break;

                var rng = ThreadSafeRandom.Next(0.0f, sum);
                var pick = cumulative.FirstOrDefault(c => rng < c.upTo);
                if (pick.upTo == 0) pick = cumulative[cumulative.Count - 1];

                Spawn(pick.index);
            }

            return results;
        }

        /// <summary>
        /// Positions evenly spaced on a circle around a point (outdoors; indoors they fall back to the point itself).
        /// </summary>
        private static IEnumerable<Position> Ring(Position center, int count, float radius)
        {
            for (var i = 0; i < count; i++)
            {
                var angle = 2 * Math.PI * i / Math.Max(1, count);
                var facing = new Position(center.LandblockId.Raw, center.PositionX, center.PositionY, center.PositionZ,
                    0f, 0f, (float)Math.Sin(angle / 2), (float)Math.Cos(angle / 2));
                var pos = center.Indoors ? new Position(center) : facing.InFrontOf(radius);
                pos.LandblockId = new LandblockId(pos.GetCell());
                yield return pos;
            }
        }

        /// <summary>
        /// Positions at random angles and distances (minRadius..maxRadius) around a point, the way world boss loot
        /// scatters on the ground (indoors they fall back to the point itself).
        /// </summary>
        private static IEnumerable<Position> Scatter(Position center, int count, float minRadius, float maxRadius)
        {
            for (var i = 0; i < count; i++)
            {
                var angle = ThreadSafeRandom.Next(0.0f, (float)(2 * Math.PI));
                var dist = ThreadSafeRandom.Next(minRadius, Math.Max(minRadius, maxRadius));
                var facing = new Position(center.LandblockId.Raw, center.PositionX, center.PositionY, center.PositionZ,
                    0f, 0f, (float)Math.Sin(angle / 2), (float)Math.Cos(angle / 2));
                var pos = center.Indoors ? new Position(center) : facing.InFrontOf(dist);
                pos.LandblockId = new LandblockId(pos.GetCell());
                yield return pos;
            }
        }

        private static void Announce(string msg)
        {
            PlayerManager.BroadcastToAll(new GameMessageSystemChat(msg, ChatMessageType.Broadcast));
            try
            {
                var webhookUrl = PropertyManager.GetString("world_boss_webhook").Item;
                if (!string.IsNullOrEmpty(webhookUrl))
                    _ = TurbineChatHandler.SendWebhookedChat("Event Boss", msg, webhookUrl, "Global");
            }
            catch (Exception ex)
            {
                log.Error($"[EVENTBOSS] webhook: {ex}");
            }
        }
    }
}
