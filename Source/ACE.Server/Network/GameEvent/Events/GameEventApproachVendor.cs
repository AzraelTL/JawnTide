using System;

using ACE.Database;
using ACE.Entity.Models;
using ACE.Server.WorldObjects;

namespace ACE.Server.Network.GameEvent.Events
{
    public class GameEventApproachVendor : GameEventMessage
    {
        /// <param name="bankExtra">JawnTide Bank: alternate currency the player's bank can add (shown so the client allows the purchase).</param>
        public GameEventApproachVendor(Session session, Vendor vendor, uint altCurrencySpent, uint bankExtra = 0)
            : base(GameEventType.ApproachVendor, GameMessageGroup.UIQueue, session, 8192) // 5,376 is the average seen in retail pcaps, 15,272 is the max seen in retail pcaps
        {        
            Writer.Write(vendor.Guid.Full);

            // the types of items vendor will purchase
            Writer.Write((uint)vendor.MerchandiseItemTypes);
            Writer.Write((uint)vendor.MerchandiseMinValue);
            Writer.Write((uint)vendor.MerchandiseMaxValue);

            Writer.Write(Convert.ToUInt32(vendor.DealMagicalItems ?? false));

            Writer.Write((float)vendor.BuyPrice);
            Writer.Write((float)vendor.SellPrice);

            // the wcid of the alternate currency
            Writer.Write(vendor.AlternateCurrency ?? 0);

            // if this vendor accepts items as alternate currency, instead of pyreals
            if (vendor.AlternateCurrency != null)
            {
                var altCurrency = DatabaseManager.World.GetCachedWeenie(vendor.AlternateCurrency.Value);
                var pluralName = altCurrency.GetPluralName();

                // the total amount of alternate currency the player currently has
                var altCurrencyInInventory = (uint)session.Player.GetNumInventoryItemsOfWCID(vendor.AlternateCurrency.Value);
                Writer.Write(altCurrencyInInventory + altCurrencySpent + bankExtra);

                // the plural name of alt currency
                Writer.WriteString16L(pluralName);
            }
            else
            {
                Writer.Write(0);
                Writer.WriteString16L(string.Empty);
            }

            var items = new System.Collections.Generic.List<WorldObject>(vendor.DefaultItemsForSale.Count + vendor.UniqueItemsForSale.Count);
            vendor.forEachItem(items.Add);

            // JawnTide My Mule: a mule can hold thousands of items, and one window listing them all can crash the client,
            // so it lists one page (mule_window_max_items) at a time; /mule page N picks the page
            if (vendor.MuleOwnerId.HasValue)
            {
                var max = Player.MuleWindowMaxItems;
                if (items.Count > max)
                {
                    var pages = (items.Count + max - 1) / max;
                    var page = Math.Clamp(vendor.MulePage, 0, pages - 1);
                    items = items.GetRange(page * max, Math.Min(max, items.Count - page * max));

                    // page turning from the window itself: "buy" one of these to go to the next or previous page
                    if (page > 0 && vendor.GetMulePageButton(false) is WorldObject prev)
                    {
                        prev.Name = $"<< Previous page ({page} of {pages})";
                        items.Insert(0, prev);
                    }
                    if (page < pages - 1 && vendor.GetMulePageButton(true) is WorldObject next)
                    {
                        next.Name = $">> Next page ({page + 2} of {pages})";
                        items.Insert(0, next);
                    }
                }
            }

            Writer.Write(items.Count);

            foreach (var obj in items)
            {
                int stackSize = obj.VendorShopCreateListStackSize ?? obj.StackSize ?? 1; // -1 = unlimited supply

                // packed value: (stackSize & 0xFFFFFF) | (pwdType << 24)
                // pwdType: flag indicating whether the new or old PublicWeenieDesc is used; -1 = PublicWeenieDesc, 1 = OldPublicWeenieDesc; -1 always used.
                Writer.Write(stackSize & 0xFFFFFF | -1 << 24);

                // JawnTide My Mule: the client prices Trade Notes (PromissoryNote) at a fixed rate whatever the vendor's
                // rates are, so on a mule (everything free) they'd show a price. Showing them as Misc avoids that.
                // Salvage (TinkeringMaterial) is left out of a vendor's for-sale list by the client (tested on JawnTest),
                // so on a mule it is listed as a Cooking Base, which gives it a tab mules hardly use (picked on JawnTest;
                // Tinkering Tool shares "Keys and Tools", and Fletching Base / Gameboard aren't listed at all).
                // Only the listing changes; the stored item keeps its real type.
                var originalItemType = obj.ItemType;
                ACE.Entity.Enum.ItemType? listAs = null;

                if (vendor.MuleOwnerId.HasValue)
                {
                    if (originalItemType == ACE.Entity.Enum.ItemType.PromissoryNote)
                        listAs = ACE.Entity.Enum.ItemType.Misc;
                    else if (originalItemType == ACE.Entity.Enum.ItemType.TinkeringMaterial)
                        listAs = ACE.Entity.Enum.ItemType.CraftCookingBase;
                }

                if (listAs.HasValue)
                {
                    obj.ItemType = listAs.Value;
                    obj.CalculateObjDesc();
                }

                obj.SerializeGameDataOnly(Writer);

                if (listAs.HasValue)
                    obj.ItemType = originalItemType;
            }

            Writer.Align();
        }
    }
}
