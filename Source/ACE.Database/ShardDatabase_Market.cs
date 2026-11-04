using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;

using Microsoft.EntityFrameworkCore;

using ACE.Database.Models.Shard;
using ACE.Entity.Enum.Properties;

namespace ACE.Database
{
    /// <summary>JawnTide Marketplace: one website request (market_request row).</summary>
    public class MarketRequest
    {
        public ulong Id;
        public uint AccountId;
        public string CharacterName;
        public string Kind;
        public uint? ItemGuid;
        public ulong? ListingId;
        public uint? PriceMmd;
        public uint? PriceTrophies;
        public string PayWith;
    }

    /// <summary>JawnTide Marketplace: one listed item (market_listing row).</summary>
    public class MarketListing
    {
        public ulong Id;
        public uint SellerAccountId;
        public string SellerName;
        public uint ItemGuid;
        public uint Wcid;
        public string Name;
        public int StackSize;
        public int ItemType;
        public uint IconId;
        public uint IconOverlayId;
        public uint IconOverlay2Id;
        public uint IconUnderlayId;
        public int UiEffects;
        public string Details;
        public string SearchText;
        public uint? PriceMmd;
        public uint? PriceTrophies;
        public string Status;
        public DateTime ExpiresAt;
    }

    public partial class ShardDatabase
    {
        // -------------------------------------------------------------------------
        // JawnTide Marketplace (see Database/Updates/Shard/2026-11-04-00-Add-Market.sql and MarketManager).
        // Every listing status change is a single UPDATE ... WHERE status = <expected>, so a listing can only ever be
        // claimed by one request at a time. Plain ADO.NET, like the bank.
        // -------------------------------------------------------------------------

        private static DbConnection MarketOpen(ShardDbContext context)
        {
            var conn = context.Database.GetDbConnection();
            conn.Open();
            return conn;
        }

        private static object DbValue(object v) => v ?? DBNull.Value;

        private static uint? ReadUIntOrNull(DbDataReader r, int i) => r.IsDBNull(i) ? (uint?)null : Convert.ToUInt32(r.GetValue(i));
        private static ulong? ReadULongOrNull(DbDataReader r, int i) => r.IsDBNull(i) ? (ulong?)null : Convert.ToUInt64(r.GetValue(i));
        private static string ReadStringOrNull(DbDataReader r, int i) => r.IsDBNull(i) ? null : r.GetString(i);

        /// <summary>Takes up to max pending requests, oldest first, and marks them 'working'.</summary>
        public List<MarketRequest> MarketTakePendingRequests(int max)
        {
            var result = new List<MarketRequest>();

            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);

                using (var cmd = BankCommand(conn, tx,
                    @"SELECT id, account_Id, character_Name, kind, item_Guid, listing_Id, price_Mmd, price_Trophies, pay_With
                      FROM market_request WHERE status = 'pending' ORDER BY id LIMIT @n FOR UPDATE;", ("@n", max)))
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        result.Add(new MarketRequest
                        {
                            Id = Convert.ToUInt64(r.GetValue(0)),
                            AccountId = Convert.ToUInt32(r.GetValue(1)),
                            CharacterName = ReadStringOrNull(r, 2),
                            Kind = r.GetString(3),
                            ItemGuid = ReadUIntOrNull(r, 4),
                            ListingId = ReadULongOrNull(r, 5),
                            PriceMmd = ReadUIntOrNull(r, 6),
                            PriceTrophies = ReadUIntOrNull(r, 7),
                            PayWith = ReadStringOrNull(r, 8),
                        });
                    }
                }

                foreach (var req in result)
                {
                    using var upd = BankCommand(conn, tx, "UPDATE market_request SET status = 'working' WHERE id = @id;", ("@id", req.Id));
                    upd.ExecuteNonQuery();
                }

                tx.Commit();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketTakePendingRequests failed: {ex}");
                return new List<MarketRequest>();
            }

