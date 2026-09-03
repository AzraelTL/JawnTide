using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using ACE.Database;
using ACE.Database.Models.Log;
using ACE.Entity.Enum;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.Network.Handlers;

namespace ACE.Server.Managers
{
    /// <summary>
    /// Season leaderboard + Season Champion.
    ///
    /// Two kinds of category:
    ///   - Arena (1v1, 2v2, ffa, tugak, group, arena-wins, arena-matches): a single season-cumulative
    ///     leaderboard read from arena_character_stats. At each weekly milestone the current standings
    ///     are snapshotted and the top 10 earn Season Champion points from that snapshot.
    ///   - Non-arena (pk-kills, kd, streak, bounty): a WEEKLY leaderboard (resets each week) and a
    ///     SEASON leaderboard (display only). Champion points are earned only from the weekly board.
    ///
    /// Season Champion = cumulative sum, across all milestones, of weighted placement points:
    ///   placement(rank) x categoryWeight, placement = rank 1/2/3/4-10 => 100/50/25/5.
    ///
    /// Week boundary: Sunday 00:00 UTC. Milestone Tick fires on Sunday, at most once per day.
    /// The season start day comes from RollingLevelCapManager (rolling_level_cap_start_timestamp).
    /// </summary>
    public static class SeasonLeaderboardManager
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private static DateTime _lastTick = DateTime.MinValue;

        // ── Categories ───────────────────────────────────────────────────────────

        public const string Cat_1v1          = "1v1";
        public const string Cat_2v2          = "2v2";
        public const string Cat_Ffa          = "ffa";
        public const string Cat_Tugak        = "tugak";
        public const string Cat_Group        = "group";
        public const string Cat_ArenaWins    = "arena-wins";
        public const string Cat_ArenaMatches = "arena-matches";
        public const string Cat_PkKills      = "pk-kills";
        public const string Cat_Kd           = "kd";
        public const string Cat_Streak       = "streak";
        public const string Cat_Bounty       = "bounty";

        public static readonly string[] ArenaCategories =
            { Cat_1v1, Cat_2v2, Cat_Ffa, Cat_Tugak, Cat_Group, Cat_ArenaWins, Cat_ArenaMatches };

        public static readonly string[] NonArenaCategories =
            { Cat_PkKills, Cat_Kd, Cat_Streak, Cat_Bounty };

        public static readonly string[] AllCategories =
            ArenaCategories.Concat(NonArenaCategories).ToArray();

        /// <summary>Per-category Season Champion weight (config-tunable via season_weight_&lt;category&gt;).</summary>
        private static readonly Dictionary<string, double> DefaultWeights = new()
        {
            [Cat_PkKills]      = 2.5,
            [Cat_ArenaWins]    = 2.0,
            [Cat_Streak]       = 1.75,
            [Cat_Bounty]       = 1.25,
            [Cat_Kd]           = 0.75,
            [Cat_1v1]          = 1.0,
            [Cat_2v2]          = 1.0,
            [Cat_Group]        = 1.0,
            [Cat_Ffa]          = 0.5,
            [Cat_Tugak]        = 0.5,
            [Cat_ArenaMatches] = 0.5,
        };

        public static double GetWeight(string category)
            => DefaultWeights.TryGetValue(category, out var w) ? w : 1.0;

        /// <summary>Weighted placement points a given rank earns toward Season Champion for a category.</summary>
        public static long GetChampionPoints(string category, int rank)
        {
            var placement = rank switch { 1 => 100, 2 => 50, 3 => 25, <= 10 => 5, _ => 0 };
            return (long)Math.Round(placement * GetWeight(category));
        }

        public static string GetCategoryDisplayName(string category) => category switch
        {
            Cat_1v1          => "1v1 Arena",
            Cat_2v2          => "2v2 Arena",
            Cat_Ffa          => "FFA Arena",
            Cat_Tugak        => "Tugak Arena",
            Cat_Group        => "Group Arena",
            Cat_ArenaWins    => "Arena Wins",
            Cat_ArenaMatches => "Arena Matches",
            Cat_PkKills      => "PK Kills",
            Cat_Kd           => "K/D Ratio",
            Cat_Streak       => "Kill Streak",
            Cat_Bounty       => "Bounty Hunter",
            _                => category
        };

