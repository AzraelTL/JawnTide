using ACE.Entity.Enum;

namespace ACE.Server.Entity
{
    /// <summary>
    /// JawnTide: ported from ClassicPvP's feature/my-mule (Supershoff/ClassicPvP).
    /// Static metadata for the single, unified "My Mule" personal storage vendor. One gem, one
    /// vendor visual (randomized per account, sticky for the account's life), one overflow-chained
    /// pool of storage containers shared account-wide -- see Player_Mule.cs.
    /// </summary>
    public static class MuleInfo
    {
        // JawnTide weenie ids (Content/sql/weenies/My Mule); ClassicPvP used 490400 / 490408 / 490409
        public const uint GemWeenieClassId = 8144001;
        public const uint StorageContainerWeenieClassId = 8144002;
        public const uint VendorWeenieClassId = 8144003;

        /// <summary>JawnTide: the mule heads home if its owner moves farther than this (meters) from it.</summary>
        public const float MaxDistance = 40.0f;

        /// <summary>
        /// Hard ceiling on how many overflow containers a single account's mule chain may grow to
        /// (10 containers x 255 items each = 2550 total item slots), so a pathological deposit loop
        /// can't spin up an unbounded number of biotas.
        /// </summary>
        public const int MaxContainers = 10;

        /// <summary>
        /// Accepted for deposit -- everything except currency and nested containers, which are
        /// blocked unconditionally in HandleMuleDeposit regardless of this mask. Also used as the
        /// vendor's MerchandiseItemTypes so the client's sell panel doesn't hide any category.
        /// </summary>
        public const ItemType AllowedItemTypes =
            ItemType.MeleeWeapon | ItemType.MissileWeapon | ItemType.Caster |
            ItemType.Armor | ItemType.Clothing | ItemType.Jewelry | ItemType.TinkeringMaterial |
            ItemType.Food | ItemType.Gem | ItemType.SpellComponents | ItemType.Key | ItemType.Writable |
            ItemType.ManaStone | ItemType.PromissoryNote | ItemType.LifeStone | ItemType.TinkeringTool |
            ItemType.CraftCookingBase | ItemType.CraftAlchemyBase | ItemType.CraftAlchemyIntermediate |
            ItemType.CraftFletchingBase | ItemType.CraftFletchingIntermediate | ItemType.Gameboard | ItemType.Misc;

        /// <summary>
        /// Item types eligible for the mule's artificial stack-size boost (see
        /// Player_Mule.IsMuleStackBoostable) -- template items with no per-instance random/
        /// generated data. Everything else (weapons/armor/casters/jewelry/clothing, and
        /// naturally-Stackable Salvage) is excluded on purpose: unique loot shouldn't be
        /// mergeable, and Salvage's Workmanship varies per batch so an artificial boost would be
        /// meaningless for it.
        /// </summary>
        public const ItemType BoostableItemTypes =
            ItemType.Food | ItemType.Gem | ItemType.SpellComponents | ItemType.Key | ItemType.Writable |
            ItemType.ManaStone | ItemType.PromissoryNote | ItemType.LifeStone | ItemType.TinkeringTool |
            ItemType.CraftCookingBase | ItemType.CraftAlchemyBase | ItemType.CraftAlchemyIntermediate |
            ItemType.CraftFletchingBase | ItemType.CraftFletchingIntermediate | ItemType.Gameboard | ItemType.Misc;

        /// <summary>
        /// Monouga variants (brutish, cruel, ferocious, merciless, wily), picked for genuinely
        /// distinct palettes/poses. Player_Mule.ApplyMuleVisual copies each chosen source's
        /// Setup/MotionTable/SoundTable/PaletteBase/PaletteTemplate/Shade/ObjScale onto the spawned
        /// vendor shell -- nothing else (combat stats, AI, etc.) is touched.
        /// </summary>
        public static readonly uint[] VisualVariantSourceWcids = { 9251, 24288, 9252, 24291, 9253 };
    }
}
