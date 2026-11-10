using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using ACE.Database;
using ACE.Entity.Enum;
using ACE.Server.Entity;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide bank extras, ported from Conquest-ACE and ACE-DreamWeave: /b, /top bank, /lhs, /lhr, /bankaudit, /economystats.
    /// Queries run on the shard queue (MarketEnqueue); results are sent from there.
    /// </summary>
    public static class BankExtraCommands
    {
        private static void Say(Session session, string text)
        {
            if (session?.Player != null)
                session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));
            else
                Console.WriteLine(text);
        }

        private static long L(object o) => o == null ? 0 : Convert.ToInt64(o);
        private static string S(object o) => o?.ToString() ?? "";

        // ---------------------------------------------------------------- /b

        [CommandHandler("b", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Short for /bank.",
            "/b - balances, /b d [currency] [amount], /b w <currency> <amount>, /b s <currency> <amount> <character>, /b log. See /help bank.")]
        public static void HandleB(Session session, params string[] parameters) => PlayerCommands.HandleBank(session, parameters);

        // ---------------------------------------------------------------- /top bank

        private static readonly object topLock = new object();
        private static readonly Dictionary<string, (DateTime at, string text)> topCache = new Dictionary<string, (DateTime, string)>();

        [CommandHandler("top", AccessLevel.Player, CommandHandlerFlag.None, 1,
            "Server leaderboards.",
            "/top bank [currency] - the 25 richest banks (pyreals by default; also trophies, luminance)")]
        public static void HandleTop(Session session, params string[] parameters)
        {
            if (!parameters[0].Equals("bank", StringComparison.OrdinalIgnoreCase))
            {
                Say(session, "Usage: /top bank [pyreals | trophies | luminance]");
                return;
            }

            var currency = parameters.Length > 1 ? BankInfo.Find(parameters[1]) : BankInfo.ByCode("pyreals");
            if (currency == null || currency.WithdrawOnly)
            {
                Say(session, "Usage: /top bank [pyreals | trophies | luminance]");
                return;
            }

            lock (topLock)
            {
                if (topCache.TryGetValue(currency.Code, out var cached) && cached.at > DateTime.UtcNow.AddSeconds(-60))
                {
                    Say(session, cached.text);
                    return;
                }
            }

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                    "SELECT account_Id, amount FROM account_bank WHERE currency = @c AND amount > 0 ORDER BY amount DESC LIMIT 100;", ("@c", currency.Code));

                if (rows == null)
                {
                    Say(session, "The bank couldn't be reached. Try again in a moment.");
                    return;
                }

                // the highest level character shown for each account; staff accounts are left out
                var byAccount = PlayerManager.GetAllPlayers()
                    .Where(p => p.Account != null && !p.IsDeleted && !p.IsPendingDeletion)
                    .GroupBy(p => p.Account.AccountId)
                    .ToDictionary(g => g.Key, g => g.OrderByDescending(p => p.Level ?? 0).First());

                var sb = new StringBuilder($"Top banks: {currency.Name}");
                var rank = 0;

                foreach (var r in rows)
                {
                    if (!byAccount.TryGetValue(Convert.ToUInt32(r[0]), out var who) || who.Account.AccessLevel > 0)
                        continue;

                    sb.Append($"\n  {++rank,2}. {who.Name}: {L(r[1]):N0}");
                    if (rank == 25)
                        break;
                }

                if (rank == 0)
                    sb.Append("\n  (nobody yet)");

                var text = sb.ToString();
                lock (topLock)
                    topCache[currency.Code] = (DateTime.UtcNow, text);

                Say(session, text);
            });
        }

        // ---------------------------------------------------------------- /lhs, /lhr

        [CommandHandler("lhs", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Luminance your account sent through the bank recently.",
            "/lhs [days] - default 7")]
        public static void HandleLumSent(Session session, params string[] parameters) => LumHistory(session, parameters, "send");

        [CommandHandler("lhr", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Luminance your account received through the bank recently.",
            "/lhr [days] - default 7")]
        public static void HandleLumReceived(Session session, params string[] parameters) => LumHistory(session, parameters, "receive");

        private static void LumHistory(Session session, string[] parameters, string action)
        {
            var days = 7;
            if (parameters.Length > 0 && (!int.TryParse(parameters[0], out days) || days < 1))
                days = 7;
            days = Math.Min(days, 90);

            var accountId = session.Player.Account.AccountId;
            var sent = action == "send";

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                    @"SELECT other_Character_Name, SUM(ABS(amount)), COUNT(*) FROM account_bank_log
                      WHERE account_Id = @a AND currency = 'luminance' AND action = @ac AND logged_At >= @t
                      GROUP BY other_Character_Name ORDER BY SUM(ABS(amount)) DESC;",
                    ("@a", accountId), ("@ac", action), ("@t", DateTime.UtcNow.AddDays(-days)));

                if (rows == null)
                {
                    Say(session, "The bank couldn't be reached. Try again in a moment.");
                    return;
                }

                if (rows.Count == 0)
                {
                    Say(session, $"Your account {(sent ? "sent" : "received")} no luminance through the bank in the last {days} day{(days == 1 ? "" : "s")}.");
                    return;
                }

                var total = rows.Sum(r => L(r[1]));
                var sb = new StringBuilder($"Luminance {(sent ? "sent" : "received")} in the last {days} day{(days == 1 ? "" : "s")}: {total:N0} in {rows.Sum(r => L(r[2])):N0} transfer(s)");

                foreach (var r in rows.Take(15))
                    sb.Append($"\n  {(sent ? "to" : "from")} {S(r[0])}: {L(r[1]):N0} ({L(r[2])}x)");

                if (rows.Count > 15)
                    sb.Append($"\n  ...and {rows.Count - 15} more");

                Say(session, sb.ToString());
            });
        }

        // ---------------------------------------------------------------- /bankaudit

        [CommandHandler("bankaudit", AccessLevel.Sentinel, CommandHandlerFlag.None, 1,
            "Bank audit: transfers between accounts (bank sends, gives, trades, ground pickups) and bank bans.",
            "/bankaudit log <character> [days] - transfers to or from that character's account (default 7 days)\n" +
            "/bankaudit suspicious [days] - flagged transfers (default 1 day)\n" +
            "/bankaudit top [days] - account pairs that moved the most value (default 7 days)\n" +
            "/bankaudit ip <character> - other accounts seen on the IPs that account used in transfers (last 30 days)\n" +
            "/bankaudit ban <character> [reason] - close that account's bank\n" +
            "/bankaudit unban <character>\n" +
            "/bankaudit bans - every account whose bank is closed\n" +
            "Flags: same_ip, large (transfer_audit_large_*), repeat (transfer_audit_repeat_count), funnel (transfer_audit_funnel_count).")]
        public static void HandleBankAudit(Session session, params string[] parameters)
        {
            var verb = parameters[0].ToLowerInvariant();
            var rest = parameters.Skip(1).ToList();

            // a trailing number is the days
            int TakeDays(int fallback)
            {
                if (rest.Count > 0 && int.TryParse(rest[^1], out var d) && d > 0)
                {
                    rest.RemoveAt(rest.Count - 1);
                    return Math.Min(d, 365);
                }
                return fallback;
            }

            IPlayer Target(string name)
            {
                var t = string.IsNullOrWhiteSpace(name) ? null : PlayerManager.FindByName(name);
                if (t?.Account == null)
                    Say(session, $"No character named {name}.");
                return t;
            }

            string Row(object[] r) // logged_At, kind, from name, to name, item name, quantity, value, flags
            {
                var qty = L(r[5]);
                var value = L(r[6]);
                return $"  {(DateTime)r[0]:MM-dd HH:mm} {S(r[1])} {S(r[2])} -> {S(r[3])}: {(qty != 1 ? $"{qty:N0} " : "")}{S(r[4])}{(value > 0 ? $" ({value:N0}p)" : "")}{(r[7] != null ? $" [{S(r[7])}]" : "")}";
            }

            const string cols = "logged_At, kind, from_Character_Name, to_Character_Name, item_Name, quantity, value, flags";

            TransferAudit.Flush();

            switch (verb)
            {
                case "log":
                {
                    var days = TakeDays(7);
                    var t = Target(string.Join(" ", rest));
                    if (t == null)
                        return;
                    var a = t.Account.AccountId;

                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                            $"SELECT {cols} FROM transfer_log WHERE (from_Account_Id = @a OR to_Account_Id = @a) AND logged_At >= @t ORDER BY id DESC LIMIT 40;",
                            ("@a", a), ("@t", DateTime.UtcNow.AddDays(-days)));
                        if (rows == null) { Say(session, "transfer_log couldn't be read."); return; }
                        Say(session, rows.Count == 0
                            ? $"No transfers for account {t.Account.AccountName} ({t.Name}) in {days} day(s)."
                            : $"Transfers of account {t.Account.AccountName} ({t.Name}), last {days} day(s), newest first (UTC):\n" + string.Join("\n", rows.Select(Row)));
                    });
                    return;
                }

                case "suspicious":
                case "flagged":
                {
                    var days = TakeDays(1);
                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                            $"SELECT {cols} FROM transfer_log WHERE flags IS NOT NULL AND logged_At >= @t ORDER BY id DESC LIMIT 40;",
                            ("@t", DateTime.UtcNow.AddDays(-days)));
                        if (rows == null) { Say(session, "transfer_log couldn't be read."); return; }
                        Say(session, rows.Count == 0
                            ? $"No flagged transfers in {days} day(s)."
                            : $"Flagged transfers, last {days} day(s), newest first (UTC):\n" + string.Join("\n", rows.Select(Row)));
                    });
                    return;
                }

                case "top":
                {
                    var days = TakeDays(7);
                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                            @"SELECT MAX(from_Character_Name), MAX(to_Character_Name), COUNT(*), SUM(value), SUM(flags IS NOT NULL)
                              FROM transfer_log WHERE logged_At >= @t GROUP BY from_Account_Id, to_Account_Id ORDER BY SUM(value) DESC, COUNT(*) DESC LIMIT 15;",
                            ("@t", DateTime.UtcNow.AddDays(-days)));
                        if (rows == null) { Say(session, "transfer_log couldn't be read."); return; }
                        Say(session, rows.Count == 0
                            ? $"No transfers in {days} day(s)."
                            : $"Top account pairs by value moved, last {days} day(s):\n" + string.Join("\n", rows.Select(r =>
                                $"  {S(r[0])} -> {S(r[1])}: {L(r[2]):N0} transfer(s), {L(r[3]):N0}p{(L(r[4]) > 0 ? $", {L(r[4])} flagged" : "")}")));
                    });
                    return;
                }

                case "ip":
                {
                    var t = Target(string.Join(" ", rest));
                    if (t == null)
                        return;
                    var a = t.Account.AccountId;

                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        var since = DateTime.UtcNow.AddDays(-30);
                        var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                            @"SELECT x.ip, x.acct, MAX(x.name), COUNT(*) FROM (
                                  SELECT from_Ip AS ip, from_Account_Id AS acct, from_Character_Name AS name FROM transfer_log WHERE logged_At >= @t
                                  UNION ALL
                                  SELECT to_Ip, to_Account_Id, to_Character_Name FROM transfer_log WHERE logged_At >= @t) x
                              WHERE x.ip IS NOT NULL AND x.ip IN (
                                  SELECT from_Ip FROM transfer_log WHERE from_Account_Id = @a AND logged_At >= @t AND from_Ip IS NOT NULL
                                  UNION SELECT to_Ip FROM transfer_log WHERE to_Account_Id = @a AND logged_At >= @t AND to_Ip IS NOT NULL)
                              GROUP BY x.ip, x.acct ORDER BY x.ip, x.acct LIMIT 60;",
                            ("@a", a), ("@t", since));
                        if (rows == null) { Say(session, "transfer_log couldn't be read."); return; }
                        if (rows.Count == 0) { Say(session, $"Account {t.Account.AccountName} ({t.Name}) has no transfers with a known IP in 30 days."); return; }

                        var sb = new StringBuilder($"IPs account {t.Account.AccountName} ({t.Name}) used in transfers (30 days), and every account seen on them:");
                        foreach (var g in rows.GroupBy(r => S(r[0])))
                        {
                            var others = g.Where(r => Convert.ToUInt32(r[1]) != a).ToList();
                            sb.Append($"\n  {g.Key}: {(others.Count == 0 ? "no other account" : string.Join(", ", others.Select(r => $"{S(r[2])} (account {L(r[1])})")))}");
                        }
                        Say(session, sb.ToString());
                    });
                    return;
                }

                case "ban":
                {
                    if (rest.Count == 0) { Say(session, "/bankaudit ban <character> [reason]"); return; }

                    // the longest prefix that is a character name; the rest is the reason
                    IPlayer t = null;
                    var reason = "";
                    for (var n = rest.Count; n > 0 && t == null; n--)
                    {
                        t = PlayerManager.FindByName(string.Join(" ", rest.Take(n)));
                        if (t?.Account == null)
                            t = null;
                        else
                            reason = string.Join(" ", rest.Skip(n));
                    }
                    if (t == null) { Say(session, $"No character named {string.Join(" ", rest)}."); return; }

                    var by = session?.Player?.Name ?? "console";
                    TransferAudit.SetBankBan(t.Account.AccountId, true, by, reason, ok =>
                        Say(session, ok ? $"The bank of account {t.Account.AccountName} ({t.Name}) is now closed." : "Saved in memory, but account_bank_ban couldn't be written."));
                    PlayerManager.BroadcastToAuditChannel(session?.Player, $"{by} closed the bank of account {t.Account.AccountName} ({t.Name}){(reason.Length > 0 ? $": {reason}" : "")}.");
                    return;
                }

                case "unban":
                {
                    var t = Target(string.Join(" ", rest));
                    if (t == null)
                        return;
                    var by = session?.Player?.Name ?? "console";
                    TransferAudit.SetBankBan(t.Account.AccountId, false, by, null, ok =>
                        Say(session, ok ? $"The bank of account {t.Account.AccountName} ({t.Name}) is open again." : "Removed in memory, but account_bank_ban couldn't be written."));
                    PlayerManager.BroadcastToAuditChannel(session?.Player, $"{by} reopened the bank of account {t.Account.AccountName} ({t.Name}).");
                    return;
                }

                case "bans":
                {
                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery("SELECT account_Id, banned_At, banned_By, reason FROM account_bank_ban ORDER BY banned_At DESC;");
                        if (rows == null) { Say(session, "account_bank_ban couldn't be read."); return; }
                        if (rows.Count == 0) { Say(session, "No bank is closed."); return; }

                        var names = PlayerManager.GetAllPlayers().Where(p => p.Account != null).GroupBy(p => p.Account.AccountId)
                            .ToDictionary(g => g.Key, g => g.OrderByDescending(p => p.Level ?? 0).First().Name);

                        Say(session, "Closed banks:\n" + string.Join("\n", rows.Select(r =>
                        {
                            var acct = Convert.ToUInt32(r[0]);
                            return $"  account {acct} ({(names.TryGetValue(acct, out var n) ? n : "?")}) since {(DateTime)r[1]:yyyy-MM-dd} by {S(r[2])}{(string.IsNullOrEmpty(S(r[3])) ? "" : $": {S(r[3])}")}";
                        })));
                    });
                    return;
                }

                default:
                    Say(session, "/bankaudit log <character> [days] | suspicious [days] | top [days] | ip <character> | ban <character> [reason] | unban <character> | bans");
                    return;
            }
        }

        // ---------------------------------------------------------------- /economystats

        [CommandHandler("economystats", AccessLevel.Sentinel, CommandHandlerFlag.None, 0,
            "Daily economy totals: luminance earned (by source) and spent, pyreals paid out by vendors and spent at vendors.",
            "/economystats [days] [currency] - default 7 days, every currency (e.g. /economystats 30 luminance)")]
        public static void HandleEconomyStats(Session session, params string[] parameters)
        {
            var days = 7;
            string currency = null;

            foreach (var p in parameters)
            {
                if (int.TryParse(p, out var d) && d > 0)
                    days = Math.Min(d, 365);
                else
                    currency = BankInfo.Find(p)?.Code ?? p.ToLowerInvariant();
            }

            EconomyStats.Flush();

            var since = DateTime.UtcNow.Date.AddDays(-(days - 1));

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var rows = DatabaseManager.Shard.BaseDatabase.AuditQuery(
                    "SELECT day, currency, source, amount, transactions FROM economy_daily WHERE day >= @d AND (@c IS NULL OR currency = @c) ORDER BY currency, day;",
                    ("@d", since), ("@c", currency));

                if (rows == null) { Say(session, "economy_daily couldn't be read."); return; }
                if (rows.Count == 0) { Say(session, $"No economy data in the last {days} day(s){(currency != null ? $" for {currency}" : "")}."); return; }

                var sb = new StringBuilder($"Economy, last {days} day(s) (UTC; + entered the game, - left it):");

                foreach (var c in rows.GroupBy(r => S(r[1])))
                {
                    var net = c.Sum(r => L(r[3]));
                    sb.Append($"\n{c.Key}: net {net:+#,0;-#,0;0}");

                    foreach (var s in c.GroupBy(r => S(r[2])).OrderByDescending(g => Math.Abs(g.Sum(r => L(r[3])))))
                        sb.Append($"\n  {s.Key}: {s.Sum(r => L(r[3])):+#,0;-#,0;0} ({s.Sum(r => L(r[4])):N0}x)");

                    if (days > 1)
                        sb.Append("\n  by day: " + string.Join(", ", c.GroupBy(r => (DateTime)r[0]).Select(g => $"{g.Key:MM-dd} {g.Sum(r => L(r[3])):+#,0;-#,0;0}")));
                }

                Say(session, sb.ToString());
            });
        }
    }
}
