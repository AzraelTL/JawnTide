using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;

using log4net;

using ACE.Database;
using ACE.Database.Models.Auth;
using ACE.Entity.Enum;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.Network.Handlers;

namespace ACE.Server.Command.Handlers
{
    public static class AccountCommands
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        // accountcreate username password (accesslevel)
        [CommandHandler("accountcreate", AccessLevel.Admin, CommandHandlerFlag.None, 2,
            "Creates a new account.",
            "username password (accesslevel)\n" +
            "accesslevel can be a number or enum name\n" +
            "0 = Player | 1 = Advocate | 2 = Sentinel | 3 = Envoy | 4 = Developer | 5 = Admin")]
        public static void HandleAccountCreate(Session session, params string[] parameters)
        {
            AccessLevel defaultAccessLevel = (AccessLevel)Common.ConfigManager.Config.Server.Accounts.DefaultAccessLevel;

            if (!Enum.IsDefined(typeof(AccessLevel), defaultAccessLevel))
                defaultAccessLevel = AccessLevel.Player;

            var accessLevel = defaultAccessLevel;

            if (parameters.Length > 2)
            {
                if (Enum.TryParse(parameters[2], true, out accessLevel))
                {
                    if (!Enum.IsDefined(typeof(AccessLevel), accessLevel))
                        accessLevel = defaultAccessLevel;
                }
            }

            string articleAorAN = "a";
            if (accessLevel == AccessLevel.Advocate || accessLevel == AccessLevel.Admin || accessLevel == AccessLevel.Envoy)
                articleAorAN = "an";

            string message = "";

            var accountExists = DatabaseManager.Authentication.GetAccountByName(parameters[0]);
                      
            if (accountExists != null)
            {
                message= "Account already exists. Try a new name.";
            }
            else
            {
                try
                {
                    var account = DatabaseManager.Authentication.CreateAccount(parameters[0].ToLower(), parameters[1], accessLevel, IPAddress.Parse("127.0.0.1"));

                    if (DatabaseManager.AutoPromoteNextAccountToAdmin && accessLevel == AccessLevel.Admin)
                        DatabaseManager.AutoPromoteNextAccountToAdmin = false;

                    message = ("Account successfully created for " + account.AccountName + " (" + account.AccountId + ") with access rights as " + articleAorAN + " " + Enum.GetName(typeof(AccessLevel), accessLevel) + ".");
                }
                catch
                {
                    message = "Account already exists. Try a new name.";
                }
            }

            CommandHandlerHelper.WriteOutputInfo(session, message, ChatMessageType.WorldBroadcast);
        }
  
        [CommandHandler("accountget", AccessLevel.Admin, CommandHandlerFlag.ConsoleInvoke, 1,
            "Gets an account.",
            "username")]
        public static void HandleAccountGet(Session session, params string[] parameters)
        {
            var account = DatabaseManager.Authentication.GetAccountByName(parameters[0]);
            Console.WriteLine($"User: {account.AccountName}, ID: {account.AccountId}");
        }

        // set-accountaccess accountname (accesslevel)
        [CommandHandler("set-accountaccess", AccessLevel.Admin, CommandHandlerFlag.None, 1, 
            "Change the access level of an account.", 
            "accountname (accesslevel)\n" +
            "accesslevel can be a number or enum name\n" +
            "0 = Player | 1 = Advocate | 2 = Sentinel | 3 = Envoy | 4 = Developer | 5 = Admin")]
        public static void HandleAccountUpdateAccessLevel(Session session, params string[] parameters)
        {
            string accountName  = parameters[0].ToLower();

            var accountId = DatabaseManager.Authentication.GetAccountIdByName(accountName);

            if (accountId == 0)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Account " + accountName + " does not exist.", ChatMessageType.Broadcast);
                return;
            }

            AccessLevel accessLevel = AccessLevel.Player;

            if (parameters.Length > 1)
            {
                if (Enum.TryParse(parameters[1], true, out accessLevel))
                {
                    if (!Enum.IsDefined(typeof(AccessLevel), accessLevel))
                        accessLevel = AccessLevel.Player;
                }
            }

            string articleAorAN = "a";
            if (accessLevel == AccessLevel.Advocate || accessLevel == AccessLevel.Admin || accessLevel == AccessLevel.Envoy)
                articleAorAN = "an";

