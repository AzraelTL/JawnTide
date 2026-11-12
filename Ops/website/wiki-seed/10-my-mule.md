# My Mule
Your own storage mule, shared by every character on your account. Summon it almost anywhere, sell items to it to store them, and buy them back for free on any of your characters.

## Getting started
1. Type `/mule` to get your **My Mule** gem. It's yours for good and can't be traded or sold.
2. Use the gem to **summon** your mule next to you. Use it again to send the mule away.
3. **Store items** by selling them to the mule. Nothing is charged.
4. **Take items back** by buying them from the mule. Nothing is charged.

ID (appraise) the gem to see how many of your mule's storage slots are used and how many are free.

Everything you store is shared by all the characters on your account.

## Where and when
| Rule | How it works |
|---|---|
| Summoning | Anywhere, except while you're PK tagged or in an arena. |
| PvP | You can't store or take items while PK tagged, and your mule bolts if you get tagged. |
| Leaving | The mule leaves when you log out, change areas, teleport, or move more than about 40 meters away. Your items stay stored. |
| Who can use it | Characters on your own account, plus any guests you add (see *Mule guests* below). |

## What it holds
- Up to **5,100** stacks or items (20 storage containers of 255, added automatically as they fill).
- Not allowed: pyreals, containers (packs) and attuned items.
- Gems, keys, spell components, mana stones and other plain items **stack up to 1,000** in the mule. When you take them out, you get fresh copies in normal stack sizes.

> Charged mana stones and other items with their own charge or state come back as fresh copies, so take out what you need before you store partly used items.

## Suit Builder
The website's [[Suit Builder]] finds the best suit in your mule for the slots and spells you pick. Save it, then open your mule and type `/mule suit CODE` to show just those items, or `/mule suit CODE take` to move them all into your pack at once.

## Clearing out your mule
`/mule purge FILTER` removes many items at once. Open your mule first.
1. `/mule purge FILTER` only **shows** what matches: the mule window filters to those items. Check them.
2. `/mule purge confirm` (within 2 minutes) asks you to agree to a warning. Say No if anything you want to keep is in the list.
3. Removed items are **held for 7 days**. `/mule purge undo` brings the last purge back, `/mule purge list` shows the purges you can still undo and `/mule purge undo N` brings back an older one. After 7 days they're deleted for good.

`/mule purge cancel` stops a purge before you confirm it. Guests can't purge.

| Filter | Meaning |
|---|---|
| `type:shield` | armor, shield, clothing, jewelry, melee, missile, caster, weapon, salvage, gem, food, key, manastone, component, misc (several type: words mean any of them) |
| `al<200` | compare armor level; also `level` (wield level), `value`, `work` (workmanship), `lore` (arcane lore), `dmg`, `spells` (how many). Use `<` `<=` `>` `>=` `=` |
| `material:leather` / `-material:metal` | made of cloth, leather, metal, gem, stone, wood or ceramic, or one material by name (`material:steel`, `material:satin`) |
| `spell:legendary` / `-spell:legendary` | has / hasn't a spell whose name matches |
| `set:defender` | armor set name contains |
| `name:robe` / `-name:robe` (or just `robe`) | name contains / doesn't contain |

All filters must match. Examples: `/mule purge type:shield al<200`, `/mule purge type:armor material:cloth`, `/mule purge type:armor -spell:legendary -spell:epic`, `/mule purge type:salvage work<6`. The purge errs on the side of caution: an item that doesn't have what a filter checks is never deleted by it. `al<200` skips items with no armor level, `level<150` skips items with no level requirement, and `-material:metal` skips items with no material.

## Mule guests
Like storage guests on a house chest, you can let characters on other accounts use your mule.

| Command | What it does |
|---|---|
| `/mule storage add NAME` | Let NAME use your mule (up to 20 guests). |
| `/mule storage remove NAME` | Take NAME off the list. |
| `/mule storage remove -all` | Remove every guest. |
| `/mule storage list` | Show your guests. |

- Guests can only use your mule while **one of your characters has it summoned**, standing next to it. They can't summon it themselves.
- Guests can store items and **take anything out**, so only add people you trust.
- You get a chat message each time a guest stores or takes something.
- The list belongs to your account, so any of your characters can change it.

## Finding items
`/mule search pattern` filters your open mule window by the spells on the items. For example `/mule search legendary.*legendary` shows double-legendary gear. Type `/mule search` with nothing after it, or reopen the mule, to see everything again.
