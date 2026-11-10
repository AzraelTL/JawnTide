using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;

using ACE.Database;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide economy stats (after Conquest-ACE's EconomyStatsManager): per day, currency and source, how much entered
    /// (positive) or left (negative) the game. Counted in memory and added to economy_daily every few seconds by
    /// TransferAudit's timer. Read with /economystats.
    ///   luminance: earned:&lt;xp type&gt; (after modifiers), spent
    ///   pyreals:   vendor_sale (paid to players), vendor_buy (paid by players, coins or bank)
    ///   &lt;alt currency name&gt;: vendor_buy
    /// </summary>
    public static class EconomyStats
    {
        private static readonly ConcurrentDictionary<(DateTime day, string currency, string source), (long amount, long count)> counters
            = new ConcurrentDictionary<(DateTime, string, string), (long, long)>();

        public static void Add(string currency, string source, long amount)
        {
            if (amount == 0 || !PropertyManager.GetBool("economy_stats_enabled").Item)
                return;

            counters.AddOrUpdate((DateTime.UtcNow.Date, currency, source), (amount, 1), (_, v) => (v.amount + amount, v.count + 1));
        }

        public static void Flush()
        {
            if (counters.IsEmpty)
                return;

            var rows = new List<(DateTime, string, string, long, long)>();

            foreach (var key in counters.Keys.ToList())
                if (counters.TryRemove(key, out var v))
                    rows.Add((key.day, key.currency, key.source, v.amount, v.count));

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.EconomyAddDaily(rows));
        }
    }
}
