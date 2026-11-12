using ACE.Entity.Enum.Properties;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide /muleflag: a character of level 5 or lower can permanently make itself a mule. It gets the extra (8th)
    /// pack slot (the stock AugmentationExtraPackSlot, opened at its next login) and never gains experience again.
    /// </summary>
    partial class Player
    {
        public const int MuleFlagMaxLevel = 5;

        public bool IsMule
        {
            get => GetProperty(PropertyBool.IsMuleCharacter) ?? false;
            set { if (!value) RemoveProperty(PropertyBool.IsMuleCharacter); else SetProperty(PropertyBool.IsMuleCharacter, value); }
        }

        /// <summary>Null if this character can be flagged as a mule, otherwise why not.</summary>
        public string GetMuleFlagError()
        {
            if (IsMule)
                return $"{Name} is already a mule.";

            if ((Level ?? 1) > MuleFlagMaxLevel)
                return $"Only a character of level {MuleFlagMaxLevel} or lower can become a mule. {Name} is level {Level ?? 1}.";

            if (IsTinker)
                return "A Tinker cannot become a mule.";

            if (IsOlthoiPlayer)
                return "The Olthoi cannot become mules.";

            return null;
        }

        public void FlagAsMule()
        {
            IsMule = true;

            // the extra (8th) pack slot; ContainerCapacity is worked out from this at login
            if (AugmentationExtraPackSlot == 0)
                AugmentationExtraPackSlot = 1;

            RushNextPlayerSave(5);

            SendMessage($"{Name} is now a mule. It will never gain experience again, and its extra pack slot opens the next time you log in on it.");

            log.Info($"[MULE] {Name} (0x{Guid}) flagged itself as a mule with /muleflag");
        }
    }
}
