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

        public static bool IsActive { get { lock (locker) return bossGuid.HasValue; } }

        public static bool IsBoss(Player player)
        {
            if (player == null) return false;
            lock (locker) return bossGuid == player.Guid.Full;
        }

        private static long L(string key) => PropertyManager.GetLong(key).Item;

        public static void Start(Player boss)
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

            boss.Session.Network.EnqueueSend(new GameMessageSystemChat("You are the event boss. Log out and back in now so your client picks up all your new skills and spells, then start the fight.", ChatMessageType.Broadcast));

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

            boss.SpellComponentsRequired = false;
            boss.Session.Network.EnqueueSend(new GameMessagePrivateUpdatePropertyBool(boss, PropertyBool.SpellComponentsRequired, false));

            DeveloperCommands.HandleAddAllSpells(boss.Session);
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
                Announce($"{boss.Name} has been slain! {topName} dealt the most damage and may claim its corpse.");

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

                // the corpse: loot only the top damager can open
                if (topDamager != null && topDamager.IsPlayer && topDamager.Guid.Full != boss.Guid.Full)
                    CreateLootCorpse(boss, topDamager);

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

        private static void CreateLootCorpse(Player boss, DamageHistoryInfo topDamager)
        {
            var corpse = WorldObjectFactory.CreateNewWorldObject(DatabaseManager.World.GetCachedWeenie("corpse")) as Corpse;
            if (corpse == null) return;

            corpse.SetupTableId = boss.SetupTableId;
            corpse.MotionTableId = boss.MotionTableId;
            corpse.PaletteBaseDID = boss.PaletteBaseDID;
            corpse.PhysicsTableId = boss.PhysicsTableId;
            corpse.ObjScale = boss.ObjScale;

            corpse.Location = new Position(boss.Location);
            corpse.VictimId = boss.Guid.Full;
            corpse.KillerId = topDamager.Guid.Full;
            corpse.Name = $"Corpse of {boss.Name}";
            corpse.LongDesc = $"Killed by {topDamager.Name?.TrimStart('+')}.";
            corpse.TimeToRot = Math.Max(60, L("event_boss_corpse_minutes") * 60);

            var profile = DatabaseManager.World.GetCachedDeathTreasure((uint)L("event_boss_corpse_treasure"));
            if (profile != null)
            {
                foreach (var item in LootGenerationFactory.CreateRandomLootObjects(profile))
                    corpse.TryAddToInventory(item);
            }
            else
                log.Warn($"[EVENTBOSS] event_boss_corpse_treasure {L("event_boss_corpse_treasure")} is not a loot profile");

            corpse.RemoveProperty(PropertyInt.Value);
            corpse.InitPhysicsObj();
            corpse.EnterWorld();
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
