using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACE.Database.Models.Log
{
    /// <summary>
    /// One row per (milestone x category x rank) entry in a weekly top-10 snapshot.
    /// Tracks whether the player has claimed the reward bundle for that finish.
    /// </summary>
    public partial class SeasonMilestoneLeader
    {
        public uint      Id              { get; set; }
        public uint      MilestoneId     { get; set; }

        /// <summary>Denormalised from SeasonMilestone for easier queries.</summary>
        public int       WeekNumber      { get; set; }

        /// <summary>Category key, e.g. "1v1", "pk-kills", "kd".</summary>
        public string    Category        { get; set; }

        /// <summary>Leaderboard rank at snapshot time (1-10).</summary>
        public int       Rank            { get; set; }

        public uint      CharacterId     { get; set; }
        public string    CharacterName   { get; set; }

        /// <summary>Raw numeric score for this category at snapshot time (K/D is ratio x 1000).</summary>
        public long      Score           { get; set; }

        public bool      RewardClaimed   { get; set; }
        public DateTime? ClaimedDatetime { get; set; }

        [NotMapped]
        public string RankDisplay => Rank switch
        {
            1 => "1st",
            2 => "2nd",
            3 => "3rd",
            _ => $"{Rank}th"
        };
    }
}
