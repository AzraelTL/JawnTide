using System.Globalization;
using System.Text;
using ACE.DatLoader;
using ACE.DatLoader.FileTypes;

// JawnTide DatFind: which 0x05 SurfaceTexture wraps a 0x06 texture image (custom clothing uses the 0x05 ID).
// usage: DatFind "<AC client folder>" <0x06 id> [more 0x06 ids...]
//        DatFind "<AC client folder>" <0x05 id>   (shows which 0x06 image it wraps)

if (args.Length < 2)
{
    Console.WriteLine("usage: DatFind \"C:\\Turbine\\Asheron's Call\" 0x06007000 [more ids...]");
    return 1;
}

Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
DatManager.Initialize(args[0], false, false);

if (DatManager.PortalDat == null)
{
    Console.WriteLine($"Could not read client_portal.dat in {args[0]}");
    return 1;
}

static uint ParseId(string s) => s.StartsWith("0x", StringComparison.OrdinalIgnoreCase)
    ? uint.Parse(s[2..], NumberStyles.HexNumber) : uint.Parse(s, NumberStyles.HexNumber);

var wanted = args.Skip(1).Select(ParseId).ToList();
var images = wanted.Where(i => i >> 24 == 0x06).ToHashSet();

foreach (var id in wanted.Where(i => i >> 24 == 0x05))
{
    var st = DatManager.PortalDat.ReadFromDat<SurfaceTexture>(id);
    Console.WriteLine($"0x{id:X8} ({id}) wraps: {string.Join(", ", st.Textures.Select(t => $"0x{t:X8}"))}");
}

if (images.Count > 0)
{
    var found = 0;
    foreach (var id in DatManager.PortalDat.AllFiles.Keys.Where(k => k >> 24 == 0x05).OrderBy(k => k))
    {
        var st = DatManager.PortalDat.ReadFromDat<SurfaceTexture>(id);
        foreach (var t in st.Textures.Where(images.Contains))
        {
            Console.WriteLine($"image 0x{t:X8} is used by SurfaceTexture 0x{id:X8}  (decimal {id})");
            found++;
        }
    }
    if (found == 0)
        Console.WriteLine("No SurfaceTexture uses those images.");
}

return 0;
