# Bank
Your account-wide bank. It holds pyreals, PK Trophies, keys and luminance, and every character on your account shares it. Use it from anywhere with the `/bank` command.

## What it holds
| Currency | Name in commands | Notes |
|---|---|---|
| Pyreals | `pyreals` | Coins and trade notes are banked by their pyreal value. |
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
| `/bank deposit` | Deposits all your pyreals, trade notes, PK Trophies and keys (not luminance). |
| `/bank deposit trophies` | Deposits all of one currency. |
| `/bank deposit pyreals 50000` | Deposits a set amount. A set amount of pyreals is taken from coins only. |
| `/bank deposit luminance 1m` | Deposits luminance. |
| `/bank withdraw pyreals 2m` | Takes pyreals out as 250,000 trade notes, plus coins for the rest. |
| `/bank withdraw pyreals 50k coins` | Takes pyreals out as coins only (up to 2,500,000 at a time). |
| `/bank withdraw hera 2` | Takes out keys (up to 100 at a time). |
| `/bank send trophies 25 Some Name` | Sends from your bank to another player's bank. You're asked to confirm first. |
| `/bank log` | Shows your last 10 bank entries (`/bank log 30` for more). |

## Buying from vendors
If you buy from a vendor that takes pyreals (or PK Trophies, at the PK Trophy Vendor) and your pack is short, a popup asks whether to pay the rest from your bank. Say yes and your pack pays what it can and the bank pays the rest. Say no and nothing happens. Bank payments show in `/bank log` as `vendor`.

## Rules
| Rule | How it works |
|---|---|
| PvP | The bank is closed while you're PK tagged and in arenas. |
| Sending | Goes to the other player's whole account, so all their characters get it. You can't send to your own account (it's already shared). Every send is logged on both sides. |
| Pack space | A withdrawal checks your pack space and burden first. If something still doesn't fit, it goes straight back into the bank. |
| Luminance | You can only withdraw up to your luminance cap. |