        public static string ResolveAlias(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            return input.ToLowerInvariant().Replace(" ", "-") switch
            {
                "1v1" => Cat_1v1,
                "2v2" => Cat_2v2,
                "ffa" => Cat_Ffa,
                "tugak" => Cat_Tugak,
                "group" => Cat_Group,
                "arena-wins" or "wins" => Cat_ArenaWins,
                "arena-matches" or "matches" or "veteran" => Cat_ArenaMatches,
                "pk-kills" or "kills" or "reaper" => Cat_PkKills,
                "kd" or "k/d" or "ratio" => Cat_Kd,
                "streak" or "killstreak" => Cat_Streak,
                "bounty" or "bountyhunter" => Cat_Bounty,
                _ => null
            };
        }

        // ── Week math ────────────────────────────────────────────────────────────

        /// <summary>Season start (UTC date), or DateTime.MinValue if the season has not started.</summary>
        public static DateTime GetSeasonStartDateUtc()
        {
            var ts = PropertyManager.GetLong("rolling_level_cap_start_timestamp").Item;
            if (ts <= 0) return DateTime.MinValue;
            return DateTimeOffset.FromUnixTimeSeconds(ts).UtcDateTime.Date;
        }

        /// <summary>Most recent Sunday 00:00 UTC at or before <paramref name="whenUtc"/>.</summary>
        public static DateTime GetWeekStartUtc(DateTime whenUtc)
        {
            var d = whenUtc.Date;
            int daysSinceSunday = (int)d.DayOfWeek; // Sunday = 0
            return d.AddDays(-daysSinceSunday);
        }

        /// <summary>1-based week number of the season for <paramref name="whenUtc"/> (0 before start).</summary>
        public static int GetSeasonWeekNumber(DateTime whenUtc)
        {
            var start = GetSeasonStartDateUtc();
            if (start == DateTime.MinValue || whenUtc.Date < start) return 0;
            var firstWeekStart = GetWeekStartUtc(start);
            return (int)((GetWeekStartUtc(whenUtc) - firstWeekStart).TotalDays / 7) + 1;
        }

        // ── Ranking ──────────────────────────────────────────────────────────────

        public class LeaderRow
        {
            public int Rank;
            public uint CharacterId;
            public string CharacterName;
            public long Score;         // raw score (K/D is ratio * 1000)
            public string ScoreDisplay;
        }

        /// <summary>
        /// Top <paramref name="count"/> for a category. <paramref name="weekly"/> only affects the
        /// non-arena categories (arena categories are always season-cumulative).
        /// </summary>
        public static List<LeaderRow> GetTop(string category, bool weekly, int count = 10)
        {
            try
            {
                if (ArenaCategories.Contains(category))
                    return RankArena(category, count);

                var windowStart = weekly ? GetWeekStartUtc(DateTime.UtcNow) : GetSeasonStartDateUtc();
                if (windowStart == DateTime.MinValue) return new List<LeaderRow>();
                return RankNonArena(category, windowStart, DateTime.UtcNow, count);
            }
            catch (Exception ex)
            {
                log.Error($"SeasonLeaderboardManager.GetTop({category}) exception: {ex}");
                return new List<LeaderRow>();
            }
        }

        private static List<LeaderRow> RankArena(string category, int count)
        {
            var stats = DatabaseManager.Log.GetAllArenaCharacterStats();
            IEnumerable<(uint id, string name, long score, string disp)> ranked;

            if (category == Cat_ArenaWins)
                ranked = stats.GroupBy(s => s.CharacterId)
                    .Select(g => (g.Key, g.First().CharacterName, (long)g.Sum(x => x.TotalWins), $"{g.Sum(x => x.TotalWins)} wins"));
            else if (category == Cat_ArenaMatches)
                ranked = stats.GroupBy(s => s.CharacterId)
                    .Select(g => (g.Key, g.First().CharacterName, (long)g.Sum(x => x.TotalMatches), $"{g.Sum(x => x.TotalMatches)} matches"));
            else
            {
                var evt = category switch
                {
                    Cat_1v1 => "1v1", Cat_2v2 => "2v2", Cat_Ffa => "FFA", Cat_Tugak => "Tugak", Cat_Group => "Group", _ => null
                };
                ranked = stats.Where(s => string.Equals(s.EventType, evt, StringComparison.OrdinalIgnoreCase))
                    .Select(s => (s.CharacterId, s.CharacterName, (long)s.RankPoints, $"{s.RankPoints} pts ({s.TotalWins}-{s.TotalLosses})"));
            }

            return ranked.OrderByDescending(r => r.Item3).Take(count)
                .Select((r, i) => new LeaderRow { Rank = i + 1, CharacterId = r.Item1, CharacterName = r.Item2, Score = r.Item3, ScoreDisplay = r.Item4 })
                .ToList();
        }

