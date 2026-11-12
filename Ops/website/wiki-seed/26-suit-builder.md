# Suit Builder
The **Suit Builder** (the **Suit Builder** tab at the top of the website, or [/suit](/suit)) has two parts:
- **Suit search** finds the best suit of armor, underclothes and jewelry for the slots and spells you choose.
- **Item search** lists your items in a sortable table, like a spreadsheet.

Sign in with your wiki login (linked to your game account).

## Where to look
At the top, tick where items can come from:
- **My mule**: your own [[My Mule]] (always available).
- **Mules you're a guest of**: any mule whose owner added one of your characters with `/mule storage add`.
- **Items for sale on the Market**: every active [[Market]] listing, with its price and a link to buy it.

When two items are otherwise equal, the Suit search uses your own first, then guest mules, then the Market.

Next to the tabs, **Show** picks which spells are listed on items and in the spell picker: **cantrips only** (Minor, Major, Epic and Legendary) or **cantrips and all spells**. Your browser remembers the choice.

## Suit search
1. **Start from a template**: Heavy, Light, Finesse, Two Handed, Dual Wield, Missile, War, Void, Life or Tinker (crafting). It ticks every slot and adds the cantrips for that build: the attributes, the three defenses (Invulnerability, Impregnability, Magic Resistance) and the build's skills. **Add: the seven wards** adds the wards on top of what you have.
2. **Slots to fill**: untick the slots you already have covered. Only items that fit entirely in the ticked slots are used, so a hauberk needs chest, upper arms and lower arms ticked (or tailoring reductions, below).
3. **Spells you need**: for each spell, the lowest level you'll accept (Minor, Major, Epic or Legendary) and whether it's **Must have** or **Nice to have**. The **Set all** row changes every spell at once. Add any other spell your items have from the list at the bottom.
4. **Extras**: armor sets, tailoring reductions, Impenetrability, how much armor level matters, ratings and the character (see *Extras* below).
5. **Item filters** (optional, items that fail them are never used): minimum base armor level for body pieces and for extremities, a wield level range, how many Legendary (or Epic or better) spells each item must have, minimum offensive, defensive or total ratings, and a name or spell pattern.
6. Press **Find suits**. You get up to five suits, best first. Every spell you asked for is marked as met, short (a lower level than you wanted) or missing. Each suit shows its armor level, set pieces, ratings, Impenetrability coverage and how many of your spells are Legendary, Epic or Major.

### Extras
- **Armor sets**: up to two, each with how many pieces (for example 5 of one set and 4 of another). Tick "body armor only from these sets" to leave out other sets' armor.
- **Tailoring reductions**: a multi-slot piece can be used as if reduced to one slot (a hauberk as a chest piece). It's marked "tailor-reduce to this" in the results.
- **Impenetrability**: on each armor piece and on each underclothes piece, doesn't matter, prefer or require, with the lowest level you'll accept. It counts per piece because it raises that piece's own armor level.
- **Armor level**: doesn't matter, tie-breaker or important.
- **Ratings** to collect (damage, crit damage, resists and so on).
- **Character**: items above its level are skipped unless you tick "ignore level requirements". You can also skip attuned items.

On any item in a result, 🔒 always uses that item and 🚫 never uses it; search again after. **Copy as text** copies a suit for Discord or notes.

The search runs in your browser. It stops after 8 seconds and shows the best suits found so far.

## Taking a suit out of your mule
Press **Save for /mule suit** on a suit to get a short code. In game, open the mule and:
- `/mule suit CODE` shows only that suit's items in the mule window, so you can buy them out. Reopen the mule to see everything again.
- `/mule suit CODE take` moves every item of the suit into the pack of the character you're on (for example your [[Tinker characters|Tinker]]) in one go. It's refused if they don't all fit.

Both work on a mule you're a guest of too. Market items aren't part of a saved suit: buy them first.

## Item search
The **Item search** tab lists every item in the places you ticked, not just armor and jewelry, with its type, slots, set, armor level, wield level, arcane lore, workmanship, Legendary and Epic counts, ratings, damage, imbue, value and where it is.
- **Filter** by name or spells (a regular expression: `legendary.*legendary` finds items with two Legendaries), type, slot, set, imbue, armor level and wield level ranges, workmanship, Legendary and Epic counts, and ratings. **Clear filters** resets them.
- **Sort** by clicking a column heading; click again to reverse.
- **Download as CSV** saves the filtered list for Excel or Google Sheets.
- 🔒 and 🚫 on an armor or jewelry row lock or exclude it in the Suit search.

It shows the first 500 matches; narrow the filters to see the rest.

## Cleaning out your mule
**Find items in my mule that another of my items beats** lists every item you have a strictly better copy of: same equip slots, every spell at the same level or better, armor level and ratings at least as high, the same armor set (or none) and no higher level requirement. Save the list, then in game open your mule and use `/mule suit CODE` to look at them, or `/mule purge suit:CODE` to remove them (with the usual warning and 7-day undo, see [[My Mule]]).

## Good to know
- Only your mule, guest mules and the Market are searched, not your packs or house chests.
- An item the game server hasn't read yet can't be used. Summon your mule once in game and reload the page.

See also [[My Mule]], [[Market]], [[Player commands]].
