using System;

using ACE.DatLoader;

namespace ACE.Server.Managers
{
    /// <summary>
    /// Server-wide rolling XP cap for a season.
    ///
    /// The cap is a raw total-XP ceiling that rises linearly from
    /// <c>rolling_level_cap_start_xp</c> on season day 0 to the level-275 XP requirement
    /// over <c>rolling_level_cap_season_days</c> days, then freezes. Because it is stored
    /// as an XP value rather than a level, the cap can land mid-level on any given day.
    /// Once it reaches the level-275 requirement it stops; from there the character is at
    /// max level and behaves exactly as end-of-retail does with no cap (XP still reduces
    /// vitae and still levels equippable gear, it just no longer raises the character).
    ///
    /// Server configs (PropertyManager):
    ///   rolling_level_cap_enabled          (bool)   master on/off
    ///   rolling_level_cap_start_timestamp  (long)   Unix timestamp of season day 0
    ///   rolling_level_cap_season_days      (long)   day the cap reaches level 275
    ///   rolling_level_cap_start_xp         (long)   XP cap on day 0
    ///   rolling_xp_cap                     (long)   computed cap (managed automatically)
    ///   rolling_xp_cap_timestamp           (long)   last update time (managed automatically)
    ///   rolling_xp_modifier_enabled        (bool)   drive xp_modifier along a season curve
    ///   rolling_xp_modifier_max            (double) end-of-ramp value for xp_modifier
    ///   catchup_xp_*                                catch-up boost for characters behind the cap
    ///   daily_{monster,quest,pvp}_xp_category_ratio per-category share of remaining headroom
    /// </summary>
    public static class RollingLevelCapManager
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static DateTime LastTickDateTime = DateTime.MinValue;

        // ── Tick ─────────────────────────────────────────────────────────────────

        /// <summary>
        /// Called from WorldManager.Tick(). Throttled to once every 15 minutes; recomputes and
        /// persists rolling_xp_cap (and xp_modifier) when a new UTC calendar day has started.
        /// </summary>
        public static void Tick()
        {
            if (DateTime.Now.AddMinutes(-15) < LastTickDateTime)
                return;

            LastTickDateTime = DateTime.Now;

            if (!PropertyManager.GetBool("rolling_level_cap_enabled").Item)
                return;

            var startTimestamp = PropertyManager.GetLong("rolling_level_cap_start_timestamp").Item;
            if (startTimestamp <= 0)
                return;

            // Only recalculate once per UTC calendar day.
            var lastUpdateTimestamp = PropertyManager.GetLong("rolling_xp_cap_timestamp").Item;
            var todayMidnightUtc = new DateTimeOffset(DateTime.UtcNow.Date, TimeSpan.Zero).ToUnixTimeSeconds();
            if (lastUpdateTimestamp >= todayMidnightUtc)
                return;

            UpdateXpCap();
        }

        // ── Core computation ─────────────────────────────────────────────────────

        private static void UpdateXpCap()
        {
            try
            {
                var day  = GetCurrentSeasonDay();
                if (day < 0) return;

                var xpCap = ComputeXpCapForDay(day);
                if (xpCap <= 0) return;

                PropertyManager.ModifyLong("rolling_xp_cap", xpCap);
                PropertyManager.ModifyLong("rolling_xp_cap_timestamp", DateTimeOffset.UtcNow.ToUnixTimeSeconds());

                log.Info($"RollingLevelCapManager: rolling_xp_cap = {xpCap:N0} (day {day}, {GetCapDescription(xpCap)}).");

                UpdateXpModifier(day);
            }
            catch (Exception ex)
            {
                log.Error($"RollingLevelCapManager.UpdateXpCap exception: {ex}");
            }
        }

