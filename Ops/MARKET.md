# JawnTide Marketplace (admin notes)

Players list items from their mule on jawntide.com/market and buy with their bank (MMDs = bank pyreals at 250,000 each, or PK Trophies).
No fees. Listings run 30 days; unsold ones are hidden ("expired") and wait in market storage until the seller relists or cancels.

## How it works
- The website only inserts rows into `market_request` (list, buy, cancel, relist). It never moves items or money.
- The game server (`MarketManager`, every 3 seconds) carries out requests one at a time and writes the result back on the row.
- Listed items sit in one market storage container (id in `market_meta`, key `storage_container`), made on first start.
- Item moves: if the account has a character online with its mule loaded, the move runs on that character (like a mule deposit or
  withdrawal). Otherwise it's made in the database, and the account's mule can't be summoned for those few seconds.
- Buy: claim the listing, take the buyer's bank, deliver to the buyer's mule, pay the seller's bank. If delivery fails the buyer is refunded.
  Bank log actions: `market buy`, `market sale`, `market refund`.

## Tables (shard, created at server start: `Database/Updates/Shard/2026-11-04-00-Add-Market.sql`)
`market_request`, `market_listing`, `market_icon` (PNG icons from portal.dat), `market_meta`.

## Admin
- `/marketcheck <character>` (Sentinel and up): the account's listings and latest requests.
- Turn it off: `/modifybool market_enabled false` (requests wait until it's back on).
- Problems: `docker logs ace-server 2>&1 | grep "\[MARKET\]"`. Lines with REFUND FAILED or SELLER NOT PAID name the account and amount to
  restore by hand (see BANK.md). A listing left `busy` by a server stop is logged at the next start; check the bank log and the item, then set its status.
- Testing without the website: `Ops/sql-snippets/market-test.sql`.
