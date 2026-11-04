using System;
using System.IO;
using System.IO.Compression;

using log4net;

using ACE.DatLoader;
using ACE.DatLoader.FileTypes;
using ACE.Entity.Enum;

namespace ACE.Server.Entity
{
    /// <summary>
    /// JawnTide Marketplace: turns an item icon from the client's portal.dat into a PNG for the website (market_icon table).
    /// Written by hand (no System.Drawing, which doesn't work on Linux). Handles the formats icons use: 32-bit ARGB, 24-bit RGB,
    /// 8-bit alpha and paletted (8 and 16 bit). Anything else is stored as "no picture" so the website shows a blank square.
    /// </summary>
    public static class MarketIcons
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>The icon as PNG bytes, or null if it can't be read.</summary>
        public static byte[] GetPng(uint iconId)
        {
            try
            {
                var texture = DatManager.PortalDat.ReadFromDat<Texture>(iconId);

                if (texture == null || texture.Width <= 0 || texture.Height <= 0 || texture.Width > 1024 || texture.Height > 1024 || texture.SourceData == null)
                    return null;

                var rgba = ToRgba(texture);
                return rgba == null ? null : EncodePng(texture.Width, texture.Height, rgba);
            }
            catch (Exception ex)
            {
                log.Warn($"[MARKET] Couldn't read icon 0x{iconId:X8}: {ex.Message}");
                return null;
            }
        }

        private static byte[] ToRgba(Texture t)
        {
            int w = t.Width, h = t.Height, n = w * h;
            var src = t.SourceData;
            var dst = new byte[n * 4];

            switch (t.Format)
            {
                case SurfacePixelFormat.PFID_A8R8G8B8:
                case SurfacePixelFormat.PFID_X8R8G8B8:
                    if (src.Length < n * 4) return null;
                    for (int i = 0; i < n; i++)
                    {
                        dst[i * 4 + 0] = src[i * 4 + 2];
                        dst[i * 4 + 1] = src[i * 4 + 1];
                        dst[i * 4 + 2] = src[i * 4 + 0];
                        dst[i * 4 + 3] = t.Format == SurfacePixelFormat.PFID_X8R8G8B8 ? (byte)255 : src[i * 4 + 3];
                    }
                    return dst;

                case SurfacePixelFormat.PFID_R8G8B8:
                    if (src.Length < n * 3) return null;
                    for (int i = 0; i < n; i++)
                    {
                        dst[i * 4 + 0] = src[i * 3 + 2];
                        dst[i * 4 + 1] = src[i * 3 + 1];
                        dst[i * 4 + 2] = src[i * 3 + 0];
                        dst[i * 4 + 3] = 255;
                    }
                    return dst;

                case SurfacePixelFormat.PFID_A8:
                    if (src.Length < n) return null;
                    for (int i = 0; i < n; i++)
                    {
                        dst[i * 4 + 0] = 255;
                        dst[i * 4 + 1] = 255;
                        dst[i * 4 + 2] = 255;
                        dst[i * 4 + 3] = src[i];
                    }
                    return dst;

                case SurfacePixelFormat.PFID_P8:
                case SurfacePixelFormat.PFID_INDEX16:
                    {
                        if (!t.DefaultPaletteId.HasValue) return null;
                        var palette = DatManager.PortalDat.ReadFromDat<Palette>(t.DefaultPaletteId.Value);
                        if (palette == null || palette.Colors.Count == 0) return null;

                        var wide = t.Format == SurfacePixelFormat.PFID_INDEX16;
                        if (src.Length < n * (wide ? 2 : 1)) return null;

                        for (int i = 0; i < n; i++)
                        {
                            int index = wide ? (src[i * 2] | (src[i * 2 + 1] << 8)) : src[i];
                            uint argb = index < palette.Colors.Count ? palette.Colors[index] : 0;
                            dst[i * 4 + 0] = (byte)(argb >> 16);
                            dst[i * 4 + 1] = (byte)(argb >> 8);
                            dst[i * 4 + 2] = (byte)argb;
                            dst[i * 4 + 3] = (byte)(argb >> 24);
                        }
                        return dst;
                    }

                default:
                    log.Warn($"[MARKET] Icon 0x{t.Id:X8} uses pixel format {t.Format}, which the market can't show yet.");
                    return null;
            }
        }

        // ---------------------------------------------------------------- minimal PNG writer (8-bit RGBA, no filtering)

        private static byte[] EncodePng(int width, int height, byte[] rgba)
        {
            using var ms = new MemoryStream();
            ms.Write(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A });

            var ihdr = new byte[13];
            WriteBigEndian(ihdr, 0, (uint)width);
            WriteBigEndian(ihdr, 4, (uint)height);
            ihdr[8] = 8;    // bit depth
            ihdr[9] = 6;    // color type: RGBA
            ihdr[10] = 0;   // compression
            ihdr[11] = 0;   // filter
            ihdr[12] = 0;   // no interlace
            WriteChunk(ms, "IHDR", ihdr);

            var raw = new byte[height * (width * 4 + 1)];
            for (int y = 0; y < height; y++)
            {
                raw[y * (width * 4 + 1)] = 0; // filter type none
                Buffer.BlockCopy(rgba, y * width * 4, raw, y * (width * 4 + 1) + 1, width * 4);
            }

            byte[] compressed;
            using (var zms = new MemoryStream())
            {
                using (var z = new ZLibStream(zms, CompressionLevel.Optimal, true))
                    z.Write(raw, 0, raw.Length);
                compressed = zms.ToArray();
            }
            WriteChunk(ms, "IDAT", compressed);
            WriteChunk(ms, "IEND", Array.Empty<byte>());

            return ms.ToArray();
        }

        private static void WriteChunk(Stream s, string type, byte[] data)
        {
            var len = new byte[4];
            WriteBigEndian(len, 0, (uint)data.Length);
            s.Write(len, 0, 4);

            var typeBytes = new byte[] { (byte)type[0], (byte)type[1], (byte)type[2], (byte)type[3] };
            s.Write(typeBytes, 0, 4);
            s.Write(data, 0, data.Length);

            var crc = Crc32(typeBytes, 0xFFFFFFFFu);
            crc = Crc32(data, crc) ^ 0xFFFFFFFFu;
            var crcBytes = new byte[4];
            WriteBigEndian(crcBytes, 0, crc);
            s.Write(crcBytes, 0, 4);
        }

        private static void WriteBigEndian(byte[] b, int offset, uint v)
        {
            b[offset] = (byte)(v >> 24);
            b[offset + 1] = (byte)(v >> 16);
            b[offset + 2] = (byte)(v >> 8);
            b[offset + 3] = (byte)v;
        }

        private static readonly uint[] crcTable = BuildCrcTable();

        private static uint[] BuildCrcTable()
        {
            var table = new uint[256];
            for (uint n = 0; n < 256; n++)
            {
                uint c = n;
                for (int k = 0; k < 8; k++)
                    c = (c & 1) != 0 ? 0xEDB88320u ^ (c >> 1) : c >> 1;
                table[n] = c;
            }
            return table;
        }

        private static uint Crc32(byte[] data, uint crc)
        {
            foreach (var b in data)
                crc = crcTable[(crc ^ b) & 0xFF] ^ (crc >> 8);
            return crc;
        }
    }
}
