# Bank
Your account-wide bank. It holds pyreals, PK Trophies, keys and luminance, and every character on your account shares it. Use it from anywhere with the `/bank` command, or `/b` for short.

## What it holds
| Currency | Name in commands | Notes |
|---|---|---|
| Pyreals | `pyreals` | Coins, and trade notes by their pyreal value (notes only with `/bank deposit notes`). |
| PK Trophies | `trophies` | |
| Luminance | `luminance` | Only deposited when you ask for it by name. |
| Darkbeat's Lost Storage Key | `darkbeat` | Unused keys only. |
| Hera's Vault Key | `hera` | Unused keys only. |
| Shimmering Skeleton Key | `skeleton` | Unused keys only. |

Amounts can use k, m and b: `5k`, `2.5m`, `1b`.

## Commands
| Command | What it does |
|---|---|
| `/bank` | Shows your balances. |
| `/bank deposit` | Deposits all your pyreal coins, PK Trophies and keys. Trade notes and luminance stay in your pack. |
| `/bank deposit notes` | Deposits your trade notes, by their pyreal value. |
| `/bank deposit trophies` | Deposits all of one currency. |
| `/bank deposit pyreals 50000` | Deposits a set amount. A set amount of pyreals is taken from coins only. |
| `/bank deposit luminance 1m` | Deposits luminance. |
| `/bank withdraw pyreals 2m` | Takes pyreals out as 250,000 trade notes, plus coins for the rest. |
| `/bank withdraw pyreals 50k coins` | Takes pyreals out as coins only (up to 2,500,000 at a time). |
| `/bank withdraw pyreals 500k notes 100k` | Takes pyreals out in the trade note size you pick (any standard note from 100 to 250,000). Anything left over comes as coins. |
| `/bank sales bank` | Vendor sales pay straight into your bank. `/bank sales coins` switches back to the default: coins in your pack. |
| `/bank purchases ask` | Ask with a popup before a vendor takes what your pack is short from your bank. `off` never uses the bank, `auto` (the default) pays without asking. |
| `/bank withdraw hera 2` | Takes out keys (up to 100 at a time). |
| `/bank send trophies 25 Some Name` | Sends from your bank to another player's bank. You're asked to confirm first. `/bank transfer` works the same. |
| `/bank log` | Shows your last 10 bank entries (`/bank log 30` for more). |

## Shortcuts
`/b` works exactly like `/bank`, and the first word has a one-letter version:

| Short | Same as |
|---|---|
| `/b` | `/bank` (your balances) |
| `/b d` | `/bank deposit` |
| `/b w pyreals 2m` | `/bank withdraw pyreals 2m` |
| `/b s t 25 Some Name` | `/bank send trophies 25 Some Name` |
| `/b log` | `/bank log` |

Currencies have short names too: `p` (pyreals), `t` (trophies), `l` (luminance).

## Leaderboard and luminance history
| Command | What it does |
|---|---|
| `/top bank` | The 25 richest banks by pyreals, showing each account's highest level character. Updates every minute. |
| `/top bank trophies` | The same for PK Trophies (`/top bank luminance` for luminance). |
| `/lhs` | Luminance your account sent through the bank in the last 7 days, and to whom (`/lhs 30` for 30 days). |
| `/lhr` | Luminance your account received through the bank, and from whom. |

## Buying from vendors
If you buy from a vendor that takes pyreals (or PK Trophies, at the PK Trophy Vendor) and your pack is short, the rest is paid from your bank automatically: your pack pays what it can and the bank pays the rest. The vendor window's "you have" counts your bank too. Bank payments show in `/bank log` as `vendor`.

Per character: `/bank purchases ask` shows a Yes/No popup first, `/bank purchases off` never uses the bank, and `/bank purchases auto` goes back to the default.

## Selling to vendors
Vendor sales pay you in coins, as always. To have them go straight into your bank instead (no pack space needed for coins), type `/bank sales bank` (per character); a message tells you how much went in each time. While you're PK tagged or in an arena you always get coins.

## Rules
| Rule | How it works |
|---|---|
| PvP | The bank is closed while you're PK tagged and in arenas. |
| Sending | Goes to the other player's whole account, so all their characters get it. You can't send to your own account (it's already shared). Every send is logged on both sides. |
| Logged transfers | Bank sends, gives, trades and items dropped for another account to pick up are logged, and staff are alerted to unusual ones. Staff can close a bank. |
| Pack space | A withdrawal checks your pack space and burden first. If something still doesn't fit, it goes straight back into the bank. |
| Luminance | You can only withdraw up to your luminance cap. |
