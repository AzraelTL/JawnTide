using System.Collections.Generic;

using ACE.Entity;

namespace ACE.Server.Entity.T9
{
    /// <summary>
    /// JawnTide instancing for the T9 dungeons.
    ///
    /// The T9 dungeons reuse five lower level dungeons: Black Spawn Den (0105), Lost City of Frore (0138),
    /// Golem Burial Ground (01B4), Halls of Metos (02F5) and the Mountain Citadel (6147). The T9 version of each
    /// runs in one shared instance copy (variation 5), reached only through the T9 hub portals (and the Mountain
    /// Citadel NPC), which carry PropertyInt.TeleportVariation = 5. The normal world copy of each dungeon has its
    /// stock content and stock portals back.
    ///
    /// Logging out inside a T9 copy puts you back in it on login (the Mountain Citadel is no-log: lifestone).
    /// </summary>
    public static class T9Dungeons
    {
        /// <summary>
        /// landblock_instance.variation_id of the T9 dungeon content, and the shared copy it runs in
        /// </summary>
        public const int Variation = 5;

        public static readonly HashSet<ushort> Landblocks = new HashSet<ushort>() { 0x0105, 0x0138, 0x01B4, 0x02F5, 0x6147 };

        public const ushort MountainCitadel = 0x6147;

        public static bool IsT9Landblock(uint landblock) => landblock <= 0xFFFF && Landblocks.Contains((ushort)landblock);

        /// <summary>
        /// True when the position is inside the T9 copy of a T9 dungeon
        /// </summary>
        public static bool IsInT9(Position position) => position != null && position.Variation == Variation && IsT9Landblock(position.Landblock);
    }
}
