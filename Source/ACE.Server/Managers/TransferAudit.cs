using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

using log4net;

using ACE.Database;
using ACE.Entity.Enum;
using ACE.Server.Entity;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.WorldObjects;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide bank audit (anti-fraud), ported in spirit from Conquest-ACE's TransferLogger.
    /// Logs every value that moves from one account to another: bank sends, direct gives, trades, and items one account
    /// drops that a different account picks up. Each transfer is flagged when it looks suspicious:
    ///   same_ip  both sides are connected from the same IP address
    ///   large    the amount is over the transfer_audit_large_* setting for its currency
    ///   repeat   the same two accounts moved value transfer_audit_repeat_count times within the window
    ///   funnel   transfer_audit_funnel_count different accounts sent to one account within the window
    /// Flagged transfers are announced to online staff (transfer_audit_notify). /bankaudit reads the log.
    /// Rows are buffered and written every few seconds on the shard queue, never on a game thread.
    /// </summary>
    public static class TransferAudit
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static readonly ConcurrentQueue<TransferLogRow> pending = new ConcurrentQueue<TransferLogRow>();

        private static readonly object windowLock = new object();
        private static readonly Dictionary<(uint from, uint to), List<DateTime>> pairEvents = new Dictionary<(uint, uint), List<DateTime>>();
        private static readonly Dictionary<uint, Dictionary<uint, DateTime>> receivedFrom = new Dictionary<uint, Dictionary<uint, DateTime>>();
        private static readonly Dictionary<(uint from, uint to), DateTime> lastNotify = new Dictionary<(uint, uint), DateTime>();

        /// <summary>Items on the ground, by guid: who dropped them.</summary>
        private static readonly ConcurrentDictionary<uint, (uint accountId, uint characterId, string name, string ip, DateTime time)> dropped = new ConcurrentDictionary<uint, (uint, uint, string, string, DateTime)>();

        private static readonly ConcurrentDictionary<uint, bool> bankBans = new ConcurrentDictionary<uint, bool>();

        private static Timer flushTimer;

        public static readonly HashSet<uint> KeyWcids = new HashSet<uint>(BankInfo.Currencies.Where(c => c.Kind == BankCurrencyKind.Key).Select(c => c.Wcid));
        public const uint TrophyWcid = 1000002;

        public static void Initialize()
        {
            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery("SELECT account_Id FROM account_bank_ban;");
                if (rows == null)
                    return;
                foreach (var r in rows)
                    bankBans[Convert.ToUInt32(r[0])] = true;
                if (rows.Count > 0)
                    log.Info($"[AUDIT] {rows.Count} account(s) are banned from the bank.");
            });

            flushTimer = new Timer(_ => { Flush(); EconomyStats.Flush(); Prune(); }, null, TimeSpan.FromSeconds(10), TimeSpan.FromSeconds(10));
        }

        /// <summary>Writes everything buffered (also called at shutdown, before the shard queue drains).</summary>
        public static void Flush()
        {
            if (pending.IsEmpty)
                return;

            var rows = new List<TransferLogRow>();
            while (rows.Count < 2000 && pending.TryDequeue(out var row))
                rows.Add(row);

            DatabaseManager.Shard.MarketEnqueue(() => DatabaseManager.Shard.BaseDatabase.AuditInsertTransfers(rows));
        }

        private static void Prune()
        {
            var dropCutoff = DateTime.UtcNow.AddHours(-2);
            foreach (var kv in dropped)
                if (kv.Value.time < dropCutoff)
                    dropped.TryRemove(kv.Key, out _);

            var cutoff = DateTime.UtcNow.AddMinutes(-WindowMinutes);
            lock (windowLock)
            {
                foreach (var key in pairEvents.Keys.ToList())
                {
                    pairEvents[key].RemoveAll(t => t < cutoff);
                    if (pairEvents[key].Count == 0)
                        pairEvents.Remove(key);
                }
                foreach (var key in receivedFrom.Keys.ToList())
                {
                    foreach (var sender in receivedFrom[key].Where(kv => kv.Value < cutoff).Select(kv => kv.Key).ToList())
                        receivedFrom[key].Remove(sender);
                    if (receivedFrom[key].Count == 0)
                        receivedFrom.Remove(key);
                }
                foreach (var key in lastNotify.Where(kv => kv.Value < cutoff).Select(kv => kv.Key).ToList())
                    lastNotify.Remove(key);
            }
        }

        private static bool Enabled => PropertyManager.GetBool("transfer_audit_enabled").Item;
        private static long WindowMinutes => Math.Max(1, PropertyManager.GetLong("transfer_audit_window_minutes").Item);

        public static string IpOf(Player p) => p?.Session?.EndPointC2S?.Address?.ToString();

        // ---------------------------------------------------------------- bank ban

        public static bool IsBankBanned(uint accountId) => bankBans.ContainsKey(accountId);

        public static void SetBankBan(uint accountId, bool banned, string by, string reason, Action<bool> done)
        {
            if (banned)
                bankBans[accountId] = true;
            else
                bankBans.TryRemove(accountId, out _);

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var n = banned
                    ? DatabaseManager.Shard.BaseDatabase.AuditExecute(
                        "INSERT INTO account_bank_ban (account_Id, banned_At, banned_By, reason) VALUES (@a, @t, @b, @r) ON DUPLICATE KEY UPDATE banned_At = @t, banned_By = @b, reason = @r;",
                        ("@a", accountId), ("@t", DateTime.UtcNow), ("@b", by), ("@r", reason))
                    : DatabaseManager.Shard.BaseDatabase.AuditExecute("DELETE FROM account_bank_ban WHERE account_Id = @a;", ("@a", accountId));
                done?.Invoke(n >= 0);
            });
        }

        // ---------------------------------------------------------------- recording

        /// <summary>A bank send that went through (/bank send).</summary>
        public static void RecordBank(Player from, uint toAccountId, uint toCharacterId, string toName, BankCurrency currency, long amount)
        {
            if (from?.Account == null)
                return;

            var to = PlayerManager.GetOnlinePlayer(toCharacterId) ?? PlayerManager.GetAllOnline().FirstOrDefault(p => p.Account?.AccountId == toAccountId);

            Record("bank", from, toAccountId, toCharacterId, toName, IpOf(to), new List<(uint, uint, string, long, long)>
            {
                (currency.Wcid, 0u, currency.Name, amount, currency.Kind == BankCurrencyKind.Pyreals ? amount : 0)
            }, currency.Code);
        }

        /// <summary>Items one player handed another (direct give or one side of a trade).</summary>
        public static void RecordItems(string kind, Player from, Player to, IEnumerable<WorldObject> items)
        {
            if (from?.Account == null || to?.Account == null)
                return;

            var list = items.Where(i => i != null).Select(i => (i.WeenieClassId, i.Guid.Full, i.Name, (long)(i.StackSize ?? 1), (long)(i.Value ?? 0))).ToList();
            if (list.Count == 0)
                return;

            Record(kind, from, to.Account.AccountId, to.Guid.Full, to.Name, IpOf(to), list, null);
        }

        public static void OnDropped(Player dropper, WorldObject item)
        {
            if (dropper?.Account == null || item == null || !Enabled)
                return;

            dropped[item.Guid.Full] = (dropper.Account.AccountId, dropper.Guid.Full, dropper.Name, IpOf(dropper), DateTime.UtcNow);
        }

        /// <summary>A player picked up (all or part of) an item from the ground. Logged when a different account dropped it.</summary>
        public static void OnPickedUp(Player picker, WorldObject item, int? amount = null)
        {
            if (picker?.Account == null || item == null || !Enabled)
                return;

            if (!dropped.TryGetValue(item.Guid.Full, out var d))
                return;

            var qty = amount ?? item.StackSize ?? 1;
            var whole = amount == null || amount >= (item.StackSize ?? 1);

            if (whole)
                dropped.TryRemove(item.Guid.Full, out _);

            if (d.accountId == picker.Account.AccountId)
                return;

            var unitValue = (item.StackSize ?? 1) > 0 ? (item.Value ?? 0) / (double)(item.StackSize ?? 1) : 0;

            var row = Build("ground", d.accountId, d.characterId, d.name, d.ip, picker.Account.AccountId, picker.Guid.Full, picker.Name, IpOf(picker),
                item.WeenieClassId, item.Guid.Full, item.Name, qty, (long)Math.Round(unitValue * qty));

            Finish(new List<TransferLogRow> { row }, d.accountId, picker.Account.AccountId, null);
        }

        private static TransferLogRow Build(string kind, uint fromAccount, uint fromChar, string fromName, string fromIp, uint toAccount, uint toChar, string toName, string toIp,
            uint wcid, uint guid, string itemName, long qty, long value) => new TransferLogRow
        {
            Time = DateTime.UtcNow,
            Kind = kind,
            FromAccountId = fromAccount,
            FromCharacterId = fromChar,
            FromName = fromName,
            FromIp = fromIp,
            ToAccountId = toAccount,
            ToCharacterId = toChar,
            ToName = toName,
            ToIp = toIp,
            ItemWcid = wcid,
            ItemGuid = guid,
            ItemName = itemName,
            Quantity = qty,
            Value = value
        };

        private static void Record(string kind, Player from, uint toAccount, uint toChar, string toName, string toIp,
            List<(uint wcid, uint guid, string name, long qty, long value)> items, string bankCurrency)
        {
            if (!Enabled || from.Account.AccountId == toAccount)
                return;

            var fromIp = IpOf(from);
            var rows = items.Select(i => Build(kind, from.Account.AccountId, from.Guid.Full, from.Name, fromIp, toAccount, toChar, toName, toIp, i.wcid, i.guid, i.name, i.qty, i.value)).ToList();

            Finish(rows, from.Account.AccountId, toAccount, bankCurrency);
        }

        /// <summary>Flags the transfer (one event, any number of rows), queues the rows and tells staff when flagged.</summary>
        private static void Finish(List<TransferLogRow> rows, uint fromAccount, uint toAccount, string bankCurrency)
        {
            try
            {
                var flags = new List<string>();
                var first = rows[0];

                if (first.FromIp != null && first.FromIp == first.ToIp)
                    flags.Add("same_ip");

                // large: by value for pyreals and items, by count for trophies, keys and luminance
                var largeValue = PropertyManager.GetLong("transfer_audit_large_pyreals").Item;
                var largeTrophies = PropertyManager.GetLong("transfer_audit_large_trophies").Item;
                var largeKeys = PropertyManager.GetLong("transfer_audit_large_keys").Item;
                var largeLum = PropertyManager.GetLong("transfer_audit_large_luminance").Item;

                var totalValue = rows.Sum(r => r.Value);
                var trophies = rows.Where(r => r.ItemWcid == TrophyWcid).Sum(r => r.Quantity);
                var keys = rows.Where(r => KeyWcids.Contains(r.ItemWcid)).Sum(r => r.Quantity);
                var lum = bankCurrency == "luminance" ? rows.Sum(r => r.Quantity) : 0;

                if ((largeValue > 0 && totalValue >= largeValue) || (largeTrophies > 0 && trophies >= largeTrophies) || (largeKeys > 0 && keys >= largeKeys) || (largeLum > 0 && lum >= largeLum))
                    flags.Add("large");

                var now = DateTime.UtcNow;
                var cutoff = now.AddMinutes(-WindowMinutes);
                var repeatCount = PropertyManager.GetLong("transfer_audit_repeat_count").Item;
                var funnelCount = PropertyManager.GetLong("transfer_audit_funnel_count").Item;
                var notify = false;

                lock (windowLock)
                {
                    if (!pairEvents.TryGetValue((fromAccount, toAccount), out var events))
                        pairEvents[(fromAccount, toAccount)] = events = new List<DateTime>();
                    events.RemoveAll(t => t < cutoff);
                    events.Add(now);
                    if (repeatCount > 0 && events.Count >= repeatCount)
                        flags.Add("repeat");

                    if (!receivedFrom.TryGetValue(toAccount, out var senders))
                        receivedFrom[toAccount] = senders = new Dictionary<uint, DateTime>();
                    senders[fromAccount] = now;
                    if (funnelCount > 0 && senders.Count(kv => kv.Value >= cutoff) >= funnelCount)
                        flags.Add("funnel");

                    // one staff message per account pair per 5 minutes
                    if (flags.Count > 0 && (!lastNotify.TryGetValue((fromAccount, toAccount), out var last) || last < now.AddMinutes(-5)))
                    {
                        lastNotify[(fromAccount, toAccount)] = now;
                        notify = true;
                    }
                }

                var flagText = flags.Count > 0 ? string.Join(",", flags) : null;
                foreach (var r in rows)
                {
                    r.Flags = flagText;
                    pending.Enqueue(r);
                }

                if (notify && PropertyManager.GetBool("transfer_audit_notify").Item)
                {
                    var what = rows.Count == 1
                        ? $"{(first.Quantity != 1 ? $"{first.Quantity:N0} " : "")}{first.ItemName}"
                        : $"{rows.Count} items";
                    var worth = totalValue > 0 ? $" (value {totalValue:N0})" : "";
                    var msg = $"[BANK AUDIT] {flagText}: {first.Kind} {first.FromName} -> {first.ToName}: {what}{worth}. /bankaudit log {first.FromName}";

                    foreach (var staff in PlayerManager.GetAllOnline().Where(p => p.Session != null && p.Session.AccessLevel >= AccessLevel.Sentinel))
                        staff.Session.Network.EnqueueSend(new GameMessageSystemChat(msg, ChatMessageType.Broadcast));

                    log.Info(msg);
                }
            }
            catch (Exception ex)
            {
                log.Error($"[AUDIT] Recording a transfer failed: {ex}");
            }
        }
    }
}
