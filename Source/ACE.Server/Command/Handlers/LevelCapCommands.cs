using System;
using System.Text;

using ACE.DatLoader;
using ACE.Entity.Enum;
using ACE.Server.Managers;
using ACE.Server.Network;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: a fixed level cap, using the season XP cap settings without the daily rise.
    /// </summary>
    public static class LevelCapCommands
    {
        /// <summary>The season start used to hold the cap still: day 0 forever, so the cap stays at rolling_level_cap_start_xp.</summary>
        private const long FrozenStart = 4102444800; // 2100-01-01 UTC

        [CommandHandler("levelcap", AccessLevel.Admin, CommandHandlerFlag.None, 0,
            "Shows or sets a fixed level cap (no daily rise, no season XP changes).",
            "/levelcap - the cap now, how it is set, and the XP each nearby level needs\n" +
            "/levelcap <level> - fix the cap at that level (1-275); characters already above it keep their level\n" +
            "/levelcap off - no cap (up to 275)")]
        public static void HandleLevelCap(Session session, params string[] parameters)
        {
            var xpTable = DatManager.PortalDat.XpTable.CharacterLevelXPList;
            var maxLevel = xpTable.Count - 1;

            string Describe()
            {
                var enabled = PropertyManager.GetBool("rolling_level_cap_enabled").Item;
                var start = PropertyManager.GetLong("rolling_level_cap_start_timestamp").Item;
                var startXp = PropertyManager.GetLong("rolling_level_cap_start_xp").Item;
                var days = PropertyManager.GetLong("rolling_level_cap_season_days").Item;
                var cap = RollingLevelCapManager.GetCurrentXpCap();

                var sb = new StringBuilder();
                if (cap <= 0)
                    sb.Append($"No level cap: characters can reach {maxLevel}.");
                else
                {
                    var level = RollingLevelCapManager.GetCurrentLevelCap(cap);
                    sb.Append($"Level cap: {level} (total XP {cap:N0}).");
                    if (start >= FrozenStart)
                        sb.Append(" It's fixed (set with /levelcap).");
                    else if (start > DateTimeOffset.UtcNow.ToUnixTimeSeconds())
                        sb.Append($" The season hasn't started yet; it starts {DateTimeOffset.FromUnixTimeSeconds(start):yyyy-MM-dd} and then rises daily.");
                    else
                        sb.Append($" It rises daily: season day {RollingLevelCapManager.GetCurrentSeasonDay() + 1} of {days}, reaching {maxLevel} at the end.");
                }
                sb.Append($"\nSettings: rolling_level_cap_enabled {enabled}, rolling_level_cap_start_timestamp {start}, rolling_level_cap_start_xp {startXp:N0}, rolling_level_cap_season_days {days}, rolling_xp_cap {PropertyManager.GetLong("rolling_xp_cap").Item:N0}.");
                return sb.ToString();
            }

            if (parameters.Length == 0)
            {
                var sb = new StringBuilder(Describe());
                var now = RollingLevelCapManager.GetCurrentLevelCap(RollingLevelCapManager.GetCurrentXpCap());
                var from = Math.Max(1, (now > 0 ? now : 126) - 2);
                sb.Append("\nTotal XP needed per level:");
                for (var l = from; l <= Math.Min(maxLevel, from + 30); l++)
                    sb.Append($"\n  {l}: {(long)xpTable[l]:N0}");
                CommandHandlerHelper.WriteOutputInfo(session, sb.ToString());
                return;
            }

            var arg = parameters[0].Trim().ToLowerInvariant();

            if (arg == "off" || arg == "none" || arg == maxLevel.ToString())
            {
                PropertyManager.ModifyBool("rolling_level_cap_enabled", false);
                PropertyManager.ModifyLong("rolling_xp_cap", 0);
                CommandHandlerHelper.WriteOutputInfo(session, "Level cap removed. " + Describe());
                PlayerManager.BroadcastToAuditChannel(session?.Player, $"Level cap removed (up to {maxLevel}).");
                return;
            }

            if (!int.TryParse(arg, out var cap) || cap < 1 || cap > maxLevel)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"Use /levelcap <1-{maxLevel}> or /levelcap off.");
                return;
            }

            var xp = (long)xpTable[cap];

            // day 0 forever, so the daily update keeps the cap at start_xp; the season XP modifier is left alone
            PropertyManager.ModifyLong("rolling_level_cap_start_xp", xp);
            PropertyManager.ModifyLong("rolling_level_cap_start_timestamp", FrozenStart);
            PropertyManager.ModifyLong("rolling_xp_cap", xp);
            PropertyManager.ModifyLong("rolling_xp_cap_timestamp", DateTimeOffset.UtcNow.ToUnixTimeSeconds());
            PropertyManager.ModifyBool("rolling_level_cap_enabled", true);

            CommandHandlerHelper.WriteOutputInfo(session, $"Level cap set to {cap}. " + Describe());
            PlayerManager.BroadcastToAuditChannel(session?.Player, $"Level cap set to {cap} (total XP {xp:N0}).");
        }
    }
}
