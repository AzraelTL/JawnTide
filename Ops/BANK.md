# JawnTide Bank (admin notes)

Account-wide bank: pyreals (coins and trade notes by value), PK Trophies, luminance and three single-use keys.
Player guide: `Ops/website/wiki-seed/11-bank.md`. Code: `Player_Bank.cs`, `BankInfo.cs`, `ShardDatabase_Bank.cs`.

## Tables (shard, created automatically at server start)
- `account_bank` — one row per account and currency (`pyreals`, `pk_trophies`, `luminance`, `key_darkbeat`, `key_hera`, `key_skeleton`).
- `account_bank_log` — every deposit, withdraw, send, receive and refund, with the balance after it.

## Safety
- Every change is one SQL transaction. A withdrawal or send only happens when the balance covers it.
- Deposits: items are deleted and the player saved first; the credit is queued behind them on the same save queue.
- Withdrawals: the balance is debited first; items that don't fit go straight back (logged as `refund`).
- A failed credit or refund is logged as an ERROR with `[BANK]` and the amount, to restore by hand.
- Closed while PK tagged, in arenas, trading, dead, teleporting or logging out.

## Admin
- `/bankcheck <character>` (Sentinel and up): balances and the last 20 log entries for that character's account.
- Find problems: `docker logs ace-server 2>&1 | grep "\[BANK\]"`
- Restore an amount by hand (example: 1,000,000 pyreals to account 9), from the shard database:
  ```sql
  INSERT INTO account_bank (account_Id, currency, amount) VALUES (9, 'pyreals', 1000000) ON DUPLICATE KEY UPDATE amount = amount + 1000000;
  INSERT INTO account_bank_log (logged_At, account_Id, action, currency, amount, balance_After, details)
  SELECT UTC_TIMESTAMP(), 9, 'admin', 'pyreals', 1000000, amount, 'restored by hand' FROM account_bank WHERE account_Id = 9 AND currency = 'pyreals';
  ```

## Adding a currency
Add a line to `BankInfo.Currencies` (a stackable item or a single-use key). The code becomes the `currency` value; never rename a live one.
