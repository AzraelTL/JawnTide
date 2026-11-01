using System;
using System.Collections.Generic;
using System.Linq;

using log4net;

using ACE.Common;
using ACE.Database;
using ACE.Database.Entity;
using ACE.Database.Models.Shard;
using ACE.DatLoader;
using ACE.DatLoader.FileTypes;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Server.Entity;
using ACE.Server.Factories;
using ACE.Server.Managers;

using DbBiota = ACE.Database.Models.Shard.Biota;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide: "Ghost of [Mule]", the passive pet called by a bound Mule Imprint Token.
    /// <para/>
    /// It looks like the mule (translucent), follows its summoner like any passive pet, and accepts items
    /// only from its summoner. Items handed to it are written straight into the offline mule's inventory in
    /// the database, so they are waiting in the mule's pack the next time the mule logs in.
    /// <para/>
    /// The ghost never holds items itself (its own Inventory stays empty).
    /// It keeps a small model of the mule's pack (slots, side packs, burden and unique counts) that is
    /// read from the database when the ghost is summoned and updated with every hand-off.
    /// </summary>
    public class MuleGhost : Pet
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public const float GhostTranslucency = 0.45f;

        public uint MuleGuid { get; private set; }

        public string MuleName { get; private set; }

        public uint TokenGuid { get; private set; }

        public MuleGhost(ACE.Entity.Models.Weenie weenie, ObjectGuid guid) : base(weenie, guid)
        {
        }

        public MuleGhost(ACE.Entity.Models.Biota biota) : base(biota)
        {
        }

        // ---------------------------------------------------------------------
        // Mule pack model
        // ---------------------------------------------------------------------

        private class SidePack
        {
            public uint Guid;
            public int Placement;
            public int Capacity;
            public int Count;
        }

        private int mainPackItemCapacity;
        private int mainPackContainerCapacity;
        private int mainPackItems;
        private int mainPackContainers;
        private readonly List<SidePack> sidePacks = new List<SidePack>();
        private long burden;
        private long burdenLimit;
        private bool burdenIgnored;
        private readonly Dictionary<uint, int> wcidCounts = new Dictionary<uint, int>();

        public int ItemsTransferred { get; private set; }

        /// <summary>
        /// Creates the ghost for the player's mule and puts it in the world next to the player.
        /// Must be called on the player's action thread.
        /// </summary>
        public static MuleGhost Summon(Player owner, MuleImprintToken token, OfflinePlayer mule, PossessedBiotas possessions)
        {
            var weenie = DatabaseManager.World.GetCachedWeenie(MuleImprintToken.GhostWcid);

            if (weenie == null)
            {
                log.Error($"[MuleImprint] {owner.Name}: ghost weenie {MuleImprintToken.GhostWcid} is missing from the world database");
                return null;
            }

            var ghost = new MuleGhost(weenie, GuidManager.NewDynamicGuid());

            if (!ghost.Init(owner, token, mule, possessions))
            {
                ghost.Destroy();
                return null;
            }

            return ghost;
        }

        private bool Init(Player owner, MuleImprintToken token, OfflinePlayer mule, PossessedBiotas possessions)
        {
            MuleGuid = mule.Guid.Full;
            MuleName = mule.Name;
            TokenGuid = token.Guid.Full;

            CopyAppearance(mule, possessions.WieldedItems);
            BuildPackModel(mule, possessions);

            Name = $"Ghost of {mule.Name}";
            Translucency = GhostTranslucency;

            // the summoner can use the ghost to see how full the mule's pack is
            ItemUseable = Usable.Remote;

            // it's only a ghost: nothing can attack, target, harm or kill it
            Attackable = false;
            Invincible = true;

            // unlike a normal passive pet (which is hidden from radar), the ghost must be easy for its owner
            // to select, so they can drag items onto it or use /give style tools on it.
            // It shows up on radar and in the selection list like an NPC.
            RadarBehavior = ACE.Entity.Enum.RadarBehavior.ShowAlways;
            RadarColor = ACE.Entity.Enum.RadarColor.Yellow;
            UiHidden = false;

            var spawnDist = owner.PhysicsObj.GetPhysicsRadius() + GetGhostRadius() + 2.0f;

            Location = owner.Location.InFrontOf(spawnDist, true);
            Location.LandblockId = new LandblockId(Location.GetCell());

            TimeToRot = -1;

            PetOwner = owner.Guid.Full;
            P_PetOwner = owner;
            NoCorpse = true;

            if (!EnterWorld())
            {
                owner.SendTransientError($"Couldn't call the {Name}");
                return false;
            }

            owner.CurrentActivePet = this;

            nextSlowTickTime = Time.GetUnixTime();

            return true;
        }

        private float GetGhostRadius()
        {
            try
            {
                var setup = DatManager.PortalDat.ReadFromDat<SetupModel>(SetupTableId);
                if (setup?.Spheres != null && setup.Spheres.Count > 0)
                    return setup.Spheres[0].Radius * (ObjScale ?? 1.0f);
            }
            catch (Exception ex)
            {
                log.Warn($"[MuleImprint] couldn't read setup 0x{SetupTableId:X8} for {Name}: {ex.Message}");
            }
            return 0.5f;
        }

        // ---------------------------------------------------------------------
        // Appearance
        // ---------------------------------------------------------------------

        private static readonly PropertyDataId[] AppearanceDids =
        {
            PropertyDataId.Setup,
            PropertyDataId.MotionTable,
            PropertyDataId.SoundTable,
            PropertyDataId.PaletteBase,
            PropertyDataId.EyesTexture,
            PropertyDataId.NoseTexture,
            PropertyDataId.MouthTexture,
            PropertyDataId.DefaultEyesTexture,
            PropertyDataId.DefaultNoseTexture,
            PropertyDataId.DefaultMouthTexture,
            PropertyDataId.HairPalette,
            PropertyDataId.EyesPalette,
            PropertyDataId.SkinPalette,
            PropertyDataId.HeadObject,
        };

        private static readonly PropertyInt[] AppearanceInts =
        {
            PropertyInt.HeritageGroup,
            PropertyInt.Gender,
            PropertyInt.Hairstyle,
        };

        /// <summary>
        /// Gives the ghost the mule's body, face and colours, and dresses it in copies of what the mule is wearing.
        /// The copies are display-only: they are never saved and are destroyed with the ghost.
        /// </summary>
        private void CopyAppearance(OfflinePlayer mule, List<DbBiota> wieldedItems)
        {
            foreach (var did in AppearanceDids)
            {
                var value = mule.GetProperty(did);
                if (value.HasValue)
                    SetProperty(did, value.Value);
                else if (did != PropertyDataId.Setup && did != PropertyDataId.MotionTable && did != PropertyDataId.SoundTable)
                    RemoveProperty(did);
            }

            foreach (var prop in AppearanceInts)
            {
                var value = mule.GetProperty(prop);
                if (value.HasValue)
                    SetProperty(prop, value.Value);
                else
                    RemoveProperty(prop);
            }

            const EquipMask visibleSlots = EquipMask.Clothing | EquipMask.Armor | EquipMask.Cloak;

            foreach (var biota in wieldedItems)
            {
                var slot = (EquipMask)(biota.GetProperty(PropertyInt.CurrentWieldedLocation) ?? 0);

                if ((slot & visibleSlots) == 0)
                    continue;

                var copy = WorldObjectFactory.CreateNewWorldObject(biota.WeenieClassId);
                if (copy == null)
                    continue;

                var paletteTemplate = biota.GetProperty(PropertyInt.PaletteTemplate);
                if (paletteTemplate.HasValue)
                    copy.PaletteTemplate = paletteTemplate.Value;

                var shade = biota.GetProperty(PropertyFloat.Shade);
                if (shade.HasValue)
                    copy.Shade = shade.Value;

                if (!TryEquipObject(copy, slot))
                    copy.Destroy();
            }
        }

        // ---------------------------------------------------------------------
        // Pack model
        // ---------------------------------------------------------------------

        private static int GetBiotaEncumbrance(DbBiota biota)
        {
            var value = biota.GetProperty(PropertyInt.EncumbranceVal);
            if (value.HasValue)
                return value.Value;

            // containers don't keep their own burden in the shard; it comes from the weenie
            var weenie = DatabaseManager.World.GetCachedWeenie(biota.WeenieClassId);
            if (weenie != null && weenie.PropertiesInt != null && weenie.PropertiesInt.TryGetValue(PropertyInt.EncumbranceVal, out var weenieValue))
                return weenieValue;

            return 0;
        }

        private static int GetBiotaItemsCapacity(DbBiota biota)
        {
            var value = biota.GetProperty(PropertyInt.ItemsCapacity);
            if (value.HasValue)
                return value.Value;

            var weenie = DatabaseManager.World.GetCachedWeenie(biota.WeenieClassId);
            if (weenie != null && weenie.PropertiesInt != null && weenie.PropertiesInt.TryGetValue(PropertyInt.ItemsCapacity, out var weenieValue))
                return weenieValue;

            return 0;
        }

        private static bool BiotaUsesPackSlot(DbBiota biota)
        {
            return biota.WeenieType == (int)WeenieType.Container || (biota.GetProperty(PropertyBool.RequiresBackpackSlot) ?? false);
        }

        private void AddWcidCount(uint wcid, int count)
        {
            wcidCounts.TryGetValue(wcid, out var current);
            wcidCounts[wcid] = current + count;
        }

        private void BuildPackModel(OfflinePlayer mule, PossessedBiotas possessions)
        {
            mainPackItemCapacity = mule.GetProperty(PropertyInt.ItemsCapacity) ?? 102;
            mainPackContainerCapacity = mule.GetProperty(PropertyInt.ContainersCapacity) ?? 7;

            // first pass: what sits directly in the mule's main pack
            foreach (var biota in possessions.Inventory)
            {
                var containerId = biota.GetProperty(PropertyInstanceId.Container) ?? 0;

                if (containerId != MuleGuid)
                    continue;

                if (BiotaUsesPackSlot(biota))
                {
                    mainPackContainers++;

                    if (biota.WeenieType == (int)WeenieType.Container)
                    {
                        sidePacks.Add(new SidePack
                        {
                            Guid = biota.Id,
                            Placement = biota.GetProperty(PropertyInt.PlacementPosition) ?? 0,
                            Capacity = GetBiotaItemsCapacity(biota),
                        });
                    }
                }
                else
                    mainPackItems++;
            }

            sidePacks.Sort((a, b) => a.Placement.CompareTo(b.Placement));

            // second pass: side pack contents, burden and unique counts
            foreach (var biota in possessions.Inventory)
            {
                var containerId = biota.GetProperty(PropertyInstanceId.Container) ?? 0;

                var sidePack = sidePacks.FirstOrDefault(p => p.Guid == containerId);
                if (sidePack != null)
                    sidePack.Count++;

                burden += GetBiotaEncumbrance(biota);
                AddWcidCount(biota.WeenieClassId, biota.GetProperty(PropertyInt.StackSize) ?? 1);
            }

            foreach (var biota in possessions.WieldedItems)
            {
                burden += GetBiotaEncumbrance(biota);
                AddWcidCount(biota.WeenieClassId, biota.GetProperty(PropertyInt.StackSize) ?? 1);
            }

            // same carrying capacity formula as Player.GetEncumbranceCapacity(), using the mule's base strength
            uint strength = 10;
            mule.BiotaDatabaseLock.EnterReadLock();
            try
            {
                if (mule.Biota.PropertiesAttribute != null && mule.Biota.PropertiesAttribute.TryGetValue(PropertyAttribute.Strength, out var str))
                    strength = str.InitLevel + str.LevelFromCP;
            }
            finally
            {
                mule.BiotaDatabaseLock.ExitReadLock();
            }

            // same rule as Player.IsBurdenIgnored: characters below ignore_burden_below_character_level carry without burden
            var muleLevel = mule.Level ?? 1;
            burdenIgnored = muleLevel < PropertyManager.GetLong("ignore_burden_below_character_level").Item;

            var carryAugs = mule.GetProperty(PropertyInt.AugmentationIncreasedCarryingCapacity) ?? 0;

            var capacity = (150L * strength) + (carryAugs * 30L * strength);

            burdenLimit = capacity * 3;
        }

        /// <summary>
        /// Finds where an item would go in the mule's pack: main pack first, then the first side pack with room.
        /// Packs (and other items that need a pack slot) can only go in the main pack's pack slots.
        /// </summary>
        public bool TryFindRoom(WorldObject item, int itemBurden, out uint containerGuid, out int placement, out string error)
        {
            containerGuid = 0;
            placement = 0;
            error = null;

            if (!burdenIgnored && burden + itemBurden > burdenLimit)
            {
                error = $"{MuleName} is too encumbered to carry that!";
                return false;
            }

            if (item.UseBackpackSlot)
            {
                if (mainPackContainers < mainPackContainerCapacity)
                {
                    containerGuid = MuleGuid;
                    placement = mainPackContainers;
                    return true;
                }

                error = $"{MuleName} has no room for another pack!";
                return false;
            }

            if (mainPackItems < mainPackItemCapacity)
            {
                containerGuid = MuleGuid;
                placement = mainPackItems;
                return true;
            }

            foreach (var pack in sidePacks)
            {
                if (pack.Count < pack.Capacity)
                {
                    containerGuid = pack.Guid;
                    placement = pack.Count;
                    return true;
                }
            }

            error = $"{MuleName}'s packs are full!";
            return false;
        }

        /// <summary>
        /// Checks the mule could hold this item (and anything inside it) without going over any Unique limits.
        /// </summary>
        public bool CheckUniques(WorldObject item, out string error)
        {
            error = null;

            var uniques = item.GetUniqueObjects();
            if (uniques.Count == 0)
                return true;

            var table = new UniqueTable(uniques);

            foreach (var kvp in table.Entries)
            {
                wcidCounts.TryGetValue(kvp.Key, out var current);

                if (current + kvp.Value.Count > kvp.Value.Max)
                {
                    var wo = uniques.FirstOrDefault(i => i.WeenieClassId == kvp.Key);
                    var itemName = kvp.Value.Max == 1 ? wo?.Name : wo?.GetPluralName();
                    error = $"{MuleName} cannot hold more than {kvp.Value.Max:N0} {itemName}!";
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Moves an item (already removed from the summoner) into the mule's pack and saves it.
        /// </summary>
        public void CommitTransfer(WorldObject item, uint containerGuid, int placement)
        {
            item.Location = null;
            item.Placement = ACE.Entity.Enum.Placement.Resting;
            item.Container = null;
            item.Wielder = null;
            item.WielderId = null;
            item.CurrentWieldedLocation = null;
            item.OwnerId = containerGuid;
            item.ContainerId = containerGuid;
            item.PlacementPosition = placement;

            // update the model
            if (containerGuid == MuleGuid)
            {
                if (item.UseBackpackSlot)
                {
                    mainPackContainers++;

                    if (item is Container pack && item.WeenieType == WeenieType.Container)
                        sidePacks.Add(new SidePack { Guid = item.Guid.Full, Placement = placement, Capacity = pack.ItemCapacity ?? 0, Count = pack.Inventory.Count });
                }
                else
                    mainPackItems++;
            }
            else
            {
                var sidePack = sidePacks.FirstOrDefault(p => p.Guid == containerGuid);
                if (sidePack != null)
                    sidePack.Count++;
            }

            burden += item.EncumbranceVal ?? 0;
            AddWcidCount(item.WeenieClassId, item.StackSize ?? 1);

            // save the item, and everything inside it if it is a pack
            var biotas = new List<(ACE.Entity.Models.Biota biota, System.Threading.ReaderWriterLockSlim rwLock)>();

            item.SaveBiotaToDatabase(false);
            biotas.Add((item.Biota, item.BiotaDatabaseLock));

            if (item is Container container)
            {
                foreach (var subItem in container.Inventory.Values)
                {
                    AddWcidCount(subItem.WeenieClassId, subItem.StackSize ?? 1);

                    subItem.SaveBiotaToDatabase(false);
                    biotas.Add((subItem.Biota, subItem.BiotaDatabaseLock));
                }
            }

            DatabaseManager.Shard.SaveBiotasInParallel(biotas, null);

            ItemsTransferred++;
        }

        public string GetPackSummary()
        {
            var sideFree = sidePacks.Sum(p => Math.Max(0, p.Capacity - p.Count));
            var sideCap = sidePacks.Sum(p => p.Capacity);

            return $"{Name} carries for {MuleName}:\n" +
                   $"  Main pack: {mainPackItems} / {mainPackItemCapacity} items, {mainPackContainers} / {mainPackContainerCapacity} packs\n" +
                   $"  Side packs: {sideCap - sideFree} / {sideCap} items\n" +
                   (burdenIgnored ? $"  Burden: not counted ({MuleName} is below level {PropertyManager.GetLong("ignore_burden_below_character_level").Item})"
                                  : $"  Burden: {burden:N0} / {burdenLimit:N0}");
        }

        // ---------------------------------------------------------------------
        // Untouchable
        // ---------------------------------------------------------------------

        // Attackable=false and Invincible=true already stop melee, missile, spells, DoTs and hotspots.
        // These overrides make sure no damage path that reaches the ghost directly can hurt it.

        public override uint TakeDamage(WorldObject source, DamageType damageType, float amount, bool crit = false)
        {
            return 0;
        }

        public override void TakeDamageOverTime(float amount, DamageType damageType)
        {
        }

        public override bool CanDamage(Creature target)
        {
            return false;
        }

        // ---------------------------------------------------------------------
        // Interaction
        // ---------------------------------------------------------------------

        public override void ActOnUse(WorldObject activator)
        {
            if (activator is not Player player)
                return;

            if (player != P_PetOwner)
            {
                player.SendMessage($"The {Name} drifts silently, paying you no mind.");
                return;
            }

            player.SendMessage(GetPackSummary());
        }

        /// <summary>
        /// The mule logged in some other way (shouldn't happen with one character per account online,
        /// but if it does the ghost's pack model would be stale), so the ghost goes away.
        /// </summary>
        public bool MuleIsOnline()
        {
            PlayerManager.FindByGuid(MuleGuid, out var isOnline);
            return isOnline;
        }
    }
}
