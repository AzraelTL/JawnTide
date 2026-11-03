using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;

using Microsoft.EntityFrameworkCore;

using ACE.Database.Models.Shard;

namespace ACE.Database
{
    /// <summary>JawnTide Bank: the outcome of one bank change or transfer.</summary>
    public enum BankResultStatus
    {
        Ok,
        Insufficient,
        Error
    }

    public class BankResult
    {
        public BankResultStatus Status;

        /// <summary>The acting account's balance after the change (only set when Status is Ok).</summary>
        public long Balance;

        /// <summary>The other account's balance after a transfer (only set for a successful transfer).</summary>
        public long OtherBalance;

        public static BankResult Fail(BankResultStatus status) => new BankResult { Status = status };
    }

    /// <summary>JawnTide Bank: who did a change, written to account_bank_log with it.</summary>
    public class BankLogInfo
    {
        public uint CharacterId;
        public string CharacterName;
        public string Action;
        public uint? OtherAccountId;
        public string OtherCharacterName;
        public string Details;
    }

    public partial class ShardDatabase
    {
        // -------------------------------------------------------------------------
        // JawnTide Bank: account-wide balances (account_bank) and their history (account_bank_log).
        // Every change is one SQL transaction: a debit only happens when the balance covers it
        // (UPDATE ... WHERE amount >= n), so two changes can never spend the same balance twice,
        // even if the website changes balances too. Plain ADO.NET is used so the transaction is ours
        // (the EF retry strategy would refuse a user transaction).
        // -------------------------------------------------------------------------

        private static void AddBankParam(DbCommand cmd, string name, object value)
        {
            var p = cmd.CreateParameter();
            p.ParameterName = name;
            p.Value = value ?? DBNull.Value;
            cmd.Parameters.Add(p);
        }

        private static DbCommand BankCommand(DbConnection conn, DbTransaction tx, string sql, params (string name, object value)[] args)
        {
            var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = sql;
            foreach (var (name, value) in args)
                AddBankParam(cmd, name, value);
            return cmd;
        }

        /// <summary>Adds (delta > 0) or removes (delta < 0) an amount. A removal fails with Insufficient when the balance is too small.</summary>
        private static bool BankApply(DbConnection conn, DbTransaction tx, uint accountId, string currency, long delta, out long balance)
        {
            balance = 0;

            if (delta > 0)
            {
                using var credit = BankCommand(conn, tx,
                    "INSERT INTO account_bank (account_Id, currency, amount) VALUES (@a, @c, @d) ON DUPLICATE KEY UPDATE amount = amount + @d;",
                    ("@a", accountId), ("@c", currency), ("@d", delta));
                credit.ExecuteNonQuery();
            }
            else if (delta < 0)
            {
                using var debit = BankCommand(conn, tx,
                    "UPDATE account_bank SET amount = amount - @n WHERE account_Id = @a AND currency = @c AND amount >= @n;",
                    ("@a", accountId), ("@c", currency), ("@n", -delta));

                if (debit.ExecuteNonQuery() == 0)
                    return false;
            }

            using var read = BankCommand(conn, tx,
                "SELECT amount FROM account_bank WHERE account_Id = @a AND currency = @c;",
                ("@a", accountId), ("@c", currency));

            var value = read.ExecuteScalar();
            balance = value == null || value is DBNull ? 0 : Convert.ToInt64(value);
            return true;
        }

        private static void BankLog(DbConnection conn, DbTransaction tx, uint accountId, string currency, long amount, long balanceAfter, BankLogInfo info)
        {
            using var cmd = BankCommand(conn, tx,
                @"INSERT INTO account_bank_log (logged_At, account_Id, character_Id, character_Name, action, currency, amount, balance_After, other_Account_Id, other_Character_Name, details)
                  VALUES (@t, @a, @ci, @cn, @ac, @c, @amt, @bal, @oa, @on, @d);",
                ("@t", DateTime.UtcNow), ("@a", accountId), ("@ci", info?.CharacterId ?? 0), ("@cn", info?.CharacterName),
                ("@ac", info?.Action ?? "change"), ("@c", currency), ("@amt", amount), ("@bal", balanceAfter),
                ("@oa", info?.OtherAccountId), ("@on", info?.OtherCharacterName), ("@d", Truncate(info?.Details, 255)));
            cmd.ExecuteNonQuery();
        }

        private static string Truncate(string s, int max) => s == null || s.Length <= max ? s : s.Substring(0, max);

