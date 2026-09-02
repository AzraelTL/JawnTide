using System.Linq;
using System.Threading;
using Microsoft.EntityFrameworkCore;

using log4net;

using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;

using ACE.Database.Models.Auth;
using ACE.Entity.Enum;
using System.Collections.Generic;
using System;
using System.Net;

namespace ACE.Database
{
    public class AuthenticationDatabase
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public bool Exists(bool retryUntilFound)
        {
            var config = Common.ConfigManager.Config.MySql.Authentication;

            for (; ; )
            {
                using (var context = new AuthDbContext())
                {
                    if (((RelationalDatabaseCreator)context.Database.GetService<IDatabaseCreator>()).Exists())
                    {
                        log.DebugFormat("Successfully connected to {0} database on {1}:{2}.", config.Database, config.Host, config.Port);
                        return true;
                    }
                }

                log.Error($"Attempting to reconnect to {config.Database} database on {config.Host}:{config.Port} in 5 seconds...");

                if (retryUntilFound)
                    Thread.Sleep(5000);
                else
                    return false;
            }
        }


        public int GetAccountCount()
        {
            using (var context = new AuthDbContext())
                return context.Account.Count();
        }

        /// <exception cref="MySqlException">Account with name already exists.</exception>
        public Account CreateAccount(string name, string password, AccessLevel accessLevel, IPAddress address)
        {
            var account = new Account();

            account.AccountName = name;
            account.SetPassword(password);
            account.SetSaltForBCrypt();
            account.AccessLevel = (uint)accessLevel;

            account.CreateTime = DateTime.UtcNow;
            account.CreateIP = address.GetAddressBytes();

            using (var context = new AuthDbContext())
            {
                context.Account.Add(account);

                context.SaveChanges();
            }

            return account;
        }

        /// <summary>
        /// Will return null if the accountId was not found.
        /// </summary>
        public Account GetAccountById(uint accountId)
        {
            using (var context = new AuthDbContext())
            {
                return context.Account
                    .AsNoTracking()
                    .FirstOrDefault(r => r.AccountId == accountId);
            }
        }

        /// <summary>
        /// Will return null if the accountName was not found.
        /// </summary>
        public Account GetAccountByName(string accountName)
        {
            using (var context = new AuthDbContext())
            {
                return context.Account
                    .AsNoTracking()
                    .FirstOrDefault(r => r.AccountName == accountName);
            }
        }

        /// <summary>
        /// id will be 0 if the accountName was not found.
        /// </summary>
        public uint GetAccountIdByName(string accountName)
        {
            using (var context = new AuthDbContext())
            {
                var result = context.Account
                    .AsNoTracking()
                    .FirstOrDefault(r => r.AccountName == accountName);

                return (result != null) ? result.AccountId : 0;
            }
        }

        public void UpdateAccount(Account account)
        {
            using (var context = new AuthDbContext())
            {
                context.Entry(account).State = EntityState.Modified;

                context.SaveChanges();
            }
        }

        public bool UpdateAccountAccessLevel(uint accountId, AccessLevel accessLevel)
        {
            using (var context = new AuthDbContext())
            {
                var account = context.Account
                    .First(r => r.AccountId == accountId);

                if (account == null)
                    return false;

                account.AccessLevel = (uint)accessLevel;

                context.SaveChanges();
            }

            return true;
        }

        public List<string> GetListofAccountsByAccessLevel(AccessLevel accessLevel)
        {
            using (var context = new AuthDbContext())
            {
                var results = context.Account
                    .AsNoTracking()
                    .Where(r => r.AccessLevel == Convert.ToUInt32(accessLevel)).ToList();

                var result = new List<string>();
                foreach (var account in results)
                    result.Add(account.AccountName);

                return result;
            }
        }

