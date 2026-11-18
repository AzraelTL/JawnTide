using System;
using System.Collections.Generic;
using System.Linq;

using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide Allegiance Mule: a My Mule that hangs on a mansion hook. Its storage belongs to the hook item (and so to the
    /// mansion it hangs in), not to an account: it stays with the mansion, contents and all, if the mansion is abandoned, and it
    /// can't be taken down while anything is in it. The same people who may open the mansion's storage chests may use it.
    /// Using the hook item brings out a mule shell (the same vendor window as My Mule), shared by everyone using it.
    /// </summary>
    public static class HookMules
    {
        private class Entry
        {
            public Hooker Item;
            public List<Container> Containers;   // kept for the whole server run once loaded (see Player.LoadMuleContainerChain)
            public Vendor Shell;
            public DateTime LastUse;
            public DateTime? LoadStarted;
        }

        private static readonly object entriesLock = new object();
        private static readonly Dictionary<uint, Entry> entries = new Dictionary<uint, Entry>();

        private static Entry Get(uint itemGuid)
        {
            lock (entriesLock)
                return entries.TryGetValue(itemGuid, out var e) ? e : null;
        }

        private static Entry GetOrAdd(Hooker item)
        {
            lock (entriesLock)
            {
                if (!entries.TryGetValue(item.Guid.Full, out var e))
                    entries[item.Guid.Full] = e = new Entry();
                e.Item = item;
                return e;
            }
        }

        /// <summary>Whether this player may use the Allegiance Mule on this hook: a mansion, and storage-chest permission there.</summary>
        public static bool CanUseHook(Player player, Hooker item, Hook hook, out string why)
        {
            why = null;
            var rootHouse = hook?.House?.RootHouse;

            if (rootHouse == null || rootHouse.HouseType != HouseType.Mansion)
            {
                why = $"{item.Name} only works on a mansion's hooks.";
                return false;
            }

            if (player.IgnoreHouseBarriers)
                return true;

            if (player.PKTimerActive)
            {
                why = $"{item.Name} won't open while you're PK tagged.";
                return false;
            }

            // its own permission list, set like house storage (/amule storage ...), separate from the mansion's chests
            if (!HasAccess(player, rootHouse))
            {
                why = $"You do not have permission to access {item.Name}.";
                return false;
            }

            return true;
        }

        /// <summary>
        /// The mansion's owner and every character on the owner's account; anyone on its /amule storage list; and the owner's
        /// allegiance when /amule storage allegiance is on. Grants made by a previous owner of the mansion don't count.
        /// </summary>
        public static bool HasAccess(Player player, House rootHouse)
        {
            if (rootHouse?.HouseOwner == null)
                return false;

            var ownerId = rootHouse.HouseOwner.Value;
            if (player.Guid.Full == ownerId)
                return true;

            var owner = ACE.Server.Managers.PlayerManager.FindByGuid(ownerId);
            if (owner?.Account != null && player.Account != null && owner.Account.AccountId == player.Account.AccountId)
                return true;

            var houseId = rootHouse.Guid.Full;
            if (ACE.Server.Managers.HookMuleAccess.Has(houseId, ownerId, player.Guid.Full))
                return true;

            if (ACE.Server.Managers.HookMuleAccess.Has(houseId, ownerId, ACE.Server.Managers.HookMuleAccess.AllegianceId))
            {
                var monarch = rootHouse.MonarchId ?? owner?.MonarchId;
                if (monarch.HasValue && player.Allegiance != null && player.Allegiance.MonarchId == monarch.Value)
                    return true;
            }

            return false;
        }

        /// <summary>The mule permission check for deposits, withdrawals, search, pages and comps on an Allegiance Mule shell.</summary>
        public static bool CanUse(Player player, Vendor shell, out string why)
        {
            why = "That mule isn't here anymore.";

            var e = shell.MuleHookItemId.HasValue ? Get(shell.MuleHookItemId.Value) : null;
            if (e == null || e.Shell != shell || e.Item == null || e.Item.IsDestroyed || !e.Item.IsHooked(player, out var hook))
                return false;

            return CanUseHook(player, e.Item, hook, out why);
        }

        /// <summary>True for the one live shell of its hook item (an old one, from before a reload, goes home instead).</summary>
        public static bool IsCurrentShell(Vendor shell)
        {
            var e = shell.MuleHookItemId.HasValue ? Get(shell.MuleHookItemId.Value) : null;
            if (e == null || e.Shell != shell)
                return false;

            e.LastUse = DateTime.UtcNow;
            return true;
        }

        /// <summary>Items stored in this hook item's mule: the live count when it's loaded, otherwise the saved one.</summary>
        public static int StoredCount(WorldObject item)
        {
            var e = Get(item.Guid.Full);
            if (e?.Containers != null)
                return e.Containers.Sum(c => c.Inventory.Count);

            if (e?.LoadStarted != null)
                return 1;   // loading right now: don't let it come down until the count is known

            return item.GetProperty(PropertyInt.HookMuleItemCount) ?? 0;
        }

        /// <summary>After a deposit or withdrawal: saves the item count on the hook item (it can't come down while above 0).</summary>
        public static void UpdateItemCount(Vendor shell)
        {
            if (!shell.MuleHookItemId.HasValue || shell.MuleContainers == null)
                return;

            var e = Get(shell.MuleHookItemId.Value);
            if (e?.Item == null || e.Item.IsDestroyed)
                return;

            var count = shell.MuleContainers.Sum(c => c.Inventory.Count);
            if ((e.Item.GetProperty(PropertyInt.HookMuleItemCount) ?? 0) == count)
                return;

            e.Item.SetProperty(PropertyInt.HookMuleItemCount, count);
            e.Item.SaveBiotaToDatabase();
        }

        internal static List<Container> GetLoaded(Hooker item) => Get(item.Guid.Full)?.Containers;

        internal static bool TryStartLoad(Hooker item)
        {
            var e = GetOrAdd(item);
            lock (entriesLock)
            {
                if (e.Containers != null)
                    return true;
                if (e.LoadStarted.HasValue && DateTime.UtcNow - e.LoadStarted.Value < TimeSpan.FromSeconds(15))
                    return false;
                e.LoadStarted = DateTime.UtcNow;
                return true;
            }
        }

        internal static List<Container> FinishLoad(Hooker item, List<Container> containers)
        {
            var e = GetOrAdd(item);
            lock (entriesLock)
            {
                e.LoadStarted = null;
                if (e.Containers == null)
                    e.Containers = containers;   // never two in-memory copies of the same storage
                return e.Containers;
            }
        }

        internal static void LoadFailed(Hooker item)
        {
            var e = Get(item.Guid.Full);
            if (e != null)
                lock (entriesLock)
                    e.LoadStarted = null;
        }

        internal static Vendor GetLiveShell(Hooker item)
        {
            var e = Get(item.Guid.Full);
            var shell = e?.Shell;
            if (shell == null || shell.IsDestroyed || shell.CurrentLandblock == null)
                return null;
            return shell;
        }

        internal static void SetShell(Hooker item, Vendor shell)
        {
            var e = GetOrAdd(item);
            e.Shell = shell;
            e.LastUse = DateTime.UtcNow;
            ScheduleIdleCheck(shell);
        }

        /// <summary>The shell goes home after HookMuleIdleSeconds with nobody opening it, or when its hook item is gone.</summary>
        private static void ScheduleIdleCheck(Vendor shell)
        {
            var chain = new ActionChain();
            chain.AddDelaySeconds(60);
            chain.AddAction(shell, () =>
            {
                if (shell.IsDestroyed)
                    return;

                var e = shell.MuleHookItemId.HasValue ? Get(shell.MuleHookItemId.Value) : null;
                var gone = e == null || e.Shell != shell || e.Item == null || e.Item.IsDestroyed || shell.CurrentLandblock == null || !e.Item.IsHooked(shell, out _);

                if (gone || (DateTime.UtcNow - e.LastUse).TotalSeconds > MuleInfo.HookMuleIdleSeconds)
                {
                    if (e != null && e.Shell == shell)
                        e.Shell = null;

                    shell.DefaultItemsForSale.Clear();
                    shell.UniqueItemsForSale.Clear();
                    shell.Destroy();
                    return;
                }

                ScheduleIdleCheck(shell);
            });
            chain.EnqueueChain();
        }
    }

    partial class Player
    {
        /// <summary>The Allegiance Mule shell this player last opened, while its window may still be open (see HookMuleTick).</summary>
        private Vendor openHookMule;

        /// <summary>Using an Allegiance Mule hook item: loads its storage the first time, brings out its shell and opens it.</summary>
        public void OpenHookMule(Hooker item, Hook hook)
        {
            if (IsDead || CurrentLandblock == null)
                return;

            if (!HookMules.CanUseHook(this, item, hook, out var why))
            {
                SendTransientError(why);
                return;
            }

            var shell = HookMules.GetLiveShell(item);
            if (shell != null)
            {
                shell.ActOnUse(this);
                return;
            }

            var loaded = HookMules.GetLoaded(item);
            if (loaded != null)
            {
                SpawnHookMuleShell(item, loaded);
                return;
            }

            if (!HookMules.TryStartLoad(item))
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat($"{item.Name} is on its way.", ChatMessageType.Broadcast));
                return;
            }

            var headGuid = item.GetProperty(PropertyInstanceId.HookMuleContainerId);

            if (!headGuid.HasValue)
            {
                var container = CreateNewMuleContainer();
                if (container == null)
                {
                    HookMules.LoadFailed(item);
                    SendTransientError($"{item.Name} could not be set up.");
                    return;
                }

                item.SetProperty(PropertyInstanceId.HookMuleContainerId, container.Guid.Full);
                item.SaveBiotaToDatabase();

                log.Info($"[MULE] Allegiance Mule 0x{item.Guid} set up by {Name} (0x{Guid}), storage 0x{container.Guid}");

                SpawnHookMuleShell(item, HookMules.FinishLoad(item, new List<Container> { container }));
                return;
            }

            // the chain loader retries on this player's thread and reports its own errors; if it never calls back,
            // TryStartLoad lets another try after 15 seconds
            LoadMuleContainerChainStep(headGuid.Value, new List<Container>(), containers =>
            {
                var chain = HookMules.FinishLoad(item, containers);

                if (HookMules.GetLiveShell(item) is Vendor existing)
                {
                    existing.ActOnUse(this);
                    return;
                }

                if (!item.IsDestroyed && item.IsHooked(this, out var stillHook) && HookMules.CanUseHook(this, item, stillHook, out _))
                    SpawnHookMuleShell(item, chain);
            });
        }

        private void SpawnHookMuleShell(Hooker item, List<Container> containers)
        {
            var vendor = WorldObjectFactory.CreateNewWorldObject(MuleInfo.VendorWeenieClassId) as Vendor;

            if (vendor == null)
            {
                log.Error($"[MULE] Failed to create mule vendor weenie {MuleInfo.VendorWeenieClassId} for Allegiance Mule 0x{item.Guid}");
                SendTransientError($"{item.Name} could not come out.");
                return;
            }

            ApplyMuleVisualFrom(vendor, MuleInfo.VisualVariantSourceWcids[(int)((item.Guid.Full * 2654435761u) % (uint)MuleInfo.VisualVariantSourceWcids.Length)]);

            var playerRadius = PhysicsObj.GetPhysicsRadius();
            var vendorRadius = vendor.PhysicsObj?.GetPhysicsRadius() ?? 0.5f;

            vendor.Location = Location.InFrontOf(playerRadius + vendorRadius + 1.0f, true);
            vendor.Location.LandblockId = new LandblockId(vendor.Location.GetCell());

            vendor.Name = item.Name;
            vendor.MerchandiseItemTypes = unchecked((int)MuleInfo.AllowedItemTypes);
            vendor.MuleOwnerId = item.Guid.Full;      // marks it as a mule everywhere My Mule code looks
            vendor.MuleOwnerAccountId = null;         // no account: permission comes from the mansion (HookMules.CanUse)
            vendor.MuleHookItemId = item.Guid.Full;
            vendor.MuleContainers = containers;
            vendor.TimeToRot = -1;
            vendor.Ethereal = true;

            foreach (var stored in SortMuleItems(containers.SelectMany(c => c.Inventory.Values)))
                vendor.UniqueItemsForSale[stored.Guid] = stored;

            if (!vendor.EnterWorld())
            {
                SendTransientError($"{item.Name} can't come out here.");
                vendor.DefaultItemsForSale.Clear();
                vendor.UniqueItemsForSale.Clear();
                vendor.Destroy();
                return;
            }

            HookMules.SetShell(item, vendor);

            // keep the saved count right (it decides whether the item may come down)
            HookMules.UpdateItemCount(vendor);

            vendor.ActOnUse(this);
        }

        /// <summary>Called from Vendor.ActOnUse when this player opens an Allegiance Mule.</summary>
        public void HookMuleOpened(Vendor shell) => openHookMule = shell;

        /// <summary>
        /// From MuleTick: once this player walks away from an Allegiance Mule (or it goes home), the client is told the real
        /// value of zero-value items and the real coin count again, as when My Mule leaves.
        /// </summary>
        private void HookMuleTick()
        {
            var shell = openHookMule;
            if (shell == null)
                return;

            if (!shell.IsDestroyed && shell.CurrentLandblock != null && CurrentLandblock != null && shell.CurrentLandblock.Id == CurrentLandblock.Id
                && Location.DistanceTo(shell.Location) <= 10.0f)
                return;

            openHookMule = null;

            if (ActiveMule != null)
                return;   // My Mule is out: it keeps the mule view until it leaves

            SetMuleZeroValueMask(false);
            BankRestoreCoinDisplay();
        }
    }
}
