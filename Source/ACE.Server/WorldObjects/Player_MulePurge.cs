using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Database;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide: /mule purge FILTER deletes many mule items at once. The first command only shows what matches (the mule window
    /// is filtered to those items); "/mule purge confirm" within 2 minutes deletes them. Only characters on the mule's own
    /// account can purge, never guests.
    ///
    /// Filter words (all must match; several type: words mean any of those types):
    ///   type:armor|shield|clothing|jewelry|melee|missile|caster|weapon|salvage|gem|food|key|manastone|component|misc
    ///   al, level, value, work, lore, dmg, spells   compared with &lt; &lt;= &gt; &gt;= = (e.g. al&lt;200, level&lt;=150, work&gt;=8)
    ///   spell:TEXT / -spell:TEXT     has / hasn't a spell whose name matches TEXT (a regular expression, e.g. -spell:legendary)
    ///   material:cloth|leather|metal|gem|stone|wood|ceramic, or a material name (steel, satin); -material: for "not"
    ///   suit:CODE                    is one of the items of a suit saved on the website (Suit Builder)
    ///   set:TEXT                     its armor set name contains TEXT
    ///   name:TEXT / -name:TEXT, or a plain word: its name contains / doesn't contain TEXT
    /// Use "quotes" for text with spaces, e.g. spell:"legendary strength".
    /// </summary>
    partial class Player
    {
        private HashSet<uint> pendingMulePurge;
        private DateTime pendingMulePurgeAt;
        private uint pendingMulePurgeVendor;
        private string pendingMulePurgeFilter;

        private const int MulePurgeConfirmMinutes = 2;

        private static readonly Regex PurgeToken = new Regex(@"(-?[a-z]+):(""[^""]*""|\S+)|([a-z]+)\s*(<=|>=|<|>|=)\s*(-?[\d.]+)|(""[^""]*""|\S+)",
            RegexOptions.IgnoreCase | RegexOptions.Compiled);

        public void MulePurge(string args)
        {
            void Say(string text) => Session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

            var vendor = CurrentLandblock?.GetObject(LastOpenedContainerId) as Vendor;

            if (vendor == null || !vendor.MuleOwnerId.HasValue || vendor.MuleContainers == null || !CanAccessMuleStorage(vendor))
            {
                Say("Open your mule first, then type /mule purge FILTER (for example /mule purge type:shield al<200).");
                return;
            }

            if (IsMuleGuestOf(vendor))
            {
                Say("Only characters on the mule's own account can purge it.");
                return;
            }

            if (ACE.Server.Managers.MarketManager.IsAccountBusy(Account.AccountId))
            {
                Say("Your mule is busy with a market order. Try again in a few seconds.");
                return;
            }

            args = (args ?? "").Trim();

            if (args.Equals("confirm", StringComparison.OrdinalIgnoreCase))
            {
                ConfirmMulePurge(vendor, Say);
                return;
            }

            if (args.Equals("list", StringComparison.OrdinalIgnoreCase))
            {
                ListMulePurges(Say);
                return;
            }

            if (args.StartsWith("undo", StringComparison.OrdinalIgnoreCase))
            {
                UndoMulePurge(vendor, args.Substring(4).Trim(), Say);
                return;
            }

            if (args.Length == 0 || args.Equals("cancel", StringComparison.OrdinalIgnoreCase))
            {
                pendingMulePurge = null;
                Say(args.Length == 0
                    ? "Usage: /mule purge FILTER, then /mule purge confirm. Filters: type:armor|shield|clothing|jewelry|melee|missile|caster|weapon|salvage|gem|..., " +
                      "al/level/value/work/lore/dmg/spells with < <= > >= = (al<200), material:cloth|leather|metal|..., spell:TEXT, -spell:TEXT, set:TEXT, name:TEXT, -name:TEXT."
                    : "Mule purge canceled.");
                return;
            }

            var filters = new List<Func<WorldObject, bool>>();
            var types = new List<Func<WorldObject, bool>>();

            foreach (Match m in PurgeToken.Matches(args))
            {
                string Unquote(string s) => s.Length >= 2 && s[0] == '"' && s[^1] == '"' ? s[1..^1] : s;

                if (m.Groups[1].Success)
                {
                    var key = m.Groups[1].Value.ToLowerInvariant();
                    var val = Unquote(m.Groups[2].Value);
                    var not = key.StartsWith("-");
                    key = key.TrimStart('-');

                    Func<WorldObject, bool> f;
                    Func<WorldObject, bool> known = wo => true;   // whether the item says what this filter looks at
                    switch (key)
                    {
                        case "type":
                            var t = PurgeType(val);
                            if (t == null) { Say($"Unknown type: {val}. Use armor, shield, clothing, jewelry, melee, missile, caster, weapon, salvage, gem, food, key, manastone, component or misc."); return; }
                            if (not) filters.Add(wo => !t(wo)); else types.Add(t);
                            continue;
                        case "spell":
                            Regex rx;
                            try { rx = new Regex(val, RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(200)); }
                            catch (ArgumentException) { Say($"That spell pattern isn't valid: {val}"); return; }
                            f = wo => GetSearchableSpellIds(wo).Any(id => SafeMatch(rx, new ACE.Server.Entity.Spell(id, false).Name));
                            break;
                        case "material":
                        case "mat":
                            var mat = PurgeMaterial(val);
                            known = wo => wo.MaterialType.HasValue && wo.MaterialType.Value != ACE.Entity.Enum.MaterialType.Unknown;
                            f = wo => known(wo) && mat((uint)wo.MaterialType.Value);
                            break;
                        case "suit":
                            // the items of a suit saved on the website (e.g. the Suit Builder's "beaten items" list)
                            var suitGuids = LoadSuitPlanGuids(vendor, val);
                            if (suitGuids == null) { Say($"There's no saved suit {val.ToUpperInvariant()} for this mule or your account."); return; }
                            f = wo => suitGuids.Contains(wo.Guid.Full);
                            break;
                        case "set":
                            f = wo => (wo.EquipmentSetId?.ToString() ?? "").Contains(val.Replace(" ", ""), StringComparison.OrdinalIgnoreCase);
                            break;
                        case "name":
                            f = wo => (wo.NameWithMaterial ?? wo.Name ?? "").Contains(val, StringComparison.OrdinalIgnoreCase);
                            break;
                        default:
                            Say($"Unknown filter: {m.Value}");
                            return;
                    }
                    // erring on the side of caution: "not X" never matches an item that doesn't say what it is
                    filters.Add(not ? wo => known(wo) && !f(wo) : f);
                }
                else if (m.Groups[3].Success)
                {
                    var field = m.Groups[3].Value.ToLowerInvariant();
                    var op = m.Groups[4].Value;
                    if (!double.TryParse(m.Groups[5].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out var num)) { Say($"Not a number: {m.Value}"); return; }

                    Func<WorldObject, double?> get = field switch
                    {
                        "al" => wo => wo.GetProperty(PropertyInt.ArmorLevel),
                        "level" => wo => PurgeWieldLevel(wo),
                        "value" => wo => wo.Value,
                        "work" => wo => wo.Workmanship,
                        "lore" => wo => wo.GetProperty(PropertyInt.ItemDifficulty),
                        "dmg" => wo => wo.GetProperty(PropertyInt.Damage),
                        "spells" => wo => GetSearchableSpellIds(wo).Count(),
                        _ => null
                    };
                    if (get == null) { Say($"Unknown field: {field}. Use al, level, value, work, lore, dmg or spells."); return; }

                    // erring on the side of caution: an item without the property never matches (no armor level, no level requirement, ...)
                    filters.Add(wo =>
                    {
                        var got = get(wo);
                        if (!got.HasValue)
                            return false;
                        var v = got.Value;
                        return op switch { "<" => v < num, "<=" => v <= num, ">" => v > num, ">=" => v >= num, _ => Math.Abs(v - num) < 0.0001 };
                    });
                }
                else
                {
                    var word = Unquote(m.Groups[6].Value);
                    filters.Add(wo => (wo.NameWithMaterial ?? wo.Name ?? "").Contains(word, StringComparison.OrdinalIgnoreCase));
                }
            }

            if (types.Count > 0)
                filters.Add(wo => types.Any(t => t(wo)));

            if (filters.Count == 0)
            {
                Say("Give at least one filter, so a purge never deletes everything by accident.");
                return;
            }

            var matches = vendor.MuleContainers.SelectMany(c => c.Inventory.Values).Where(wo => filters.All(f => f(wo))).ToList();

            if (matches.Count == 0)
            {
                pendingMulePurge = null;
                Say("Nothing in your mule matches that.");
                return;
            }

            pendingMulePurge = matches.Select(wo => wo.Guid.Full).ToHashSet();
            pendingMulePurgeAt = DateTime.UtcNow;
            pendingMulePurgeVendor = vendor.Guid.Full;
            pendingMulePurgeFilter = args.Length > 255 ? args.Substring(0, 255) : args;

            // show just these in the mule window, so they can be checked before confirming
            vendor.MuleSearchRegex = null;
            vendor.MuleSuitGuids = new HashSet<uint>(pendingMulePurge);
            vendor.MuleCompsOnly = false;
            vendor.MulePage = 0;
            RefreshMuleVendorDisplay(vendor, VendorType.Undef);

            var units = matches.Sum(wo => wo.StackSize ?? 1);
            var sample = string.Join(", ", matches.Take(6).Select(wo => wo.NameWithMaterial ?? wo.Name)) + (matches.Count > 6 ? $" and {matches.Count - 6} more" : "");
            Say($"{matches.Count} mule item{(matches.Count == 1 ? "" : "s")} match{(matches.Count == 1 ? "es" : "")} ({units:N0} counting stacks): {sample}. " +
                $"The mule window now shows only these: check them. To remove them, type /mule purge confirm within {MulePurgeConfirmMinutes} minutes (you'll get a warning to agree to). /mule purge cancel to stop.");
        }

        private void ConfirmMulePurge(Vendor vendor, Action<string> Say)
        {
            if (pendingMulePurge == null || DateTime.UtcNow - pendingMulePurgeAt > TimeSpan.FromMinutes(MulePurgeConfirmMinutes) || pendingMulePurgeVendor != vendor.Guid.Full)
            {
                pendingMulePurge = null;
                Say($"Nothing to confirm. Run /mule purge FILTER first, then confirm within {MulePurgeConfirmMinutes} minutes.");
                return;
            }

            var count = pendingMulePurge.Count;
            var days = ACE.Server.Managers.MulePurgeManager.HoldDays;
            var msg = $"WARNING: remove {count} item{(count == 1 ? "" : "s")} from your mule?\n\n" +
                      "Check the mule window first: it shows exactly what will be removed. If your filter caught items you meant to keep, say No.\n\n" +
                      (days > 0
                        ? $"The items are held for {days} day{(days == 1 ? "" : "s")}: /mule purge undo brings the last purge back (/mule purge list shows them). After that they are deleted for good and can't be recovered."
                        : "They are deleted for good right away and can't be recovered.");

            if (!ConfirmationManager.EnqueueSend(new Confirmation_Custom(Guid, () => ExecuteMulePurge(vendor)), msg))
                Say("You already have a question waiting. Answer it first.");
        }

        /// <summary>After the popup's Yes: takes the items out of the mule into the account's purge bin, held for mule_purge_hold_days.</summary>
        private void ExecuteMulePurge(Vendor vendor)
        {
            void Say(string text) => Session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

            if (pendingMulePurge == null || vendor == null || vendor.IsDestroyed || vendor.MuleContainers == null || pendingMulePurgeVendor != vendor.Guid.Full
                || DateTime.UtcNow - pendingMulePurgeAt > TimeSpan.FromMinutes(MulePurgeConfirmMinutes + 2))
            {
                pendingMulePurge = null;
                Say("That purge expired or your mule left. Nothing was removed.");
                return;
            }

            var guids = pendingMulePurge;
            var filter = pendingMulePurgeFilter;
            pendingMulePurge = null;

            var db = DatabaseManager.Shard.BaseDatabase;
            var accountId = Account.AccountId;
            var days = ACE.Server.Managers.MulePurgeManager.HoldDays;

            // the account's purge bin: a storage container that isn't part of the mule, so held items don't show or count
            uint binGuid = 0;
            if (days > 0)
            {
                var rows = db.PvpToolsQuery("SELECT container_Id FROM mule_purge_bin WHERE account_Id = @a;", ("@a", accountId));
                if (rows == null)
                {
                    Say("The purge couldn't start (database). Nothing was removed.");
                    return;
                }
                if (rows.Count > 0)
                    binGuid = Convert.ToUInt32(rows[0][0]);
                else
                {
                    var bin = CreateNewMuleContainer();
                    if (bin == null)
                    {
                        Say("The purge couldn't start. Nothing was removed.");
                        return;
                    }
                    binGuid = bin.Guid.Full;
                    db.PvpToolsExecute("INSERT INTO mule_purge_bin (account_Id, container_Id) VALUES (@a, @c);", ("@a", accountId), ("@c", binGuid));
                }
            }

            var touched = new HashSet<WorldObject>();
            var moved = new List<(uint guid, string name, int stack)>();

            foreach (var guid in guids)
            {
                var objGuid = new ACE.Entity.ObjectGuid(guid);
                var container = ResolveMuleItemContainer(vendor.MuleContainers, objGuid);
                if (container == null || !container.TryRemoveFromInventory(objGuid, out var item) || item == null)
                    continue;

                vendor.UniqueItemsForSale.Remove(objGuid);
                touched.Add(container);
                moved.Add((guid, (item.NameWithMaterial ?? item.Name ?? "?").Length > 128 ? (item.NameWithMaterial ?? item.Name).Substring(0, 128) : (item.NameWithMaterial ?? item.Name ?? "?"), item.StackSize ?? 1));

                if (days > 0)
                {
                    item.ContainerId = binGuid;
                    item.SaveBiotaToDatabase();
                }
                else
                    item.Destroy();   // handles its own database removal
            }

            foreach (var c in touched)
                c.SaveBiotaToDatabase();

            vendor.MuleSuitGuids = null;
            vendor.MuleCompsOnly = false;
            vendor.MulePage = 0;
            RefreshMuleVendorDisplay(vendor, VendorType.Undef);

            if (moved.Count > 0)
            {
                var by = Name;
                var batch = DateTime.UtcNow.Ticks;
                var status = days > 0 ? "held" : "deleted";
                DatabaseManager.Shard.MarketEnqueue(() =>
                {
                    foreach (var m in moved)
                        db.PvpToolsExecute("INSERT INTO mule_purge (account_Id, batch_Id, item_Guid, item_Name, stack_Size, filter, purged_By, purged_At, status, done_At) " +
                                           "VALUES (@a, @b, @g, @n, @s, @f, @by, @t, @st, @d);",
                            ("@a", accountId), ("@b", batch), ("@g", m.guid), ("@n", m.name), ("@s", m.stack), ("@f", filter), ("@by", by),
                            ("@t", DateTime.UtcNow), ("@st", status), ("@d", days > 0 ? null : (object)DateTime.UtcNow));
                });
            }

            log.Info($"[MULE] {Name} (0x{Guid}, account {accountId}) purged {moved.Count} mule items ({(days > 0 ? $"held {days} days" : "deleted")}), filter \"{filter}\": " +
                     string.Join(", ", moved.Select(m => $"{m.name} x{m.stack} (0x{m.guid:X8})")));
            Say(days > 0
                ? $"Removed {moved.Count} item{(moved.Count == 1 ? "" : "s")} from your mule. They're held for {days} day{(days == 1 ? "" : "s")}: /mule purge undo brings them back."
                : $"Deleted {moved.Count} item{(moved.Count == 1 ? "" : "s")} from your mule.");
        }

        /// <summary>/mule purge list: this account's purges still held.</summary>
        private void ListMulePurges(Action<string> Say)
        {
            var rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery(
                "SELECT batch_Id, MIN(purged_At), COUNT(*), MIN(filter), MIN(purged_By) FROM mule_purge WHERE account_Id = @a AND status = 'held' GROUP BY batch_Id ORDER BY batch_Id DESC LIMIT 10;",
                ("@a", Account.AccountId));
            if (rows == null || rows.Count == 0)
            {
                Say("No purged items are being held for your account.");
                return;
            }
            var days = ACE.Server.Managers.MulePurgeManager.HoldDays;
            var i = 0;
            Say("Purges you can still undo (newest first; /mule purge undo N brings one back, /mule purge undo the newest):");
            foreach (var r in rows)
            {
                i++;
                var at = (DateTime)r[1];
                var left = at.AddDays(days) - DateTime.UtcNow;
                Say($"  {i}. {Convert.ToInt32(r[2])} items, \"{r[3]}\" by {r[4]}, deleted for good in {(left.TotalHours >= 24 ? $"{(int)left.TotalDays} days" : $"{Math.Max(0, (int)left.TotalHours)} hours")}");
            }
        }

        /// <summary>/mule purge undo [N]: brings a held purge back into the open mule (newest, or the Nth from /mule purge list).</summary>
        private void UndoMulePurge(Vendor vendor, string which, Action<string> Say)
        {
            var n = 1;
            if (!string.IsNullOrWhiteSpace(which) && (!int.TryParse(which, out n) || n < 1 || n > 10))
            {
                Say("Usage: /mule purge undo [N], where N is a number from /mule purge list.");
                return;
            }

            var accountId = Account.AccountId;
            var db = DatabaseManager.Shard.BaseDatabase;

            DatabaseManager.Shard.MarketEnqueue(() =>
            {
                var batches = db.PvpToolsQuery("SELECT batch_Id FROM mule_purge WHERE account_Id = @a AND status = 'held' GROUP BY batch_Id ORDER BY batch_Id DESC LIMIT 10;", ("@a", accountId));
                if (batches == null || batches.Count < n)
                {
                    EnqueueAction(new ActionEventDelegate(() => Say("There's no held purge to undo. /mule purge list shows them.")));
                    return;
                }
                var batch = Convert.ToInt64(batches[n - 1][0]);
                var rows = db.PvpToolsQuery("SELECT id, item_Guid FROM mule_purge WHERE account_Id = @a AND batch_Id = @b AND status = 'held';", ("@a", accountId), ("@b", batch));

                // read the held items here, off the game thread
                var items = new List<(long id, ACE.Database.Models.Shard.Biota biota)>();
                foreach (var r in rows ?? new List<object[]>())
                {
                    var b = db.GetBiota(Convert.ToUInt32(r[1]));
                    if (b != null)
                        items.Add((Convert.ToInt64(r[0]), b));
                }

                EnqueueAction(new ActionEventDelegate(() =>
                {
                    if (vendor == null || vendor.IsDestroyed || vendor.MuleContainers == null)
                    {
                        Say("Your mule left. Open it again and retry /mule purge undo.");
                        return;
                    }

                    // only as many as the mule has room for; the rest stay held for another undo
                    var free = vendor.MuleContainers.Sum(c => Math.Max(0, (c.ItemCapacity ?? 0) - c.Inventory.Count))
                               + Math.Max(0, MuleInfo.MaxContainers - vendor.MuleContainers.Count) * 255;
                    var skipped = Math.Max(0, items.Count - free);

                    var touched = new HashSet<WorldObject>();
                    var restored = new List<long>();
                    foreach (var (id, biota) in items.Take(free))
                    {
                        var wo = WorldObjectFactory.CreateWorldObject(biota);
                        if (wo == null)
                            continue;
                        wo.ContainerId = null;
                        AddToMuleStorage(vendor.MuleContainers, wo, touched);
                        restored.Add(id);
                    }

                    foreach (var wo in touched)
                        wo.SaveBiotaToDatabase();

                    ACE.Server.Managers.MarketManager.QueueIcons(touched);
                    RefreshMuleVendorDisplay(vendor, VendorType.Undef);

                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        foreach (var id in restored)
                            db.PvpToolsExecute("UPDATE mule_purge SET status = 'restored', done_At = @t WHERE id = @id;", ("@t", DateTime.UtcNow), ("@id", id));
                    });

                    log.Info($"[MULE] {Name} (0x{Guid}, account {accountId}) undid a purge: {restored.Count} items back in the mule");
                    Say($"Brought {restored.Count} item{(restored.Count == 1 ? "" : "s")} back into your mule." +
                        (skipped > 0 ? $" {skipped} more didn't fit and are still held: make room and run /mule purge undo again." : ""));
                }));
            });
        }

        private HashSet<uint> LoadSuitPlanGuids(Vendor vendor, string code)
        {
            code = (code ?? "").Trim().ToUpperInvariant();
            if (!Regex.IsMatch(code, "^[A-Z0-9]{4,8}$"))
                return null;
            var rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery("SELECT items FROM suit_plan WHERE account_Id IN (@a, @me) AND code = @c ORDER BY account_Id = @me DESC LIMIT 1;",
                ("@a", vendor.MuleOwnerAccountId ?? 0), ("@me", Account.AccountId), ("@c", code));
            if (rows == null || rows.Count == 0)
                return null;
            var set = new HashSet<uint>();
            foreach (var part in (rows[0][0]?.ToString() ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries))
                if (uint.TryParse(part.Trim(), out var g))
                    set.Add(g);
            return set;
        }

        private static bool SafeMatch(Regex rx, string text)
        {
            try { return text != null && rx.IsMatch(text); }
            catch (RegexMatchTimeoutException) { return false; }
        }

        /// <summary>material:cloth|leather|metal|gem|stone|wood|ceramic (the groups), or any material name or part of one (steel, satin, hide).</summary>
        private static Func<uint, bool> PurgeMaterial(string name)
        {
            switch (name.ToLowerInvariant())
            {
                case "ceramic": return m => m >= 1 && m <= 2;
                case "cloth": return m => m >= 3 && m <= 8;
                case "gem": return m => m >= 9 && m <= 50;
                case "leather": return m => m >= 52 && m <= 55;
                case "metal": return m => m >= 56 && m <= 64;
                case "stone": return m => m >= 65 && m <= 71;
                case "wood": return m => m >= 72 && m <= 77;
            }
            var key = name.Replace(" ", "");
            return m => ((MaterialType)m).ToString().Contains(key, StringComparison.OrdinalIgnoreCase);
        }

        private static double? PurgeWieldLevel(WorldObject wo)
        {
            var pairs = new[] { (PropertyInt.WieldRequirements, PropertyInt.WieldDifficulty), (PropertyInt.WieldRequirements2, PropertyInt.WieldDifficulty2),
                                (PropertyInt.WieldRequirements3, PropertyInt.WieldDifficulty3), (PropertyInt.WieldRequirements4, PropertyInt.WieldDifficulty4) };
            foreach (var (req, diff) in pairs)
                if (wo.GetProperty(req) == (int)WieldRequirement.Level)
                    return wo.GetProperty(diff);
            return null;
        }

        private static Func<WorldObject, bool> PurgeType(string name) => name.ToLowerInvariant() switch
        {
            "armor" => wo => (wo.ItemType & ItemType.Armor) != 0 && !IsPurgeShield(wo),
            "shield" or "shields" => IsPurgeShield,
            "clothing" => wo => (wo.ItemType & ItemType.Clothing) != 0,
            "jewelry" => wo => (wo.ItemType & ItemType.Jewelry) != 0,
            "melee" => wo => (wo.ItemType & ItemType.MeleeWeapon) != 0,
            "missile" => wo => (wo.ItemType & ItemType.MissileWeapon) != 0,
            "caster" or "wand" => wo => (wo.ItemType & ItemType.Caster) != 0,
            "weapon" or "weapons" => wo => (wo.ItemType & (ItemType.MeleeWeapon | ItemType.MissileWeapon | ItemType.Caster)) != 0,
            "salvage" => wo => (wo.ItemType & ItemType.TinkeringMaterial) != 0,
            "gem" or "gems" => wo => (wo.ItemType & ItemType.Gem) != 0,
            "food" => wo => (wo.ItemType & ItemType.Food) != 0,
            "key" or "keys" => wo => (wo.ItemType & ItemType.Key) != 0,
            "manastone" => wo => (wo.ItemType & ItemType.ManaStone) != 0,
            "component" or "components" => wo => (wo.ItemType & ItemType.SpellComponents) != 0,
            "misc" => wo => (wo.ItemType & ItemType.Misc) != 0,
            _ => null
        };

        private static bool IsPurgeShield(WorldObject wo) => wo.IsShield || ((wo.ValidLocations ?? 0) & EquipMask.Shield) != 0;
    }
}
