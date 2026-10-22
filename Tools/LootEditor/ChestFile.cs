using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace LootEditor
{
    /// <summary>
    /// One row of a chest's generator list (weenie_properties_generator).
    /// Values holds the 19 raw column values exactly as written in the SQL file.
    /// </summary>
    public class GeneratorRow
    {
        public string[] Values;
        public string Comment;

        public double Probability => double.Parse(Values[1], CultureInfo.InvariantCulture);
        public uint Wcid => uint.Parse(Values[2], CultureInfo.InvariantCulture);
        public int StackSize => int.Parse(Values[8], CultureInfo.InvariantCulture);
        public int WhereCreate => int.Parse(Values[7], CultureInfo.InvariantCulture);

        /// <summary>Probability -1 means "always generated" (not part of the random pick).</summary>
        public bool IsAlways => Probability == -1;

        /// <summary>Where 72 (ContainTreasure) means the WCID is a random-loot profile, not an item.</summary>
        public bool IsTreasureProfile => WhereCreate == 72;

        public string ToSql() => "(" + string.Join(", ", Values) + ")";
    }

    /// <summary>A pick row as shown in the editor: plain percentage instead of cumulative probability.</summary>
    public class PickItem
    {
        public uint Wcid;
        public string Name;
        public int StackSize;
        public double Percent;
        public GeneratorRow Original;   // null for newly added items

        // reward tables: which emote block this row was read from (-1 = new or WCID changed) and its stack then
        public int SourceBlock = -1;
        public int SourceStack = -1;
    }

    /// <summary>
    /// A chest weenie SQL file. Parses its generator list and writes it back,
    /// leaving everything else in the file untouched.
    /// </summary>
    public class ChestFile
    {
        private const string GeneratorMarker = "INSERT INTO `weenie_properties_generator`";

        public string Path { get; private set; }
        public uint ChestWcid { get; private set; }
        public string Name { get; private set; }
        public int? InitGeneratedObjects { get; private set; }
        public int? MaxGeneratedObjects { get; private set; }

        public List<GeneratorRow> AlwaysRows { get; } = new List<GeneratorRow>();
        public List<PickItem> Picks { get; } = new List<PickItem>();

        private string text;
        private bool hasBom;
        private string newline;
        private int blockStart;
        private int blockEnd;
        private string header;

        private static readonly Regex WeenieTypeRegex = new Regex(@"INSERT INTO `weenie` [^;]*?VALUES\s*\((\d+),\s*'(?:[^']|'')*',\s*(\d+)", RegexOptions.Singleline);
        private static readonly Regex NameRegex = new Regex(@"\(\s*\d+\s*,\s*1\s*,\s*'((?:[^']|'')*)'\s*\)\s*/\*\s*Name", RegexOptions.Singleline);

        /// <summary>Returns the weenie type (20 = Chest) and WCID of a weenie SQL file, or null.</summary>
        public static (uint wcid, int type)? ReadWeenieHeader(string fileText)
        {
            var m = WeenieTypeRegex.Match(fileText);
            if (!m.Success)
                return null;
            return (uint.Parse(m.Groups[1].Value), int.Parse(m.Groups[2].Value));
        }

        public static string ReadName(string fileText)
        {
            var m = NameRegex.Match(fileText);
            return m.Success ? m.Groups[1].Value.Replace("''", "'") : null;
        }

        public static bool IsChestWithGenerator(string fileText)
        {
            if (!fileText.Contains(GeneratorMarker))
                return false;
            var header = ReadWeenieHeader(fileText);
            return header.HasValue && header.Value.type == 20;
        }

        public static ChestFile Load(string path, WeenieIndex index)
        {
            var bytes = File.ReadAllBytes(path);
            var chest = new ChestFile { Path = path };
            chest.hasBom = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
            chest.text = new UTF8Encoding(false).GetString(bytes, chest.hasBom ? 3 : 0, bytes.Length - (chest.hasBom ? 3 : 0));
            chest.newline = chest.text.Contains("\r\n") ? "\r\n" : "\n";

            var header = ReadWeenieHeader(chest.text);
            if (header == null)
                throw new InvalidDataException("Could not find the weenie header in " + path);
            chest.ChestWcid = header.Value.wcid;
            chest.Name = ReadName(chest.text) ?? "(no name)";
            chest.InitGeneratedObjects = ReadInt(chest.text, 82);
            chest.MaxGeneratedObjects = ReadInt(chest.text, 81);

            chest.ParseGeneratorBlock(index);
            return chest;
        }

        private static int? ReadInt(string fileText, int propertyType)
        {
            var m = Regex.Match(fileText, @"\(\s*\d+\s*,\s*" + propertyType + @"\s*,\s*(-?\d+)\s*\)");
            return m.Success ? int.Parse(m.Groups[1].Value) : (int?)null;
        }

        private void ParseGeneratorBlock(WeenieIndex index)
        {
            blockStart = text.IndexOf(GeneratorMarker, StringComparison.Ordinal);
            if (blockStart < 0)
                throw new InvalidDataException("This file has no generator list.");

            var valuesIdx = text.IndexOf("VALUES", blockStart, StringComparison.OrdinalIgnoreCase);
            if (valuesIdx < 0)
                throw new InvalidDataException("Generator list has no VALUES.");

            header = text.Substring(blockStart, valuesIdx - blockStart).TrimEnd();

            var rows = new List<GeneratorRow>();
            var pos = valuesIdx + "VALUES".Length;

            while (true)
            {
                pos = SkipWhitespace(pos, true);
                if (pos < text.Length && text[pos] == ',')
                {
                    pos++;
                    pos = SkipWhitespace(pos, true);
                }

                if (pos >= text.Length || text[pos] != '(')
                    break;

                var close = text.IndexOf(')', pos);
                if (close < 0)
                    throw new InvalidDataException("Unclosed generator row.");

                var values = text.Substring(pos + 1, close - pos - 1).Split(',').Select(v => v.Trim()).ToArray();
                if (values.Length < 19)
                    throw new InvalidDataException("A generator row has fewer than 19 values.");
                pos = close + 1;

                var ended = false;
                pos = SkipWhitespace(pos, false);
                if (pos < text.Length && text[pos] == ';')
                {
                    ended = true;
                    pos++;
                    pos = SkipWhitespace(pos, false);
                }

                string comment = null;
                if (pos + 1 < text.Length && text[pos] == '/' && text[pos + 1] == '*')
                {
                    var commentEnd = text.IndexOf("*/", pos + 2, StringComparison.Ordinal);
                    if (commentEnd < 0)
                        throw new InvalidDataException("Unclosed comment in generator list.");
                    comment = text.Substring(pos + 2, commentEnd - pos - 2).Trim();
                    pos = commentEnd + 2;
                }

                pos = SkipWhitespace(pos, false);
                if (!ended && pos < text.Length && text[pos] == ';')
                {
                    ended = true;
                    pos++;
                }

                rows.Add(new GeneratorRow { Values = values, Comment = comment });

                if (ended)
                    break;
            }

            blockEnd = pos;

            if (rows.Count == 0)
                throw new InvalidDataException("Generator list is empty.");

            // Convert cumulative probabilities into plain percentages, the same way the server reads them:
            // each row's chance is its value minus the previous row's value; a drop in value starts a new block.
            double last = 0, total = 0;
            var pickRows = new List<(GeneratorRow row, double diff)>();
            foreach (var row in rows)
            {
                if (row.IsAlways)
                {
                    AlwaysRows.Add(row);
                    continue;
                }

                var p = row.Probability;
                if (last > p)
                    last = 0;
                var diff = p - last;
                last = p;
                total += diff;
                pickRows.Add((row, diff));
            }

            foreach (var pickRow in pickRows)
            {
                var row = pickRow.row;
                var diff = pickRow.diff;
                Picks.Add(new PickItem
                {
                    Wcid = row.Wcid,
                    Name = index.GetName(row.Wcid) ?? WeenieIndex.NameFromComment(row.Comment) ?? "(unknown)",
                    StackSize = row.StackSize,
                    Percent = total > 0 ? diff / total * 100.0 : 0,
                    Original = row,
                });
            }
        }

        private int SkipWhitespace(int pos, bool includeNewlines)
        {
            while (pos < text.Length)
            {
                var c = text[pos];
                if (c == ' ' || c == '\t' || (includeNewlines && (c == '\r' || c == '\n')))
                    pos++;
                else
                    break;
            }
            return pos;
        }

        /// <summary>
        /// Writes the chest back to disk with the given pick list. The "always" rows are kept exactly as they were.
        /// </summary>
        public void Save(string targetPath, List<PickItem> picks)
        {
            var template = picks.Select(p => p.Original).FirstOrDefault(r => r != null && r.WhereCreate == 8)
                ?? Picks.Select(p => p.Original).FirstOrDefault(r => r != null && r.WhereCreate == 8);

            var allRows = new List<GeneratorRow>(AlwaysRows);

            double cumulative = 0;
            for (var i = 0; i < picks.Count; i++)
            {
                var pick = picks[i];
                cumulative += pick.Percent / 100.0;
                if (i == picks.Count - 1)
                    cumulative = Math.Round(cumulative, 6);

                var values = template != null
                    ? (string[])template.Values.Clone()
                    : new[] { "0", "0", "0", "1", "1", "1", "1", "8", "-1", "0", "0", "0", "0", "0", "0", "1", "0", "0", "0" };

                if (pick.Original != null)
                    values = (string[])pick.Original.Values.Clone();
                else
                {
                    values[3] = "1";    // delay
                    values[4] = "1";    // init_Create
                    values[5] = "1";    // max_Create
                    values[7] = "8";    // where_Create: Contain
                }

                values[0] = ChestWcid.ToString(CultureInfo.InvariantCulture);
                values[1] = cumulative.ToString("0.######", CultureInfo.InvariantCulture);
                values[2] = pick.Wcid.ToString(CultureInfo.InvariantCulture);
                values[8] = pick.StackSize.ToString(CultureInfo.InvariantCulture);

                var shownStack = pick.StackSize <= 0 ? 1 : pick.StackSize;
                var safeName = (pick.Name ?? "unknown").Replace("*/", "* /");
                var comment = $"Generate {safeName} ({pick.Wcid}) (x{shownStack}) - {pick.Percent.ToString("0.###", CultureInfo.InvariantCulture)}% per pick - Location to (re)Generate: Contain";

                allRows.Add(new GeneratorRow { Values = values, Comment = comment });
            }

            var sb = new StringBuilder();
            sb.Append(header).Append(newline).Append("VALUES ");
            for (var i = 0; i < allRows.Count; i++)
            {
                if (i > 0)
                    sb.Append(newline).Append("     , ");
                sb.Append(allRows[i].ToSql());
                if (!string.IsNullOrEmpty(allRows[i].Comment))
                    sb.Append(" /* ").Append(allRows[i].Comment).Append(" */");
            }
            sb.Append(';');

            var newText = text.Substring(0, blockStart) + sb + text.Substring(blockEnd);

            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(targetPath));
            var body = new UTF8Encoding(false).GetBytes(newText);
            using (var fs = new FileStream(targetPath, FileMode.Create, FileAccess.Write))
            {
                if (hasBom)
                    fs.Write(new byte[] { 0xEF, 0xBB, 0xBF }, 0, 3);
                fs.Write(body, 0, body.Length);
            }
        }
    }
}
