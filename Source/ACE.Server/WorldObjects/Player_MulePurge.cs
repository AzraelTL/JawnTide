using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Server.Entity;
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
    ///   set:TEXT                     its armor set name contains TEXT
    ///   name:TEXT / -name:TEXT, or a plain word: its name contains / doesn't contain TEXT
    /// Use "quotes" for text with spaces, e.g. spell:"legendary strength".
    /// </summary>
    partial class Player
    {
        private HashSet<uint> pendingMulePurge;
        private DateTime pendingMulePurgeAt;
        private uint pendingMulePurgeVendor;

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

            // show just these in the mule window, so they can be checked before confirming
            vendor.MuleSearchRegex = null;
            vendor.MuleSuitGuids = new HashSet<uint>(pendingMulePurge);
            RefreshMuleVendorDisplay(vendor, VendorType.Undef);

            var units = matches.Sum(wo => wo.StackSize ?? 1);
            var sample = string.Join(", ", matches.Take(6).Select(wo => wo.NameWithMaterial ?? wo.Name)) + (matches.Count > 6 ? $" and {matches.Count - 6} more" : "");
            Say($"{matches.Count} mule item{(matches.Count == 1 ? "" : "s")} match{(matches.Count == 1 ? "es" : "")} ({units:N0} counting stacks): {sample}. " +
                $"The mule window now shows only these. To DELETE them for good, type /mule purge confirm within {MulePurgeConfirmMinutes} minutes. /mule purge cancel to stop.");
        }

        private void ConfirmMulePurge(Vendor vendor, Action<string> Say)
        {
            if (pendingMulePurge == null || DateTime.UtcNow - pendingMulePurgeAt > TimeSpan.FromMinutes(MulePurgeConfirmMinutes) || pendingMulePurgeVendor != vendor.Guid.Full)
            {
                pendingMulePurge = null;
                Say($"Nothing to confirm. Run /mule purge FILTER first, then confirm within {MulePurgeConfirmMinutes} minutes.");
                return;
            }

            var guids = pendingMulePurge;
            pendingMulePurge = null;

            var touched = new HashSet<WorldObject>();
            var deleted = new List<string>();

            foreach (var guid in guids)
            {
                var objGuid = new ACE.Entity.ObjectGuid(guid);
                var container = ResolveMuleItemContainer(vendor.MuleContainers, objGuid);
                if (container == null || !container.TryRemoveFromInventory(objGuid, out var item) || item == null)
                    continue;

                vendor.UniqueItemsForSale.Remove(objGuid);
                touched.Add(container);
                deleted.Add($"{item.NameWithMaterial ?? item.Name} x{item.StackSize ?? 1} (0x{guid:X8})");
                item.Destroy();   // handles its own database removal
            }

            foreach (var c in touched)
                c.SaveBiotaToDatabase();

            vendor.MuleSuitGuids = null;
            RefreshMuleVendorDisplay(vendor, VendorType.Undef);

            log.Info($"[MULE] {Name} (0x{Guid}, account {Account.AccountId}) purged {deleted.Count} mule items: {string.Join(", ", deleted)}");
            Say($"Deleted {deleted.Count} item{(deleted.Count == 1 ? "" : "s")} from your mule.");
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