        private static List<LeaderRow> RankNonArena(string category, DateTime startUtc, DateTime endUtc, int count)
        {
            var kills = DatabaseManager.Log.GetOpenWorldPkKillsInWindow(startUtc, endUtc);

            if (category == Cat_PkKills)
            {
                return kills.GroupBy(k => k.KillerId)
                    .Select(g => new { g.Key, Count = g.Count(), Name = ResolveName(g.Key) })
                    .OrderByDescending(x => x.Count).Take(count)
                    .Select((x, i) => new LeaderRow { Rank = i + 1, CharacterId = x.Key, CharacterName = x.Name, Score = x.Count, ScoreDisplay = $"{x.Count} kills" })
                    .ToList();
            }

            if (category == Cat_Kd)
            {
                var minKills = (int)PropertyManager.GetLong("season_kd_min_kills").Item;
                var byChar = new Dictionary<uint, (int k, int d)>();
                foreach (var k in kills)
                {
                    var kv = byChar.GetValueOrDefault(k.KillerId); byChar[k.KillerId] = (kv.k + 1, kv.d);
                    var vv = byChar.GetValueOrDefault(k.VictimId); byChar[k.VictimId] = (vv.k, vv.d + 1);
                }
                return byChar.Where(p => p.Value.k >= minKills)
                    .Select(p => new { p.Key, Ratio = p.Value.d > 0 ? (double)p.Value.k / p.Value.d : p.Value.k, p.Value.k, p.Value.d })
                    .OrderByDescending(x => x.Ratio).Take(count)
                    .Select((x, i) => new LeaderRow { Rank = i + 1, CharacterId = x.Key, CharacterName = ResolveName(x.Key), Score = (long)Math.Round(x.Ratio * 1000), ScoreDisplay = $"{x.Ratio:F2} ({x.k}/{x.d})" })
                    .ToList();
            }

            if (category == Cat_Streak)
            {
                // Derive the best streak in the window per player by replaying their kill/death events.
                var events = new Dictionary<uint, List<(DateTime t, bool isKill)>>();
                void Add(uint id, DateTime t, bool isKill)
                {
                    if (!events.TryGetValue(id, out var list)) { list = new(); events[id] = list; }
                    list.Add((t, isKill));
                }
                foreach (var k in kills)
                {
                    Add(k.KillerId, k.KillDateTime, true);
                    Add(k.VictimId, k.KillDateTime, false);
                }
                var best = new List<(uint id, int streak)>();
                foreach (var (id, evs) in events)
                {
                    int cur = 0, max = 0;
                    foreach (var e in evs.OrderBy(e => e.t))
                    {
                        if (e.isKill) { cur++; if (cur > max) max = cur; }
                        else cur = 0;
                    }
                    if (max > 0) best.Add((id, max));
                }
                return best.OrderByDescending(b => b.streak).Take(count)
                    .Select((b, i) => new LeaderRow { Rank = i + 1, CharacterId = b.id, CharacterName = ResolveName(b.id), Score = b.streak, ScoreDisplay = $"{b.streak} streak" })
                    .ToList();
            }

            // Cat_Bounty: not yet wired (needs a timestamped bounty-completion source). Returns empty.
            return new List<LeaderRow>();
        }

        private static string ResolveName(uint characterId)
        {
            var offline = PlayerManager.GetOfflinePlayer(characterId);
            return offline?.Name ?? PlayerManager.GetOnlinePlayer(characterId)?.Name ?? $"#{characterId}";
        }

        // ── Season Champion ──────────────────────────────────────────────────────

        public static List<SeasonChampionPoints> GetChampionLeaderboard(int count = 10)
            => DatabaseManager.Log.GetSeasonChampionLeaderboard(count);

        public static long GetChampionPointsFor(uint characterId)
            => DatabaseManager.Log.GetSeasonChampionPoints(characterId);

        // ── Weekly milestone ─────────────────────────────────────────────────────

