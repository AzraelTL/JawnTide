using System;
using System.Collections.Generic;

using Microsoft.EntityFrameworkCore;

using ACE.Database.Models.Shard;

namespace ACE.Database
{
    public partial class ShardDatabase
    {
        // -------------------------------------------------------------------------
        // JawnTide PvP balance tools: target dummy config and sessions (training_dummy, training_dummy_session) and
        // setting changes requested from the LAN admin page (settings_request).
        // Run these through SerializedShardDatabase.MarketEnqueue so they stay off the game threads.
        // -------------------------------------------------------------------------

        /// <summary>Runs a read-only query and returns every row as an array of column values (DBNull becomes null). Null when it failed.</summary>
        public List<object[]> PvpToolsQuery(string sql, params (string name, object value)[] args)
        {
            var result = new List<object[]>();

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();

                using var cmd = BankCommand(conn, null, sql, args);
                using var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    var row = new object[reader.FieldCount];
                    reader.GetValues(row);
                    for (var i = 0; i < row.Length; i++)
                        if (row[i] is DBNull)
                            row[i] = null;
                    result.Add(row);
                }
            }
            catch (Exception ex)
            {
                log.Error($"[PVPTOOLS] Query failed: {ex}");
                return null;
            }

            return result;
        }

        /// <summary>Runs one write statement. Returns the rows changed, or -1 when it failed.</summary>
        public int PvpToolsExecute(string sql, params (string name, object value)[] args)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();

                using var cmd = BankCommand(conn, null, sql, args);
                return cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[PVPTOOLS] Execute failed: {ex}");
                return -1;
            }
        }
    }
}
