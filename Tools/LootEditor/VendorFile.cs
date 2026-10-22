using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace LootEditor
{
    /// <summary>One item a vendor sells (a create_list row with destination Shop).</summary>
    public class VendorItem
    {
        public uint Wcid;
        public string Name;
        public int StackSize;          // as stored: -1 = unlimited supply, 0 = normal

        internal List<string> Tokens;  // the original row, null for a newly added item
        internal string Comment;       // the original row's comment, kept when the item isn't changed
    }

    /// <summary>
    /// A vendor weenie SQL file. The weenie_properties_create_list rows with destination Shop (4) are what the
    /// vendor sells; BuyPrice (float 37), SellPrice (float 38) and AlternateCurrency (DID 57) set its prices.
    /// Saving rewrites only those; the vendor's other create_list rows (what it wears or carries) and everything
    /// else in the file stay as they are.
    ///
    /// In ACE a shop item costs ceil(SellPrice x item Value - 0.1), at least 1, in pyreals or in the vendor's
    /// alternate currency (Promissory Notes use a rate of 1.15). A vendor pays floor(BuyPrice x Value + 0.1).
    /// </summary>
    public class VendorFile
    {
        private const string CreateListTable = "weenie_properties_create_list";
        private const string FloatTable = "weenie_properties_float";
        private const string DidTable = "weenie_properties_d_i_d";
        private const int DestinationShop = 4;
        private const int FloatBuyPrice = 37;
        private const int FloatSellPrice = 38;
        private const int DidAlternateCurrency = 57;
        public const uint PromissoryNoteItemType = 0x00040000;

        public string Path { get; private set; }
        public uint Wcid { get; private set; }
        public string Name { get; private set; }
        public List<VendorItem> Items { get; } = new List<VendorItem>();
        public double? SellRate { get; private set; }
        public double? BuyRate { get; private set; }
        public uint? AlternateCurrency { get; private set; }

        private string text;
        private bool hasBom;
        private string newline;
        private SqlStatement createList;

        /// <summary>True when the file has a create_list with at least one Shop row.</summary>
        public static bool IsVendor(string fileText)
        {
            if (!fileText.Contains(CreateListTable))
                return false;
            try
            {
                var statement = SqlStatement.Find(fileText, CreateListTable);
                return statement != null && statement.Rows.Any(r => r.Tokens.Count == 7 && SqlStatement.TypeOf(r) == DestinationShop);
            }
            catch { return false; }
        }

        public static VendorFile Load(string path, WeenieIndex index)
        {
            var file = new VendorFile { Path = path };
            file.text = ReadText(path, out file.hasBom);
            file.newline = file.text.Contains("\r\n") ? "\r\n" : "\n";

            var header = ChestFile.ReadWeenieHeader(file.text);
            if (header == null)
                throw new InvalidDataException("Could not find the weenie header in " + path);
            file.Wcid = header.Value.wcid;
            file.Name = ChestFile.ReadName(file.text) ?? "(no name)";

            file.createList = SqlStatement.Find(file.text, CreateListTable);
            if (file.createList == null)
                throw new InvalidDataException("This file has no create list.");
            if (file.createList.Rows.Any(r => r.Tokens.Count != 7))
                throw new InvalidDataException("Unexpected create list row.");
            if (!file.createList.Rows.Any(IsShopRow))
                throw new InvalidDataException("This file's create list has no items for sale.");

            foreach (var row in file.createList.Rows.Where(IsShopRow))
            {
                var wcid = ParseUInt(row.Tokens[2]);
                file.Items.Add(new VendorItem
                {
                    Wcid = wcid,
                    Name = index.GetName(wcid) ?? NameFromComment(row.Comment) ?? "(unknown item)",
                    StackSize = ParseInt(row.Tokens[3]),
                    Tokens = row.Tokens,
                    Comment = row.Comment,
                });
            }

            var floats = SqlStatement.Find(file.text, FloatTable);
            if (floats != null)
            {
                foreach (var row in floats.Rows)
                {
                    var type = SqlStatement.TypeOf(row);
                    if ((type == FloatBuyPrice || type == FloatSellPrice) && double.TryParse(SqlStatement.StripComment(row.Tokens[2]), NumberStyles.Float, CultureInfo.InvariantCulture, out var rate))
                    {
                        if (type == FloatBuyPrice) file.BuyRate = rate; else file.SellRate = rate;
                    }
                }
            }

            var dids = SqlStatement.Find(file.text, DidTable);
            var currencyRow = dids?.Rows.FirstOrDefault(r => SqlStatement.TypeOf(r) == DidAlternateCurrency);
            if (currencyRow != null)
                file.AlternateCurrency = ParseUInt(currencyRow.Tokens[2]);

            return file;
        }

        private static bool IsShopRow(SqlRow row) => SqlStatement.TypeOf(row) == DestinationShop;

        /// <summary>What a shop item costs at a vendor with this sell rate (the same formula ACE uses).</summary>
        public static uint SellCost(double? sellRate, int value, uint itemType)
        {
            var rate = (itemType & PromissoryNoteItemType) != 0 ? 1.15 : sellRate ?? 1.0;
            return Math.Max(1, (uint)Math.Ceiling((float)rate * value - 0.1));
        }

        public void Save(string targetPath, List<VendorItem> items, double sellRate, double buyRate, uint? alternateCurrency, string currencyName)
        {
            var edits = new TextEdits();

            // create list: keep the non-shop rows where they were, put the shop list where the first shop row was
            var rows = new List<SqlRow>();
            var shopWritten = false;
            foreach (var row in createList.Rows)
            {
                if (!IsShopRow(row))
                {
                    rows.Add(row);
                    continue;
                }
                if (shopWritten)
                    continue;
                shopWritten = true;
                rows.AddRange(items.Select(ShopRow));
            }
            if (rows.Count == 0)
                edits.Replace(createList.Start, EndOfLine(text, createList.End), "");   // an INSERT without rows isn't valid SQL
            else
                edits.Replace(createList.ValuesStart, createList.End, SqlStatement.BuildValues(rows, newline));

            // prices: BuyPrice / SellPrice floats
            var floats = SqlStatement.Find(text, FloatTable);
            var floatRows = floats?.Rows.ToList() ?? new List<SqlRow>();
            SetRow(floatRows, FloatBuyPrice, Format(buyRate), "/* BuyPrice */");
            SetRow(floatRows, FloatSellPrice, Format(sellRate), "/* SellPrice */");
            if (floats != null)
                edits.Replace(floats.ValuesStart, floats.End, SqlStatement.BuildValues(floatRows, newline));
            else
                edits.Replace(createList.Start, createList.Start, NewStatement(FloatTable, floatRows));

            // currency: AlternateCurrency DID (none = pyreals)
            var dids = SqlStatement.Find(text, DidTable);
            var didRows = dids?.Rows.ToList() ?? new List<SqlRow>();
            didRows.RemoveAll(r => SqlStatement.TypeOf(r) == DidAlternateCurrency);
            if (alternateCurrency.HasValue)
            {
                var original = dids?.Rows.FirstOrDefault(r => SqlStatement.TypeOf(r) == DidAlternateCurrency);
                var row = original != null ? new SqlRow { Tokens = new List<string>(original.Tokens) } : new SqlRow { Tokens = new List<string> { Wcid.ToString(CultureInfo.InvariantCulture), DidAlternateCurrency.ToString(CultureInfo.InvariantCulture), "" } };
                row.Tokens[2] = alternateCurrency.Value.ToString(CultureInfo.InvariantCulture);
                row.Comment = "/* AlternateCurrency" + (string.IsNullOrWhiteSpace(currencyName) ? "" : " - " + currencyName.Replace("*/", "* /")) + " */";
                didRows.Add(row);
            }
            if (dids != null)
            {
                if (didRows.Count == 0)
                    edits.Replace(dids.Start, EndOfLine(text, dids.End), "");
                else
                    edits.Replace(dids.ValuesStart, dids.End, SqlStatement.BuildValues(didRows, newline));
            }
            else if (didRows.Count > 0)
            {
                edits.Replace(createList.Start, createList.Start, NewStatement(DidTable, didRows));
            }

            WriteText(targetPath, edits.Apply(text), hasBom);
        }

        private string NewStatement(string table, List<SqlRow> rows) =>
            $"INSERT INTO `{table}` (`object_Id`, `type`, `value`){newline}{SqlStatement.BuildValues(rows, newline)}{newline}{newline}";

        private void SetRow(List<SqlRow> rows, int type, string value, string comment)
        {
            var row = rows.FirstOrDefault(r => SqlStatement.TypeOf(r) == type);
            if (row == null)
            {
                rows.Add(new SqlRow { Tokens = new List<string> { Wcid.ToString(CultureInfo.InvariantCulture), type.ToString(CultureInfo.InvariantCulture), value }, Comment = comment });
                return;
            }
            var index = rows.IndexOf(row);
            rows[index] = new SqlRow { Tokens = new List<string>(row.Tokens), Comment = row.Comment };
            rows[index].Tokens[2] = value;
        }

        private SqlRow ShopRow(VendorItem item)
        {
            var stack = item.StackSize.ToString(CultureInfo.InvariantCulture);
            if (item.Tokens != null && ParseUInt(item.Tokens[2]) == item.Wcid)
            {
                // an original row: keep its palette, shade, bond and comment
                var tokens = new List<string>(item.Tokens);
                tokens[0] = Wcid.ToString(CultureInfo.InvariantCulture);
                tokens[3] = stack;
                return new SqlRow { Tokens = tokens, Comment = item.Comment };
            }
            var name = string.IsNullOrWhiteSpace(item.Name) || item.Name.StartsWith("(") ? "" : item.Name.Replace("*/", "* /") + " ";
            return new SqlRow
            {
                Tokens = new List<string> { Wcid.ToString(CultureInfo.InvariantCulture), DestinationShop.ToString(CultureInfo.InvariantCulture), item.Wcid.ToString(CultureInfo.InvariantCulture), stack, "0", "0", "False" },
                Comment = $"/* Create {name}({item.Wcid}) for Shop */",
            };
        }

        // ---------- item Value (the item's own weenie file) ----------

        /// <summary>
        /// Sets an item's Value (int 19) in its own weenie file. This changes its price at every vendor
        /// and what vendors pay for it.
        /// </summary>
        public static void SetItemValue(string itemPath, int value)
        {
            var itemText = ReadText(itemPath, out var bom);
            var nl = itemText.Contains("\r\n") ? "\r\n" : "\n";
            var header = ChestFile.ReadWeenieHeader(itemText);
            if (header == null)
                throw new InvalidDataException("Could not find the weenie header in " + itemPath);

            var ints = SqlStatement.Find(itemText, "weenie_properties_int");
            if (ints == null)
                throw new InvalidDataException("This item's file has no int properties to put a Value in.");
            var rows = ints.Rows.ToList();
            var row = rows.FirstOrDefault(r => SqlStatement.TypeOf(r) == 19);
            var valueText = value.ToString(CultureInfo.InvariantCulture);
            if (row == null)
            {
                rows.Add(new SqlRow { Tokens = new List<string> { header.Value.wcid.ToString(CultureInfo.InvariantCulture), "19", valueText }, Comment = "/* Value */" });
            }
            else
            {
                var i = rows.IndexOf(row);
                rows[i] = new SqlRow { Tokens = new List<string>(row.Tokens), Comment = row.Comment };
                rows[i].Tokens[2] = valueText;
            }

            var edits = new TextEdits();
            edits.Replace(ints.ValuesStart, ints.End, SqlStatement.BuildValues(rows, nl));
            WriteText(itemPath, edits.Apply(itemText), bom);
        }

        // ---------- helpers ----------

        private static string ReadText(string path, out bool bom)
        {
            var bytes = File.ReadAllBytes(path);
            bom = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
            return new UTF8Encoding(false).GetString(bytes, bom ? 3 : 0, bytes.Length - (bom ? 3 : 0));
        }

        private static void WriteText(string path, string text, bool bom)
        {
            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(path));
            var body = new UTF8Encoding(false).GetBytes(text);
            using (var fs = new FileStream(path, FileMode.Create, FileAccess.Write))
            {
                if (bom)
                    fs.Write(new byte[] { 0xEF, 0xBB, 0xBF }, 0, 3);
                fs.Write(body, 0, body.Length);
            }
        }

        /// <summary>Position after the line break(s) following pos, so a removed statement leaves no blank lines.</summary>
        private static int EndOfLine(string text, int pos)
        {
            while (pos < text.Length && (text[pos] == '\r' || text[pos] == '\n'))
                pos++;
            return pos;
        }

        private static string Format(double rate) => rate.ToString("0.######", CultureInfo.InvariantCulture);

        private static uint ParseUInt(string token) => uint.TryParse(SqlStatement.StripComment(token), out var v) ? v : 0;

        private static int ParseInt(string token) => int.TryParse(SqlStatement.StripComment(token), out var v) ? v : 0;

        private static string NameFromComment(string comment)
        {
            if (comment == null)
                return null;
            var m = Regex.Match(comment, @"Create\s+(.*?)\s*\(\d+\)");
            return m.Success && m.Groups[1].Value.Length > 0 ? m.Groups[1].Value : null;
        }
    }
}
