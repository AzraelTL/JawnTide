# JawnTide Marketplace (admin notes)

Players list items from their mule on jawntide.com/market and buy with their bank (MMDs = bank pyreals at 250,000 each, or PK Trophies).
No fees. Listings run 30 days; unsold ones are hidden ("expired") and wait in market storage until the seller relists or cancels.

## Auctions
Seller picks one currency, a starting bid, optional Buy It Now and 1-14 days. A bid takes the amount from the bidder's bank at once (one
transaction: check, take, refund the previous high bidder, record the bid); outbid bidders are refunded immediately. Minimum raise 5%,
a bid in the last 5 minutes extends to 5 minutes. Buy It Now stays until bids reach it and refunds the high bidder. At the end the item goes to
the winner's mule and the winning bid to the seller; if the winner's mule is full the auction waits as `won` and delivery is retried every
2 minutes. No bids: `expired`, the seller can run it again or take it back. Bank log actions: `market bid`, `market outbid`, `market sale`.
Table `market_bid` keeps every bid.

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

## Website (`Ops/website/market.py`)
`/market` (search, filters), `/market/item/ID`, `/market/mine` (your mule, listings, history), `/market/icon/ID.png`.
Sign-in is the wiki login. Mule items with no picture yet get one the next time their owner summons the mule.

## Going live (order matters)
1. Deploy the game server with the marketplace (it creates the tables at start).
2. Linux, once: `bash ~/JawnTide/Ops/website/market-setup.sh` (the mule view and the website's grants).
3. Rebuild the website.
