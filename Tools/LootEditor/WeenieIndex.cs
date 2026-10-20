using System.Text.RegularExpressions;

namespace LootEditor
{
    /// <summary>
    /// Looks up item names by WCID. Names come from the weenie files in Content/sql/weenies,
    /// plus the "Generate Name (wcid)" comments in chest files, which also cover stock items
    /// (like Foolproofs) that only exist in the stock world database.
    /// </summary>
    public class WeenieIndex
    {
        private readonly Dictionary<uint, string> names = new Dictionary<uint, string>();
        private readonly Dictionary<uint, List<string>> profileUsers = new Dictionary<uint, List<string>>();

        private static readonly Regex DeathTreasureRegex = new Regex(@"\(\s*\d+\s*,\s*35\s*,\s*(\d+)\s*\)");
        private static readonly Regex TreasureGeneratorRegex = new Regex(@"\(\s*\d+\s*,\s*-?[\d.]+\s*,\s*(\d+)\s*,(?:[^,()]*,){4}\s*72\s*,");

        private static readonly Regex GenerateCommentRegex = new Regex(@"Generate\s+(.+?)\s+\((\d+)\)");

        public void Build(string contentSqlFolder, Action<string> foundChest, Action<string, List<string>> foundRewardTables, Action<string> foundProfile)
        {
            names.Clear();
            profileUsers.Clear();
            if (!Directory.Exists(contentSqlFolder))
                return;

            foreach (var file in Directory.EnumerateFiles(contentSqlFolder, "*.sql", SearchOption.AllDirectories))
            {
                string text;
                try { text = File.ReadAllText(file); }
                catch { continue; }

                if (LootProfileFile.IsProfileFile(text))
                    foundProfile(file);

                var header = ChestFile.ReadWeenieHeader(text);
                if (header == null)
                    continue;

                RecordProfileUsers(text, ChestFile.ReadName(text) ?? ("WCID " + header.Value.wcid), header.Value.wcid);

                var name = ChestFile.ReadName(text);
                if (name != null)
                    names[header.Value.wcid] = name;

                foreach (Match m in GenerateCommentRegex.Matches(text))
                {
                    if (uint.TryParse(m.Groups[2].Value, out var wcid) && !names.ContainsKey(wcid))
                        names[wcid] = m.Groups[1].Value.Trim();
                }

                if (ChestFile.IsChestWithGenerator(text))
                    foundChest(file);

                var tables = EmoteRewardFile.FindRewardTables(text);
                if (tables.Count > 0)
                    foundRewardTables(file, tables);
            }
        }

        public string GetName(uint wcid) => names.TryGetValue(wcid, out var name) ? name : null;

        /// <summary>Monsters (DeathTreasureType) and chests (random-loot rows) in Content that use a loot profile.</summary>
        public List<string> GetProfileUsers(uint treasureType) =>
            profileUsers.TryGetValue(treasureType, out var list) ? list : new List<string>();

        private void RecordProfileUsers(string text, string name, uint wcid)
        {
            var did = Section(text, "weenie_properties_d_i_d");
            if (did != null)
                foreach (Match m in DeathTreasureRegex.Matches(did))
                    AddProfileUser(uint.Parse(m.Groups[1].Value), $"Monster drops: {name} ({wcid})");

            var gen = Section(text, "weenie_properties_generator");
            if (gen != null)
                foreach (Match m in TreasureGeneratorRegex.Matches(gen))
                    AddProfileUser(uint.Parse(m.Groups[1].Value), $"Container loot: {name} ({wcid})");
        }

        private void AddProfileUser(uint profile, string entry)
        {
            if (!profileUsers.TryGetValue(profile, out var list))
            {
                list = new List<string>();
                profileUsers[profile] = list;
            }
            if (!list.Contains(entry))
                list.Add(entry);
        }

        /// <summary>The text of one INSERT block (from the table name to the next INSERT/DELETE), or null.</summary>
        private static string Section(string text, string table)
        {
            var start = text.IndexOf("INSERT INTO `" + table + "`", StringComparison.Ordinal);
            if (start < 0)
                return null;
            var next = text.IndexOf("INSERT INTO", start + 12, StringComparison.Ordinal);
            var del = text.IndexOf("DELETE FROM", start + 12, StringComparison.Ordinal);
            var end = new[] { next < 0 ? text.Length : next, del < 0 ? text.Length : del }.Min();
            return text.Substring(start, end - start);
        }

        public static string NameFromComment(string comment)
        {
            if (string.IsNullOrEmpty(comment))
                return null;
            var m = GenerateCommentRegex.Match(comment);
            return m.Success ? m.Groups[1].Value.Trim() : null;
        }
    }
}
