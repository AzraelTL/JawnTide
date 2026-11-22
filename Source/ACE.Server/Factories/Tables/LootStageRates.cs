using ACE.Common;
using ACE.Database.Models.World;
using ACE.Server.Managers;

namespace ACE.Server.Factories.Tables
{
    /// <summary>
    /// JawnTide loot stages: how often the top results of random loot (Epic and Legendary cantrips, equipment sets,
    /// gear ratings) are kept, and how much a loot profile's quality modifier is allowed to help.
    /// </summary>
    public static class LootStageRates
    {
        /// <summary>
        /// loot_quality_edge. Below 0 (the default) loot quality works as in stock ACE: a high enough quality
        /// modifier makes Epics, sets and ratings certain. At 0 or more that is switched off: every profile rolls
        /// them at the plain table chance, and quality instead raises the kept share by (edge x quality).
        /// </summary>
        private static double Edge => PropertyManager.GetDouble("loot_quality_edge").Item;

        /// <summary>
        /// The quality modifier to use for a top-result roll (cantrip level, set, rating, and the number of
        /// cantrips from tier 7): the profile's own, or 0 while loot_quality_edge is on
        /// </summary>
        public static float TopQuality(TreasureDeath profile)
        {
            return Edge >= 0.0 ? 0.0f : profile.LootQualityMod;
        }

        /// <summary>
        /// The final say on a top result that has already been rolled. The named setting is the share that is
        /// kept: 1 keeps them all, 0.2 keeps one in five, 0 keeps none. It applies to every loot profile. While
        /// loot_quality_edge is on, the share is multiplied by (1 + edge x the profile's quality), so better
        /// profiles keep a little more.
        /// </summary>
        public static bool Passes(string setting, TreasureDeath profile)
        {
            var rate = PropertyManager.GetDouble(setting).Item;

            if (rate <= 0.0)
                return false;

            var edge = Edge;
            if (edge > 0.0 && rate < 1.0)
                rate *= 1.0 + edge * profile.LootQualityMod;

            if (rate >= 1.0)
                return true;

            return ThreadSafeRandom.Next(0.0f, 1.0f) < rate;
        }
    }
}