            return result;
        }

        public void MarketFinishRequest(ulong id, bool ok, string message)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    "UPDATE market_request SET status = @s, result = @m, processed_At = @t WHERE id = @id;",
                    ("@s", ok ? "done" : "failed"), ("@m", Truncate(message, 255)), ("@t", DateTime.UtcNow), ("@id", id));
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketFinishRequest failed for request {id} ({(ok ? "done" : "failed")}: {message}): {ex}");
            }
        }

        /// <summary>Requests left 'working' by a server stop are marked failed (their listings are logged by MarketFindStuckListings).</summary>
        public int MarketFailInterruptedRequests()
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    "UPDATE market_request SET status = 'failed', result = 'The server restarted before this finished. Please try again.', processed_At = @t WHERE status = 'working';",
                    ("@t", DateTime.UtcNow));
                return cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketFailInterruptedRequests failed: {ex}");
                return 0;
            }
        }

        /// <summary>Listings left 'busy' (a server stop in the middle of a buy or cancel). These need an admin to check by hand.</summary>
        public List<(ulong id, uint itemGuid, string name)> MarketFindStuckListings()
        {
            var result = new List<(ulong, uint, string)>();

            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null, "SELECT id, item_Guid, name FROM market_listing WHERE status = 'busy';");
                using var r = cmd.ExecuteReader();
                while (r.Read())
                    result.Add((Convert.ToUInt64(r.GetValue(0)), Convert.ToUInt32(r.GetValue(1)), r.GetString(2)));
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketFindStuckListings failed: {ex}");
            }

            return result;
        }

        /// <summary>Active listings past their end date become 'expired' (hidden from the market; the item stays in market storage).</summary>
        public int MarketExpireListings()
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    "UPDATE market_listing SET status = 'expired' WHERE status = 'active' AND expires_At <= @t;", ("@t", DateTime.UtcNow));
                return cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketExpireListings failed: {ex}");
                return 0;
            }
        }

        /// <summary>True if this item is already on the market (any status that still holds the item).</summary>
        public bool MarketIsItemListed(uint itemGuid)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    "SELECT COUNT(*) FROM market_listing WHERE item_Guid = @g AND status IN ('active', 'expired', 'busy');", ("@g", itemGuid));
                return Convert.ToInt64(cmd.ExecuteScalar()) > 0;
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketIsItemListed failed for 0x{itemGuid:X8}: {ex}");
                return true; // unknown: don't list it twice
            }
        }

        public ulong? MarketInsertListing(MarketListing l)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    @"INSERT INTO market_listing (seller_Account_Id, seller_Name, item_Guid, wcid, name, stack_Size, item_Type, icon_Id, icon_Overlay_Id, icon_Overlay2_Id,
                        icon_Underlay_Id, ui_Effects, details, search_Text, price_Mmd, price_Trophies, status, listed_At, expires_At)
                      VALUES (@sa, @sn, @g, @w, @n, @ss, @it, @i, @io, @io2, @iu, @ui, @d, @st, @pm, @pt, 'active', @la, @ea);
                      SELECT LAST_INSERT_ID();",
                    ("@sa", l.SellerAccountId), ("@sn", Truncate(l.SellerName, 64)), ("@g", l.ItemGuid), ("@w", l.Wcid), ("@n", Truncate(l.Name, 128)),
                    ("@ss", l.StackSize), ("@it", l.ItemType), ("@i", l.IconId), ("@io", l.IconOverlayId), ("@io2", l.IconOverlay2Id), ("@iu", l.IconUnderlayId),
                    ("@ui", l.UiEffects), ("@d", l.Details), ("@st", l.SearchText), ("@pm", DbValue(l.PriceMmd)), ("@pt", DbValue(l.PriceTrophies)),
                    ("@la", DateTime.UtcNow), ("@ea", l.ExpiresAt));
                return Convert.ToUInt64(cmd.ExecuteScalar());
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketInsertListing failed for {l.Name} (0x{l.ItemGuid:X8}) from account {l.SellerAccountId}: {ex}");
                return null;
            }
        }

        /// <summary>
        /// Moves a listing from one of the expected statuses to 'busy' and returns it, or null if it isn't in one of those
        /// statuses (someone else got there first). sellerAccountId limits it to the seller's own listing; notSellerAccountId
        /// stops a buyer buying their own listing. Active listings that are past their end date can't be claimed as active.
        /// </summary>
        public MarketListing MarketClaimListing(ulong listingId, string[] fromStatuses, uint? sellerAccountId, uint? notSellerAccountId, out string previousStatus)
        {
            previousStatus = null;

            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);

                MarketListing l = null;

                using (var cmd = BankCommand(conn, tx,
                    @"SELECT id, seller_Account_Id, seller_Name, item_Guid, wcid, name, stack_Size, price_Mmd, price_Trophies, status, expires_At
                      FROM market_listing WHERE id = @id FOR UPDATE;", ("@id", listingId)))
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        l = new MarketListing
                        {
                            Id = Convert.ToUInt64(r.GetValue(0)),
                            SellerAccountId = Convert.ToUInt32(r.GetValue(1)),
                            SellerName = ReadStringOrNull(r, 2),
                            ItemGuid = Convert.ToUInt32(r.GetValue(3)),
                            Wcid = Convert.ToUInt32(r.GetValue(4)),
                            Name = r.GetString(5),
                            StackSize = Convert.ToInt32(r.GetValue(6)),
                            PriceMmd = ReadUIntOrNull(r, 7),
                            PriceTrophies = ReadUIntOrNull(r, 8),
                            Status = r.GetString(9),
                            ExpiresAt = r.GetDateTime(10),
                        };
                    }
                }

                if (l == null || Array.IndexOf(fromStatuses, l.Status) < 0
                    || (sellerAccountId.HasValue && l.SellerAccountId != sellerAccountId.Value)
                    || (notSellerAccountId.HasValue && l.SellerAccountId == notSellerAccountId.Value)
                    || (l.Status == "active" && Array.IndexOf(fromStatuses, "expired") < 0 && l.ExpiresAt <= DateTime.UtcNow))
                {
                    tx.Rollback();
                    return null;
                }

                using (var upd = BankCommand(conn, tx, "UPDATE market_listing SET status = 'busy' WHERE id = @id;", ("@id", listingId)))
                    upd.ExecuteNonQuery();

                tx.Commit();

                previousStatus = l.Status;
                l.Status = "busy";
                return l;
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketClaimListing failed for listing {listingId}: {ex}");
                return null;
            }
        }

        /// <summary>Puts a claimed ('busy') listing back to the status it had (a buy or cancel that didn't go through).</summary>
        public void MarketReleaseListing(ulong listingId, string status)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null, "UPDATE market_listing SET status = @s WHERE id = @id AND status = 'busy';", ("@s", status), ("@id", listingId));
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketReleaseListing failed for listing {listingId} (back to {status}): {ex}");
            }
        }

        public void MarketCloseListing(ulong listingId, string status, uint? buyerAccountId, string buyerName, string paidCurrency, long? paidAmount)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    @"UPDATE market_listing SET status = @s, closed_At = @t, buyer_Account_Id = @ba, buyer_Name = @bn, paid_Currency = @pc, paid_Amount = @pa
                      WHERE id = @id;",
                    ("@s", status), ("@t", DateTime.UtcNow), ("@ba", DbValue(buyerAccountId)), ("@bn", Truncate(buyerName, 64)),
                    ("@pc", paidCurrency), ("@pa", DbValue(paidAmount)), ("@id", listingId));
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketCloseListing failed for listing {listingId} ({status}): {ex}");
            }
        }

        /// <summary>The seller's active or expired listing goes (back) on the market until newExpiry. False if it isn't theirs or isn't listed.</summary>
        public bool MarketRelist(ulong listingId, uint sellerAccountId, DateTime newExpiry)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null,
                    @"UPDATE market_listing SET status = 'active', expires_At = @e
                      WHERE id = @id AND seller_Account_Id = @a AND status IN ('active', 'expired');",
                    ("@e", newExpiry), ("@id", listingId), ("@a", sellerAccountId));
                return cmd.ExecuteNonQuery() > 0;
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketRelist failed for listing {listingId}: {ex}");
                return false;
            }
        }

        public string MarketGetMeta(string key)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null, "SELECT v FROM market_meta WHERE k = @k;", ("@k", key));
                var v = cmd.ExecuteScalar();
                return v == null || v is DBNull ? null : Convert.ToString(v);
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketGetMeta failed for {key}: {ex}");
                throw; // callers must not mistake a failed read for "not set"
            }
        }

        public void MarketSetMeta(string key, string value)
        {
            using var context = new ShardDbContext();
            var conn = MarketOpen(context);
            using var cmd = BankCommand(conn, null, "INSERT INTO market_meta (k, v) VALUES (@k, @v) ON DUPLICATE KEY UPDATE v = @v;", ("@k", key), ("@v", value));
            cmd.ExecuteNonQuery();
        }

        public bool MarketHasIcon(uint iconId)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null, "SELECT COUNT(*) FROM market_icon WHERE icon_Id = @i;", ("@i", iconId));
                return Convert.ToInt64(cmd.ExecuteScalar()) > 0;
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketHasIcon failed for 0x{iconId:X8}: {ex}");
                return true; // try again some other time
            }
        }

        public void MarketSaveIcon(uint iconId, byte[] png)
        {
            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var cmd = BankCommand(conn, null, "INSERT IGNORE INTO market_icon (icon_Id, png) VALUES (@i, @p);", ("@i", iconId), ("@p", (object)png));
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketSaveIcon failed for 0x{iconId:X8}: {ex}");
            }
        }

        /// <summary>For /marketcheck: the account's listings (newest first) and latest requests, as text lines.</summary>
        public List<string> MarketGetAccountActivity(uint accountId, int count)
        {
            var lines = new List<string>();

            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);

                using (var cmd = BankCommand(conn, null,
                    @"SELECT id, name, stack_Size, status, price_Mmd, price_Trophies, expires_At, buyer_Name, paid_Currency, paid_Amount, item_Guid
                      FROM market_listing WHERE seller_Account_Id = @a OR buyer_Account_Id = @a ORDER BY id DESC LIMIT @n;", ("@a", accountId), ("@n", count)))
                using (var r = cmd.ExecuteReader())
                {
                    lines.Add("Listings (sold by or bought by this account):");
                    while (r.Read())
                        lines.Add($"  #{r.GetValue(0)} {r.GetString(1)} x{r.GetValue(2)} [{r.GetString(3)}] mmd={(r.IsDBNull(4) ? "-" : r.GetValue(4).ToString())} trophies={(r.IsDBNull(5) ? "-" : r.GetValue(5).ToString())} ends {r.GetDateTime(6):yyyy-MM-dd}"
                            + (r.IsDBNull(7) ? "" : $" buyer {r.GetString(7)} paid {r.GetValue(9)} {r.GetValue(8)}") + $" item 0x{Convert.ToUInt32(r.GetValue(10)):X8}");
                }

                using (var cmd = BankCommand(conn, null,
                    @"SELECT id, created_At, character_Name, kind, status, result FROM market_request WHERE account_Id = @a ORDER BY id DESC LIMIT @n;", ("@a", accountId), ("@n", count)))
                using (var r = cmd.ExecuteReader())
                {
                    lines.Add("Requests:");
                    while (r.Read())
                        lines.Add($"  #{r.GetValue(0)} {r.GetDateTime(1):yyyy-MM-dd HH:mm} {(r.IsDBNull(2) ? "" : r.GetString(2))}: {r.GetString(3)} [{r.GetString(4)}] {(r.IsDBNull(5) ? "" : r.GetString(5))}");
                }
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketGetAccountActivity failed for account {accountId}: {ex}");
                return null;
            }

            return lines;
        }

        /// <summary>Saves (or replaces) the details of mule items, for the website's My Market page.</summary>
        public void MarketSaveItemDetails(List<(uint itemGuid, string details)> items)
        {
            if (items.Count == 0)
                return;

            try
            {
                using var context = new ShardDbContext();
                var conn = MarketOpen(context);
                using var tx = conn.BeginTransaction(IsolationLevel.ReadCommitted);
                var now = DateTime.UtcNow;

                foreach (var (itemGuid, details) in items)
                {
                    using var cmd = BankCommand(conn, tx, "REPLACE INTO market_item_detail (item_Guid, details, updated_At) VALUES (@g, @d, @t);",
                        ("@g", itemGuid), ("@d", details), ("@t", now));
                    cmd.ExecuteNonQuery();
                }

                tx.Commit();
            }
            catch (Exception ex)
            {
                log.Error($"[MARKET] MarketSaveItemDetails failed for {items.Count} item(s): {ex}");
            }
        }

        // ---------------------------------------------------------------- mule storage, read straight from the database
        // Used only while no character on the account has the mule loaded in memory (see MarketManager).

        /// <summary>The account's mule storage containers, head first. Empty if the account never summoned a mule.</summary>
        public List<uint> MarketGetMuleChain(uint accountId)
        {
            var chain = new List<uint>();

            var head = GetAccountMuleContainerId(accountId);
            if (!head.HasValue)
                return chain;

            using var context = new ShardDbContext();
            var conn = MarketOpen(context);

            var next = (uint?)head.Value;

            while (next.HasValue && chain.Count < 50 && !chain.Contains(next.Value))
            {
                chain.Add(next.Value);

                using var cmd = BankCommand(conn, null, "SELECT value FROM biota_properties_i_i_d WHERE object_Id = @o AND type = @t;",
                    ("@o", next.Value), ("@t", (ushort)PropertyInstanceId.MuleNextContainerId));
                var v = cmd.ExecuteScalar();
                next = v == null || v is DBNull ? (uint?)null : Convert.ToUInt32(v);
            }

            return chain;
        }

        /// <summary>The container an item is in, or null.</summary>
        public uint? MarketGetItemContainer(uint itemGuid)
        {
            using var context = new ShardDbContext();
            var conn = MarketOpen(context);
            using var cmd = BankCommand(conn, null, "SELECT value FROM biota_properties_i_i_d WHERE object_Id = @o AND type = @t;",
                ("@o", itemGuid), ("@t", (ushort)PropertyInstanceId.Container));
            var v = cmd.ExecuteScalar();
            return v == null || v is DBNull ? (uint?)null : Convert.ToUInt32(v);
        }

        /// <summary>How many items are in a container.</summary>
        public int MarketCountContainerItems(uint containerGuid)
        {
            using var context = new ShardDbContext();
            var conn = MarketOpen(context);
            using var cmd = BankCommand(conn, null, "SELECT COUNT(*) FROM biota_properties_i_i_d WHERE type = @t AND value = @c;",
                ("@t", (ushort)PropertyInstanceId.Container), ("@c", containerGuid));
            return Convert.ToInt32(cmd.ExecuteScalar());
        }
    }
}
