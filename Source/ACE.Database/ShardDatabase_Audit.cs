using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

using Microsoft.EntityFrameworkCore;

using ACE.Database.Models.Shard;

namespace ACE.Database
{
    /// <summary>JawnTide bank audit: one value moving from one account to another.</summary>
    public class TransferLogRow
    {
        public DateTime Time;
        public string Kind;
        public uint FromAccountId;
        public uint FromCharacterId;
        public string FromName;
        public string FromIp;
        public uint ToAccountId;
        public uint ToCharacterId;
        public string ToName;
        public string ToIp;
        public uint ItemWcid;
        public uint ItemGuid;
        public string ItemName;
        public long Quantity;
        public long Value;
        public string Flags;
    }

    public partial class ShardDatabase
    {
        // -------------------------------------------------------------------------
        // JawnTide bank audit (transfer_log, account_bank_ban) and economy stats (economy_daily).
        // Run these through SerializedShardDatabase.MarketEnqueue so they stay off the game threads.
        // -------------------------------------------------------------------------

        public void AuditInsertTransfers(List<TransferLogRow> rows)
        {
            if (rows == null || rows.Count == 0)
                return;

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();
                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);

                foreach (var r in rows)
                {
                    using var cmd = BankCommand(conn, tx,
                        @"INSERT INTO transfer_log (logged_At, kind, from_Account_Id, from_Character_Id, from_Character_Name, from_Ip, to_Account_Id, to_Character_Id, to_Character_Name, to_Ip, item_Wcid, item_Guid, item_Name, quantity, value, flags)
                          VALUES (@t, @k, @fa, @fc, @fn, @fi, @ta, @tc, @tn, @ti, @w, @g, @in, @q, @v, @f);",
                        ("@t", r.Time), ("@k", r.Kind), ("@fa", r.FromAccountId), ("@fc", r.FromCharacterId), ("@fn", Truncate(r.FromName, 64)), ("@fi", r.FromIp),
                        ("@ta", r.ToAccountId), ("@tc", r.ToCharacterId), ("@tn", Truncate(r.ToName, 64)), ("@ti", r.ToIp),
                        ("@w", r.ItemWcid), ("@g", r.ItemGuid), ("@in", Truncate(r.ItemName, 128)), ("@q", r.Quantity), ("@v", r.Value), ("@f", Truncate(r.Flags, 128)));
                    cmd.ExecuteNonQuery();
                }

                tx.Commit();
            }
            catch (Exception ex)
            {
                log.Error($"[AUDIT] AuditInsertTransfers failed ({rows.Count} rows): {ex}");
            }
        }

        /// <summary>Adds to the daily economy totals (one row per day, currency and source).</summary>
        public void EconomyAddDaily(List<(DateTime day, string currency, string source, long amount, long count)> rows)
        {
            if (rows == null || rows.Count == 0)
                return;

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();
                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);

                foreach (var (day, currency, source, amount, count) in rows)
                {
                    using var cmd = BankCommand(conn, tx,
                        @"INSERT INTO economy_daily (day, currency, source, amount, transactions) VALUES (@d, @c, @s, @a, @n)
                          ON DUPLICATE KEY UPDATE amount = amount + @a, transactions = transactions + @n;",
                        ("@d", day.Date), ("@c", Truncate(currency, 32)), ("@s", Truncate(source, 48)), ("@a", amount), ("@n", count));
                    cmd.ExecuteNonQuery();
                }

                tx.Commit();
            }
            catch (Exception ex)
            {
                log.Error($"[ECONOMY] EconomyAddDaily failed ({rows.Count} rows): {ex}");
            }
        }

        /// <summary>Runs a read-only query and returns every row as an array of column values (DBNull becomes null). Null when it failed.</summary>
        public List<object[]> AuditQuery(string sql, params (string name, object value)[] args)
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
                log.Error($"[AUDIT] AuditQuery failed: {ex}");
                return null;
            }

            return result;
        }

        /// <summary>Runs one write statement. Returns the rows changed, or -1 when it failed.</summary>
        public int AuditExecute(string sql, params (string name, object value)[] args)
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
                log.Error($"[AUDIT] AuditExecute failed: {ex}");
                return -1;
            }
        }
    }
}
