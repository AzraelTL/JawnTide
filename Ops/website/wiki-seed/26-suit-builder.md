# Suit Builder
The **Suit Builder** on the website ([/suit](/suit)) searches your [[My Mule]] for the best suit of armor, underclothes and jewelry for the slots and spells you choose. Sign in with your wiki login (linked to your game account).

## How to use it
0. **Where to look**: your own mule is always an option. You can also tick the mules you're a guest of (see [[My Mule]]) and the items for sale on the [[Market]]. When two items are otherwise equal, your own comes first, then guest mules, then the Market. Market items show their price with a link to buy them.
1. **Start from a template** (Heavy, Light, Finesse, Two Handed, Missile, War, Void or Life). It ticks every slot and adds the six attribute cantrips, the three defense cantrips and the cantrips for that build. "Add: the seven wards" adds the wards on top.
2. **Slots to fill**: untick the slots you already have covered. Only items that fit entirely in the ticked slots are used, so a hauberk needs chest, upper arms and lower arms all ticked.
3. **Spells you need**: for each spell pick the lowest level you'll accept (Minor, Major, Epic, Legendary) and whether it's a **Must have** or **Nice to have**. Add any spell your items have from the list.
4. **Extras**: up to two armor sets with how many pieces of each (for example 5 of one set and 4 of another), optionally using only those sets for body armor; **tailoring reductions** (a multi-slot piece such as a hauberk can be used as if reduced to one slot, marked "tailor-reduce" in the results); Impenetrability on each armor piece and on each underclothes piece (doesn't matter, prefer or require, with the lowest level you'll accept; it counts per piece because it raises that piece's armor level), an armor set and how many pieces of it, how much armor level matters, ratings to collect, and the character (items above its level are skipped unless you tick "ignore level requirements").
5. **Item filters** (optional): minimum base armor level for body pieces and for extremities, a wield level range, how many Legendary (or Epic or better) spells each item must have, minimum offensive, defensive or total ratings, and a text or spell pattern items must match.
6. Press **Find suits**. You get up to five suits, best first, with every spell you asked for marked as met, short (lower level than you wanted) or missing.

Each result shows its armor level, set pieces, ratings and how many of your spells are Legendary, Epic or Major. **Copy as text** copies the suit for Discord or notes.

On any item in a result, 🔒 always uses that item and 🚫 never uses it. Search again after locking or excluding.

## Taking the suit out of your mule
Press **Save for /mule suit** on a suit to get a short code. In game, open your mule and type `/mule suit CODE`: the mule window shows only that suit's items, so you can buy them out. Type `/mule suit CODE take` instead to move every item of the suit into the pack of the character you're on (for example your Tinker) in one go; it's refused if they don't all fit. It works the same on a mule you're a guest of. Reopen the mule to see everything again. Market items aren't part of a saved suit: buy them first.

## Cleaning out your mule
**Find items in my mule that another of my items beats** lists every item you have a strictly better copy of: same equip slots, every spell at the same level or better, armor level and ratings at least as high, the same armor set (or none) and no higher level requirement. Save the list, then in game open your mule and use `/mule suit CODE` to look at them or `/mule purge suit:CODE` to remove them (with the usual warning and 7-day undo).

## Good to know
- Your mule, guest mules and the Market are searched, not your packs or house chests.
- An item the game server hasn't read yet can't be used. Summon your mule once in game and reload the page.
- The search runs in your browser and stops after 8 seconds with the best suits found so far.

See also [[My Mule]], [[Market]].
