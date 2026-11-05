using System.Collections.Concurrent;
using System.Threading;

using log4net;

namespace ACE.Server.Managers
{
    /// <summary>
    /// JawnTide instancing.
    ///
    /// A landblock can exist many times at once: the normal world (variation null) plus any number of
    /// private copies, each with its own variation id. Copies are isolated: they have their own objects,
    /// their own physics cells, and players in one copy never see, hit or collide with players in another.
    ///
    /// Each copy loads a "content variation": exactly the landblock_instance rows with that variation_id
    /// (a landblock with none of those rows gives an empty copy).
    ///
    /// Copies unload like any other landblock (5 minutes after the last player leaves).
    /// When a copy unloads, player corpses and dropped items in it move to the normal world.
    /// </summary>
    public static class InstanceManager
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// Content variation ids used by JawnTide (landblock_instance.variation_id)
        /// </summary>
        public const int ArenaContent = 1;

        // 2 = Town Control conflict areas (TownControlInstances.Content)

        /// <summary>
        /// Dynamically created copies start at this id. Ids below it are fixed content variations.
        /// </summary>
        public const int FirstDynamicVariation = 100000;

        private static int nextVariation = FirstDynamicVariation;

        /// <summary>
        /// variation id -> content variation id, for dynamically created copies
        /// </summary>
        private static readonly ConcurrentDictionary<int, int> contentByVariation = new ConcurrentDictionary<int, int>();

        /// <summary>
        /// variation id -> what it's for (shown in logs and admin commands)
        /// </summary>
        private static readonly ConcurrentDictionary<int, string> descriptionByVariation = new ConcurrentDictionary<int, string>();

        /// <summary>
        /// Reserves a new, never used before, variation id. Nothing loads until something is placed in it.
        /// </summary>
        public static int CreateInstance(int contentVariation, string description)
        {
            var variation = Interlocked.Increment(ref nextVariation);

            contentByVariation[variation] = contentVariation;
            descriptionByVariation[variation] = description;

            log.Info($"[INSTANCE] Created instance {variation} (content {contentVariation}) for {description}");

            return variation;
        }

        /// <summary>
        /// Which landblock_instance.variation_id rows a copy loads
        /// </summary>
        public static int GetContentVariation(int variation)
        {
            if (contentByVariation.TryGetValue(variation, out var content))
                return content;

            return variation;
        }

        public static string GetDescription(int? variation)
        {
            if (!variation.HasValue)
                return "normal world";

            if (descriptionByVariation.TryGetValue(variation.Value, out var description))
                return $"instance {variation.Value} ({description})";

            return $"instance {variation.Value}";
        }
    }
}