        /// <summary>JawnTide Bank: every non-zero balance on an account, keyed by currency code.</summary>
        public Dictionary<string, long> GetAccountBank(uint accountId)
        {
            var result = new Dictionary<string, long>();

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();

                using var cmd = BankCommand(conn, null, "SELECT currency, amount FROM account_bank WHERE account_Id = @a;", ("@a", accountId));
                using var reader = cmd.ExecuteReader();

                while (reader.Read())
                    result[reader.GetString(0)] = reader.GetInt64(1);
            }
            catch (Exception ex)
            {
                log.Error($"[BANK] GetAccountBank failed for account {accountId}: {ex}");
                return null;
            }

            return result;
        }

        /// <summary>
        /// JawnTide Bank: adds delta (positive = deposit/refund, negative = withdrawal) to one account's balance and logs it,
        /// in one transaction. A withdrawal larger than the balance changes nothing and returns Insufficient.
        /// </summary>
        public BankResult BankChange(uint accountId, string currency, long delta, BankLogInfo info)
        {
            if (delta == 0)
                return BankResult.Fail(BankResultStatus.Error);

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();

                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);

                if (!BankApply(conn, tx, accountId, currency, delta, out var balance))
                {
                    tx.Rollback();
                    return BankResult.Fail(BankResultStatus.Insufficient);
                }

                BankLog(conn, tx, accountId, currency, delta, balance, info);

                tx.Commit();

                return new BankResult { Status = BankResultStatus.Ok, Balance = balance };
            }
            catch (Exception ex)
            {
                log.Error($"[BANK] BankChange failed: account {accountId}, {currency} {delta:+#;-#;0}, {info?.Action} by {info?.CharacterName} (0x{info?.CharacterId:X8}): {ex}");
                return BankResult.Fail(BankResultStatus.Error);
            }
        }

        /// <summary>
        /// JawnTide Bank: moves an amount from one account to another and logs both sides, in one transaction.
        /// Returns Insufficient (and changes nothing) when the sender's balance is too small.
        /// </summary>
        public BankResult BankTransfer(uint fromAccountId, uint toAccountId, string currency, long amount, uint fromCharacterId, string fromCharacterName, uint toCharacterId, string toCharacterName, string details)
        {
            if (amount <= 0 || fromAccountId == toAccountId)
                return BankResult.Fail(BankResultStatus.Error);

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();

                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);

                if (!BankApply(conn, tx, fromAccountId, currency, -amount, out var fromBalance))
                {
                    tx.Rollback();
                    return BankResult.Fail(BankResultStatus.Insufficient);
                }

                BankApply(conn, tx, toAccountId, currency, amount, out var toBalance);

                BankLog(conn, tx, fromAccountId, currency, -amount, fromBalance, new BankLogInfo
                {
                    CharacterId = fromCharacterId, CharacterName = fromCharacterName, Action = "send",
                    OtherAccountId = toAccountId, OtherCharacterName = toCharacterName, Details = details
                });

                BankLog(conn, tx, toAccountId, currency, amount, toBalance, new BankLogInfo
                {
                    CharacterId = toCharacterId, CharacterName = toCharacterName, Action = "receive",
                    OtherAccountId = fromAccountId, OtherCharacterName = fromCharacterName, Details = details
                });

                tx.Commit();

                return new BankResult { Status = BankResultStatus.Ok, Balance = fromBalance, OtherBalance = toBalance };
            }
            catch (Exception ex)
            {
                log.Error($"[BANK] BankTransfer failed: {currency} {amount} from account {fromAccountId} ({fromCharacterName}) to account {toAccountId} ({toCharacterName}): {ex}");
                return BankResult.Fail(BankResultStatus.Error);
            }
        }

        /// <summary>JawnTide Bank: the most recent log rows for an account (both its own changes and transfers it received).</summary>
        public List<(DateTime time, string characterName, string action, string currency, long amount, long balanceAfter, string otherCharacterName)> GetAccountBankLog(uint accountId, int count)
        {
            var result = new List<(DateTime, string, string, string, long, long, string)>();

            try
            {
                using var context = new ShardDbContext();
                var conn = context.Database.GetDbConnection();
                conn.Open();

                using var cmd = BankCommand(conn, null,
                    @"SELECT logged_At, character_Name, action, currency, amount, balance_After, other_Character_Name
                      FROM account_bank_log WHERE account_Id = @a ORDER BY id DESC LIMIT @n;",
                    ("@a", accountId), ("@n", count));
                using var reader = cmd.ExecuteReader();

                while (reader.Read())
                    result.Add((
                        reader.GetDateTime(0),
                        reader.IsDBNull(1) ? "" : reader.GetString(1),
                        reader.GetString(2),
                        reader.GetString(3),
                        reader.GetInt64(4),
                        reader.GetInt64(5),
                        reader.IsDBNull(6) ? null : reader.GetString(6)));
            }
            catch (Exception ex)
            {
                log.Error($"[BANK] GetAccountBankLog failed for account {accountId}: {ex}");
                return null;
            }

            return result;
        }
    }
}
