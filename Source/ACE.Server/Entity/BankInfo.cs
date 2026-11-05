using System;
using System.Collections.Generic;
using System.Linq;

namespace ACE.Server.Entity
{
    public enum BankCurrencyKind
    {
        /// <summary>Pyreal coins and trade notes, banked as their pyreal value.</summary>
        Pyreals,
        /// <summary>A stackable item, banked by count.</summary>
        Stack,
        /// <summary>A single-use key (one per item), banked by count. Only unused keys are taken.</summary>
        Key,
        /// <summary>Available luminance.</summary>
        Luminance
    }

    public class BankCurrency
    {
        /// <summary>The account_bank.currency value. Never rename one that is live.</summary>
        public string Code;
        public string Name;
        public BankCurrencyKind Kind;
        public uint Wcid;
        public string[] Aliases;

        /// <summary>
        /// JawnTide: can't be deposited or sent any more (only withdrawn), so carrying it keeps its PK risk.
        /// </summary>
        public bool WithdrawOnly;
    }

    /// <summary>
    /// JawnTide Bank: what the account-wide bank holds. To add a stackable or key currency, add a line here
    /// (a new Code adds a new row per account automatically; nothing else changes).
    /// </summary>
    public static class BankInfo
    {
        public const uint PyrealWcid = 273;
        public const uint MMDWcid = 20630;
        public const long MMDValue = 250000;

        /// <summary>Trade notes taken on deposit, with their pyreal value each.</summary>
        public static readonly Dictionary<uint, long> TradeNoteValues = new Dictionary<uint, long>
        {
            { 2621, 100 },
            { 2622, 500 },
            { 2623, 1000 },
            { 2624, 5000 },
            { 2625, 10000 },
            { 7374, 15000 },
            { 7375, 20000 },
            { 7376, 25000 },
            { 2626, 50000 },
            { 7377, 75000 },
            { 2627, 100000 },
            { 20628, 150000 },
            { 20629, 200000 },
            { 20630, 250000 },
        };

        public static readonly List<BankCurrency> Currencies = new List<BankCurrency>
        {
            new BankCurrency { Code = "pyreals",      Name = "Pyreals",                     Kind = BankCurrencyKind.Pyreals,   Wcid = PyrealWcid, Aliases = new[] { "pyreals", "pyreal", "py", "p", "notes", "mmd", "mmds" } },
            new BankCurrency { Code = "pk_trophies",  Name = "PK Trophies",                 Kind = BankCurrencyKind.Stack,     Wcid = 1000002,    Aliases = new[] { "trophies", "trophy", "pk", "pktrophy", "pktrophies", "t" } },
            new BankCurrency { Code = "luminance",    Name = "Luminance",                   Kind = BankCurrencyKind.Luminance, Wcid = 0,          Aliases = new[] { "luminance", "lum", "l" } },
            new BankCurrency { Code = "key_darkbeat", Name = "Darkbeat's Lost Storage Key", Kind = BankCurrencyKind.Key,       Wcid = 480608,     WithdrawOnly = true, Aliases = new[] { "darkbeat", "darkbeats", "darkbeatkey", "dk" } },
            new BankCurrency { Code = "key_hera",     Name = "Hera's Vault Key",            Kind = BankCurrencyKind.Key,       Wcid = 490364,     WithdrawOnly = true, Aliases = new[] { "hera", "heras", "herakey", "hk" } },
            new BankCurrency { Code = "key_skeleton", Name = "Shimmering Skeleton Key",     Kind = BankCurrencyKind.Key,       Wcid = 30258,      WithdrawOnly = true, Aliases = new[] { "skeleton", "shimmering", "skeletonkey", "sk" } },
        };

        public static BankCurrency Find(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return null;

            var t = text.Trim().ToLowerInvariant().Replace("'", "");

            return Currencies.FirstOrDefault(c => c.Code == t || c.Aliases.Contains(t));
        }

        public static BankCurrency ByCode(string code) => Currencies.FirstOrDefault(c => c.Code == code);

        /// <summary>The standard trade note worth exactly this many pyreals, or 0.</summary>
        public static uint TradeNoteWcidForValue(long value) => TradeNoteValues.FirstOrDefault(kv => kv.Value == value).Key;

        /// <summary>The bank currency a vendor's purchases can be paid from (null alternate currency = pyreals), or null if none.</summary>
        public static BankCurrency ForVendorCurrency(uint? alternateCurrency)
        {
            if (alternateCurrency == null)
                return ByCode("pyreals");

            return Currencies.FirstOrDefault(c => c.Kind == BankCurrencyKind.Stack && c.Wcid == alternateCurrency.Value);
        }

        public static string Format(BankCurrency currency, long amount) => $"{amount:N0} {currency.Name}";

        /// <summary>Accepts 1000, 1,000, 5k, 2.5m, 1b (k/m/b suffixes).</summary>
        public static bool TryParseAmount(string text, out long value)
        {
            value = 0;

            if (string.IsNullOrWhiteSpace(text))
                return false;

            var t = text.Trim().ToLowerInvariant().Replace(",", "").Replace("_", "");

            long mult = 1;

            if (t.EndsWith("k")) { mult = 1_000; t = t[..^1]; }
            else if (t.EndsWith("m")) { mult = 1_000_000; t = t[..^1]; }
            else if (t.EndsWith("b")) { mult = 1_000_000_000; t = t[..^1]; }

            if (!decimal.TryParse(t, System.Globalization.NumberStyles.AllowDecimalPoint, System.Globalization.CultureInfo.InvariantCulture, out var d))
                return false;

            var total = d * mult;

            if (total <= 0 || total > long.MaxValue / 4 || total != Math.Floor(total))
                return false;

            value = (long)total;
            return true;
        }
    }
}
