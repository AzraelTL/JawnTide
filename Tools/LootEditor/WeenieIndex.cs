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

        private static readonly Regex GenerateCommentRegex = new Regex(@"Generate\s+(.+?)\s+\((\d+)\)");

        public void Build(string contentSqlFolder, Action<string> foundChest)
        {
            names.Clear();
            var weeniesFolder = Path.Combine(contentSqlFolder, "weenies");
            if (!Directory.Exists(weeniesFolder))
                return;

            foreach (var file in Directory.EnumerateFiles(weeniesFolder, "*.sql", SearchOption.AllDirectories))
            {
                string text;
                try { text = File.ReadAllText(file); }
                catch { continue; }

                var header = ChestFile.ReadWeenieHeader(text);
                if (header == null)
                    continue;

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
            }
        }

        public string GetName(uint wcid) => names.TryGetValue(wcid, out var name) ? name : null;

        public static string NameFromComment(string comment)
        {
            if (string.IsNullOrEmpty(comment))
                return null;
            var m = GenerateCommentRegex.Match(comment);
            return m.Success ? m.Groups[1].Value.Trim() : null;
        }
    }
}
