using System.Collections.Generic;

using ACE.Database;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Server.Factories;
using ACE.Server.Managers;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    partial class Player
    {
        // -------------------------------------------------------------------------
        // JawnTide Marketplace: item moves between this character's loaded mule and market storage. Called by MarketManager on
        // this player's own thread, only while ActiveMuleContainers is loaded (otherwise MarketManager works in the database).
        // Each returns null on success or a message for the player.
        // -------------------------------------------------------------------------

        /// <summary>Takes an item out of the loaded mule into market storage and returns its details.</summary>
        internal string MarketTakeFromLoadedMule(uint itemGuid, out MarketManager.MarketItemInfo info)
        {
            info = null;

            var containers = ActiveMuleContainers;
            if (containers == null)
                return "Your mule isn't loaded. Please try again.";

            var guid = new ObjectGuid(itemGuid);
            var container = ResolveMuleItemContainer(containers, guid);

            if (container == null || !container.Inventory.TryGetValue(guid, out var item))
                return "That item isn't in your mule any more.";

            var error = MarketManager.CheckListable(item);
            if (error != null)
                return error;

            var details = MarketManager.BuildItemInfo(item);

            if (!container.TryRemoveFromInventory(guid, out var removed) || removed == null)
                return "That item couldn't be taken out of your mule.";

            ActiveMule?.UniqueItemsForSale.Remove(guid);

            removed.ContainerId = MarketManager.StorageContainerId;
            removed.PlacementPosition = 0;
            removed.SaveBiotaToDatabase();
            container.SaveBiotaToDatabase(); // TryRemoveFromInventory changed its burden and value

            Session?.Network.EnqueueSend(new GameMessageSystemChat($"[Market] {details.Name} left your mule for the market.", ChatMessageType.Broadcast));

            info = details;
            return null;
        }

        /// <summary>Moves an item from market storage into the loaded mule.</summary>
        internal string MarketGiveToLoadedMule(uint itemGuid)
        {
            var containers = ActiveMuleContainers;
            if (containers == null)
                return "Your mule isn't loaded. Please try again.";

            var biota = DatabaseManager.Shard.BaseDatabase.GetBiota(itemGuid);
            var item = biota != null ? WorldObjectFactory.CreateWorldObject(biota) : null;

            if (item == null)
                return "The item couldn't be loaded from market storage.";

            if (item.ContainerId != MarketManager.StorageContainerId)
                return "That item isn't in market storage.";

            var touched = new HashSet<WorldObject>();
            var target = GetOrCreateMuleDepositTarget(containers, touched);

            if (target == null || !target.TryAddToInventory(item, burdenCheck: false))
            {
                foreach (var wo in touched)
                    wo.SaveBiotaToDatabase();
                return "Your mule is full.";
            }

            touched.Add(target);
            touched.Add(item);

            foreach (var wo in touched)
                wo.SaveBiotaToDatabase();

            if (ActiveMule != null && !ActiveMule.IsDestroyed && ActiveMule.MuleSearchRegex == null && ActiveMule.MuleSuitGuids == null)
                ActiveMule.UniqueItemsForSale[item.Guid] = item;

            Session?.Network.EnqueueSend(new GameMessageSystemChat($"[Market] {item.NameWithMaterial ?? item.Name} is now in your mule.", ChatMessageType.Broadcast));

            return null;
        }
    }
}