        /// <summary>
        /// Pure computation: the raw XP cap the linear schedule produces for
        /// <paramref name="daysSinceStart"/>. Returns 0 if the dat is unavailable.
        /// </summary>
        public static long ComputeXpCapForDay(int daysSinceStart)
        {
            try
            {
                var xpTable    = DatManager.PortalDat.XpTable.CharacterLevelXPList;
                var maxLevelXp = (long)xpTable[xpTable.Count - 1];

                var startXp = Math.Max(0L, PropertyManager.GetLong("rolling_level_cap_start_xp").Item);
                if (startXp > maxLevelXp) startXp = maxLevelXp;

                var seasonDays = PropertyManager.GetLong("rolling_level_cap_season_days").Item;
                if (seasonDays <= 0) return maxLevelXp;

                if (daysSinceStart >= seasonDays)
                    return maxLevelXp;

                double fraction = Math.Max(0.0, Math.Min(1.0, (double)daysSinceStart / seasonDays));
                return startXp + (long)(fraction * (maxLevelXp - startXp));
            }
            catch { return 0; }
        }

        /// <summary>
        /// Current raw total-XP cap, or 0 when the system is disabled or unconfigured.
        /// Callers treat 0 as "no active cap".
        /// </summary>
        public static long GetCurrentXpCap()
        {
            if (!PropertyManager.GetBool("rolling_level_cap_enabled").Item)
                return 0;

            if (PropertyManager.GetLong("rolling_level_cap_start_timestamp").Item <= 0)
                return 0;

            return PropertyManager.GetLong("rolling_xp_cap").Item;
        }

        /// <summary>Current season day (0-based, UTC); -1 if the season has not started.</summary>
        public static int GetCurrentSeasonDay()
        {
            var startTimestamp = PropertyManager.GetLong("rolling_level_cap_start_timestamp").Item;
            if (startTimestamp <= 0) return -1;
            var startDate = DateTimeOffset.FromUnixTimeSeconds(startTimestamp).UtcDateTime.Date;
            return Math.Max(0, (DateTime.UtcNow.Date - startDate).Days);
        }

        /// <summary>Highest character level whose total-XP requirement is &lt;= <paramref name="xpCap"/>.</summary>
        public static int GetCurrentLevelCap(long xpCap)
        {
            if (xpCap <= 0) return 0;
            try
            {
                var xpTable = DatManager.PortalDat.XpTable.CharacterLevelXPList;
                int impliedLevel = 0;
                for (int lvl = 1; lvl < xpTable.Count; lvl++)
                {
                    if ((long)xpTable[lvl] <= xpCap)
                        impliedLevel = lvl;
                    else
                        break;
                }
                return impliedLevel;
            }
            catch { return 0; }
        }

        /// <summary>Human-readable description of an XP cap for status/messages.</summary>
        public static string GetCapDescription(long xpCap)
        {
            if (xpCap <= 0) return "no cap";
            var level = GetCurrentLevelCap(xpCap);
            return $"level {level} (XP: {xpCap:N0})";
        }

        /// <summary>
        /// Forces an immediate recalculation and persists it. Use after changing
        /// rolling_level_cap_start_timestamp or the schedule configs via admin command.
        /// </summary>
        public static void ForceRecalculate()
        {
            PropertyManager.ModifyLong("rolling_xp_cap_timestamp", 0);
            LastTickDateTime = DateTime.MinValue;
            UpdateXpCap();
        }

        /// <summary>Time until the cap next advances (next UTC midnight); Zero if frozen or not started.</summary>
        public static TimeSpan GetTimeUntilNextCapIncrease()
        {
            int day = GetCurrentSeasonDay();
            if (day < 0) return TimeSpan.Zero;
            var seasonDays = PropertyManager.GetLong("rolling_level_cap_season_days").Item;
            if (seasonDays > 0 && day >= seasonDays) return TimeSpan.Zero;
            return DateTime.UtcNow.Date.AddDays(1) - DateTime.UtcNow;
        }

        // ── Rolling XP modifier ──────────────────────────────────────────────────

