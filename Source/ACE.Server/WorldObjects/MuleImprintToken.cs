using System.Collections.Generic;

using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Entity.Models;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide: the Mule Imprint Token.
    /// <para/>
    /// Every character that is not a mule can get exactly one, from an Imprinter in Holtburg, Shoushi or Yaraq.
    /// The token is attuned and bonded and can never leave the character (no drop, give, trade, sell, NPC hand-in,
    /// salvage, tinkering, recipes, or death drop).
    /// <para/>
    /// Unbound: using it asks for the name of a level 1 character on the same account. On confirmation that
    /// character is permanently flagged as this character's mule.
    /// Bound: using it summons (or dismisses) the "Ghost of [Mule]", a passive pet that accepts items from
    /// its summoner and places them straight into the offline mule's inventory.
    /// </summary>
    public class MuleImprintToken : WorldObject
    {
        /// <summary>Class id of the Mule Imprint Token</summary>
        public const uint TokenWcid = 8143004;

        /// <summary>Class id of the creature template used for the Ghost of [Mule] pet</summary>
        public const uint GhostWcid = 8143005;

        /// <summary>
        /// The three Imprinter NPCs (Holtburg, Shoushi, Yaraq). They all behave the same way.
        /// The value is the greeting each one opens with.
        /// </summary>
        public static readonly Dictionary<uint, string> ImprinterNpcs = new Dictionary<uint, string>()
        {
            { 8143001, "Well met, friend. Old Holtburg has always looked after its pack-bearers, and I keep the imprint tokens." },  // Aluvian, Holtburg
            { 8143002, "Peace be upon your journey. In Shoushi we say a loyal companion is worth more than jade." },                  // Sho, Shoushi
            { 8143003, "Ahlan, traveller. The caravans of Yaraq would be lost without their faithful beasts of burden." },          // Gharu'ndim, Yaraq
        };

        public static bool IsImprinterNpc(uint wcid) => ImprinterNpcs.ContainsKey(wcid);

        public const string UnboundDescription =
            "A small token humming with spirit magic. Use it to imprint a level 1 character on your account as your mule. " +
            "The imprint is permanent. Once imprinted, using the token calls the Ghost of your mule, which will carry anything you hand it to your mule's pack. " +
            "This token is bound to your soul and can never be given away, sold, dropped or destroyed.";

        public MuleImprintToken(Weenie weenie, ObjectGuid guid) : base(weenie, guid)
        {
            SetEphemeralValues();
        }

        public MuleImprintToken(Biota biota) : base(biota)
        {
            SetEphemeralValues();
        }

        private void SetEphemeralValues()
        {
            EnforcePermanence();
        }

        /// <summary>
        /// Puts back the properties that keep the token on its owner, in case anything (old data, a recipe,
        /// an admin tool) ever stripped them. Runs every time the token is created or loaded.
        /// </summary>
        public void EnforcePermanence()
        {
            if ((Attuned ?? AttunedStatus.Normal) < AttunedStatus.Attuned)
                Attuned = AttunedStatus.Attuned;

            if ((Bonded ?? BondedStatus.Normal) < BondedStatus.Bonded)
                Bonded = BondedStatus.Bonded;

            if (!Retained)
                Retained = true;

            if (IsSellable)
                IsSellable = false;

            if (Inscribable)
                Inscribable = false;
        }

        /// <summary>The character this token was given to</summary>
        public uint? TokenOwner
        {
            get => GetProperty(PropertyInstanceId.MuleImprintOwner);
            set { if (!value.HasValue) RemoveProperty(PropertyInstanceId.MuleImprintOwner); else SetProperty(PropertyInstanceId.MuleImprintOwner, value.Value); }
        }

        /// <summary>The character imprinted as the mule, once bound</summary>
        public uint? BoundMule
        {
            get => GetProperty(PropertyInstanceId.MuleImprintMule);
            set { if (!value.HasValue) RemoveProperty(PropertyInstanceId.MuleImprintMule); else SetProperty(PropertyInstanceId.MuleImprintMule, value.Value); }
        }

        /// <summary>Name of the mule when it was bound (for the description; the live name is looked up by guid)</summary>
        public string BoundMuleName
        {
            get => GetProperty(PropertyString.MuleImprintMuleName);
            set { if (string.IsNullOrEmpty(value)) RemoveProperty(PropertyString.MuleImprintMuleName); else SetProperty(PropertyString.MuleImprintMuleName, value); }
        }

        public bool IsBound => BoundMule.HasValue;

        public void Bind(uint muleGuid, string muleName)
        {
            BoundMule = muleGuid;
            BoundMuleName = muleName;
            UpdateDescription();
        }

        public void ClearBinding()
        {
            BoundMule = null;
            BoundMuleName = null;
            UpdateDescription();
        }

        public void UpdateDescription()
        {
            if (IsBound)
                LongDesc = $"This token carries the imprint of {BoundMuleName}. Use it to call the Ghost of {BoundMuleName}; anything you hand the ghost is carried to {BoundMuleName}'s pack. Use the token again to send the ghost away. " +
                           "This token is bound to your soul and can never be given away, sold, dropped or destroyed.";
            else
                LongDesc = UnboundDescription;
        }

        public override void ActOnUse(WorldObject activator)
        {
            if (activator is not Player player)
                return;

            player.HandleMuleImprintTokenUse(this);
        }

        /// <summary>
        /// True if the object is a Mule Imprint Token, or is a container holding one.
        /// </summary>
        public static bool IsOrContainsToken(WorldObject wo)
        {
            if (wo == null)
                return false;

            if (wo is MuleImprintToken)
                return true;

            if (wo is Container container)
            {
                foreach (var item in container.Inventory.Values)
                {
                    if (IsOrContainsToken(item))
                        return true;
                }
            }

            return false;
        }
    }
}