        public List<string> GetListofBannedAccounts()
        {
            using (var context = new AuthDbContext())
            {
                var results = context.Account
                    .AsNoTracking()
                    .Where(r => r.BanExpireTime > DateTime.UtcNow).ToList();

                var result = new List<string>();
                foreach (var account in results)
                {
                    var bannedbyAccount = account.BannedByAccountId.Value > 0 ? $"account {GetAccountById(account.BannedByAccountId.Value).AccountName}" : "CONSOLE";
                    result.Add($"{account.AccountName} -- banned by {bannedbyAccount} until server time {account.BanExpireTime.Value.ToLocalTime():MMM dd yyyy  h:mmtt}{(!string.IsNullOrWhiteSpace(account.BanReason) ? $" -- Reason: {account.BanReason}" : "")}");
                }

                return result;
            }
        }

        // -------------------------------------------------------------------------
        // IP Binding
        // -------------------------------------------------------------------------

        /// <summary>Returns all IP addresses ever associated with an account, newest first.</summary>
        public List<AccountIpBinding> GetIpBindings(uint accountId)
        {
            using (var context = new AuthDbContext())
                return context.AccountIpBinding.AsNoTracking()
                    .Where(r => r.AccountId == accountId)
                    .OrderByDescending(r => r.BoundAt)
                    .ToList();
        }

        /// <summary>Returns the first binding that owns the given IP address, or null if unclaimed.</summary>
        public AccountIpBinding GetIpBindingByIp(string ip)
        {
            using (var context = new AuthDbContext())
                return context.AccountIpBinding.AsNoTracking().FirstOrDefault(r => r.IpAddress == ip);
        }

        /// <summary>
        /// Returns every binding row for the given IP address. An IP may be shared by more than one
        /// account (up to the configured allowance), so use this to count distinct accounts on an IP.
        /// </summary>
        public List<AccountIpBinding> GetIpBindingsByIp(string ip)
        {
            using (var context = new AuthDbContext())
                return context.AccountIpBinding.AsNoTracking()
                    .Where(r => r.IpAddress == ip)
                    .OrderBy(r => r.BoundAt)
                    .ToList();
        }

        /// <summary>Adds an IP address to an account's known-IP set.</summary>
        public void CreateIpBinding(uint accountId, string ip, string boundBy = "login")
        {
            using (var context = new AuthDbContext())
            {
                context.AccountIpBinding.Add(new AccountIpBinding
                {
                    AccountId = accountId,
                    IpAddress = ip,
                    BoundAt   = DateTime.UtcNow,
                    BoundBy   = boundBy
                });
                context.SaveChanges();
            }
        }

        /// <summary>Removes all IP bindings for an account (admin clear).</summary>
        public void DeleteIpBinding(uint accountId)
        {
            using (var context = new AuthDbContext())
            {
                var bindings = context.AccountIpBinding.Where(r => r.AccountId == accountId).ToList();
                if (bindings.Count > 0)
                {
                    context.AccountIpBinding.RemoveRange(bindings);
                    context.SaveChanges();
                }
            }
        }

        /// <summary>Appends a record to the IP change audit log.</summary>
        public void InsertIpChangeLog(uint accountId, string oldIp, string newIp, bool autoBanned)
        {
            using (var context = new AuthDbContext())
            {
                context.AccountIpChangeLog.Add(new AccountIpChangeLog
                {
                    AccountId    = accountId,
                    OldIp        = oldIp,
                    NewIp        = newIp,
                    ChangedAt    = DateTime.UtcNow,
                    AutoBanned   = autoBanned,
                    AdminCleared = false
                });
                context.SaveChanges();
            }
        }

        /// <summary>Returns recent IP change log entries for an account, newest first.</summary>
        public List<AccountIpChangeLog> GetIpChangeLog(uint accountId, int limit = 10)
        {
            using (var context = new AuthDbContext())
                return context.AccountIpChangeLog
                    .AsNoTracking()
                    .Where(r => r.AccountId == accountId)
                    .OrderByDescending(r => r.ChangedAt)
                    .Take(limit)
                    .ToList();
        }
    }
}
