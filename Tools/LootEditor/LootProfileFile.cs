using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace LootEditor
{
    /// <summary>One editable setting of a loot profile.</summary>
    public class ProfileField
    {
        public string Column;
        public string Value;
        public string Label;
        public string Help;
        public bool IsInteger;
    }

    /// <summary>
    /// A loot profile (treasure_death row) SQL file, as used by monsters (DeathTreasureType)
    /// and by chests (generator rows with location 72). Supports both
    /// "INSERT INTO ... (columns) VALUES (...)" and "INSERT INTO ... SET column = value, ..." files.
    /// Saving rewrites only that INSERT statement, in the SET form.
    /// </summary>
    public class LootProfileFile
    {
        public string Path { get; private set; }
        public uint TreasureType { get; private set; }
        public List<ProfileField> Fields { get; } = new List<ProfileField>();

        private string text;
        private bool hasBom;
        private string newline;
        private int statementStart;
        private int statementEnd;
        private string tableName;
        private List<(string column, string value)> columns = new List<(string, string)>();

        private static readonly Regex InsertRegex = new Regex(@"INSERT\s+INTO\s+((?:`?\w+`?\.)?`?treasure_death`?)\s*", RegexOptions.IgnoreCase);

        private static readonly (string column, string label, string help, bool integer)[] Editable =
        {
            ("tier", "Loot tier", "1 to 8 (9 = custom JawnTide tier). The loot_max_tier setting still caps this at runtime.", true),
            ("loot_Quality_Mod", "Quality modifier", "0 to 1. Higher = better rolls within the tier (workmanship, spells, values).", false),
            ("magic_Item_Chance", "Magic items: chance %", "Chance (0-100) that magic items drop at all.", true),
            ("magic_Item_Min_Amount", "Magic items: min", "Fewest magic items when they drop.", true),
            ("magic_Item_Max_Amount", "Magic items: max", "Most magic items when they drop.", true),
            ("item_Chance", "Non-magic items: chance %", "Chance (0-100) for the 'item' group (scrolls, potions, kits and so on).", true),
            ("item_Min_Amount", "Non-magic items: min", "Fewest items from the 'item' group.", true),
            ("item_Max_Amount", "Non-magic items: max", "Most items from the 'item' group.", true),
            ("mundane_Item_Chance", "Mundane items: chance %", "Chance (0-100) for mundane items (food, mana stones and so on).", true),
            ("mundane_Item_Min_Amount", "Mundane items: min", "Fewest mundane items.", true),
            ("mundane_Item_Max_Amount", "Mundane items: max", "Most mundane items.", true),
            ("magic_Item_Treasure_Type_Selection_Chances", "Magic item type table", "Which built-in table picks the magic item types (armor, weapons...). Leave unless you know the table numbers.", true),
            ("item_Treasure_Type_Selection_Chances", "Item type table", "Which built-in table picks the 'item' group types. Leave unless you know the table numbers.", true),
            ("mundane_Item_Type_Selection_Chances", "Mundane type table", "Which built-in table picks mundane types. Leave unless you know the table numbers.", true),
            ("unknown_Chances", "Unknown chances", "Retail value, normally 19. Leave as is.", true),
        };

        public static bool IsProfileFile(string fileText) => InsertRegex.IsMatch(fileText);

        public static uint? ReadTreasureType(string fileText)
        {
            try
            {
                var f = new LootProfileFile { text = fileText };
                f.Parse();
                return f.TreasureType;
            }
            catch { return null; }
        }

        public static LootProfileFile Load(string path)
        {
            var bytes = File.ReadAllBytes(path);
            var f = new LootProfileFile { Path = path };
            f.hasBom = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
            f.text = new UTF8Encoding(false).GetString(bytes, f.hasBom ? 3 : 0, bytes.Length - (f.hasBom ? 3 : 0));
            f.newline = f.text.Contains("\r\n") ? "\r\n" : "\n";
            f.Parse();

            foreach (var e in Editable)
            {
                var col = f.columns.FirstOrDefault(c => string.Equals(c.column, e.column, StringComparison.OrdinalIgnoreCase));
                if (col.column == null)
                    continue;
                f.Fields.Add(new ProfileField { Column = col.column, Value = col.value, Label = e.label, Help = e.help, IsInteger = e.integer });
            }
            return f;
        }

        private void Parse()
        {
            var m = InsertRegex.Match(text);
            if (!m.Success)
                throw new InvalidDataException("No treasure_death INSERT found.");
            statementStart = m.Index;
            tableName = m.Groups[1].Value;
            var pos = m.Index + m.Length;

            columns.Clear();
            if (text.Substring(pos).StartsWith("SET", StringComparison.OrdinalIgnoreCase))
            {
                pos += 3;
                var semicolon = text.IndexOf(';', pos);
                var end = semicolon < 0 ? text.Length : semicolon;
                foreach (var part in StripComments(text.Substring(pos, end - pos)).Split(','))
                {
                    var eq = part.IndexOf('=');
                    if (eq < 0)
                        continue;
                    columns.Add((part.Substring(0, eq).Trim().Trim('`'), part.Substring(eq + 1).Trim()));
                }
                statementEnd = semicolon < 0 ? text.Length : semicolon + 1;
            }
            else
            {
                // (columns) VALUES (values)
                var open = text.IndexOf('(', pos);
                var close = text.IndexOf(')', open);
                var names = StripComments(text.Substring(open + 1, close - open - 1)).Split(',').Select(n => n.Trim().Trim('`')).ToList();

                var valuesIdx = text.IndexOf("VALUES", close, StringComparison.OrdinalIgnoreCase);
                if (valuesIdx < 0)
                    throw new InvalidDataException("treasure_death INSERT has no VALUES.");
                var p = valuesIdx + "VALUES".Length;
                var tuples = EmoteRewardFile.ReadTuples(text, ref p);
                if (tuples.Count != 1)
                    throw new InvalidDataException("Expected exactly one loot profile row.");
                var values = tuples[0].tokens.Select(v => StripComments(v).Trim()).ToList();
                if (values.Count != names.Count)
                    throw new InvalidDataException("Column and value counts differ.");
                for (var i = 0; i < names.Count; i++)
                    columns.Add((names[i], values[i]));

                // ReadTuples stops after an optional ';'
                statementEnd = p;
            }

            var tt = columns.FirstOrDefault(c => string.Equals(c.column, "treasure_Type", StringComparison.OrdinalIgnoreCase));
            if (tt.column == null || !uint.TryParse(tt.value, out var treasureType))
                throw new InvalidDataException("Loot profile has no treasure_Type.");
            TreasureType = treasureType;
        }

        private static string StripComments(string s) => Regex.Replace(s, @"/\*.*?\*/", "", RegexOptions.Singleline);

        /// <summary>Checks the values; returns an error message, or null when everything is valid.</summary>
        public static string Validate(List<ProfileField> fields)
        {
            foreach (var f in fields)
            {
                if (f.IsInteger)
                {
                    if (!int.TryParse(f.Value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var v) || v < 0)
                        return $"{f.Label}: must be a whole number of 0 or more.";
                }
                else if (!double.TryParse(f.Value, NumberStyles.Float, CultureInfo.InvariantCulture, out var d) || d < 0 || d > 1)
                    return $"{f.Label}: must be a number from 0 to 1 (use a dot, like 0.85).";
            }

            var tier = GetInt(fields, "tier");
            if (tier.HasValue && (tier < 1 || tier > 9))
                return "Loot tier must be from 1 to 9.";

            foreach (var group in new[] { "magic_Item", "item", "mundane_Item" })
            {
                var chance = GetInt(fields, group + "_Chance");
                if (chance.HasValue && chance > 100)
                    return $"{group} chance can't be above 100.";
                var min = GetInt(fields, group + "_Min_Amount");
                var max = GetInt(fields, group + "_Max_Amount");
                if (min.HasValue && max.HasValue && min > max)
                    return $"{group}: min can't be larger than max.";
            }
            return null;
        }

        private static int? GetInt(List<ProfileField> fields, string column)
        {
            var field = fields.FirstOrDefault(f => f.Column.Equals(column, StringComparison.OrdinalIgnoreCase));
            return field != null && int.TryParse(field.Value, out var v) ? v : (int?)null;
        }

        public void Save(string targetPath, List<ProfileField> edited)
        {
            var updated = columns.Select(c =>
            {
                var e = edited.FirstOrDefault(f => f.Column.Equals(c.column, StringComparison.OrdinalIgnoreCase));
                return (column: c.column, value: e != null ? e.Value.Trim() : c.value);
            }).ToList();

            var sb = new StringBuilder();
            sb.Append("INSERT INTO ").Append(tableName).Append(newline).Append("SET").Append(newline);
            for (var i = 0; i < updated.Count; i++)
            {
                sb.Append("  ").Append(updated[i].column).Append(" = ").Append(updated[i].value);
                sb.Append(i < updated.Count - 1 ? "," : "").Append(newline);
            }
            sb.Append(';');

            var newText = text.Substring(0, statementStart) + sb + text.Substring(statementEnd);

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
