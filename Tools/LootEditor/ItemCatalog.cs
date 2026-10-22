using System.Globalization;

namespace LootEditor
{
    /// <summary>An item that could be put on a vendor.</summary>
    public class CatalogItem
    {
        public uint Wcid;
        public string Name;
        public uint ItemType;
        public int Value;
        public bool InContent;     // has a file in Content (its Value can be edited)
        public string Path;        // the Content file, when InContent

        public string TypeName => ItemCatalog.TypeName(ItemType);
    }

    /// <summary>
    /// Every item that could be sold by a vendor: the server's world database export (Ops/item-catalog.tsv,
    /// see Ops/item-catalog-README.md) with Content's own items on top (Content wins, it's what gets imported).
    /// Items are weenies with an ItemType, except creatures, portals and lifestones.
    /// </summary>
    public class ItemCatalog
    {
        public const string FileName = "item-catalog.tsv";
        private const uint NotItems = 0x00000010 | 0x00010000 | 0x10000000;   // Creature, Portal, LifeStone

        private readonly Dictionary<uint, CatalogItem> items = new Dictionary<uint, CatalogItem>();

        public int Count => items.Count;
        public bool HasExport { get; private set; }
        public int ExportCount { get; private set; }
        public IEnumerable<CatalogItem> Items => items.Values;

        public CatalogItem Get(uint wcid) => items.TryGetValue(wcid, out var item) ? item : null;

        public void Load(string exportPath, WeenieIndex index)
        {
            items.Clear();
            HasExport = false;
            ExportCount = 0;

            // export lines: wcid <tab> weenie type <tab> item type <tab> value <tab> name
            if (File.Exists(exportPath))
            {
                foreach (var line in File.ReadLines(exportPath))
                {
                    var parts = line.Split('\t');
                    if (parts.Length < 5 || !uint.TryParse(parts[0], out var wcid))
                        continue;
                    long.TryParse(parts[2], NumberStyles.Integer, CultureInfo.InvariantCulture, out var itemType);
                    int.TryParse(parts[3], NumberStyles.Integer, CultureInfo.InvariantCulture, out var value);
                    var name = parts[4] == "NULL" ? "" : parts[4].Replace("\\t", " ").Replace("\\n", " ");
                    var type = unchecked((uint)itemType);
                    if (type == 0 || (type & NotItems) != 0)
                        continue;
                    items[wcid] = new CatalogItem { Wcid = wcid, Name = name, ItemType = type, Value = value };
                }
                HasExport = true;
                ExportCount = items.Count;
            }

            foreach (var weenie in index.AllWeenies)
            {
                if (weenie.ItemType == 0 || (weenie.ItemType & NotItems) != 0)
                    continue;
                items[weenie.Wcid] = new CatalogItem
                {
                    Wcid = weenie.Wcid,
                    Name = index.GetName(weenie.Wcid) ?? "",
                    ItemType = weenie.ItemType,
                    Value = weenie.Value ?? 0,
                    InContent = true,
                    Path = weenie.Path,
                };
            }
        }

        public static string TypeName(uint itemType)
        {
            foreach (var pair in Names)
                if ((itemType & pair.Key) != 0)
                    return pair.Value;
            return "0x" + itemType.ToString("X");
        }

        private static readonly KeyValuePair<uint, string>[] Names =
        {
            new KeyValuePair<uint, string>(0x00000001, "Melee weapon"),
            new KeyValuePair<uint, string>(0x00000100, "Missile weapon"),
            new KeyValuePair<uint, string>(0x00008000, "Caster"),
            new KeyValuePair<uint, string>(0x00000002, "Armor"),
            new KeyValuePair<uint, string>(0x00000004, "Clothing"),
            new KeyValuePair<uint, string>(0x00000008, "Jewelry"),
            new KeyValuePair<uint, string>(0x00000020, "Food"),
            new KeyValuePair<uint, string>(0x00000040, "Money"),
            new KeyValuePair<uint, string>(0x00000200, "Container"),
            new KeyValuePair<uint, string>(0x00000800, "Gem"),
            new KeyValuePair<uint, string>(0x00001000, "Spell component"),
            new KeyValuePair<uint, string>(0x00002000, "Writable"),
            new KeyValuePair<uint, string>(0x00004000, "Key"),
            new KeyValuePair<uint, string>(0x00040000, "Promissory note"),
            new KeyValuePair<uint, string>(0x00080000, "Mana stone"),
            new KeyValuePair<uint, string>(0x00100000, "Service"),
            new KeyValuePair<uint, string>(0x20000000, "Tinkering tool"),
            new KeyValuePair<uint, string>(0x40000000, "Salvage"),
            new KeyValuePair<uint, string>(0x00400000, "Cooking"),
            new KeyValuePair<uint, string>(0x00800000, "Alchemy"),
            new KeyValuePair<uint, string>(0x04000000, "Alchemy"),
            new KeyValuePair<uint, string>(0x02000000, "Fletching"),
            new KeyValuePair<uint, string>(0x08000000, "Fletching"),
            new KeyValuePair<uint, string>(0x00000400, "Useless"),
            new KeyValuePair<uint, string>(0x00000080, "Misc"),
            new KeyValuePair<uint, string>(0x00200000, "Magic wieldable"),
            new KeyValuePair<uint, string>(0x00020000, "Lockable"),
            new KeyValuePair<uint, string>(0x80000000, "Gameboard"),
        };
    }
}