            if (accountId == 0)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Account " + accountName + " does not exist.", ChatMessageType.Broadcast);
                return;
            }

            DatabaseManager.Authentication.UpdateAccountAccessLevel(accountId, accessLevel);

            if (DatabaseManager.AutoPromoteNextAccountToAdmin && accessLevel == AccessLevel.Admin)
                DatabaseManager.AutoPromoteNextAccountToAdmin = false;

            CommandHandlerHelper.WriteOutputInfo(session, "Account " + accountName + " updated with access rights set as " + articleAorAN + " " + Enum.GetName(typeof(AccessLevel), accessLevel) + ".", ChatMessageType.Broadcast);
        }

        // set-accountpassword accountname newpassword
        [CommandHandler("set-accountpassword", AccessLevel.Admin, CommandHandlerFlag.None, 2,
            "Set the account password.",
            "accountname newpassword\n")]
        public static void HandleAccountSetPassword(Session session, params string[] parameters)
        {
            string accountName = parameters[0].ToLower();

            var account = DatabaseManager.Authentication.GetAccountByName(accountName);

            if (account == null)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Account " + accountName + " does not exist.", ChatMessageType.Broadcast);
                return;
            }

            if (parameters.Length < 1)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "You must specify a password for the account.", ChatMessageType.Broadcast);
                return;
            }

            account.SetPassword(parameters[1]);
            account.SetSaltForBCrypt();

            DatabaseManager.Authentication.UpdateAccount(account);

            CommandHandlerHelper.WriteOutputInfo(session, $"Account password for {accountName} successfully changed.", ChatMessageType.Broadcast);
        }

        /// <summary>
        /// Rate limiter for /passwd command
        /// </summary>
        private static readonly TimeSpan PasswdInterval = TimeSpan.FromSeconds(5);

        // passwd oldpassword newpassword
        [CommandHandler("passwd", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 2,
            "Change your account password.",
            "oldpassword newpassword\n")]
        public static void HandlePasswd(Session session, params string[] parameters)
        {
            if (session == null)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "This command is run from ingame client only", ChatMessageType.Broadcast);
                return;
            }
            else if (!PlayerCommands.CheckPlayerCommandRateLimit(session))
            {
                return;
            }


            log.DebugFormat("{0} is changing their password", session.Player.Name);

            var currentTime = DateTime.UtcNow;

            if (currentTime - session.LastPassTime < PasswdInterval)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"This command may only be run once every {PasswdInterval.TotalSeconds} seconds.", ChatMessageType.Broadcast);
                return;
            }
            session.LastPassTime = currentTime;

            if (parameters.Length <= 0)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "You must specify the current password for the account.", ChatMessageType.Broadcast);
                return;
            }

            if (parameters.Length < 1)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "You must specify a new password for the account.", ChatMessageType.Broadcast);
                return;
            }

            var account = DatabaseManager.Authentication.GetAccountById(session.AccountId);

            if (account == null)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"Account {session.Account} ({session.AccountId}) wasn't found in the database! How are you in world without a valid account?", ChatMessageType.Broadcast);                
                return;
            }

            var oldpassword = parameters[0];
            var newpassword = parameters[1];

            if (account.PasswordMatches(oldpassword))
            {
                account.SetPassword(newpassword);
                account.SetSaltForBCrypt();
            }
            else
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"Unable to change password: Password provided in first parameter does not match current account password for this account!", ChatMessageType.Broadcast);
                return;
            }


            DatabaseManager.Authentication.UpdateAccount(account);

            CommandHandlerHelper.WriteOutputInfo(session, "Account password successfully changed.", ChatMessageType.Broadcast);
        }

        // clearipbinding accountname
        [CommandHandler("clearipbinding", AccessLevel.Admin, CommandHandlerFlag.None, 1,
            "Removes all known IP bindings for an account. Their next login will start fresh.",
            "accountname")]
        public static void HandleClearIpBinding(Session session, params string[] parameters)
        {
            var accountName = parameters[0].ToLower();
            var account     = DatabaseManager.Authentication.GetAccountByName(accountName);

            if (account == null)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"Account '{accountName}' does not exist.", ChatMessageType.Broadcast);
                return;
            }

            var bindings = DatabaseManager.Authentication.GetIpBindings(account.AccountId);
            var ipList   = bindings.Count > 0 ? string.Join(", ", bindings.Select(b => b.IpAddress)) : "(none)";

            DatabaseManager.Authentication.DeleteIpBinding(account.AccountId);

            var adminName = session?.Player?.Name ?? "CONSOLE";
            log.Info($"[IPBinding] Admin '{adminName}' cleared all IP bindings for account '{accountName}' (removed: {ipList}).");

            CommandHandlerHelper.WriteOutputInfo(session,
                $"Cleared {bindings.Count} IP binding(s) for '{accountName}' ({ipList}). Their next login will create a fresh binding.",
                ChatMessageType.Broadcast);
        }

        // checkipbinding accountname
        [CommandHandler("checkipbinding", AccessLevel.Admin, CommandHandlerFlag.None, 1,
            "Displays all known IP addresses for an account and their recent IP change history.",
            "accountname")]
        public static void HandleCheckIpBinding(Session session, params string[] parameters)
        {
            var accountName = parameters[0].ToLower();
            var account     = DatabaseManager.Authentication.GetAccountByName(accountName);

            if (account == null)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"Account '{accountName}' does not exist.", ChatMessageType.Broadcast);
                return;
            }

            var bindings  = DatabaseManager.Authentication.GetIpBindings(account.AccountId);
            var changeLog = DatabaseManager.Authentication.GetIpChangeLog(account.AccountId, limit: 10);

            var sb = new StringBuilder();
            sb.AppendLine($"=== IP Binding: '{account.AccountName}' ===");

            if (bindings.Count == 0)
            {
                sb.AppendLine("Known IPs   : (none - will bind on next login)");
            }
            else
            {
                sb.AppendLine($"Known IPs ({bindings.Count}):");
                foreach (var b in bindings)
                {
                    var sharedBy  = DatabaseManager.Authentication.GetIpBindingsByIp(b.IpAddress)
                        .Select(x => x.AccountId).Distinct().Count();
                    var allowance = AuthenticationHandler.GetIpAllowance(b.IpAddress);
                    var shareNote = sharedBy > 1 ? $", {sharedBy} accounts share this IP" : "";
                    sb.AppendLine($"  {b.IpAddress}  (first seen {b.BoundAt:yyyy-MM-dd HH:mm} UTC, source: {b.BoundBy}; allowance {allowance}{shareNote})");
                }
            }

            if (changeLog.Count == 0)
            {
                sb.AppendLine("Change log  : (none)");
            }
            else
            {
                sb.AppendLine("Recent IP changes (newest first):");
                foreach (var entry in changeLog)
                    sb.AppendLine($"  {entry.ChangedAt:yyyy-MM-dd HH:mm} UTC  {entry.OldIp} -> {entry.NewIp}");
            }

            CommandHandlerHelper.WriteOutputInfo(session, sb.ToString(), ChatMessageType.Broadcast);
        }

        // setipallowance ip count
        [CommandHandler("setipallowance", AccessLevel.Admin, CommandHandlerFlag.None, 2,
            "Sets how many distinct accounts may bind to a single IP address (edits the ip_binding_ip_allowance property).",
            "ip count\n" +
            "count of 1 or less removes the override (that IP returns to the default of one account per IP).\n" +
            "Example: /setipallowance 203.0.113.42 2")]
        public static void HandleSetIpAllowance(Session session, params string[] parameters)
        {
            var ip = parameters[0].Trim();

            if (!int.TryParse(parameters[1].Trim(), out var count))
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"'{parameters[1]}' is not a valid number.", ChatMessageType.Broadcast);
                return;
            }

            // Parse the current property into a map keyed by IP (last entry wins, case-insensitive).
            var map = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            var raw = PropertyManager.GetString("ip_binding_ip_allowance").Item;
            foreach (var entry in raw.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                var sep = entry.LastIndexOf(':');
                if (sep <= 0 || sep == entry.Length - 1)
                    continue;
                var entryIp = entry.Substring(0, sep).Trim();
                if (int.TryParse(entry.Substring(sep + 1).Trim(), out var c) && c >= 1)
                    map[entryIp] = c;
            }

            string resultMsg;
            if (count <= 1)
            {
                if (map.Remove(ip))
                    resultMsg = $"Removed the allowance override for {ip}. It now uses the default of 1 account per IP.";
                else
                    resultMsg = $"{ip} had no allowance override; it already uses the default of 1 account per IP.";
            }
            else
            {
                map[ip] = count;
                resultMsg = $"{ip} may now bind up to {count} distinct accounts.";
            }

            var serialized = string.Join(", ", map.Select(kvp => $"{kvp.Key}:{kvp.Value}"));
            PropertyManager.ModifyString("ip_binding_ip_allowance", serialized);

            var adminName = session?.Player?.Name ?? "CONSOLE";
            log.Info($"[IPBinding] Admin '{adminName}' set ip_binding_ip_allowance to '{serialized}' (change: {ip} -> {count}).");

            CommandHandlerHelper.WriteOutputInfo(session, resultMsg, ChatMessageType.Broadcast);
        }
    }
}