        public static void Tick()
        {
            if (DateTime.Now < _lastTick.AddMinutes(1)) return;
            _lastTick = DateTime.Now;

            if (!PropertyManager.GetBool("season_leaderboard_enabled").Item) return;
            if (GetSeasonStartDateUtc() == DateTime.MinValue) return;

            // Fire on Sunday UTC, at most once per day, and only once per week number.
            if (DateTime.UtcNow.DayOfWeek != DayOfWeek.Sunday) return;

            var lastMilestone = DatabaseManager.Log.GetLatestSeasonMilestone();
            var thisWeek = GetSeasonWeekNumber(DateTime.UtcNow);
            if (thisWeek <= 0) return;
            if (lastMilestone != null && lastMilestone.WeekNumber >= thisWeek) return;
            if (lastMilestone != null && lastMilestone.SnapshotDatetime.Date == DateTime.UtcNow.Date) return;

            FireWeeklyMilestone(thisWeek);
        }

        /// <summary>Admin-forced milestone (via command), independent of the Sunday gate.</summary>
        public static void ForceMilestone()
        {
            var week = Math.Max(1, GetSeasonWeekNumber(DateTime.UtcNow));
            var last = DatabaseManager.Log.GetLatestSeasonMilestone();
            if (last != null && last.WeekNumber >= week) week = last.WeekNumber + 1;
            FireWeeklyMilestone(week);
        }

        private static void FireWeeklyMilestone(int weekNumber)
        {
            log.Info($"[Season] Firing week {weekNumber} milestone snapshot.");

            var milestoneId = DatabaseManager.Log.CaptureSeasonMilestone(weekNumber);
            if (milestoneId == 0)
            {
                log.Error("[Season] CaptureSeasonMilestone returned 0 - milestone NOT recorded.");
                return;
            }

            var leaders = new List<SeasonMilestoneLeader>();

            foreach (var category in AllCategories)
            {
                // Arena categories snapshot the season-cumulative board; non-arena use the WEEKLY board.
                bool weekly = NonArenaCategories.Contains(category);
                var top = GetTop(category, weekly, 10);

                foreach (var row in top)
                {
                    leaders.Add(new SeasonMilestoneLeader
                    {
                        MilestoneId = milestoneId,
                        WeekNumber = weekNumber,
                        Category = category,
                        Rank = row.Rank,
                        CharacterId = row.CharacterId,
                        CharacterName = row.CharacterName,
                        Score = row.Score,
                        RewardClaimed = false
                    });

                    var champPts = GetChampionPoints(category, row.Rank);
                    if (champPts > 0)
                        DatabaseManager.Log.AddSeasonChampionPoints(row.CharacterId, row.CharacterName, champPts);
                }
            }

            DatabaseManager.Log.SaveSeasonMilestoneLeaders(leaders);

            var champLeader = GetChampionLeaderboard(1).FirstOrDefault();
            var champNote = champLeader != null ? $" Current Season Champion: {champLeader.CharacterName} ({champLeader.Points:N0} pts)." : "";
            PlayerManager.BroadcastToAll(new GameMessageSystemChat(
                $"Season Week {weekNumber} leaderboards have been recorded.{champNote} Claim any rewards with /season rewards.",
                ChatMessageType.WorldBroadcast));

            PostDiscordMilestone(weekNumber, leaders, champLeader);

            log.Info($"[Season] Week {weekNumber} milestone recorded: {leaders.Count} leader rows.");
        }

        private static void PostDiscordMilestone(int weekNumber, List<SeasonMilestoneLeader> leaders, SeasonChampionPoints champLeader)
        {
            var webhook = PropertyManager.GetString("season_leaderboard_webhook").Item;
            if (string.IsNullOrWhiteSpace(webhook)) return;

            var sb = new StringBuilder();
            sb.AppendLine($"**Season Week {weekNumber} Leaderboards**");
            if (champLeader != null)
                sb.AppendLine($"Season Champion so far: **{champLeader.CharacterName}** ({champLeader.Points:N0} pts)");
            sb.AppendLine();

            foreach (var category in AllCategories)
            {
                var rows = leaders.Where(l => l.Category == category).OrderBy(l => l.Rank).ToList();
                if (rows.Count == 0) continue;
                sb.AppendLine($"__{GetCategoryDisplayName(category)}__");
                foreach (var r in rows.Take(10))
                    sb.AppendLine($"  {r.Rank}. {r.CharacterName}");
                sb.AppendLine();
            }

            try { _ = TurbineChatHandler.SendWebhookedChat("Season", sb.ToString(), webhook, "Global"); }
            catch (Exception ex) { log.Error($"[Season] Discord milestone post failed: {ex}"); }
        }
    }
}