        /// <summary>
        /// When rolling_xp_modifier_enabled is true, drives the stock xp_modifier config
        /// along a quadratic season curve: day 0 -> 0.25x, ~36% through -> 1.0x,
        /// 80% through -> rolling_xp_modifier_max, then held at the max.
        /// </summary>
        private static void UpdateXpModifier(int daysSinceStart)
        {
            if (!PropertyManager.GetBool("rolling_xp_modifier_enabled").Item)
                return;

            var seasonDays = (int)PropertyManager.GetLong("rolling_level_cap_season_days").Item;
            var maxModifier = PropertyManager.GetDouble("rolling_xp_modifier_max").Item;
            if (maxModifier <= 0) maxModifier = 3.0;

            var modifier = ComputeRollingXpModifier(daysSinceStart, seasonDays, maxModifier);
            PropertyManager.ModifyDouble("xp_modifier", modifier);

            log.Info($"RollingLevelCapManager: xp_modifier = {modifier:F3} (day {daysSinceStart}, max={maxModifier:F2}).");
        }

        /// <summary>
        /// Quadratic season-rate curve anchored at t=0 -> 0.25, t≈0.364 -> 1.0,
        /// t=0.800 -> <paramref name="maxModifier"/>; clamped to [0.25, maxModifier].
        /// </summary>
        public static double ComputeRollingXpModifier(int daysSinceStart, int seasonEndDay, double maxModifier)
        {
            if (seasonEndDay <= 0)
                return maxModifier;

            double t = Math.Min(1.0, Math.Max(0.0, (double)daysSinceStart / seasonEndDay));

            const double c  = 0.25;
            const double t1 = 100.0 / 275.0;   // ≈ 0.3636
            const double t2 = 220.0 / 275.0;   // = 0.8000
            const double y1 = 1.0;
            double       y2 = maxModifier;

            double r1  = y1 - c;
            double r2  = y2 - c;
            double det = t1 * t1 * t2 - t2 * t2 * t1;   // t1*t2*(t1 - t2), always != 0
            double a   = (r1 * t2 - r2 * t1) / det;
            double b   = (r2 * t1 * t1 - r1 * t2 * t2) / det;

            double raw = a * t * t + b * t + c;
            return Math.Min(maxModifier, Math.Max(0.25, raw));
        }

        // ── Catch-up XP boost ────────────────────────────────────────────────────

        /// <summary>
        /// Catch-up XP multiplier for a character whose lifetime total XP is <paramref name="totalXp"/>.
        /// Returns 1.0 (no boost) when disabled, when no cap is active, or when the character has
        /// reached catchup_xp_threshold of the cap. Ramps linearly from catchup_xp_max_multiplier at
        /// 0% of the threshold band down to catchup_xp_min_multiplier at 100%, then steps to 1.0.
        /// </summary>
        public static double GetCatchUpXpMultiplier(long totalXp)
        {
            if (!PropertyManager.GetBool("catchup_xp_enabled").Item)
                return 1.0;

            var xpCap = GetCurrentXpCap();
            if (xpCap <= 0)
                return 1.0;

            var threshold = Math.Min(1.0, PropertyManager.GetDouble("catchup_xp_threshold").Item);
            if (threshold <= 0.0)
                return 1.0;

            var progress = Math.Max(0.0, (double)totalXp / xpCap);
            if (progress >= threshold)
                return 1.0;

            var maxMultiplier = PropertyManager.GetDouble("catchup_xp_max_multiplier").Item;
            var minMultiplier = PropertyManager.GetDouble("catchup_xp_min_multiplier").Item;

            if (maxMultiplier < minMultiplier)
                (maxMultiplier, minMultiplier) = (minMultiplier, maxMultiplier);

            var bandProgress = progress / threshold;
            var multiplier   = maxMultiplier - bandProgress * (maxMultiplier - minMultiplier);

            return Math.Max(1.0, multiplier);
        }

        /// <summary>Fraction (0.0–1.0+) of the current cap that <paramref name="totalXp"/> represents; -1 if no cap.</summary>
        public static double GetSeasonCapProgress(long totalXp)
        {
            var xpCap = GetCurrentXpCap();
            if (xpCap <= 0) return -1.0;
            return Math.Max(0.0, (double)totalXp / xpCap);
        }
    }
}
