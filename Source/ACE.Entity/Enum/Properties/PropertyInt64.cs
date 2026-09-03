using System.ComponentModel;

namespace ACE.Entity.Enum.Properties
{
    // No properties are sent to the client unless they featured an attribute.
    // SendOnLogin gets sent to players in the PlayerDescription event
    // AssessmentProperty gets sent in successful appraisal
    public enum PropertyInt64 : ushort
    {
        Undef                 = 0,
        [SendOnLogin]
        TotalExperience       = 1,
        [SendOnLogin]
        AvailableExperience   = 2,
        [AssessmentProperty]
        AugmentationCost      = 3,
        [AssessmentProperty]
        ItemTotalXp           = 4,
        [AssessmentProperty]
        ItemBaseXp            = 5,
        [SendOnLogin]
        AvailableLuminance    = 6,
        [SendOnLogin]
        MaximumLuminance      = 7,
        InteractionReqs       = 8,

        /* Custom Properties */
        AllegianceXPCached    = 9000,
        AllegianceXPGenerated = 9001,
        AllegianceXPReceived  = 9002,
        VerifyXp              = 9003,

        // Season rolling XP cap: per-category XP earned in the current cap window,
        // the per-category daily budgets, and the cap value the buckets were last reset against.
        CapMonsterXp          = 9004,
        CapQuestXp            = 9005,
        CapPvpXp              = 9006,
        CapDailyMaxMonsterCat = 9007,
        CapDailyMaxQuestCat   = 9008,
        CapDailyMaxPvpCat     = 9009,
        CapPreviousXpCap      = 9010,
    }
}
