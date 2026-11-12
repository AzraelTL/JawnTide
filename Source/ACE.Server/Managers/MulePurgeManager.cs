using System;
using System.Threading;

using log4net;

using ACE.Database;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide /mule purge hold: every 10 minutes deletes, for good, purged mule items that have been held longer than
    /// mule_purge_hold_days (until then /mule purge undo can bring them back).
    /// </summary>
    public static class MulePurgeManager
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static Timer timer;
        private static int busy;

        public static int HoldDays => (int)Math.Clamp(PropertyManager.GetLong("mule_purge_hold_days").Item, 0, 365);

        public static void Initialize()
        {
            timer = new Timer(_ => Sweep(), null, TimeSpan.FromMinutes(2), TimeSpan.FromMinutes(10));
        }

        private static void Sweep()
        {
            if (Interlocked.Exchange(ref busy, 1) == 1)
                return;

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                try
                {
                    var db = DatabaseManager.Shard.BaseDatabase;
                    var rows = db.PvpToolsQuery("SELECT id, item_Guid FROM mule_purge WHERE status = 'held' AND purged_At < @cut ORDER BY id LIMIT 500;",
                        ("@cut", DateTime.UtcNow.AddDays(-HoldDays)));
                    if (rows == null || rows.Count == 0)
                        return;

                    var n = 0;
                    foreach (var r in rows)
                    {
                        var guid = Convert.ToUInt32(r[1]);
                        db.RemoveBiota(guid);
                        db.PvpToolsExecute("UPDATE mule_purge SET status = 'deleted', done_At = @t WHERE id = @id;", ("@t", DateTime.UtcNow), ("@id", Convert.ToInt64(r[0])));
                        n++;
                    }
                    log.Info($"[MULE] Purge hold: deleted {n} purged mule items for good (held over {HoldDays} days).");
                }
                catch (Exception ex)
                {
                    log.Error($"[MULE] Purge hold sweep failed: {ex}");
                }
                finally
                {
                    Interlocked.Exchange(ref busy, 0);
                }
            });
        }
    }
}
