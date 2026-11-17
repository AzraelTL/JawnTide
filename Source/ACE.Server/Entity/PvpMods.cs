using ACE.Server.Managers;
using ACE.Server.WorldObjects;

namespace ACE.Server.Entity
{
    /// <summary>
    /// JawnTide: the PvP damage settings, with their arena versions. Inside an arena (any arena match) each pvp_ setting is
    /// read from arena_pvp_... instead, unless that is below 0 (the default -1), which means "same as outside".
    /// arena_1v1_global_dmg_mod still applies on top in 1v1 matches.
    /// </summary>
    public static class PvpMods
    {
        /// <summary>True when the one being hit stands in an arena match (the arena rules decide by the defender's location).</summary>
        public static bool InArena(WorldObject defender) => defender?.Location != null && ArenaLocation.IsArenaLocation(defender.Location);

        public static double Get(string key, bool arena, double fallback = 0.0)
        {
            if (arena)
            {
                var a = PropertyManager.GetDouble("arena_" + key, -1.0).Item;
                if (a >= 0)
                    return a;
            }
            return PropertyManager.GetDouble(key, fallback).Item;
        }

        public static long DamageCap(bool arena)
        {
            if (arena)
            {
                var a = PropertyManager.GetLong("arena_pvp_damage_cap", -1).Item;
                if (a >= 0)
                    return a;
            }
            return PropertyManager.GetLong("pvp_damage_cap").Item;
        }
    }
}
