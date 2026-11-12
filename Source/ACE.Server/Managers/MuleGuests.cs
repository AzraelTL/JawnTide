using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;

using ACE.Database;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide My Mule guests (mule_guest table): characters on other accounts that may use an account's mule while it's
    /// summoned, like house storage guests on a chest. Each account's list is read once and kept in memory; changes write
    /// through to the database.
    /// </summary>
    public static class MuleGuests
    {
        public const int MaxGuests = 20;

        private static readonly ConcurrentDictionary<uint, Dictionary<uint, string>> cache = new ConcurrentDictionary<uint, Dictionary<uint, string>>();

        public static bool Enabled => PropertyManager.GetBool("mule_guests_enabled").Item;

        private static Dictionary<uint, string> Load(uint accountId) => cache.GetOrAdd(accountId, id =>
        {
            var list = new Dictionary<uint, string>();
            var rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery("SELECT guest_Id, guest_Name FROM mule_guest WHERE account_Id = @a;", ("@a", id));
            if (rows != null)
                foreach (var r in rows)
                    list[Convert.ToUInt32(r[0])] = r[1]?.ToString() ?? "";
            return list;
        });

        public static bool IsGuest(uint accountId, uint characterId)
        {
            if (!Enabled)
                return false;

            var list = Load(accountId);
            lock (list)
                return list.ContainsKey(characterId);
        }

        public static List<(uint id, string name)> List(uint accountId)
        {
            var list = Load(accountId);
            lock (list)
                return list.Select(kv => (kv.Key, kv.Value)).OrderBy(g => g.Value, StringComparer.OrdinalIgnoreCase).ToList();
        }

        /// <summary>Adds a guest. Returns false if the list is full; true if added or already there.</summary>
        public static bool Add(uint accountId, uint characterId, string name, string addedBy)
        {
            var list = Load(accountId);
            lock (list)
            {
                if (!list.ContainsKey(characterId) && list.Count >= MaxGuests)
                    return false;
                list[characterId] = name;
            }

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                "INSERT INTO mule_guest (account_Id, guest_Id, guest_Name, added_By, added_At) VALUES (@a, @g, @n, @b, UTC_TIMESTAMP()) " +
                "ON DUPLICATE KEY UPDATE guest_Name = @n, added_By = @b, added_At = UTC_TIMESTAMP();",
                ("@a", accountId), ("@g", characterId), ("@n", name), ("@b", addedBy)));
            return true;
        }

        public static bool Remove(uint accountId, uint characterId)
        {
            var list = Load(accountId);
            lock (list)
                if (!list.Remove(characterId))
                    return false;

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                "DELETE FROM mule_guest WHERE account_Id = @a AND guest_Id = @g;", ("@a", accountId), ("@g", characterId)));
            return true;
        }

        public static int Clear(uint accountId)
        {
            var list = Load(accountId);
            int n;
            lock (list)
            {
                n = list.Count;
                list.Clear();
            }

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.PvpToolsExecute(
                "DELETE FROM mule_guest WHERE account_Id = @a;", ("@a", accountId)));
            return n;
        }
    }
}
