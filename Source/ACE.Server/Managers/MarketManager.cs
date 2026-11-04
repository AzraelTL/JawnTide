using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

using log4net;

using ACE.Database;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Entity.Models;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.WorldObjects;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide Marketplace (jawntide.com/market). The website only writes market_request rows; this carries them out, one
    /// at a time, in the order they were made:
    ///   list   - an item leaves the seller's mule for market storage and a listing is made (with its full details and icons)
    ///   buy    - the buyer's bank pays (MMDs = bank pyreals, or PK Trophies), the item goes to the buyer's mule, then the
    ///            seller's bank is paid. If the item can't be delivered, the buyer gets their money back.
    ///   cancel - the item goes back to the seller's mule
    ///   relist - an active or expired listing gets 30 more days
    /// Listings end after 30 days unsold: they are hidden ('expired') and the item stays in market storage until the seller
    /// relists or cancels. No fees.
    ///
    /// Moving items in and out of a mule: if the account has a character online with its mule loaded in memory, the move
    /// runs on that character's own thread, on the loaded containers (like a mule deposit or withdrawal). Otherwise the mule
    /// only exists in the database, so the move is made there (on the save queue), and the account is marked busy so the
    /// mule can't be loaded halfway through (Player.LoadMuleContainerChain waits for it).
    /// </summary>
    public static class MarketManager
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public const int ListingDays = 30;
        public const long PyrealsPerMmd = 250000;
        public const uint MaxPriceMmd = 1000000;
        public const uint MaxPriceTrophies = 100000000;

        private const string StorageKey = "storage_container";
        private const int MuleContainerSlots = 255;

        private static ShardDatabase Db => DatabaseManager.Shard.BaseDatabase;

        private static uint storageContainerId;

        /// <summary>The container listed items wait in. 0 until the market has started.</summary>
        public static uint StorageContainerId => storageContainerId;

        private static readonly ConcurrentDictionary<uint, byte> busyAccounts = new ConcurrentDictionary<uint, byte>();

        /// <summary>True while the market is changing this account's mule in the database.</summary>
        public static bool IsAccountBusy(uint accountId) => busyAccounts.ContainsKey(accountId);

        private static int running;
        private static bool started;
        private static DateTime nextPoll = DateTime.MinValue;
        private static DateTime nextExpire = DateTime.MinValue;

        // ---------------------------------------------------------------- the loop

        /// <summary>Called from the world loop. Every few seconds, picks up new website requests.</summary>
        public static void Tick()
        {
            var now = DateTime.UtcNow;
            if (now < nextPoll)
                return;
            nextPoll = now.AddSeconds(3);

            if (!PropertyManager.GetBool("market_enabled").Item)
                return;

            if (Interlocked.CompareExchange(ref running, 1, 0) != 0)
                return;

            DatabaseManager.Shard.MarketEnqueue(() => Prepare(() =>
            {
                if (DateTime.UtcNow >= nextExpire)
                {
                    nextExpire = DateTime.UtcNow.AddMinutes(1);
                    var expired = Db.MarketExpireListings();
                    if (expired > 0)
                        log.Info($"[MARKET] {expired} listing(s) reached {ListingDays} days and were taken off the market.");
                }

                var requests = Db.MarketTakePendingRequests(20);

                if (requests.Count == 0)
                {
                    Interlocked.Exchange(ref running, 0);
                    return;
                }

                WorldManager.EnqueueAction(new ActionEventDelegate(() => RunNext(requests, 0)));
            }));
        }

        private static void Stop() => Interlocked.Exchange(ref running, 0);

        /// <summary>Runs once (on the save queue): clears up after a server stop and makes sure market storage exists.</summary>
        private static void Prepare(Action ready)
        {
            if (started)
            {
                ready();
                return;
            }

            string stored;
            try
            {
                stored = Db.MarketGetMeta(StorageKey);
            }
            catch
            {
                Stop(); // tables not there yet, or the database is down: try again next time
                return;
            }

            var interrupted = Db.MarketFailInterruptedRequests();
            if (interrupted > 0)
                log.Warn($"[MARKET] {interrupted} request(s) were interrupted by a server stop and marked failed.");

            foreach (var (id, itemGuid, name) in Db.MarketFindStuckListings())
                log.Error($"[MARKET] Listing {id} ({name}, item 0x{itemGuid:X8}) was left 'busy' by a server stop in the middle of a buy or cancel. Check the bank log and where the item is, then set its status by hand.");

            if (stored != null && uint.TryParse(stored, out var existing) && existing != 0)
            {
                storageContainerId = existing;
                started = true;
                log.Info($"[MARKET] Market started. Storage container 0x{existing:X8}.");
                ready();
                return;
            }

            // first start: make the storage container on the world thread, save it, then remember it
            WorldManager.EnqueueAction(new ActionEventDelegate(() =>
            {
                var container = WorldObjectFactory.CreateNewWorldObject(MuleInfo.StorageContainerWeenieClassId) as Container;

                if (container == null)
                {
                    log.Error($"[MARKET] Couldn't create the market storage container (weenie {MuleInfo.StorageContainerWeenieClassId}). The market stays off.");
                    Stop();
                    return;
                }

                container.ItemCapacity = byte.MaxValue;
                container.ContainerCapacity = 0;
                container.SaveBiotaToDatabase();

                DatabaseManager.Shard.MarketEnqueue(() =>
                {
                    try
                    {
                        Db.MarketSetMeta(StorageKey, container.Guid.Full.ToString());
                    }
                    catch (Exception ex)
                    {
                        log.Error($"[MARKET] Couldn't save the market storage container id: {ex}");
                        Stop();
                        return;
                    }

                    storageContainerId = container.Guid.Full;
                    started = true;
                    log.Info($"[MARKET] Market started. Created storage container 0x{storageContainerId:X8}.");
                    ready();
                });
            }));
        }

        private static void RunNext(List<MarketRequest> requests, int index)
        {
            if (index >= requests.Count)
            {
                Stop();
                return;
            }

            void next() => WorldManager.EnqueueAction(new ActionEventDelegate(() => RunNext(requests, index + 1)));

            var req = requests[index];

            try
            {
                switch (req.Kind)
                {
                    case "list": DoList(req, next); break;
                    case "buy": DoBuy(req, next); break;
                    case "cancel": DoCancel(req, next); break;
                    case "relist": DoRelist(req, next); break;
                    default: Finish(req, false, "Unknown request.", next); break;
                }
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] Request {req.Id} ({req.Kind}) failed: {ex}");
                Finish(req, false, "Something went wrong. Please try again.", next);
            }
        }

        private static void Finish(MarketRequest req, bool ok, string message, Action next)
        {
            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                Db.MarketFinishRequest(req.Id, ok, message);
                Notify(req.AccountId, message);
                next();
            });
        }

        // ---------------------------------------------------------------- requests

        private static void DoList(MarketRequest req, Action next)
        {
            var priceMmd = req.PriceMmd > 0 ? req.PriceMmd : null;
            var priceTrophies = req.PriceTrophies > 0 ? req.PriceTrophies : null;

            if (!req.ItemGuid.HasValue)
            {
                Finish(req, false, "No item was picked.", next);
                return;
            }
            if (priceMmd == null && priceTrophies == null)
            {
                Finish(req, false, "Set a price in MMDs, PK Trophies, or both.", next);
                return;
            }
            if (priceMmd > MaxPriceMmd || priceTrophies > MaxPriceTrophies)
            {
                Finish(req, false, "That price is too high.", next);
                return;
            }

            var itemGuid = req.ItemGuid.Value;

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                if (Db.MarketIsItemListed(itemGuid))
                {
                    Finish(req, false, "That item is already on the market.", next);
                    return;
                }

                TakeFromMule(req.AccountId, itemGuid, (info, error) => DatabaseManager.Shard.MarketEnqueue(() =>
                {
                    if (info == null)
                    {
                        Finish(req, false, error ?? "That item couldn't be listed.", next);
                        return;
                    }

                    var id = Db.MarketInsertListing(new MarketListing
                    {
                        SellerAccountId = req.AccountId,
                        SellerName = req.CharacterName,
                        ItemGuid = itemGuid,
                        Wcid = info.Wcid,
                        Name = info.Name,
                        StackSize = info.StackSize,
                        ItemType = info.ItemType,
                        IconId = info.IconId,
                        IconOverlayId = info.IconOverlayId,
                        IconOverlay2Id = info.IconOverlay2Id,
                        IconUnderlayId = info.IconUnderlayId,
                        UiEffects = info.UiEffects,
                        Details = info.DetailsJson,
                        SearchText = info.SearchText,
                        PriceMmd = priceMmd,
                        PriceTrophies = priceTrophies,
                        ExpiresAt = DateTime.UtcNow.AddDays(ListingDays),
                    });

                    if (id == null)
                    {
                        // the item is in market storage but has no listing: put it back
                        GiveToMule(req.AccountId, itemGuid, (ok, err) =>
                        {
                            if (!ok)
                                log.Error($"[MARKET] {info.Name} (0x{itemGuid:X8}) of account {req.AccountId} is in market storage with no listing and couldn't go back to the mule ({err}). Move it back by hand.");
                            Finish(req, false, ok ? "The listing couldn't be saved. The item is back in your mule." : "The listing couldn't be saved. An admin has to return the item; please tell one.", next);
                        });
                        return;
                    }

                    SaveIcons(new[] { info.IconId, info.IconOverlayId, info.IconOverlay2Id, info.IconUnderlayId });

                    log.Info($"[MARKET] Listing {id}: {req.CharacterName} (account {req.AccountId}) listed {info.Name} x{info.StackSize} (0x{itemGuid:X8}) for {PriceText(priceMmd, priceTrophies)}.");
                    Finish(req, true, $"{info.Name} is on the market for {PriceText(priceMmd, priceTrophies)}.", next);
                }));
            });
        }

        private static void DoBuy(MarketRequest req, Action next)
        {
            if (!req.ListingId.HasValue)
            {
                Finish(req, false, "No listing was picked.", next);
                return;
            }

            var payTrophies = req.PayWith == "trophies";

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var listing = Db.MarketClaimListing(req.ListingId.Value, new[] { "active" }, null, req.AccountId, out var previous);

                if (listing == null)
                {
                    Finish(req, false, "That item isn't for sale any more (or it's your own listing).", next);
                    return;
                }

                string currency;
                long amount;

                if (payTrophies)
                {
                    if (!listing.PriceTrophies.HasValue)
                    {
                        Db.MarketReleaseListing(listing.Id, previous);
                        Finish(req, false, "That item can't be bought with PK Trophies.", next);
                        return;
                    }
                    currency = "pk_trophies";
                    amount = listing.PriceTrophies.Value;
                }
                else
                {
                    if (!listing.PriceMmd.HasValue)
                    {
                        Db.MarketReleaseListing(listing.Id, previous);
                        Finish(req, false, "That item can't be bought with MMDs.", next);
                        return;
                    }
                    currency = "pyreals";
                    amount = listing.PriceMmd.Value * PyrealsPerMmd;
                }

                var paid = payTrophies ? $"{amount:N0} PK Trophies" : $"{listing.PriceMmd.Value:N0} MMDs";
                var details = $"market listing {listing.Id}: {listing.Name}";

                var debit = Db.BankChange(req.AccountId, currency, -amount, new BankLogInfo
                {
                    CharacterName = req.CharacterName, Action = "market buy", OtherAccountId = listing.SellerAccountId, OtherCharacterName = listing.SellerName, Details = details
                });

                if (debit.Status != BankResultStatus.Ok)
                {
                    Db.MarketReleaseListing(listing.Id, previous);
                    Finish(req, false, debit.Status == BankResultStatus.Insufficient
                        ? $"Your bank doesn't have {paid}{(payTrophies ? "" : $" ({amount:N0} pyreals)")}."
                        : "The bank couldn't be reached. Nothing was charged.", next);
                    return;
                }

                GiveToMule(req.AccountId, listing.ItemGuid, (delivered, error) => DatabaseManager.Shard.MarketEnqueue(() =>
                {
                    if (!delivered)
                    {
                        var refund = Db.BankChange(req.AccountId, currency, amount, new BankLogInfo
                        {
                            CharacterName = req.CharacterName, Action = "market refund", OtherAccountId = listing.SellerAccountId, OtherCharacterName = listing.SellerName, Details = details
                        });

                        if (refund.Status != BankResultStatus.Ok)
                            log.Error($"[MARKET] REFUND FAILED: account {req.AccountId} ({req.CharacterName}) is owed {currency} {amount} for listing {listing.Id}. Restore it by hand (Ops/BANK.md).");

                        Db.MarketReleaseListing(listing.Id, previous);
                        Finish(req, false, $"{error ?? "The item couldn't be delivered."} You weren't charged.", next);
                        return;
                    }

                    var credit = Db.BankChange(listing.SellerAccountId, currency, amount, new BankLogInfo
                    {
                        CharacterName = listing.SellerName, Action = "market sale", OtherAccountId = req.AccountId, OtherCharacterName = req.CharacterName, Details = details
                    });

                    if (credit.Status != BankResultStatus.Ok)
                        log.Error($"[MARKET] SELLER NOT PAID: account {listing.SellerAccountId} ({listing.SellerName}) is owed {currency} {amount} for listing {listing.Id}. Pay it by hand (Ops/BANK.md).");

                    Db.MarketCloseListing(listing.Id, "sold", req.AccountId, req.CharacterName, currency, amount);

                    log.Info($"[MARKET] Listing {listing.Id}: {req.CharacterName} (account {req.AccountId}) bought {listing.Name} x{listing.StackSize} from {listing.SellerName} (account {listing.SellerAccountId}) for {paid}.");

                    Notify(listing.SellerAccountId, $"Your {listing.Name} sold for {paid}. It's in your bank.");
                    Finish(req, true, $"You bought {listing.Name} for {paid}. It's in your mule.", next);
                }));
            });
        }

        private static void DoCancel(MarketRequest req, Action next)
        {
            if (!req.ListingId.HasValue)
            {
                Finish(req, false, "No listing was picked.", next);
                return;
            }

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var listing = Db.MarketClaimListing(req.ListingId.Value, new[] { "active", "expired" }, req.AccountId, null, out var previous);

                if (listing == null)
                {
                    Finish(req, false, "That listing isn't yours, or it's already closed.", next);
                    return;
                }

                GiveToMule(req.AccountId, listing.ItemGuid, (ok, error) => DatabaseManager.Shard.MarketEnqueue(() =>
                {
                    if (!ok)
                    {
                        Db.MarketReleaseListing(listing.Id, previous);
                        Finish(req, false, $"{error ?? "The item couldn't be returned."} It's still on the market.", next);
                        return;
                    }

                    Db.MarketCloseListing(listing.Id, "returned", null, null, null, null);
                    log.Info($"[MARKET] Listing {listing.Id}: {listing.Name} went back to {req.CharacterName}'s mule (account {req.AccountId}).");
                    Finish(req, true, $"{listing.Name} is back in your mule.", next);
                }));
            });
        }

        private static void DoRelist(MarketRequest req, Action next)
        {
            if (!req.ListingId.HasValue)
            {
                Finish(req, false, "No listing was picked.", next);
                return;
            }

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var ok = Db.MarketRelist(req.ListingId.Value, req.AccountId, DateTime.UtcNow.AddDays(ListingDays));
                Finish(req, ok, ok ? $"Relisted for {ListingDays} more days." : "That listing isn't yours, or it's already closed.", next);
            });
        }

        // ---------------------------------------------------------------- moving items in and out of a mule

        private class Gate
        {
            public bool Started;
            public bool Cancelled;
        }

        private static Player FindOnline(uint accountId) =>
            PlayerManager.GetAllOnline().FirstOrDefault(p => p.Account != null && p.Account.AccountId == accountId);

        /// <summary>
        /// Runs work on the player's own thread. A player's queued work is dropped if they log out or are between landblocks,
        /// so if it hasn't started after 30 seconds it is cancelled (it can then never run) and ifNotRun runs instead.
        /// </summary>
        private static void RunOnPlayer(Player player, Action work, Action ifNotRun)
        {
            var gate = new Gate();

            player.EnqueueAction(new ActionEventDelegate(() =>
            {
                lock (gate)
                {
                    if (gate.Cancelled)
                        return;
                    gate.Started = true;
                }
                work();
            }));

            Task.Delay(TimeSpan.FromSeconds(30)).ContinueWith(_ =>
            {
                lock (gate)
                {
                    if (gate.Started)
                        return;
                    gate.Cancelled = true;
                }
                WorldManager.EnqueueAction(new ActionEventDelegate(ifNotRun));
            });
        }

        /// <summary>Takes an item out of the account's mule into market storage. Answers with the item's details, or an error.</summary>
        private static void TakeFromMule(uint accountId, uint itemGuid, Action<MarketItemInfo, string> done)
        {
            var player = FindOnline(accountId);

            if (player == null)
            {
                TakeFromMuleInDatabase(accountId, itemGuid, done);
                return;
            }

            RunOnPlayer(player,
                () =>
                {
                    if (player.ActiveMuleContainers == null)
                    {
                        TakeFromMuleInDatabase(accountId, itemGuid, done);
                        return;
                    }

                    var error = player.MarketTakeFromLoadedMule(itemGuid, out var info);
                    DatabaseManager.Shard.MarketEnqueue(() => done(info, error)); // after the saves it queued
                },
                () =>
                {
                    var again = FindOnline(accountId);
                    if (again != null && again.ActiveMuleContainers != null)
                        done(null, "Your character is busy (zoning?). Please try again.");
                    else
                        TakeFromMuleInDatabase(accountId, itemGuid, done);
                });
        }

        private static void TakeFromMuleInDatabase(uint accountId, uint itemGuid, Action<MarketItemInfo, string> done)
        {
            busyAccounts[accountId] = 1;

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                MarketItemInfo info = null;
                string error = null;

                try
                {
                    var chain = Db.MarketGetMuleChain(accountId);
                    var containerId = Db.MarketGetItemContainer(itemGuid);

                    if (!containerId.HasValue || !chain.Contains(containerId.Value))
                        error = "That item isn't in your mule any more.";
                    else
                    {
                        var biota = Db.GetBiota(itemGuid);
                        var item = biota != null ? WorldObjectFactory.CreateWorldObject(biota) : null;

                        if (item == null)
                            error = "That item couldn't be loaded.";
                        else
                        {
                            error = CheckListable(item);

                            if (error == null)
                            {
                                info = BuildItemInfo(item);
                                item.ContainerId = StorageContainerId;
                                item.PlacementPosition = 0;
                                item.SaveBiotaToDatabase();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    log.Error($"[MARKET] Taking 0x{itemGuid:X8} from the mule of account {accountId} failed: {ex}");
                    info = null;
                    error = "Something went wrong. Please try again.";
                }

                // answer after the save queued above
                DatabaseManager.Shard.MarketEnqueue(() =>
                {
                    busyAccounts.TryRemove(accountId, out _);
                    done(info, error);
                });
            });
        }

        /// <summary>Moves an item from market storage into the account's mule. Answers true, or false with an error.</summary>
        private static void GiveToMule(uint accountId, uint itemGuid, Action<bool, string> done)
        {
            var player = FindOnline(accountId);

            if (player == null)
            {
                GiveToMuleInDatabase(accountId, itemGuid, done);
                return;
            }

            RunOnPlayer(player,
                () =>
                {
                    if (player.ActiveMuleContainers == null)
                    {
                        GiveToMuleInDatabase(accountId, itemGuid, done);
                        return;
                    }

                    var error = player.MarketGiveToLoadedMule(itemGuid);
                    DatabaseManager.Shard.MarketEnqueue(() => done(error == null, error)); // after the saves it queued
                },
                () =>
                {
                    var again = FindOnline(accountId);
                    if (again != null && again.ActiveMuleContainers != null)
                        done(false, "Your character is busy (zoning?). Please try again.");
                    else
                        GiveToMuleInDatabase(accountId, itemGuid, done);
                });
        }

        private static void GiveToMuleInDatabase(uint accountId, uint itemGuid, Action<bool, string> done)
        {
            busyAccounts[accountId] = 1;

            void answer(bool ok, string error) => DatabaseManager.Shard.MarketEnqueue(() =>
            {
                busyAccounts.TryRemove(accountId, out _);
                done(ok, error);
            });

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                try
                {
                    var containerId = Db.MarketGetItemContainer(itemGuid);
                    if (containerId != StorageContainerId)
                    {
                        log.Error($"[MARKET] Item 0x{itemGuid:X8} should be in market storage but is in 0x{containerId ?? 0:X8}.");
                        answer(false, "That item isn't in market storage.");
                        return;
                    }

                    var chain = Db.MarketGetMuleChain(accountId);

                    foreach (var container in chain)
                    {
                        var count = Db.MarketCountContainerItems(container);
                        if (count < MuleContainerSlots)
                        {
                            MoveItemInDatabase(itemGuid, container, count, answer);
                            return;
                        }
                    }

                    if (chain.Count >= MuleInfo.MaxContainers)
                    {
                        answer(false, "Your mule is full.");
                        return;
                    }

                    // every container is full (or there's no mule yet): add a container on the world thread, then link it here
                    WorldManager.EnqueueAction(new ActionEventDelegate(() =>
                    {
                        var created = WorldObjectFactory.CreateNewWorldObject(MuleInfo.StorageContainerWeenieClassId) as Container;
                        if (created == null)
                        {
                            answer(false, "Your mule couldn't be given more room.");
                            return;
                        }

                        created.ItemCapacity = byte.MaxValue;
                        created.ContainerCapacity = 0;
                        created.SaveBiotaToDatabase();

                        DatabaseManager.Shard.MarketEnqueue(() =>
                        {
                            try
                            {
                                if (chain.Count == 0)
                                    Db.SetAccountMuleContainerId(accountId, created.Guid.Full);
                                else
                                {
                                    var tailBiota = Db.GetBiota(chain[chain.Count - 1]);
                                    var tail = tailBiota != null ? WorldObjectFactory.CreateWorldObject(tailBiota) : null;
                                    if (tail == null)
                                    {
                                        answer(false, "Your mule couldn't be given more room.");
                                        return;
                                    }
                                    tail.SetProperty(PropertyInstanceId.MuleNextContainerId, created.Guid.Full);
                                    tail.SaveBiotaToDatabase();
                                }

                                MoveItemInDatabase(itemGuid, created.Guid.Full, 0, answer);
                            }
                            catch (Exception ex)
                            {
                                log.Error($"[MARKET] Adding a mule container for account {accountId} failed: {ex}");
                                answer(false, "Something went wrong. Please try again.");
                            }
                        });
                    }));
                }
                catch (Exception ex)
                {
                    log.Error($"[MARKET] Giving 0x{itemGuid:X8} to the mule of account {accountId} failed: {ex}");
                    answer(false, "Something went wrong. Please try again.");
                }
            });
        }

        /// <summary>On the save queue: puts the item in the container and saves it; answers once the save has run.</summary>
        private static void MoveItemInDatabase(uint itemGuid, uint containerId, int position, Action<bool, string> answer)
        {
            var biota = Db.GetBiota(itemGuid);
            var item = biota != null ? WorldObjectFactory.CreateWorldObject(biota) : null;

            if (item == null)
            {
                answer(false, "The item couldn't be loaded.");
                return;
            }

            item.ContainerId = containerId;
            item.PlacementPosition = position;
            item.SaveBiotaToDatabase();

            answer(true, null); // answer() queues behind the save
        }

        // ---------------------------------------------------------------- item rules and details

        /// <summary>Why an item can't be listed, or null if it can.</summary>
        public static string CheckListable(WorldObject item)
        {
            if (item is Container)
                return "Packs can't be sold on the market.";
            if (item.WeenieClassId == MuleInfo.GemWeenieClassId)
                return "You can't sell your mule gem.";
            if ((item.GetProperty(PropertyInt.Attuned) ?? 0) == 1)
                return "Attuned items can't be sold.";
            return null;
        }

        public class MarketItemInfo
        {
            public uint Wcid;
            public string Name;
            public int StackSize;
            public int ItemType;
            public uint IconId;
            public uint IconOverlayId;
            public uint IconOverlay2Id;
            public uint IconUnderlayId;
            public int UiEffects;
            public string DetailsJson;
            public string SearchText;
        }

        private static readonly HashSet<PropertyString> PrivateStrings = new HashSet<PropertyString>
        {
            PropertyString.ScribeAccount, PropertyString.HouseOwnerAccount,
        };

        /// <summary>Everything the website needs to show the item like the in-game appraisal panel.</summary>
        public static MarketItemInfo BuildItemInfo(WorldObject item)
        {
            var ints = item.GetAllPropertyInt().ToDictionary(kv => kv.Key.ToString(), kv => (object)kv.Value);
            var int64s = item.GetAllPropertyInt64().ToDictionary(kv => kv.Key.ToString(), kv => (object)kv.Value);
            var floats = item.GetAllPropertyFloat().ToDictionary(kv => kv.Key.ToString(), kv => double.IsFinite(kv.Value) ? (object)kv.Value : null);
            var bools = item.GetAllPropertyBools().ToDictionary(kv => kv.Key.ToString(), kv => (object)kv.Value);
            var strings = item.GetAllPropertyString().Where(kv => !PrivateStrings.Contains(kv.Key)).ToDictionary(kv => kv.Key.ToString(), kv => (object)kv.Value);
            var dids = item.GetAllPropertyDataId().ToDictionary(kv => kv.Key.ToString(), kv => (object)kv.Value);

            var names = new Dictionary<string, string>();

            void name<T>(PropertyInt prop) where T : struct, Enum
            {
                var v = item.GetProperty(prop);
                if (v.HasValue)
                    names[prop.ToString()] = Enum.ToObject(typeof(T), v.Value).ToString();
            }

            name<MaterialType>(PropertyInt.MaterialType);
            name<Skill>(PropertyInt.WeaponSkill);
            name<Skill>(PropertyInt.WieldSkillType);
            name<Skill>(PropertyInt.WieldSkillType2);
            name<Skill>(PropertyInt.WieldSkillType3);
            name<Skill>(PropertyInt.WieldSkillType4);
            name<WieldRequirement>(PropertyInt.WieldRequirements);
            name<WieldRequirement>(PropertyInt.WieldRequirements2);
            name<WieldRequirement>(PropertyInt.WieldRequirements3);
            name<WieldRequirement>(PropertyInt.WieldRequirements4);
            name<DamageType>(PropertyInt.DamageType);
            name<ImbuedEffectType>(PropertyInt.ImbuedEffect);
            name<ImbuedEffectType>(PropertyInt.ImbuedEffect2);
            name<EquipmentSet>(PropertyInt.EquipmentSetId);
            name<CreatureType>(PropertyInt.SlayerCreatureType);
            name<WeaponType>(PropertyInt.WeaponType);
            name<ItemType>(PropertyInt.ItemType);

            var spells = new List<Dictionary<string, object>>();
            var seen = new HashSet<uint>();

            var spellIds = new List<uint>();
            if (item.SpellDID.HasValue) spellIds.Add(item.SpellDID.Value);
            if (item.ProcSpell.HasValue) spellIds.Add(item.ProcSpell.Value);
            spellIds.AddRange(item.Biota.GetKnownSpellsIds(item.BiotaDatabaseLock).Select(i => (uint)i));

            foreach (var id in spellIds)
            {
                if (!seen.Add(id))
                    continue;

                var spell = new Spell(id, false);
                if (spell._spellBase == null)
                    continue;

                spells.Add(new Dictionary<string, object>
                {
                    ["id"] = id,
                    ["name"] = spell.Name,
                    ["proc"] = item.ProcSpell == id,
                    ["use"] = item.SpellDID == id,
                });
            }

            var details = new Dictionary<string, object>
            {
                ["v"] = 1,
                ["wcid"] = item.WeenieClassId,
                ["int"] = ints,
                ["int64"] = int64s,
                ["float"] = floats,
                ["bool"] = bools,
                ["string"] = strings,
                ["did"] = dids,
                ["names"] = names,
                ["spells"] = spells,
            };

            var search = new List<string> { item.Name ?? "" };
            search.AddRange(spells.Select(s => (string)s["name"]));
            if (names.TryGetValue("EquipmentSetId", out var set)) search.Add(set);
            if (names.TryGetValue("MaterialType", out var material)) search.Add(material);
            if (names.TryGetValue("ImbuedEffect", out var imbue)) search.Add(imbue);

            return new MarketItemInfo
            {
                Wcid = item.WeenieClassId,
                Name = item.NameWithMaterial ?? item.Name ?? "Unknown item",
                StackSize = item.StackSize ?? 1,
                ItemType = (int)item.ItemType,
                IconId = item.IconId,
                IconOverlayId = item.IconOverlayId ?? 0,
                IconOverlay2Id = item.IconOverlaySecondary ?? 0,
                IconUnderlayId = item.IconUnderlayId ?? 0,
                UiEffects = (int)(item.UiEffects ?? 0),
                DetailsJson = JsonSerializer.Serialize(details),
                SearchText = string.Join("\n", search).ToLowerInvariant(),
            };
        }

        // ---------------------------------------------------------------- icons

        private static readonly ConcurrentDictionary<uint, byte> knownIcons = new ConcurrentDictionary<uint, byte>();

        /// <summary>Makes sure the website has these icons (on the save queue).</summary>
        private static void SaveIcons(IEnumerable<uint> iconIds)
        {
            foreach (var id in iconIds.Where(i => i != 0).Distinct())
            {
                if (!knownIcons.TryAdd(id, 1))
                    continue;

                if (Db.MarketHasIcon(id))
                    continue;

                Db.MarketSaveIcon(id, MarketIcons.GetPng(id));
            }
        }

        private static readonly ConcurrentDictionary<uint, byte> knownDetails = new ConcurrentDictionary<uint, byte>();

        /// <summary>
        /// Called when a mule is summoned or something is put in it: exports the icons and details of its items, so the website's
        /// My Market page can show them (with pictures and the ID panel) before they're listed. Each item is done once per server
        /// run; the work happens on the save queue, not the player's thread.
        /// </summary>
        public static void QueueIcons(IEnumerable<WorldObject> items)
        {
            var ids = new List<uint>();
            var newItems = new List<WorldObject>();

            foreach (var item in items)
            {
                if (item == null || item is Container)
                    continue;

                foreach (var id in new[] { item.IconId, item.IconOverlayId ?? 0, item.IconOverlaySecondary ?? 0, item.IconUnderlayId ?? 0 })
                {
                    if (id != 0 && !knownIcons.ContainsKey(id))
                        ids.Add(id);
                }

                if (knownDetails.TryAdd(item.Guid.Full, 1))
                    newItems.Add(item);
            }

            if (ids.Count == 0 && newItems.Count == 0)
                return;

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                SaveIcons(ids);

                var details = new List<(uint, string)>();
                foreach (var item in newItems)
                {
                    try
                    {
                        details.Add((item.Guid.Full, BuildItemInfo(item).DetailsJson));
                    }
                    catch (Exception ex)
                    {
                        log.Warn($"[MARKET] Couldn't read the details of {item.Name} (0x{item.Guid}): {ex.Message}");
                    }

                    if (details.Count >= 200)
                    {
                        Db.MarketSaveItemDetails(details);
                        details = new List<(uint, string)>();
                    }
                }
                Db.MarketSaveItemDetails(details);
            });
        }

        // ---------------------------------------------------------------- messages

        public static string PriceText(uint? mmd, uint? trophies)
        {
            if (mmd.HasValue && trophies.HasValue)
                return $"{mmd.Value:N0} MMDs or {trophies.Value:N0} PK Trophies";
            if (mmd.HasValue)
                return $"{mmd.Value:N0} MMDs";
            return $"{trophies ?? 0:N0} PK Trophies";
        }

        private static void Notify(uint accountId, string message)
        {
            var player = FindOnline(accountId);
            player?.Session?.Network.EnqueueSend(new GameMessageSystemChat($"[Market] {message}", ChatMessageType.Broadcast));
        }
    }
}
