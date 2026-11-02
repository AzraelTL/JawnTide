-- JawnTide: ported from ClassicPvP feature/my-mule (Supershoff/ClassicPvP), weenie ids moved from 490400/490408/490409 to 8144001-8144003.
-- Shared Vendor weenie used as the ephemeral "My Mule" NPC shell. A fresh instance of this
-- is spawned next to the player on summon (see Player_Mule.SpawnMuleVendor) and destroyed
-- when they leave the landblock or log out -- it never persists. Its displayed inventory is
-- populated at spawn time from the account's real persistent storage container chain (wcid
-- 8144002, shared account-wide across every character), not from a create_list, so this weenie
-- intentionally has none.
--
-- Cloned from an existing working vendor (blacksmith-sho, wcid 402) so it starts from a
-- known-good baseline (valid model/animations/combat-stat floats), then overridden:
--   * Tier is forced to 0. Vendor.ApproachVendor() unconditionally calls RestockRandomItems()
--     under the CustomDM ruleset, which -- if Tier ends up non-zero (its fallback path derives
--     one from nearby objects when unset) -- would start generating and adding real random
--     loot into UniqueItemsForSale on every approach. Tier=0 makes RestockRandomItems() return
--     immediately, so the mule's item list is never anything but the player's own stored items.
--   * VendorStockTimeToRot is forced to a ~20 year window. Vendor.ApproachVendor() also
--     unconditionally calls RotUniques() on every approach, which normally expires unique
--     items after a short time; My Mule sets SoldTimestamp on deposited items (to avoid a
--     harmless but noisy "no SoldTimestamp" log warning on every approach) so this window
--     needs to be effectively permanent instead of the ~5 minute default.
--   * MerchandiseItemTypes/MerchandiseMinValue/MerchandiseMaxValue/BuyPrice/SellPrice are
--     reset to neutral placeholders -- MerchandiseItemTypes is overridden per-instance at
--     spawn time to MuleInfo.AllowedItemTypes, and the price fields are otherwise unused since
--     the mule buy/sell path never calls GetSellCost/GetBuyCost. They only need to be non-null
--     to satisfy Vendor.ValidateVendorRequirements().

DELETE FROM `weenie` WHERE `class_Id` = 8144003;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8144003, 'ace8144003-mulevendor', 12, '2026-08-11 00:00:00') /* Vendor */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
SELECT 8144003, `type`, `value` FROM `weenie_properties_int` WHERE `object_Id` = 402;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
SELECT 8144003, `type`, `value` FROM `weenie_properties_float` WHERE `object_Id` = 402;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
SELECT 8144003, `type`, `value` FROM `weenie_properties_bool` WHERE `object_Id` = 402;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
SELECT 8144003, `type`, `value` FROM `weenie_properties_d_i_d` WHERE `object_Id` = 402;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8144003, 1, 'My Mule')  /* Name -- always overridden at spawn time in C# */
     , (8144003, 5, 'Mule');    /* Title */

UPDATE `weenie_properties_int` SET `value` = 0          WHERE `object_Id` = 8144003 AND `type` = 74; /* MerchandiseItemTypes -- overridden per-instance at spawn */
UPDATE `weenie_properties_int` SET `value` = 0          WHERE `object_Id` = 8144003 AND `type` = 75; /* MerchandiseMinValue */
UPDATE `weenie_properties_int` SET `value` = 2000000000 WHERE `object_Id` = 8144003 AND `type` = 76; /* MerchandiseMaxValue */

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8144003, 10009, 0) /* Tier -- forces RestockRandomItems() to no-op, see header comment */
ON DUPLICATE KEY UPDATE `value` = 0;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8144003, 10007, 630720000) /* VendorStockTimeToRot -- ~20 years, see header comment */
ON DUPLICATE KEY UPDATE `value` = 630720000;

UPDATE `weenie_properties_float` SET `value` = 0 WHERE `object_Id` = 8144003 AND `type` = 37; /* BuyPrice */
UPDATE `weenie_properties_float` SET `value` = 0 WHERE `object_Id` = 8144003 AND `type` = 38; /* SellPrice */
