using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ACE.Database
{
    public partial class SerializedShardDatabase
    {
        // JawnTide Bank: these run on the same single save queue as character and item saves, so a bank credit
        // queued after an item delete (or a player save) is always written after it. The callback runs on the
        // database thread: hand the result back to the player's own action queue before touching the player.

        public void GetAccountBank(uint accountId, Action<Dictionary<string, long>> callback)
        {
            _queue.Add(new Task(() =>
            {
                var result = BaseDatabase.GetAccountBank(accountId);
                callback?.Invoke(result);
            }));
        }

        public void BankChange(uint accountId, string currency, long delta, BankLogInfo info, Action<BankResult> callback)
        {
            _queue.Add(new Task(() =>
            {
                var result = BaseDatabase.BankChange(accountId, currency, delta, info);
                callback?.Invoke(result);
            }));
        }

        public void BankTransfer(uint fromAccountId, uint toAccountId, string currency, long amount, uint fromCharacterId, string fromCharacterName, uint toCharacterId, string toCharacterName, string details, Action<BankResult> callback)
        {
            _queue.Add(new Task(() =>
            {
                var result = BaseDatabase.BankTransfer(fromAccountId, toAccountId, currency, amount, fromCharacterId, fromCharacterName, toCharacterId, toCharacterName, details);
                callback?.Invoke(result);
            }));
        }

        public void GetAccountBankLog(uint accountId, int count, Action<List<(DateTime time, string characterName, string action, string currency, long amount, long balanceAfter, string otherCharacterName)>> callback)
        {
            _queue.Add(new Task(() =>
            {
                var result = BaseDatabase.GetAccountBankLog(accountId, count);
                callback?.Invoke(result);
            }));
        }
    }
}
