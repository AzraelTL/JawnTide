using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using ACE.Database;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Managers;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    partial class Player
    {
        // -------------------------------------------------------------------------
        // JawnTide Bank: one balance per account (shard tables account_bank / account_bank_log), shared by every
        // character on the account. Holds pyreals (coins and trade notes, by value), PK Trophies, single-use keys
        // and luminance. Closed while PK tagged or in an arena (same rule as My Mule).
        //
        // Ordering, so a crash can never duplicate anything:
        //   deposit:  items are deleted / the player is saved first, then the credit is queued behind them on the
        //             same serial save queue. A crash in between loses the deposit; it can't keep both.
        //   withdraw: the debit is written first (and fails if the balance is short), then the items are created
        //             on the player's thread and the player is saved. Anything that doesn't fit is refunded.
        // -------------------------------------------------------------------------

        /// <summary>Bank operations queued but not finished yet. Not persisted.</summary>
        private int bankPending;

        private void BankMessage(string text) => Session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

        /// <summary>Runs on this player's own thread (DB callbacks arrive on the database thread).</summary>
        private void BankOnPlayer(Action action) => EnqueueAction(new ActionEventDelegate(action));

        private BankLogInfo BankLogFor(string action, string details = null) => new BankLogInfo
        {
            CharacterId = Guid.Full,
            CharacterName = Name,
            Action = action,
            Details = details
        };

        /// <summary>Why the bank is closed right now, or null if it's open.</summary>
        public string BankClosedReason(bool checkPending = true)
        {
            if (IsDead)
                return "You can't use the bank while dead.";

            if (PKTimerActive)
                return "The bank is closed to you while you're PK tagged.";

            if (IsArenaObserver || (Location != null && ArenaLocation.IsArenaLandblock(Location.Landblock)))
                return "The bank can't be used in an arena.";

            if (IsTrading)
                return "Finish your trade before using the bank.";

            if (IsLoggingOut || Teleporting)
                return "You can't use the bank right now.";

            if (checkPending && bankPending > 0)
                return "Your last bank request is still being processed. Try again in a moment.";

            return null;
        }

        private bool BankCheckOpen()
        {
            var why = BankClosedReason();

            if (why == null)
                return true;

            BankMessage(why);
            return false;
        }

        // ---------------------------------------------------------------- balance / log

        public void BankShowBalance()
        {
            var accountId = Account.AccountId;

            DatabaseManager.Shard.GetAccountBank(accountId, balances => BankOnPlayer(() =>
            {
                if (balances == null)
                {
                    BankMessage("The bank couldn't be reached. Try again in a moment.");
                    return;
                }

                var sb = new StringBuilder("Your bank (shared by every character on your account):");

                foreach (var currency in BankInfo.Currencies)
                {
                    balances.TryGetValue(currency.Code, out var amount);
                    sb.Append($"\n  {currency.Name}: {amount:N0}");
                }

                BankMessage(sb.ToString());
            }));
        }

        public void BankShowLog(int count)
        {
            var accountId = Account.AccountId;

            DatabaseManager.Shard.GetAccountBankLog(accountId, count, rows => BankOnPlayer(() =>
            {
                if (rows == null)
                {
                    BankMessage("The bank couldn't be reached. Try again in a moment.");
                    return;
                }

                if (rows.Count == 0)
                {
                    BankMessage("Your bank has no history yet.");
                    return;
                }

                var sb = new StringBuilder($"Your last {rows.Count} bank entries (newest first, UTC):");

                foreach (var r in rows)
                {
                    var name = BankInfo.ByCode(r.currency)?.Name ?? r.currency;
                    var who = r.action switch
                    {
                        "send" => $" to {r.otherCharacterName}",
                        "receive" => $" from {r.otherCharacterName}",
                        _ => ""
                    };
                    sb.Append($"\n  {r.time:MM-dd HH:mm} {r.characterName}: {r.action}{who} {r.amount:+#,0;-#,0} {name} (balance {r.balanceAfter:N0})");
                }

                BankMessage(sb.ToString());
            }));
        }

        // ---------------------------------------------------------------- deposit

        /// <summary>Deposits every bankable currency except luminance.</summary>
        public void BankDepositAll()
        {
            if (!BankCheckOpen())
                return;

            var any = false;

            foreach (var currency in BankInfo.Currencies.Where(c => c.Kind != BankCurrencyKind.Luminance))
                any |= BankDepositInternal(currency, null, quietIfNone: true);

            if (!any)
                BankMessage("You have nothing to deposit. (Luminance is only deposited with /bank deposit luminance.)");
        }

        /// <summary>Deposits one currency. amount null = all of it.</summary>
        public void BankDeposit(BankCurrency currency, long? amount)
        {
            if (!BankCheckOpen())
                return;

            BankDepositInternal(currency, amount, quietIfNone: false);
        }

        /// <summary>Takes the currency from the player, then queues the credit behind the deletes / save. Returns true if anything was taken.</summary>
        private bool BankDepositInternal(BankCurrency currency, long? amount, bool quietIfNone)
        {
            long taken = 0;
            var details = "";

            switch (currency.Kind)
            {
                case BankCurrencyKind.Pyreals:
                {
                    if (amount.HasValue)
                    {
                        // a set amount comes from coins only (notes can't be split)
                        var coins = GetInventoryItemsOfWCID(BankInfo.PyrealWcid).Sum(i => (long)(i.StackSize ?? 1));

                        if (coins < amount.Value)
                        {
                            BankMessage($"You only have {coins:N0} pyreal coins. To bank trade notes, use /bank deposit pyreals with no amount.");
                            return false;
                        }

                        if (amount.Value > int.MaxValue || !TryConsumeFromInventoryWithNetworking(BankInfo.PyrealWcid, (int)amount.Value))
                        {
                            BankMessage("Those pyreals couldn't be taken.");
                            return false;
                        }

                        taken = amount.Value;
                        details = "coins";
                    }
                    else
                    {
                        long coinTotal = 0, noteTotal = 0;

                        foreach (var item in GetInventoryItemsOfWCID(BankInfo.PyrealWcid))
                        {
                            var value = (long)(item.StackSize ?? 1);
                            if (TryConsumeFromInventoryWithNetworking(item))
                                coinTotal += value;
                        }

                        foreach (var (wcid, unit) in BankInfo.TradeNoteValues)
                        {
                            foreach (var item in GetInventoryItemsOfWCID(wcid))
                            {
                                var value = unit * (item.StackSize ?? 1);
                                if (TryConsumeFromInventoryWithNetworking(item))
                                    noteTotal += value;
                            }
                        }

                        taken = coinTotal + noteTotal;
                        details = $"coins {coinTotal:N0}, notes {noteTotal:N0}";
                    }

                    UpdateCoinValue();
                    break;
                }

                case BankCurrencyKind.Stack:
                {
                    var have = GetInventoryItemsOfWCID(currency.Wcid).Sum(i => (long)(i.StackSize ?? 1));
                    var want = amount ?? have;

                    if (have < want || want > int.MaxValue)
                    {
                        BankMessage($"You only have {BankInfo.Format(currency, have)}.");
                        return false;
                    }

                    if (want > 0 && TryConsumeFromInventoryWithNetworking(currency.Wcid, (int)want))
                        taken = want;
                    break;
                }

                case BankCurrencyKind.Key:
                {
                    // unused keys only (a single-use key with no uses left isn't worth banking)
                    var keys = GetInventoryItemsOfWCID(currency.Wcid).Where(k => (k.Structure ?? 1) >= (k.MaxStructure ?? 1) && (k.Structure ?? 1) > 0).ToList();
                    var want = amount ?? keys.Count;

                    if (keys.Count < want)
                    {
                        BankMessage($"You only have {keys.Count:N0} unused {currency.Name}.");
                        return false;
                    }

                    foreach (var key in keys.Take((int)want))
                    {
                        if (TryConsumeFromInventoryWithNetworking(key))
                            taken++;
                    }
                    break;
                }

                case BankCurrencyKind.Luminance:
                {
                    var available = AvailableLuminance ?? 0;
                    var want = amount ?? available;

                    if (want > available)
                    {
                        BankMessage($"You only have {available:N0} luminance.");
                        return false;
                    }

                    if (want > 0 && SpendLuminance(want))
                        taken = want;
                    break;
                }
            }

            if (taken <= 0)
            {
                if (!quietIfNone)
                    BankMessage($"You have no {currency.Name} to deposit.");
                return false;
            }

            // the deletes are already queued (Destroy); this queues the changed stacks / luminance, then the credit goes in behind them
            SavePlayerToDatabase();

            bankPending++;

            var accountId = Account.AccountId;
            var deposited = taken;

            DatabaseManager.Shard.BankChange(accountId, currency.Code, deposited, BankLogFor("deposit", details), result => BankOnPlayer(() =>
            {
                bankPending = Math.Max(0, bankPending - 1);

                if (result.Status == BankResultStatus.Ok)
                {
                    BankMessage($"Deposited {BankInfo.Format(currency, deposited)}. Bank balance: {result.Balance:N0}.");
                    return;
                }

                log.Error($"[BANK] Deposit of {deposited} {currency.Code} by {Name} (0x{Guid.Full:X8}, account {accountId}) was taken but NOT credited ({result.Status}). Restore it by hand.");
                BankMessage($"Your deposit of {BankInfo.Format(currency, deposited)} couldn't be recorded. It has been logged; please tell an admin.");
            }));

            return true;
        }

        // ---------------------------------------------------------------- withdraw

        /// <summary>Builds (but doesn't place) the items for a withdrawal.</summary>
        private List<WorldObject> BankBuildItems(BankCurrency currency, long amount, bool coinsOnly)
        {
            var items = new List<WorldObject>();

            void AddStacks(uint wcid, long count)
            {
                while (count > 0)
                {
                    var wo = WorldObjectFactory.CreateNewWorldObject(wcid);

                    if (wo == null)
                    {
                        log.Error($"[BANK] Couldn't create wcid {wcid} for {Name}'s withdrawal.");
                        foreach (var made in items)
                            made.Destroy();
                        items = null;
                        return;
                    }

                    var max = Math.Max(1, (int)(wo.MaxStackSize ?? 1));
                    var size = (int)Math.Min(count, max);

                    if (max > 1)
                        wo.SetStackSize(size);

                    items.Add(wo);
                    count -= size;
                }
            }

            switch (currency.Kind)
            {
                case BankCurrencyKind.Pyreals:
                    if (!coinsOnly && amount >= BankInfo.MMDValue)
                    {
                        AddStacks(BankInfo.MMDWcid, amount / BankInfo.MMDValue);
                        if (items == null) return null;
                        amount %= BankInfo.MMDValue;
                    }
                    if (amount > 0)
                        AddStacks(BankInfo.PyrealWcid, amount);
                    break;

                case BankCurrencyKind.Stack:
                case BankCurrencyKind.Key:
                    AddStacks(currency.Wcid, amount);
                    break;
            }

            return items;
        }

        /// <summary>The pyreal value / count an item stands for, for refunds.</summary>
        private static long BankItemWorth(BankCurrency currency, WorldObject item)
        {
            var stack = (long)(item.StackSize ?? 1);

            if (currency.Kind == BankCurrencyKind.Pyreals && item.WeenieClassId == BankInfo.MMDWcid)
                return stack * BankInfo.MMDValue;

            return stack;
        }

        public void BankWithdraw(BankCurrency currency, long amount, bool coinsOnly)
        {
            if (!BankCheckOpen())
                return;

            if (amount <= 0)
            {
                BankMessage("The amount must be more than zero.");
                return;
            }

            List<WorldObject> items = null;

            if (currency.Kind == BankCurrencyKind.Luminance)
            {
                if (MaximumLuminance == null)
                {
                    BankMessage("You can't hold luminance yet.");
                    return;
                }

                var room = (MaximumLuminance ?? 0) - (AvailableLuminance ?? 0);

                if (amount > room)
                {
                    BankMessage($"You only have room for {room:N0} more luminance.");
                    return;
                }
            }
            else
            {
                // keep a single request sane: 100 keys, or what fits in a pack
                if (currency.Kind == BankCurrencyKind.Key && amount > 100)
                {
                    BankMessage("You can withdraw up to 100 keys at a time.");
                    return;
                }

                if (currency.Kind == BankCurrencyKind.Pyreals && coinsOnly && amount > 2_500_000)
                {
                    BankMessage("You can withdraw up to 2,500,000 pyreals as coins at a time.");
                    return;
                }

                items = BankBuildItems(currency, amount, coinsOnly);

                if (items == null || items.Count == 0)
                {
                    BankMessage("That withdrawal couldn't be made.");
                    return;
                }

                if (!CanAddToInventory(items, out var tooHeavy, out var noRoom))
                {
                    foreach (var item in items)
                        item.Destroy();

                    BankMessage(tooHeavy ? "You're carrying too much to take that out." : $"You don't have enough pack space for that ({items.Count} slots needed).");
                    return;
                }
            }

            bankPending++;

            var accountId = Account.AccountId;
            var playerGuid = Guid.Full;
            var playerName = Name;

            DatabaseManager.Shard.BankChange(accountId, currency.Code, -amount, BankLogFor("withdraw", coinsOnly ? "coins" : null), result =>
            {
                // database thread: if the character already left, put it straight back
                if (result.Status == BankResultStatus.Ok && PlayerManager.GetOnlinePlayer(playerGuid) != this)
                {
                    DatabaseManager.Shard.BaseDatabase.BankChange(accountId, currency.Code, amount, new BankLogInfo { CharacterId = playerGuid, CharacterName = playerName, Action = "refund", Details = "logged out before the withdrawal was handed over" });
                    return;
                }

                BankOnPlayer(() => BankFinishWithdraw(currency, amount, items, result));
            });
        }

        private void BankFinishWithdraw(BankCurrency currency, long amount, List<WorldObject> items, BankResult result)
        {
            bankPending = Math.Max(0, bankPending - 1);

            if (result.Status != BankResultStatus.Ok)
            {
                if (items != null)
                    foreach (var item in items)
                        item.Destroy();

                BankMessage(result.Status == BankResultStatus.Insufficient
                    ? $"Your bank doesn't have {BankInfo.Format(currency, amount)}. Use /bank to see your balance."
                    : "The bank couldn't be reached. Nothing was taken out.");
                return;
            }

            long refund = 0;

            if (currency.Kind == BankCurrencyKind.Luminance)
            {
                var room = Math.Max(0, (MaximumLuminance ?? 0) - (AvailableLuminance ?? 0));
                var give = Math.Min(room, amount);

                AvailableLuminance = (AvailableLuminance ?? 0) + give;
                UpdateLuminance();

                refund = amount - give;
            }
            else
            {
                foreach (var item in items)
                {
                    if (!TryCreateInInventoryWithNetworking(item))
                    {
                        refund += BankItemWorth(currency, item);
                        item.Destroy();
                    }
                }

                if (currency.Kind == BankCurrencyKind.Pyreals)
                    UpdateCoinValue();
            }

            SavePlayerToDatabase();

            var handed = amount - refund;

            if (refund <= 0)
            {
                BankMessage($"Withdrew {BankInfo.Format(currency, amount)}. Bank balance: {result.Balance:N0}.");
                return;
            }

            bankPending++;

            DatabaseManager.Shard.BankChange(Account.AccountId, currency.Code, refund, BankLogFor("refund", "did not fit"), refundResult => BankOnPlayer(() =>
            {
                bankPending = Math.Max(0, bankPending - 1);

                if (refundResult.Status == BankResultStatus.Ok)
                    BankMessage($"Withdrew {BankInfo.Format(currency, handed)}. {refund:N0} didn't fit and went back into the bank. Bank balance: {refundResult.Balance:N0}.");
                else
                {
                    log.Error($"[BANK] Refund of {refund} {currency.Code} to account {Account.AccountId} ({Name}) failed ({refundResult.Status}). Restore it by hand.");
                    BankMessage($"Withdrew {BankInfo.Format(currency, handed)}. {refund:N0} didn't fit and couldn't be put back; it has been logged, please tell an admin.");
                }
            }));
        }

        // ---------------------------------------------------------------- transfer

        public void BankSend(BankCurrency currency, long amount, string targetName)
        {
            if (!BankCheckOpen())
                return;

            if (amount <= 0)
            {
                BankMessage("The amount must be more than zero.");
                return;
            }

            var target = PlayerManager.FindByName(targetName);

            if (target == null || target.IsDeleted || target.IsPendingDeletion || target.Account == null)
            {
                BankMessage($"There's no character named {targetName}.");
                return;
            }

            if (target.Account.AccountId == Account.AccountId)
            {
                BankMessage($"{target.Name} is on your account and already shares this bank.");
                return;
            }

            var msg = $"Send {BankInfo.Format(currency, amount)} from your bank to {target.Name}'s bank? This can't be undone.";

            if (!ConfirmationManager.EnqueueSend(new Confirmation_Custom(Guid, () => BankSendConfirmed(currency, amount, target)), msg))
                BankMessage("You already have a question waiting. Answer it first.");
        }

        private void BankSendConfirmed(BankCurrency currency, long amount, IPlayer target)
        {
            // things may have changed while the dialog was open
            if (!BankCheckOpen())
                return;

            bankPending++;

            var fromAccount = Account.AccountId;
            var toAccount = target.Account.AccountId;
            var targetName = target.Name;
            var targetGuid = target.Guid.Full;

            DatabaseManager.Shard.BankTransfer(fromAccount, toAccount, currency.Code, amount, Guid.Full, Name, targetGuid, targetName, null, result =>
            {
                if (result.Status == BankResultStatus.Ok)
                {
                    // tell whoever is online on the receiving account
                    var notify = PlayerManager.GetOnlinePlayer(targetGuid)
                        ?? PlayerManager.GetAllOnline().FirstOrDefault(p => p.Account?.AccountId == toAccount);

                    notify?.Session?.Network.EnqueueSend(new GameMessageSystemChat($"{Name} sent {BankInfo.Format(currency, amount)} to your bank. Bank balance: {result.OtherBalance:N0}.", ChatMessageType.Broadcast));
                }

                BankOnPlayer(() =>
                {
                    bankPending = Math.Max(0, bankPending - 1);

                    switch (result.Status)
                    {
                        case BankResultStatus.Ok:
                            BankMessage($"Sent {BankInfo.Format(currency, amount)} to {targetName}. Bank balance: {result.Balance:N0}.");
                            break;
                        case BankResultStatus.Insufficient:
                            BankMessage($"Your bank doesn't have {BankInfo.Format(currency, amount)}. Nothing was sent.");
                            break;
                        default:
                            BankMessage("The bank couldn't be reached. Nothing was sent.");
                            break;
                    }
                });
            });
        }
    }
}
