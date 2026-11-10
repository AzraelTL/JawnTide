using System;
using System.Globalization;
using System.Threading;

using log4net;

using ACE.Database;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide: applies server setting changes made on the LAN admin page (rows the monitor adds to settings_request).
    /// Checked every 5 seconds. Only bool, long and double settings the server knows can be changed (never strings,
    /// which hold webhooks and keys). A change is the same as @modifybool / @modifylong / @modifydouble: live at once,
    /// saved by the normal settings save, and announced on the audit channel.
    /// </summary>
    public static class SettingsRequests
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static Timer timer;
        private static int busy;

        public static void Initialize()
        {
            timer = new Timer(_ => Poll(), null, TimeSpan.FromSeconds(15), TimeSpan.FromSeconds(5));
        }

        private static void Poll()
        {
            if (Interlocked.Exchange(ref busy, 1) == 1)
                return;

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                try
                {
                    var db = DatabaseManager.Shard.BaseDatabase;
                    var rows = db.PvpToolsQuery("SELECT id, `key`, type, value, requested_By FROM settings_request WHERE status = 'pending' ORDER BY id LIMIT 50;");
                    if (rows == null)
                        return;

                    foreach (var r in rows)
                    {
                        var id = Convert.ToInt64(r[0]);
                        var key = r[1]?.ToString() ?? "";
                        var type = r[2]?.ToString() ?? "";
                        var value = (r[3]?.ToString() ?? "").Trim();
                        var by = r[4]?.ToString() ?? "admin page";

                        var (ok, message) = Apply(key, type, value);

                        db.PvpToolsExecute("UPDATE settings_request SET status = @s, applied_At = @t, message = @m WHERE id = @id;",
                            ("@s", ok ? "applied" : "rejected"), ("@t", DateTime.UtcNow), ("@m", message), ("@id", id));

                        if (ok)
                        {
                            log.Info($"[SETTINGS] {by} (admin page) changed {key} to {value}");
                            PlayerManager.BroadcastToAuditChannel(null, $"Admin page ({by}): changed server {type} property {key} to {value}");
                        }
                        else
                            log.Warn($"[SETTINGS] Rejected admin page change of {key} to {value}: {message}");
                    }
                }
                catch (Exception ex)
                {
                    log.Error($"[SETTINGS] Applying admin page changes failed: {ex}");
                }
                finally
                {
                    Interlocked.Exchange(ref busy, 0);
                }
            });
        }

        private static (bool ok, string message) Apply(string key, string type, string value)
        {
            switch (type)
            {
                case "double":
                    if (!DefaultPropertyManager.DefaultDoubleProperties.ContainsKey(key)) return (false, "unknown double setting");
                    if (!double.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out var d) || double.IsNaN(d) || double.IsInfinity(d)) return (false, "not a number");
                    return PropertyManager.ModifyDouble(key, d) ? (true, "applied") : (false, "not changed");

                case "long":
                    if (!DefaultPropertyManager.DefaultLongProperties.ContainsKey(key)) return (false, "unknown long setting");
                    if (!long.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var l)) return (false, "not a whole number");
                    return PropertyManager.ModifyLong(key, l) ? (true, "applied") : (false, "not changed");

                case "bool":
                    if (!DefaultPropertyManager.DefaultBooleanProperties.ContainsKey(key)) return (false, "unknown bool setting");
                    if (!bool.TryParse(value, out var b)) return (false, "not true or false");
                    return PropertyManager.ModifyBool(key, b) ? (true, "applied") : (false, "not changed");

                default:
                    return (false, "only bool, long and double settings can be changed here");
            }
        }
    }
}
