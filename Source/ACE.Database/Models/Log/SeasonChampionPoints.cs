namespace ACE.Database.Models.Log
{
    /// <summary>
    /// Cumulative Season Champion points for a character. Points are added at each weekly milestone
    /// from the player's finish in every category leaderboard (weighted placement points). The
    /// Season Champion is whoever holds the most points at season end.
    /// </summary>
    public partial class SeasonChampionPoints
    {
        public uint   Id            { get; set; }
        public uint   CharacterId   { get; set; }
        public string CharacterName { get; set; }
        public long   Points        { get; set; }
    }
}
