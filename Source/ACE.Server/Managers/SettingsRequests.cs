using System;
using System.Globalization;
using System.Threading;

using log4net;

using System.Collections.Generic;
using System.Linq;
using System.Text.Json;

using ACE.Database;
using ACE.Server.WorldObjects;

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

                    DummyRequests(db);
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

        /// <summary>Target Drudge changes from the LAN admin page (training_dummy_request).</summary>
        private static void DummyRequests(ShardDatabase db)
        {
            var rows = db.PvpToolsQuery("SELECT id, dummy_Guid, request FROM training_dummy_request WHERE status = 'pending' ORDER BY id LIMIT 20;");
            if (rows == null)
                return;

            foreach (var r in rows)
            {
                var id = Convert.ToInt64(r[0]);
                var guid = Convert.ToUInt32(r[1]);

                void Done(string status, string message) => DatabaseManager.Shard.MarketEnqueue(() =>
                    DatabaseManager.Shard.BaseDatabase.PvpToolsExecute("UPDATE training_dummy_request SET status = @s, applied_At = @t, message = @m WHERE id = @id;",
                        ("@s", status), ("@t", DateTime.UtcNow), ("@m", message?.Length > 255 ? message.Substring(0, 255) : message), ("@id", id)));

                JsonElement req;
                try
                {
                    req = JsonDocument.Parse(r[2]?.ToString() ?? "{}").RootElement.Clone();
                }
                catch (Exception)
                {
                    Done("rejected", "bad request");
                    continue;
                }

                var missing = new List<string>();
                List<uint> buffs = null;
                if (req.TryGetProperty("buffs", out var b) && b.ValueKind == JsonValueKind.String)
                    buffs = TrainingDummy.ResolveBuffs(b.GetString(), missing);
                var replace = !req.TryGetProperty("buffs_mode", out var bm) || bm.GetString() != "add";
                var note = missing.Count > 0 ? $"; no spell named: {string.Join(", ", missing)}" : "";

                if (TrainingDummy.Placed.TryGetValue(guid, out var dummy) && dummy.CurrentLandblock != null && !dummy.IsDestroyed)
                {
                    dummy.EnqueueAction(new ACE.Server.Entity.Actions.ActionEventDelegate(() =>
                    {
                        try
                        {
                            Done("applied", dummy.ApplyWebRequest(req, buffs, replace) + note);
                        }
                        catch (Exception ex)
                        {
                            log.Error($"[DUMMY] Admin page change failed: {ex}");
                            Done("rejected", "error: " + ex.Message);
                        }
                    }));
                    continue;
                }

                // not loaded right now: change its saved setup, which it reads when its landblock loads
                int Int(string name) => req.TryGetProperty(name, out var v) && v.TryGetInt32(out var i) && i >= 0 ? i : -1;
                var sets = new List<string>();
                var args = new List<(string, object)> { ("@g", guid), ("@t", DateTime.UtcNow) };
                foreach (var (field, col) in new[] { ("armor", "armor"), ("armor_extremities", "armor_Extremities"), ("melee_defense", "melee_Defense"),
                    ("missile_defense", "missile_Defense"), ("magic_defense", "magic_Defense"), ("damage_resist_rating", "damage_Resist_Rating"),
                    ("crit_damage_resist_rating", "crit_Damage_Resist_Rating"), ("pk_damage_resist_rating", "pk_Damage_Resist_Rating") })
                {
                    var v = Int(field);
                    if (v < 0) continue;
                    sets.Add($"{col} = @{field}");
                    args.Add(($"@{field}", v));
                }
                if (buffs != null)
                {
                    // adding to what it already keeps up: merge with its saved list
                    var list = buffs;
                    if (!replace)
                    {
                        var cur = db.PvpToolsQuery("SELECT spells FROM training_dummy WHERE dummy_Guid = @g;", ("@g", guid));
                        list = TrainingDummy.ParseIds(cur != null && cur.Count > 0 ? cur[0][0]?.ToString() : null);
                        foreach (var spellId in buffs)
                            if (!list.Contains(spellId))
                                list.Add(spellId);
                    }
                    sets.Add("spells = @spells");
                    args.Add(("@spells", string.Join(",", list)));
                }
                var worn = req.TryGetProperty("worn", out var w) ? w.GetString() : "keep";
                if (worn == "strip")
                    sets.Add("worn_Items = NULL");

                sets.Add("updated_At = @t");
                var n = db.PvpToolsExecute($"UPDATE training_dummy SET {string.Join(", ", sets)} WHERE dummy_Guid = @g;", args.ToArray());
                if (n > 0)
                {
                    // the page shows this row's setup in words; a loaded drudge writes its own, so write it here
                    var row = db.PvpToolsQuery("SELECT armor, armor_Extremities, melee_Defense, missile_Defense, magic_Defense, damage_Resist_Rating, " +
                        "crit_Damage_Resist_Rating, pk_Damage_Resist_Rating, spells FROM training_dummy WHERE dummy_Guid = @g;", ("@g", guid));
                    if (row != null && row.Count > 0)
                    {
                        var x = row[0];
                        var spellNames = TrainingDummy.ParseIds(x[8]?.ToString()).Select(TrainingDummy.SpellName).ToList();
                        var text = (guid == 0 ? "Defaults for new Target Drudges: " : "") +
                            $"armor {x[0]} (head, hands, feet {x[1]}), melee defense {x[2]}, missile defense {x[3]}, magic defense {x[4]}, " +
                            $"damage resist rating {x[5]}, crit damage resist rating {x[6]}, PK damage resist rating {x[7]}, buffs: {(spellNames.Count == 0 ? "none" : string.Join(", ", spellNames))}";
                        db.PvpToolsExecute("UPDATE training_dummy SET description = @d WHERE dummy_Guid = @g;", ("@d", text.Length > 2000 ? text.Substring(0, 2000) : text), ("@g", guid));
                    }
                }

                var what = guid == 0 ? "saved as the defaults for new drudges" : "saved; it isn't loaded right now, so it takes effect when its area loads";
                Done(n > 0 ? "applied" : "rejected", (n > 0 ? what : "no such dummy") + (worn == "strip_under" && guid != 0 ? "; taking off underclothes needs it loaded" : "") + note);
            }
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
