using System;

namespace ACE.Database.Models.Log
{
    /// <summary>
    /// One row per weekly milestone snapshot taken by SeasonLeaderboardManager (Sunday 00:00 UTC).
    /// </summary>
    public partial class SeasonMilestone
    {
        public uint     Id               { get; set; }
        public int      WeekNumber       { get; set; }
        public DateTime SnapshotDatetime { get; set; }
    }
}
