using System;
using System.Globalization;
using System.Net.Http;
using System.Text.Json;

using log4net;

using ACE.Server.Managers;

namespace ACE.Server.Network
{
    public class ISPInfo
    {
        public string ASN { get; set; }
        public string Provider { get; set; }
        public string Continent { get; set; }
        public string Country { get; set; }
        public string IsoCode { get; set; }
        public string Region { get; set; }
        public string RegionCode { get; set; }
        public string City { get; set; }
        public float Latitude { get; set; }
        public float Longitude { get; set; }
        public string Proxy { get; set; }
        public string Type { get; set; }

        public override string ToString()
        {
            return $"ASN = {ASN}, Provider = {Provider}, Continent = {Continent}, Country = {Country}, IsoCode = {IsoCode}, Region = {Region}, RegionCode = {RegionCode}, City = {City}, Latitude = {Latitude}, Longitude = {Longitude}, Proxy = {Proxy}, Type = {Type}";
        }
    }

    /// <summary>
    /// Asks proxycheck.io (v2 API) whether an IP address is a VPN or proxy.
    /// </summary>
    public static class VPNDetection
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        // One shared client; a slow or unreachable proxycheck.io never holds a login for more than 3 seconds.
        private static readonly HttpClient httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(3) };

        /// <summary>
        /// Returns the proxycheck.io result for the IP, or null if the check could not be completed
        /// (timeout, network error, quota exceeded, unexpected answer). Callers treat null as "allow".
        /// The API key is read from the proxycheck_api_key server setting on every call.
        /// </summary>
        public static ISPInfo CheckVPN(string ip)
        {
            if (string.IsNullOrEmpty(ip))
                return null;

            var url = $"https://proxycheck.io/v2/{Uri.EscapeDataString(ip)}?vpn=1&asn=1";
            var apiKey = PropertyManager.GetString("proxycheck_api_key").Item;
            if (!string.IsNullOrWhiteSpace(apiKey))
                url += "&key=" + Uri.EscapeDataString(apiKey.Trim());

            try
            {
                var json = httpClient.GetStringAsync(url).GetAwaiter().GetResult();

                using var doc = JsonDocument.Parse(json);
                var root = doc.RootElement;

                var status = GetString(root, "status");
                if (status != "ok" && status != "warning")
                {
                    log.Warn($"VPNDetection: proxycheck.io answered status '{status}' for {ip}: {GetString(root, "message")}");
                    return null;
                }

                if (status == "warning")
                    log.Warn($"VPNDetection: proxycheck.io warning: {GetString(root, "message")}");

                if (!root.TryGetProperty(ip, out var d) || d.ValueKind != JsonValueKind.Object)
                {
                    log.Warn($"VPNDetection: proxycheck.io answer had no entry for {ip}");
                    return null;
                }

                return new ISPInfo
                {
                    ASN = GetString(d, "asn"),
                    Provider = GetString(d, "provider"),
                    Continent = GetString(d, "continent"),
                    Country = GetString(d, "country"),
                    IsoCode = GetString(d, "isocode"),
                    Region = GetString(d, "region"),
                    RegionCode = GetString(d, "regioncode"),
                    City = GetString(d, "city"),
                    Latitude = GetFloat(d, "latitude"),
                    Longitude = GetFloat(d, "longitude"),
                    Proxy = GetString(d, "proxy"),
                    Type = GetString(d, "type")
                };
            }
            catch (Exception ex)
            {
                // Never log the URL: it contains the API key.
                log.Warn($"VPNDetection: check for {ip} could not be completed ({ex.GetType().Name}: {ex.Message}); allowing the login");
                return null;
            }
        }

        private static string GetString(JsonElement element, string name)
        {
            if (!element.TryGetProperty(name, out var value))
                return null;

            return value.ValueKind == JsonValueKind.String ? value.GetString() : value.ToString();
        }

        private static float GetFloat(JsonElement element, string name)
        {
            if (!element.TryGetProperty(name, out var value))
                return 0;

            if (value.ValueKind == JsonValueKind.Number && value.TryGetSingle(out var number))
                return number;

            if (value.ValueKind == JsonValueKind.String && float.TryParse(value.GetString(), NumberStyles.Float, CultureInfo.InvariantCulture, out number))
                return number;

            return 0;
        }
    }
}
