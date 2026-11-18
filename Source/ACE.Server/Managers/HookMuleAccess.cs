using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;

using ACE.Database;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide Allegiance Mule permissions (hook_mule_access table): its own list per mansion, set with the same kind of
    /// commands as house storage (/amule storage add NAME, remove NAME, remove -all, list, allegiance on|off). Separate from
    /// the mansion's storage chests. Entries granted by a previous owner of the mansion don't count (a new owner starts empty).
    /// Each mansion's list is read once and kept in memory; changes write through to the database.
    /// </summary>
    public static class HookMuleAccess
    {
        public const int MaxGuests = 100;

        /// <summary>guest_Id 0: the owner's allegiance may use it.</summary>
        public const uint AllegianceId = 0;

        private class Entry { public string Name; public uint OwnerId; }

        private static readonly ConcurrentDictionary<uint, Dictionary<uint, Entry>> cache = new ConcurrentDictionary<uint, Dictionary<uint, Entry>>();

        private static Dictionary<uint, Entry> Load(uint houseId) => cache.GetOrAdd(houseId, id =>
        {
            var list = new Dictionary<uint, Entry>();
            var rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery("SELECT guest_Id, guest_Name, owner_Id FROM hook_mule_access WHERE house_Id = @h;", ("@h", id));
            if (rows != null)
                foreach (var r in rows)
                    list[Convert.ToUInt32(r[0])] = new Entry { Name = r[1]?.ToString() ?? "", OwnerId = Convert.ToUInt32(r[2]) };
            return list;
        });

        public static bool Has(uint houseId, uint ownerId, uint guestId)
        {
            var list = Load(houseId);
            lock (list)
                return list.TryGetValue(guestId, out var e) && e.OwnerId == ownerId;
        }

        public static List<(uint id, string name)> List(uint houseId, uint ownerId)
        {
            var list = Load(houseId);
            lock (list)
                return list.Where(kv => kv.Value.OwnerId == ownerId).Select(kv => (kv.Key, kv.Value.Name)).OrderBy(g => g.Name, StringComparer.OrdinalIgnoreCase).ToList();
        }

        /// <summary>Adds a guest (or AllegianceId). Returns false if the list is full; true if added or already there.</summary>
        public static bool Add(uint houseId, uint ownerId, uint guestId, string name, string addedBy)
        {
            var list = Load(houseId);
            lock (list)
            {
                // a previous owner's entries go away the first time the new owner changes the list
                foreach (var stale in list.Where(kv => kv.Value.OwnerId != ownerId).Select(kv => kv.Key).ToList())
                    list.Remove(stale);

                if (!list.ContainsKey(guestId) && list.Count(kv => kv.Key != AllegianceId) >= MaxGuests && guestId != AllegianceId)
                    return false;
                list[guestId] = new Entry { Name = name, OwnerId = ownerId };
            }

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                DatabaseManager.Shard.BaseDatabase.PvpToolsExecute("DELETE FROM hook_mule_access WHERE house_Id = @h AND owner_Id <> @o;", ("@h", houseId), ("@o", ownerId));
                DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                    "INSERT INTO hook_mule_access (house_Id, guest_Id, guest_Name, owner_Id, added_By, added_At) VALUES (@h, @g, @n, @o, @b, UTC_TIMESTAMP()) " +
                    "ON DUPLICATE KEY UPDATE guest_Name = @n, owner_Id = @o, added_By = @b, added_At = UTC_TIMESTAMP();",
                    ("@h", houseId), ("@g", guestId), ("@n", name), ("@o", ownerId), ("@b", addedBy));
            });
            return true;
        }

        public static bool Remove(uint houseId, uint ownerId, uint guestId)
        {
            var list = Load(houseId);
            lock (list)
            {
                if (!list.TryGetValue(guestId, out var e) || e.OwnerId != ownerId)
                    return false;
                list.Remove(guestId);
            }

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                "DELETE FROM hook_mule_access WHERE house_Id = @h AND guest_Id = @g;", ("@h", houseId), ("@g", guestId)));
            return true;
        }

        /// <summary>Removes every guest (not the allegiance setting). Returns how many.</summary>
        public static int ClearGuests(uint houseId, uint ownerId)
        {
            var list = Load(houseId);
            int n;
            lock (list)
            {
                var gone = list.Where(kv => kv.Key != AllegianceId || kv.Value.OwnerId != ownerId).Select(kv => kv.Key).ToList();
                n = gone.Count(id => list[id].OwnerId == ownerId);
                foreach (var id in gone)
                    list.Remove(id);
            }

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                "DELETE FROM hook_mule_access WHERE house_Id = @h AND (guest_Id <> 0 OR owner_Id <> @o);", ("@h", houseId), ("@o", ownerId)));
            return n;
        }
    }
}
