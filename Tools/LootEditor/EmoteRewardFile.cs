using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace LootEditor
{
    /// <summary>A fixed "Give" reward inside an NPC's emote script (given every time, no chance roll).</summary>
    public class FixedGive
    {
        public string Situation;   // for example "QuestSuccess WorldBossCompleted"
        public uint Wcid;
        public int StackSize;      // -1 = default (NULL in the file)
        public string Name;

        internal int TupleStart;   // position of '(' of the action row in the file
        internal int TupleEnd;     // position just after ')'
        internal List<string> Tokens;
    }

    /// <summary>
    /// An NPC (or item) weenie SQL file with a random reward table: a group of GotoSet emotes that share
    /// one name and each give exactly one item, like Aidoneus's "WorldBoss_random_reward".
    /// Also exposes the fixed Give rewards found in the file's other emotes.
    /// </summary>
    public class EmoteRewardFile
    {
        private const string EmoteMarker = "INSERT INTO `weenie_properties_emote` ";
        private const string ActionMarker = "INSERT INTO `weenie_properties_emote_action`";

        private const int CategoryGotoSet = 32;
        private const int ActionGive = 3;
        private const int ActionWcidIndex = 27;
        private const int ActionStackIndex = 28;

        public string Path { get; private set; }
        public uint Wcid { get; private set; }
        public string Name { get; private set; }
        public string TableName { get; private set; }

        public List<PickItem> Picks { get; } = new List<PickItem>();
        public List<FixedGive> FixedGives { get; } = new List<FixedGive>();

        private string text;
        private bool hasBom;
        private string newline;

        private int tableStart;
        private int tableEnd;
        private string emoteHeader;
        private List<string> emoteTemplate;
        private string actionHeader;
        private List<string> actionTemplate;

        private class EmoteBlock
        {
            public int Start, End;
            public List<string> EmoteTokens;
            public int Category;
            public double Probability;
            public string Quest;
            public string EmoteHeader;
            public string ActionHeader;
            public List<(int start, int end, List<string> tokens)> Actions = new List<(int, int, List<string>)>();
        }

        // ---------- discovery ----------

        /// <summary>Returns the names of the random reward tables in a file (GotoSet groups where every set gives exactly one item).</summary>
        public static List<string> FindRewardTables(string fileText)
        {
            var result = new List<string>();
            if (!fileText.Contains("GotoSet"))
                return result;

            List<EmoteBlock> blocks;
            try { blocks = ParseBlocks(fileText); }
            catch { return result; }

            foreach (var group in blocks.Where(b => b.Category == CategoryGotoSet && b.Quest != null).GroupBy(b => b.Quest))
            {
                if (IsEditableTable(blocks, group.Key))
                    result.Add(group.Key);
            }
            return result;
        }

        private static bool IsEditableTable(List<EmoteBlock> blocks, string quest)
        {
            var indexes = blocks.Select((b, i) => (b: b, i: i)).Where(x => x.b.Category == CategoryGotoSet && x.b.Quest == quest).Select(x => x.i).ToList();
            if (indexes.Count < 2)
                return false;

            // must be one contiguous run of blocks, each with exactly one Give action
            for (var k = 1; k < indexes.Count; k++)
                if (indexes[k] != indexes[k - 1] + 1)
                    return false;

            return indexes.All(i => blocks[i].Actions.Count == 1 && ActionType(blocks[i].Actions[0].tokens) == ActionGive);
        }

        // ---------- loading ----------

        public static EmoteRewardFile Load(string path, string tableName, WeenieIndex index)
        {
            var bytes = File.ReadAllBytes(path);
            var file = new EmoteRewardFile { Path = path, TableName = tableName };
            file.hasBom = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
            file.text = new UTF8Encoding(false).GetString(bytes, file.hasBom ? 3 : 0, bytes.Length - (file.hasBom ? 3 : 0));
            file.newline = file.text.Contains("\r\n") ? "\r\n" : "\n";

            var header = ChestFile.ReadWeenieHeader(file.text);
            if (header == null)
                throw new InvalidDataException("Could not find the weenie header in " + path);
            file.Wcid = header.Value.wcid;
            file.Name = ChestFile.ReadName(file.text) ?? "(no name)";

            var blocks = ParseBlocks(file.text);
            if (!IsEditableTable(blocks, tableName))
                throw new InvalidDataException($"The reward table '{tableName}' isn't in a format this editor can change.");

            var table = blocks.Where(b => b.Category == CategoryGotoSet && b.Quest == tableName).ToList();
            file.tableStart = table.First().Start;
            file.tableEnd = table.Last().End;
            file.emoteHeader = table[0].EmoteHeader;
            file.emoteTemplate = table[0].EmoteTokens;
            file.actionHeader = table[0].ActionHeader;
            file.actionTemplate = table[0].Actions[0].tokens;

            // cumulative probabilities -> plain percentages (the server picks the first set whose value is above its roll)
            double last = 0;
            foreach (var block in table.OrderBy(b => b.Probability))
            {
                var tokens = block.Actions[0].tokens;
                var wcid = ParseUInt(tokens[ActionWcidIndex]);
                file.Picks.Add(new PickItem
                {
                    Wcid = wcid,
                    Name = index.GetName(wcid) ?? CommentOf(tokens[ActionWcidIndex]) ?? "(unknown)",
                    StackSize = ParseStack(tokens[ActionStackIndex]),
                    Percent = Math.Max(0, block.Probability - last) * 100.0,
                });
                last = block.Probability;
            }

            // fixed Give rewards everywhere else in the file
            foreach (var block in blocks.Where(b => !(b.Category == CategoryGotoSet && b.Quest == tableName)))
            {
                foreach (var action in block.Actions)
                {
                    if (ActionType(action.tokens) != ActionGive)
                        continue;
                    var wcid = ParseUInt(action.tokens[ActionWcidIndex]);
                    if (wcid == 0)
                        continue;
                    file.FixedGives.Add(new FixedGive
                    {
                        Situation = CategoryName(block.EmoteTokens) + (block.Quest != null ? " " + block.Quest : ""),
                        Wcid = wcid,
                        StackSize = ParseStack(action.tokens[ActionStackIndex]),
                        Name = index.GetName(wcid) ?? CommentOf(action.tokens[ActionWcidIndex]) ?? "(unknown)",
                        TupleStart = action.start,
                        TupleEnd = action.end,
                        Tokens = action.tokens,
                    });
                }
            }

            return file;
        }

        // ---------- saving ----------

        public void Save(string targetPath, List<PickItem> picks, List<FixedGive> fixedGives)
        {
            var edits = new List<(int start, int end, string replacement)>();

            // fixed gives: rewrite each action row in place
            foreach (var give in fixedGives)
            {
                var tokens = new List<string>(give.Tokens);
                tokens[ActionWcidIndex] = WcidToken(give.Wcid, give.Name);
                tokens[ActionStackIndex] = give.StackSize <= 0 ? "NULL" : give.StackSize.ToString(CultureInfo.InvariantCulture);
                edits.Add((give.TupleStart, give.TupleEnd, "(" + string.Join(", ", tokens) + ")"));
            }

            // random table: regenerate the whole run of GotoSet blocks
            var sb = new StringBuilder();
            double cumulative = 0;
            for (var i = 0; i < picks.Count; i++)
            {
                var pick = picks[i];
                cumulative += pick.Percent / 100.0;
                var probability = i == picks.Count - 1 ? 1.0 : Math.Round(cumulative, 6);

                var emote = new List<string>(emoteTemplate);
                emote[2] = probability.ToString("0.######", CultureInfo.InvariantCulture);

                var action = new List<string>(actionTemplate);
                action[ActionWcidIndex] = WcidToken(pick.Wcid, pick.Name);
                action[ActionStackIndex] = pick.StackSize <= 0 ? "NULL" : pick.StackSize.ToString(CultureInfo.InvariantCulture);

                sb.Append(emoteHeader).Append(newline)
                  .Append("VALUES (").Append(string.Join(", ", emote)).Append(");").Append(newline).Append(newline)
                  .Append("SET @parent_id = LAST_INSERT_ID();").Append(newline).Append(newline)
                  .Append(actionHeader).Append(newline)
                  .Append("VALUES (").Append(string.Join(", ", action)).Append(");").Append(newline).Append(newline);
            }
            edits.Add((tableStart, tableEnd, sb.ToString()));

            var newText = text;
            foreach (var edit in edits.OrderByDescending(e => e.start))
                newText = newText.Substring(0, edit.start) + edit.replacement + newText.Substring(edit.end);

            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(targetPath));
            var body = new UTF8Encoding(false).GetBytes(newText);
            using (var fs = new FileStream(targetPath, FileMode.Create, FileAccess.Write))
            {
                if (hasBom)
                    fs.Write(new byte[] { 0xEF, 0xBB, 0xBF }, 0, 3);
                fs.Write(body, 0, body.Length);
            }
        }

        private static string WcidToken(uint wcid, string name)
        {
            var safe = (name ?? "").Replace("*/", "* /");
            return string.IsNullOrWhiteSpace(safe) || safe.StartsWith("(")
                ? wcid.ToString(CultureInfo.InvariantCulture)
                : $"{wcid} /* {safe} */";
        }

        // ---------- parsing helpers ----------

        private static List<EmoteBlock> ParseBlocks(string text)
        {
            var blocks = new List<EmoteBlock>();
            var pos = 0;
            while (true)
            {
                var start = text.IndexOf(EmoteMarker, pos, StringComparison.Ordinal);
                if (start < 0)
                    break;

                var block = new EmoteBlock { Start = start };
                var valuesIdx = text.IndexOf("VALUES", start, StringComparison.OrdinalIgnoreCase);
                block.EmoteHeader = text.Substring(start, valuesIdx - start).TrimEnd();

                var p = valuesIdx + "VALUES".Length;
                var tuples = ReadTuples(text, ref p);
                if (tuples.Count != 1)
                    throw new InvalidDataException("Unexpected emote format.");
                block.EmoteTokens = tuples[0].tokens;
                block.Category = LeadingInt(block.EmoteTokens[1]);
                block.Probability = double.TryParse(StripComment(block.EmoteTokens[2]), NumberStyles.Float, CultureInfo.InvariantCulture, out var prob) ? prob : 1;
                block.Quest = Unquote(block.EmoteTokens[6]);

                // the block runs until the next emote, or the next non-emote table, or the end of the file
                var nextEmote = text.IndexOf(EmoteMarker, p, StringComparison.Ordinal);
                var nextOther = FindNextOtherInsert(text, p);
                var blockLimit = new[] { nextEmote < 0 ? text.Length : nextEmote, nextOther < 0 ? text.Length : nextOther }.Min();

                var actionStart = text.IndexOf(ActionMarker, p, StringComparison.Ordinal);
                if (actionStart >= 0 && actionStart < blockLimit)
                {
                    var actionValues = text.IndexOf("VALUES", actionStart, StringComparison.OrdinalIgnoreCase);
                    block.ActionHeader = text.Substring(actionStart, actionValues - actionStart).TrimEnd();
                    var ap = actionValues + "VALUES".Length;
                    block.Actions = ReadTuples(text, ref ap);
                    p = ap;
                }

                // include the blank lines after the block so regenerated text keeps the same spacing
                block.End = blockLimit;
                blocks.Add(block);
                pos = blockLimit;
                if (nextEmote < 0)
                    break;
            }
            return blocks;
        }

        private static int FindNextOtherInsert(string text, int from)
        {
            var pos = from;
            while (true)
            {
                var i = text.IndexOf("INSERT INTO `", pos, StringComparison.Ordinal);
                if (i < 0)
                    return -1;
                if (!text.Substring(i).StartsWith(EmoteMarker) && !text.Substring(i).StartsWith(ActionMarker))
                    return i;
                pos = i + 1;
            }
        }

        /// <summary>Reads "(...), (...), ... ;" tuples, respecting quotes and /* comments */.</summary>
        private static List<(int start, int end, List<string> tokens)> ReadTuples(string text, ref int pos)
        {
            var result = new List<(int, int, List<string>)>();
            while (pos < text.Length)
            {
                var c = text[pos];
                if (char.IsWhiteSpace(c) || c == ',')
                {
                    pos++;
                    continue;
                }
                if (c == '/' && pos + 1 < text.Length && text[pos + 1] == '*')
                {
                    var e = text.IndexOf("*/", pos + 2, StringComparison.Ordinal);
                    pos = e < 0 ? text.Length : e + 2;
                    continue;
                }
                if (c == ';')
                {
                    pos++;
                    break;
                }
                if (c != '(')
                    break;

                var start = pos;
                var tokens = new List<string>();
                var current = new StringBuilder();
                pos++;
                var depth = 0;
                while (pos < text.Length)
                {
                    var ch = text[pos];
                    if (ch == '\'')
                    {
                        // quoted string, '' is an escaped quote
                        current.Append(ch);
                        pos++;
                        while (pos < text.Length)
                        {
                            current.Append(text[pos]);
                            if (text[pos] == '\'')
                            {
                                if (pos + 1 < text.Length && text[pos + 1] == '\'')
                                {
                                    current.Append('\'');
                                    pos += 2;
                                    continue;
                                }
                                pos++;
                                break;
                            }
                            pos++;
                        }
                        continue;
                    }
                    if (ch == '/' && pos + 1 < text.Length && text[pos + 1] == '*')
                    {
                        var e = text.IndexOf("*/", pos + 2, StringComparison.Ordinal);
                        var end = e < 0 ? text.Length : e + 2;
                        current.Append(text, pos, end - pos);
                        pos = end;
                        continue;
                    }
                    if (ch == '(') depth++;
                    if (ch == ')')
                    {
                        if (depth == 0)
                        {
                            tokens.Add(current.ToString().Trim());
                            pos++;
                            break;
                        }
                        depth--;
                    }
                    if (ch == ',' && depth == 0)
                    {
                        tokens.Add(current.ToString().Trim());
                        current.Clear();
                        pos++;
                        continue;
                    }
                    current.Append(ch);
                    pos++;
                }
                result.Add((start, pos, tokens));
            }
            return result;
        }

        private static string StripComment(string token) => Regex.Replace(token ?? "", @"/\*.*?\*/", "", RegexOptions.Singleline).Trim();

        private static string CommentOf(string token)
        {
            var m = Regex.Match(token ?? "", @"/\*\s*(.*?)\s*\*/", RegexOptions.Singleline);
            return m.Success ? m.Groups[1].Value : null;
        }

        private static int LeadingInt(string token) => int.TryParse(StripComment(token), out var v) ? v : -1;

        private static uint ParseUInt(string token) => uint.TryParse(StripComment(token), out var v) ? v : 0;

        private static int ParseStack(string token)
        {
            var s = StripComment(token);
            return int.TryParse(s, out var v) && v > 0 ? v : -1;
        }

        private static string Unquote(string token)
        {
            var s = StripComment(token);
            if (s.Length >= 2 && s[0] == '\'' && s[s.Length - 1] == '\'')
                return s.Substring(1, s.Length - 2).Replace("''", "'");
            return null;
        }

        private static int ActionType(List<string> tokens) => tokens.Count > ActionStackIndex ? LeadingInt(tokens[2]) : -1;

        private static string CategoryName(List<string> emoteTokens)
        {
            var name = CommentOf(emoteTokens[1]);
            return name ?? ("category " + LeadingInt(emoteTokens[1]));
        }
    }
}
