using System.Text;
using System.Text.RegularExpressions;

namespace LootEditor
{
    /// <summary>One row of an INSERT statement, with the comment that follows it in the file.</summary>
    public class SqlRow
    {
        public List<string> Tokens;
        public string Comment;   // "/* ... */" or null

        public string ToSql() => "(" + string.Join(", ", Tokens) + ")" + (Comment != null ? " " + Comment : "");
    }

    /// <summary>
    /// One "INSERT INTO `table` (...) VALUES (...), (...);" statement in a weenie SQL file: where it is and its rows.
    /// Used to rewrite a statement's rows while keeping everything else in the file as it is.
    /// </summary>
    public class SqlStatement
    {
        public int Start;          // position of "INSERT INTO"
        public int ValuesStart;    // position of "VALUES"
        public int End;            // just after the ';'
        public List<SqlRow> Rows = new List<SqlRow>();

        public static SqlStatement Find(string text, string table)
        {
            var marker = "INSERT INTO `" + table + "`";
            var start = text.IndexOf(marker, StringComparison.Ordinal);
            if (start < 0)
                return null;

            var statement = new SqlStatement { Start = start };
            statement.ValuesStart = text.IndexOf("VALUES", start, StringComparison.OrdinalIgnoreCase);
            if (statement.ValuesStart < 0)
                throw new InvalidDataException($"Unexpected {table} format.");
            var pos = statement.ValuesStart + "VALUES".Length;
            var tuples = EmoteRewardFile.ReadTuples(text, ref pos);
            statement.End = pos;

            for (var i = 0; i < tuples.Count; i++)
            {
                // the row's comment sits between its ')' and the next row (or the ';')
                var gapEnd = i + 1 < tuples.Count ? tuples[i + 1].start : statement.End;
                var gap = text.Substring(tuples[i].end, Math.Max(0, gapEnd - tuples[i].end));
                var m = Regex.Match(gap, @"/\*.*?\*/", RegexOptions.Singleline);
                statement.Rows.Add(new SqlRow { Tokens = tuples[i].tokens, Comment = m.Success ? m.Value : null });
            }
            return statement;
        }

        /// <summary>"VALUES (...)\n     , (...);" for the given rows.</summary>
        public static string BuildValues(IList<SqlRow> rows, string newline)
        {
            var sb = new StringBuilder("VALUES ");
            for (var i = 0; i < rows.Count; i++)
            {
                if (i > 0)
                    sb.Append(newline).Append("     , ");
                sb.Append(rows[i].ToSql());
            }
            return sb.Append(';').ToString();
        }

        public static string StripComment(string token) => Regex.Replace(token ?? "", @"/\*.*?\*/", "", RegexOptions.Singleline).Trim();

        public static int TypeOf(SqlRow row) => int.TryParse(StripComment(row.Tokens[1]), out var t) ? t : -1;
    }

    /// <summary>Applies text replacements to a file's text, last position first so earlier positions stay valid.</summary>
    public class TextEdits
    {
        private class Edit
        {
            public int Start, End;
            public string Replacement;
        }

        private readonly List<Edit> edits = new List<Edit>();

        public void Replace(int start, int end, string replacement) => edits.Add(new Edit { Start = start, End = end, Replacement = replacement });

        public string Apply(string text)
        {
            foreach (var edit in edits.OrderByDescending(e => e.Start))
                text = text.Substring(0, edit.Start) + edit.Replacement + text.Substring(edit.End);
            return text;
        }
    }
}
