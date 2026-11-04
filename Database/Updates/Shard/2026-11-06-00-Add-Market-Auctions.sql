/* JawnTide Marketplace auctions. A listing is either fixed price ('fixed') or an auction ('auction').
   Auctions: one currency (mmd or trophies), a starting bid, an optional Buy It Now, a length of 1 to 14 days.
   A bid takes the amount from the bidder's bank straight away; an outbid bidder gets it back at once.
   market_bid keeps every bid. Applied automatically at server start (AutoApplyDatabaseUpdates). */

ALTER TABLE `market_listing`
    ADD COLUMN IF NOT EXISTS `kind`                   VARCHAR(8)   NOT NULL DEFAULT 'fixed' AFTER `id`,
    ADD COLUMN IF NOT EXISTS `auction_Currency`       VARCHAR(16)  NULL,
    ADD COLUMN IF NOT EXISTS `auction_Hours`          INT          NULL,
    ADD COLUMN IF NOT EXISTS `start_Bid`              INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS `buy_Now`                INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS `high_Bid`               INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS `high_Bidder_Account_Id` INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS `high_Bidder_Name`       VARCHAR(64)  NULL,
    ADD COLUMN IF NOT EXISTS `bid_Count`              INT          NOT NULL DEFAULT 0;

ALTER TABLE `market_request`
    ADD COLUMN IF NOT EXISTS `auction_Currency` VARCHAR(16)  NULL,
    ADD COLUMN IF NOT EXISTS `auction_Hours`    INT          NULL,
    ADD COLUMN IF NOT EXISTS `start_Bid`        INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS `buy_Now`          INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS `bid_Amount`       INT UNSIGNED NULL;

CREATE TABLE IF NOT EXISTS `market_bid` (
    `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `listing_Id`     BIGINT UNSIGNED NOT NULL,
    `account_Id`     INT UNSIGNED    NOT NULL,
    `character_Name` VARCHAR(64)     NULL,
    `amount`         INT UNSIGNED    NOT NULL,
    `placed_At`      DATETIME        NOT NULL,
    `status`         VARCHAR(16)     NOT NULL,     -- high, outbid, won, refunded
    PRIMARY KEY (`id`),
    KEY `ix_market_bid_listing` (`listing_Id`, `id`),
    KEY `ix_market_bid_account` (`account_Id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
