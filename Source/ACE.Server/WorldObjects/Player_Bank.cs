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
                BankMessage("You have nothing to deposit. (Trade notes stay in your pack: /bank deposit notes banks them. Luminance: /bank deposit luminance.)");
        }

        /// <summary>Deposits one currency. amount null = all of it.</summary>
        public void BankDeposit(BankCurrency currency, long? amount)
        {
            if (!BankCheckOpen())
                return;

            BankDepositInternal(currency, amount, quietIfNone: false);
        }

        /// <summary>JawnTide Bank: deposits trade notes only (by pyreal value). Notes are never taken by /bank deposit or
        /// /bank deposit pyreals, because players and auto-vendor tools keep them in the pack to trade with.</summary>
        public void BankDepositNotes()
        {
            if (!BankCheckOpen())
                return;

            BankDepositInternal(BankInfo.ByCode("pyreals"), null, quietIfNone: false, notesOnly: true);
        }

        /// <summary>Takes the currency from the player, then queues the credit behind the deletes / save. Returns true if anything was taken.
        /// Pyreals: coins only, unless notesOnly (then trade notes only).</summary>
        private bool BankDepositInternal(BankCurrency currency, long? amount, bool quietIfNone, bool notesOnly = false)
        {
            long taken = 0;
            var details = "";
            var breakdown = "";

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
                            BankMessage($"You only have {coins:N0} pyreal coins. To bank trade notes, use /bank deposit notes.");
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

                        if (!notesOnly)
                        {
                            foreach (var item in GetInventoryItemsOfWCID(BankInfo.PyrealWcid))
                            {
                                var value = (long)(item.StackSize ?? 1);
                                if (TryConsumeFromInventoryWithNetworking(item))
                                    coinTotal += value;
                            }
                        }

                        foreach (var (wcid, unit) in notesOnly ? BankInfo.TradeNoteValues : new Dictionary<uint, long>())
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

                        if (noteTotal > 0)
                            breakdown = " in trade notes";
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
                    BankMessage(notesOnly ? "You have no trade notes to deposit." : $"You have no {currency.Name} to deposit.");
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
                    BankCacheSet(currency.Code, result.Balance);
                    BankMessage($"Deposited {BankInfo.Format(currency, deposited)}{breakdown}. Bank balance: {result.Balance:N0}.");
                    return;
                }

                log.Error($"[BANK] Deposit of {deposited} {currency.Code} by {Name} (0x{Guid.Full:X8}, account {accountId}) was taken but NOT credited ({result.Status}). Restore it by hand.");
                BankMessage($"Your deposit of {BankInfo.Format(currency, deposited)} couldn't be recorded. It has been logged; please tell an admin.");
            }));

            return true;
        }

        // ---------------------------------------------------------------- withdraw

        /// <summary>Builds (but doesn't place) the items for a withdrawal.</summary>
        private List<WorldObject> BankBuildItems(BankCurrency currency, long amount, bool coinsOnly, uint noteWcid = 0, long noteValue = 0)
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
                    if (noteWcid != 0 && noteValue > 0)
                    {
                        // a chosen trade note size; whatever doesn't divide evenly comes as coins
                        if (amount >= noteValue)
                        {
                            AddStacks(noteWcid, amount / noteValue);
                            if (items == null) return null;
                            amount %= noteValue;
                        }
                    }
                    else if (!coinsOnly && amount >= BankInfo.MMDValue)
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

            if (currency.Kind == BankCurrencyKind.Pyreals && BankInfo.TradeNoteValues.TryGetValue(item.WeenieClassId, out var noteValue))
                return stack * noteValue;

            return stack;
        }

        /// <param name="noteValue">Pyreals only: the trade note size to pay out in (0 = 250,000 notes plus coins, or coins only).</param>
        public void BankWithdraw(BankCurrency currency, long amount, bool coinsOnly, long noteValue = 0)
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

                uint noteWcid = 0;

                if (noteValue > 0)
                {
                    noteWcid = BankInfo.TradeNoteWcidForValue(noteValue);

                    if (currency.Kind != BankCurrencyKind.Pyreals || noteWcid == 0)
                    {
                        BankMessage($"There's no {noteValue:N0} trade note. Sizes: {string.Join(", ", BankInfo.TradeNoteValues.Values.OrderBy(v => v).Select(v => v.ToString("N0")))}.");
                        return;
                    }

                    if (amount / noteValue > 2_000)
                    {
                        BankMessage("That's more than 2,000 notes at once. Use a bigger note size.");
                        return;
                    }

                    if (amount % noteValue > 2_500_000)
                    {
                        BankMessage("The part that doesn't fit the note size is too much to take as coins.");
                        return;
                    }
                }

                items = BankBuildItems(currency, amount, coinsOnly, noteWcid, noteValue);

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

            BankCacheSet(currency.Code, result.Balance);

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
                    BankCacheSet(currency.Code, refundResult.Balance);

                if (refundResult.Status == BankResultStatus.Ok)
                    BankMessage($"Withdrew {BankInfo.Format(currency, handed)}. {refund:N0} didn't fit and went back into the bank. Bank balance: {refundResult.Balance:N0}.");
                else
                {
                    log.Error($"[BANK] Refund of {refund} {currency.Code} to account {Account.AccountId} ({Name}) failed ({refundResult.Status}). Restore it by hand.");
                    BankMessage($"Withdrew {BankInfo.Format(currency, handed)}. {refund:N0} didn't fit and couldn't be put back; it has been logged, please tell an admin.");
                }
            }));
        }

        // ---------------------------------------------------------------- balance cache (for vendor windows)

        /// <summary>This account's balances as last seen (null = not loaded yet). Only used to show vendors what the bank can cover; every real change goes through the database.</summary>
        private Dictionary<string, long> bankCache;

        /// <summary>True while the client is being shown pack coins + banked pyreals (so it lets the player click Buy).</summary>
        private bool bankCoinDisplayRaised;

        private void BankCacheSet(string code, long balance)
        {
            if (bankCache != null)
                bankCache[code] = balance;
        }

        /// <summary>Called on the receiving player when someone sends to their bank.</summary>
        public void BankCacheReceived(string code, long balance) => BankOnPlayer(() => BankCacheSet(code, balance));

        private void BankRefreshCache(Action onLoaded)
        {
            DatabaseManager.Shard.GetAccountBank(Account.AccountId, balances => BankOnPlayer(() =>
            {
                if (balances == null)
                    return;

                bankCache = balances;
                onLoaded?.Invoke();
            }));
        }

        /// <summary>
        /// How much of this vendor's currency the bank could add, for the vendor window (0 if the bank is closed or the vendor's
        /// currency isn't banked). The client won't even send a purchase it thinks you can't afford, so it is shown pack + bank.
        /// The first time, the balances are loaded and the window is re-sent.
        /// </summary>
        public uint BankVendorExtra(Vendor vendor)
        {
            var currency = BankInfo.ForVendorCurrency(vendor.AlternateCurrency);

            if (currency == null || BankPurchasesOff || BankClosedReason(false) != null)
                return 0;

            if (bankCache == null)
            {
                var vendorGuid = vendor.Guid;
                BankRefreshCache(() =>
                {
                    if (LastOpenedContainerId == vendorGuid && !vendor.IsDestroyed)
                        vendor.ApproachVendor(this);
                });
                return 0;
            }

            // keep it fresh for next time (the website or another server action may have changed it)
            BankRefreshCache(null);

            bankCache.TryGetValue(currency.Code, out var balance);
            return (uint)Math.Clamp(balance, 0, int.MaxValue / 2);
        }

        /// <summary>Shows the client pack coins + banked pyreals while a pyreal vendor is open.</summary>
        public void BankRaiseCoinDisplay(uint extra)
        {
            if (extra == 0)
            {
                BankRestoreCoinDisplay();
                return;
            }

            var shown = (int)Math.Min((long)(CoinValue ?? 0) + extra, int.MaxValue);
            Session.Network.EnqueueSend(new GameMessagePrivateUpdatePropertyInt(this, PropertyInt.CoinValue, shown));
            bankCoinDisplayRaised = true;
        }

        /// <summary>Puts the client's pyreal count back to what's really in the pack.</summary>
        public void BankRestoreCoinDisplay()
        {
            if (!bankCoinDisplayRaised)
                return;

            bankCoinDisplayRaised = false;
            Session?.Network.EnqueueSend(new GameMessagePrivateUpdatePropertyInt(this, PropertyInt.CoinValue, CoinValue ?? 0));
        }

        // ---------------------------------------------------------------- vendor purchases

        /// <summary>
        /// Called when a pyreal or PK Trophy vendor purchase is short. Asks (popup) whether to pay the rest from the bank;
        /// yes re-runs the purchase with that much approved (HandleActionBuyItem with bankApproved).
        /// </summary>
        public void BankOfferPurchase(Vendor vendor, List<ItemProfile> itemProfiles, BankCurrency currency, long shortfall)
        {
            // the player turned paying from the bank off (/bank purchases off): a short purchase just fails, as before the bank
            if (BankPurchasesOff)
                return;

            var why = BankClosedReason();

            if (why != null)
            {
                BankMessage($"You don't have enough {currency.Name}, and your bank can't cover it right now: {why}");
                return;
            }

            var vendorGuid = vendor.Guid.Full;
            var profiles = itemProfiles.Select(p => new ItemProfile(p.Amount, p.ObjectGuid)).ToList();

            var msg = $"You're {BankInfo.Format(currency, shortfall)} short. Pay {shortfall:N0} from your bank to complete this purchase?";

            if (!ConfirmationManager.EnqueueSend(new Confirmation_Custom(Guid, () => HandleActionBuyItem(vendorGuid, profiles, shortfall)), msg))
                BankMessage("You already have a question waiting. Answer it first.");
        }

        /// <summary>
        /// The player approved paying a vendor shortfall from the bank. Debits the bank first; the purchase is finished
        /// (pack pays the rest, items handed over) once the debit is written. Anything that goes wrong after the debit is refunded.
        /// </summary>
        public void BankPayAndFinalize(Vendor vendor, List<WorldObject> genericItems, List<WorldObject> uniqueItems, uint totalPrice, uint packSpend, BankCurrency currency, long shortfall)
        {
            if (!BankCheckOpen())
            {
                Vendor.CleanupCreatedItems(genericItems);
                return;
            }

            bankPending++;

            var accountId = Account.AccountId;
            var playerGuid = Guid.Full;
            var playerName = Name;
            var details = $"{vendor.Name} (wcid {vendor.WeenieClassId}), price {totalPrice:N0}, pack {packSpend:N0}";

            DatabaseManager.Shard.BankChange(accountId, currency.Code, -shortfall, BankLogFor("vendor", details), result =>
            {
                if (result.Status == BankResultStatus.Ok && PlayerManager.GetOnlinePlayer(playerGuid) != this)
                {
                    DatabaseManager.Shard.BaseDatabase.BankChange(accountId, currency.Code, shortfall, new BankLogInfo { CharacterId = playerGuid, CharacterName = playerName, Action = "refund", Details = "logged out before the purchase finished" });
                    return;
                }

                BankOnPlayer(() => BankFinishPurchase(vendor, genericItems, uniqueItems, totalPrice, packSpend, currency, shortfall, result));
            });
        }

        private void BankFinishPurchase(Vendor vendor, List<WorldObject> genericItems, List<WorldObject> uniqueItems, uint totalPrice, uint packSpend, BankCurrency currency, long shortfall, BankResult result)
        {
            bankPending = Math.Max(0, bankPending - 1);

            if (result.Status != BankResultStatus.Ok)
            {
                Vendor.CleanupCreatedItems(genericItems);

                BankMessage(result.Status == BankResultStatus.Insufficient
                    ? $"Your bank doesn't have {BankInfo.Format(currency, shortfall)}. Nothing was bought."
                    : "The bank couldn't be reached. Nothing was bought.");
                return;
            }

            // things may have changed while the debit was written
            long packHas = vendor.AlternateCurrency == null ? (CoinValue ?? 0) : GetNumInventoryItemsOfWCID(vendor.AlternateCurrency.Value);

            string problem = null;

            if (vendor.IsDestroyed || vendor.CurrentLandblock == null)
                problem = "the vendor is gone";
            else if (uniqueItems.Any(u => !vendor.UniqueItemsForSale.ContainsKey(u.Guid)))
                problem = "someone else bought it first";
            else if (packHas < packSpend)
                problem = $"you no longer have {packSpend:N0} {currency.Name} in your pack";
            else if (IsTrading)
                problem = "you're trading";

            if (problem != null)
            {
                Vendor.CleanupCreatedItems(genericItems);

                bankPending++;

                DatabaseManager.Shard.BankChange(Account.AccountId, currency.Code, shortfall, BankLogFor("refund", $"purchase cancelled: {problem}"), refund => BankOnPlayer(() =>
                {
                    bankPending = Math.Max(0, bankPending - 1);

                    if (refund.Status == BankResultStatus.Ok)
                        BankCacheSet(currency.Code, refund.Balance);

                    if (refund.Status == BankResultStatus.Ok)
                        BankMessage($"The purchase was cancelled ({problem}). {BankInfo.Format(currency, shortfall)} went back into your bank.");
                    else
                    {
                        log.Error($"[BANK] Refund of {shortfall} {currency.Code} to account {Account.AccountId} ({Name}) after a cancelled purchase failed ({refund.Status}). Restore it by hand.");
                        BankMessage("The purchase was cancelled and the refund couldn't be recorded. It has been logged; please tell an admin.");
                    }
                }));
                return;
            }

            BankCacheSet(currency.Code, result.Balance);

            FinalizeBuyTransaction(vendor, genericItems, uniqueItems, totalPrice, packSpend);

            BankMessage($"Paid {BankInfo.Format(currency, shortfall)} from your bank. Bank balance: {result.Balance:N0}.");
        }

        // ---------------------------------------------------------------- vendor sales

        /// <summary>
        /// JawnTide Bank: a vendor sale's pyreals go into the bank instead of the pack. Called after the sold items have left
        /// the player (their removal is already queued for saving); the player is saved, then the credit is queued behind it,
        /// so a crash can't leave both the items and the pyreals. If the credit fails, the player gets coins instead.
        /// </summary>
        public void BankDepositSaleProceeds(Vendor vendor, int amount, int itemCount)
        {
            SavePlayerToDatabase();

            bankPending++;

            var currency = BankInfo.ByCode("pyreals");
            var details = $"sold {itemCount} item(s) to {vendor.Name} (wcid {vendor.WeenieClassId})";

            DatabaseManager.Shard.BankChange(Account.AccountId, currency.Code, amount, BankLogFor("sale", details), result => BankOnPlayer(() =>
            {
                bankPending = Math.Max(0, bankPending - 1);

                if (result.Status == BankResultStatus.Ok)
                {
                    BankCacheSet(currency.Code, result.Balance);
                    BankMessage($"{amount:N0} pyreals from the sale went into your bank. Bank balance: {result.Balance:N0}. (/bank sales coins to get coins instead)");
                    return;
                }

                // couldn't record it: hand over coins instead
                var stacks = CreatePayoutCoinStacks(amount);
                long missed = 0;

                foreach (var stack in stacks)
                {
                    if (!TryCreateInInventoryWithNetworking(stack))
                    {
                        missed += stack.StackSize ?? 0;
                        stack.Destroy();
                    }
                }

                if (missed > 0)
                {
                    log.Error($"[BANK] Sale proceeds of {amount} for {Name} (0x{Guid.Full:X8}, account {Account.AccountId}) couldn't be banked ({result.Status}) and {missed} didn't fit as coins. Restore it by hand.");
                    BankMessage($"The bank couldn't be reached, and {missed:N0} pyreals from the sale didn't fit in your pack. It has been logged; please tell an admin.");
                }
                else
                    BankMessage("The bank couldn't be reached, so the sale's pyreals were given to you as coins.");
            }));
        }

        /// <summary>JawnTide Bank: true when this character turned off paying vendors from the bank (/bank purchases off).</summary>
        public bool BankPurchasesOff => GetProperty(PropertyBool.BankPurchasesOff) ?? false;

        /// <summary>JawnTide Bank: whether vendors may offer (with a popup) to pay a shortfall from the bank.</summary>
        public void BankSetPurchases(bool on)
        {
            if (on)
                RemoveProperty(PropertyBool.BankPurchasesOff);
            else
                SetProperty(PropertyBool.BankPurchasesOff, true);

            // the vendor window shows pack + bank only while this is on
            if (!on)
                BankRestoreCoinDisplay();

            BankMessage(on
                ? "When your pack is short at a vendor, you'll be asked whether to pay the rest from your bank. (/bank purchases off to stop)"
                : "Vendors will no longer offer to pay from your bank; purchases use only what's in your pack. (/bank purchases on to turn it back on)");
        }

        /// <summary>JawnTide Bank: where this character's vendor sale proceeds go.</summary>
        /// <summary>JawnTide Bank: true when this character chose to have vendor sales pay into the bank (/bank sales bank). Off by default.</summary>
        public bool BankSalesToBank => GetProperty(PropertyBool.BankSaleProceedsToBank) ?? false;

        public void BankSetSaleProceeds(bool toPack)
        {
            RemoveProperty(PropertyBool.BankSaleProceedsToPack); // the old opt-out flag, no longer used

            if (toPack)
                RemoveProperty(PropertyBool.BankSaleProceedsToBank);
            else
                SetProperty(PropertyBool.BankSaleProceedsToBank, true);

            BankMessage(toPack
                ? "Vendor sales pay you in coins, in your pack (the default). (/bank sales bank to send them to your bank instead)"
                : "Vendor sales now go straight into your bank. (/bank sales coins to get coins in your pack again)");
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

                    notify?.BankCacheReceived(currency.Code, result.OtherBalance);
                    notify?.Session?.Network.EnqueueSend(new GameMessageSystemChat($"{Name} sent {BankInfo.Format(currency, amount)} to your bank. Bank balance: {result.OtherBalance:N0}.", ChatMessageType.Broadcast));
                }

                BankOnPlayer(() =>
                {
                    bankPending = Math.Max(0, bankPending - 1);

                    switch (result.Status)
                    {
                        case BankResultStatus.Ok:
                            BankCacheSet(currency.Code, result.Balance);
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
