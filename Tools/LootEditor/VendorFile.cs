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
    /// A vendor weenie SQL file: the weenie_properties_create_list rows with destination Shop (4) are what the
    /// vendor sells. Saving rewrites only that statement; the vendor's other create_list rows (what it wears
    /// or carries) and everything else in the file stay as they are.
    /// </summary>
    public class VendorFile
    {
        private const string CreateListMarker = "INSERT INTO `weenie_properties_create_list`";
        private const int DestinationShop = 4;

        public string Path { get; private set; }
        public uint Wcid { get; private set; }
        public string Name { get; private set; }
        public List<VendorItem> Items { get; } = new List<VendorItem>();

        private string text;
        private bool hasBom;
        private string newline;

        private int statementStart;     // position of "INSERT INTO `weenie_properties_create_list`"
        private int valuesStart;        // position of "VALUES"
        private int statementEnd;       // just after the ';'
        private List<Row> rows = new List<Row>();

        private class Row
        {
            public List<string> tokens;
            public string comment;
            public bool shop;
        }

        /// <summary>True when the file has a create_list with at least one Shop row.</summary>
        public static bool IsVendor(string fileText)
        {
            var start = fileText.IndexOf(CreateListMarker, StringComparison.Ordinal);
            if (start < 0)
                return false;
            try
            {
                var parsed = ParseRows(fileText, start, out _, out _);
                return parsed.Any(r => r.shop);
            }
            catch { return false; }
        }

        public static VendorFile Load(string path, WeenieIndex index)
        {
            var bytes = File.ReadAllBytes(path);
            var file = new VendorFile { Path = path };
            file.hasBom = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
            file.text = new UTF8Encoding(false).GetString(bytes, file.hasBom ? 3 : 0, bytes.Length - (file.hasBom ? 3 : 0));
            file.newline = file.text.Contains("\r\n") ? "\r\n" : "\n";

            var header = ChestFile.ReadWeenieHeader(file.text);
            if (header == null)
                throw new InvalidDataException("Could not find the weenie header in " + path);
            file.Wcid = header.Value.wcid;
            file.Name = ChestFile.ReadName(file.text) ?? "(no name)";

            file.statementStart = file.text.IndexOf(CreateListMarker, StringComparison.Ordinal);
            if (file.statementStart < 0)
                throw new InvalidDataException("This file has no create list.");
            file.rows = ParseRows(file.text, file.statementStart, out file.valuesStart, out file.statementEnd);
            if (!file.rows.Any(r => r.shop))
                throw new InvalidDataException("This file's create list has no items for sale.");

            foreach (var row in file.rows.Where(r => r.shop))
            {
                var wcid = ParseUInt(row.tokens[2]);
                file.Items.Add(new VendorItem
                {
                    Wcid = wcid,
                    Name = index.GetName(wcid) ?? NameFromComment(row.comment) ?? "(not in Content - stock item)",
                    StackSize = ParseInt(row.tokens[3]),
                    Tokens = row.tokens,
                    Comment = row.comment,
                });
            }
            return file;
        }

        private static List<Row> ParseRows(string text, int statementStart, out int valuesStart, out int statementEnd)
        {
            valuesStart = text.IndexOf("VALUES", statementStart, StringComparison.OrdinalIgnoreCase);
            if (valuesStart < 0)
                throw new InvalidDataException("Unexpected create list format.");
            var pos = valuesStart + "VALUES".Length;
            var tuples = EmoteRewardFile.ReadTuples(text, ref pos);
            statementEnd = pos;

            var result = new List<Row>();
            for (var i = 0; i < tuples.Count; i++)
            {
                var tokens = tuples[i].tokens;
                if (tokens.Count != 7)
                    throw new InvalidDataException("Unexpected create list row.");
                // the row's comment sits between its ')' and the next row (or the ';')
                var gapEnd = i + 1 < tuples.Count ? tuples[i + 1].start : statementEnd;
                var gap = text.Substring(tuples[i].end, Math.Max(0, gapEnd - tuples[i].end));
                var m = Regex.Match(gap, @"/\*.*?\*/", RegexOptions.Singleline);
                result.Add(new Row { tokens = tokens, comment = m.Success ? m.Value : null, shop = ParseInt(tokens[1]) == DestinationShop });
            }
            return result;
        }

        public void Save(string targetPath, List<VendorItem> items)
        {
            // keep the non-shop rows where they were and put the shop list where the first shop row was
            var lines = new List<string>();
            var shopWritten = false;
            foreach (var row in rows)
            {
                if (!row.shop)
                {
                    lines.Add("(" + string.Join(", ", row.tokens) + ")" + (row.comment != null ? " " + row.comment : ""));
                    continue;
                }
                if (shopWritten)
                    continue;
                shopWritten = true;
                foreach (var item in items)
                    lines.Add(ShopLine(item));
            }

            string replacement;
            if (lines.Count == 0)
            {
                // nothing left at all: drop the whole statement (an INSERT without rows isn't valid SQL)
                replacement = null;
            }
            else
            {
                var sb = new StringBuilder("VALUES ");
                for (var i = 0; i < lines.Count; i++)
                {
                    if (i > 0)
                        sb.Append(newline).Append("     , ");
                    sb.Append(lines[i]);
                }
                sb.Append(';');
                replacement = sb.ToString();
            }

            var newText = replacement == null
                ? text.Substring(0, statementStart) + text.Substring(statementEnd).TrimStart('\r', '\n')
                : text.Substring(0, valuesStart) + replacement + text.Substring(statementEnd);

            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(targetPath));
            var body = new UTF8Encoding(false).GetBytes(newText);
            using (var fs = new FileStream(targetPath, FileMode.Create, FileAccess.Write))
            {
                if (hasBom)
                    fs.Write(new byte[] { 0xEF, 0xBB, 0xBF }, 0, 3);
                fs.Write(body, 0, body.Length);
            }
        }

        private string ShopLine(VendorItem item)
        {
            var stack = item.StackSize.ToString(CultureInfo.InvariantCulture);
            if (item.Tokens != null && ParseUInt(item.Tokens[2]) == item.Wcid)
            {
                // an original row: keep its palette, shade, bond and comment
                var tokens = new List<string>(item.Tokens);
                tokens[0] = Wcid.ToString(CultureInfo.InvariantCulture);
                tokens[3] = stack;
                return "(" + string.Join(", ", tokens) + ")" + (item.Comment != null ? " " + item.Comment : "");
            }
            var name = string.IsNullOrWhiteSpace(item.Name) || item.Name.StartsWith("(") ? "" : item.Name.Replace("*/", "* /") + " ";
            return $"({Wcid}, {DestinationShop}, {item.Wcid}, {stack}, 0, 0, False) /* Create {name}({item.Wcid}) for Shop */";
        }

        private static string StripComment(string token) => Regex.Replace(token ?? "", @"/\*.*?\*/", "", RegexOptions.Singleline).Trim();

        private static uint ParseUInt(string token) => uint.TryParse(StripComment(token), out var v) ? v : 0;

        private static int ParseInt(string token) => int.TryParse(StripComment(token), out var v) ? v : 0;

        private static string NameFromComment(string comment)
        {
            if (comment == null)
                return null;
            var m = Regex.Match(comment, @"Create\s+(.*?)\s*\(\d+\)");
            return m.Success && m.Groups[1].Value.Length > 0 ? m.Groups[1].Value : null;
        }
    }
}
