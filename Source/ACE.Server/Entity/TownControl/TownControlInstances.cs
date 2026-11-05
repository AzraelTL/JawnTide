using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;

using ACE.Database.Models.TownControl;
using ACE.Server.Managers;

namespace ACE.Server.Entity.TownControl
{
    /// <summary>
    /// JawnTide instancing for Town Control.
    ///
    /// The governor fights that start an event stay in the towns. The conflict areas behind the crystal portals
    /// (Holtburg 4FF1, Yaraq 00AB, Shoushi E9F0/E9F1/E8F1) run in a private copy per event: anyone teleporting into a
    /// conflict area while that town's event is active goes into the event's copy. That copy has the Town Control
    /// content (crystal generator, gates and walls that keep people in the area). Outside an event, and for anyone
    /// who walks in, the conflict area is the normal world with its stock content back.
    /// </summary>
    public static class TownControlInstances
    {
        /// <summary>
        /// landblock_instance.variation_id of the Town Control conflict area content
        /// </summary>
        public const int Content = 2;

        /// <summary>
        /// TC event id -> the instance it runs in
        /// </summary>
        private static readonly ConcurrentDictionary<uint, int> variationByEvent = new ConcurrentDictionary<uint, int>();

        /// <summary>
        /// instance -> town id
        /// </summary>
        private static readonly ConcurrentDictionary<int, uint> townByVariation = new ConcurrentDictionary<int, uint>();

        private static HashSet<uint> _conflictLandblocks;

        private static HashSet<uint> ConflictLandblocks
        {
            get
            {
                if (_conflictLandblocks == null)
                    _conflictLandblocks = new HashSet<uint>(TownControlLandblocks.TownControlRewardLandblocksMap.Values.SelectMany(i => i));

                return _conflictLandblocks;
            }
        }

        private static DateTime nextTick = DateTime.MinValue;

        /// <summary>
        /// How long players get to leave an event's copy after the event ends, before they're sent to their lifestone
        /// </summary>
        public static readonly TimeSpan EventOverGrace = TimeSpan.FromMinutes(2);

        /// <summary>
        /// instance -> when its event was first seen to be over (the same clock for every landblock of the copy)
        /// </summary>
        private static readonly ConcurrentDictionary<int, DateTime> eventOverTimes = new ConcurrentDictionary<int, DateTime>();

        public static DateTime GetEventOverTime(int variation)
        {
            return eventOverTimes.GetOrAdd(variation, _ => DateTime.UtcNow);
        }

        /// <summary>
        /// Called from the world tick. While a town's event runs, its conflict area copy is kept loaded
        /// (like the old keep-alive objects did), so the crystal spawns and the event can end on time even before anyone enters.
        /// </summary>
        public static void Tick()
        {
            if (DateTime.UtcNow < nextTick)
                return;

            nextTick = DateTime.UtcNow.AddSeconds(10);

            foreach (var kvp in TownControlLandblocks.TownControlRewardLandblocksMap)
            {
                var variation = GetActiveVariation(kvp.Key);
                if (!variation.HasValue)
                    continue;

                foreach (var landblock in kvp.Value)
                    LandblockManager.GetLandblock(new ACE.Entity.LandblockId(landblock << 16), variation, false);
            }
        }

        /// <summary>
        /// Is this landblock one of the conflict areas (any copy)?
        /// </summary>
        public static bool IsConflictLandblock(uint landblock)
        {
            return ConflictLandblocks.Contains(landblock);
        }

        private static uint? GetTownIdForConflictLandblock(uint landblock)
        {
            foreach (var kvp in TownControlLandblocks.TownControlRewardLandblocksMap)
            {
                if (kvp.Value.Contains(landblock))
                    return kvp.Key;
            }
            return null;
        }

        /// <summary>
        /// The town's running event, or null
        /// </summary>
        public static TownControlEvent GetActiveEvent(uint townId)
        {
            var ev = TownControl.GetLatestTownControlEventByTownId(townId);

            if (ev == null || ev.EventEndDateTime.HasValue)
                return null;

            return ev;
        }

        /// <summary>
        /// The instance of this town's running event (made the first time someone needs it), or null when there's no event
        /// </summary>
        public static int? GetActiveVariation(uint townId)
        {
            var ev = GetActiveEvent(townId);
            if (ev == null)
                return null;

            var town = TownControl.GetTownById(townId);

            var variation = variationByEvent.GetOrAdd(ev.EventId, _ => InstanceManager.CreateInstance(Content, $"{town?.TownName ?? townId.ToString()} town control event {ev.EventId}"));
            townByVariation[variation] = townId;

            return variation;
        }

        /// <summary>
        /// The instance a teleport into this conflict landblock should use right now (null = normal world)
        /// </summary>
        public static int? GetActiveVariationForLandblock(uint landblock)
        {
            var townId = GetTownIdForConflictLandblock(landblock);
            if (!townId.HasValue)
                return null;

            return GetActiveVariation(townId.Value);
        }

        /// <summary>
        /// Is this instance a Town Control event copy (running or finished)?
        /// </summary>
        public static bool IsTownControlVariation(int variation)
        {
            return townByVariation.ContainsKey(variation);
        }

        /// <summary>
        /// Is this instance the copy of an event that's still running?
        /// </summary>
        public static bool IsActiveTownControlVariation(int variation)
        {
            if (!townByVariation.TryGetValue(variation, out var townId))
                return false;

            var ev = GetActiveEvent(townId);

            return ev != null && variationByEvent.TryGetValue(ev.EventId, out var active) && active == variation;
        }

        /// <summary>
        /// Is this position inside a running Town Control event's conflict area?
        /// </summary>
        public static bool IsInActiveConflictArea(ACE.Entity.Position pos)
        {
            return pos != null && pos.Variation.HasValue && IsConflictLandblock(pos.Landblock) && IsActiveTownControlVariation(pos.Variation.Value);
        }

        /// <summary>
        /// Town Control rules apply here: the towns themselves (normal world) or a running event's conflict area copy
        /// </summary>
        public static bool IsTownControlLocation(ACE.Entity.Position pos)
        {
            if (pos == null)
                return false;

            if (IsConflictLandblock(pos.Landblock))
                return IsInActiveConflictArea(pos);

            return !pos.Variation.HasValue && TownControlLandblocks.IsTownControlLandblock(pos.Landblock);
        }
    }
}
