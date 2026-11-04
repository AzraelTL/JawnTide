/* JawnTide Marketplace (jawntide.com/market): players list items from their mule on the website and buy with their bank.
   The website only writes market_request rows; the game server (MarketManager) carries them out and owns every other change.
   market_request = what a player asked for on the website (list, buy, cancel, relist) and how it went.
   market_listing = one row per listed item. The item itself waits in the market's storage container until sold or returned.
   market_icon    = item icons as PNG, exported from the client's portal.dat by the game server for the website.
   market_meta    = market settings the server keeps for itself (the storage container's id).
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

CREATE TABLE IF NOT EXISTS `market_request` (
    `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `created_At`     DATETIME        NOT NULL,
    `account_Id`     INT UNSIGNED    NOT NULL,
    `character_Name` VARCHAR(64)     NULL,
    `kind`           VARCHAR(16)     NOT NULL,          -- list, buy, cancel, relist
    `item_Guid`      INT UNSIGNED    NULL,              -- list
    `listing_Id`     BIGINT UNSIGNED NULL,              -- buy, cancel, relist
    `price_Mmd`      INT UNSIGNED    NULL,              -- list
    `price_Trophies` INT UNSIGNED    NULL,              -- list
    `pay_With`       VARCHAR(16)     NULL,              -- buy: mmd or trophies
    `status`         VARCHAR(16)     NOT NULL DEFAULT 'pending',   -- pending, working, done, failed
    `result`         VARCHAR(255)    NULL,
    `processed_At`   DATETIME        NULL,
    PRIMARY KEY (`id`),
    KEY `ix_market_request_status` (`status`, `id`),
    KEY `ix_market_request_account` (`account_Id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `market_listing` (
    `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `seller_Account_Id` INT UNSIGNED    NOT NULL,
    `seller_Name`       VARCHAR(64)     NULL,
    `item_Guid`         INT UNSIGNED    NOT NULL,
    `wcid`              INT UNSIGNED    NOT NULL,
    `name`              VARCHAR(128)    NOT NULL,
    `stack_Size`        INT             NOT NULL DEFAULT 1,
    `item_Type`         INT             NOT NULL DEFAULT 0,
    `icon_Id`           INT UNSIGNED    NOT NULL DEFAULT 0,
    `icon_Overlay_Id`   INT UNSIGNED    NOT NULL DEFAULT 0,
    `icon_Overlay2_Id`  INT UNSIGNED    NOT NULL DEFAULT 0,
    `icon_Underlay_Id`  INT UNSIGNED    NOT NULL DEFAULT 0,
    `ui_Effects`        INT             NOT NULL DEFAULT 0,
    `details`           MEDIUMTEXT      NULL,           -- JSON: every property of the item, spell names, enum names
    `search_Text`       TEXT            NULL,           -- name, spells, set, material (lower case) for the website search
    `price_Mmd`         INT UNSIGNED    NULL,
    `price_Trophies`    INT UNSIGNED    NULL,
    `status`            VARCHAR(16)     NOT NULL,       -- active, expired, busy, sold, returned
    `listed_At`         DATETIME        NOT NULL,
    `expires_At`        DATETIME        NOT NULL,
    `closed_At`         DATETIME        NULL,
    `buyer_Account_Id`  INT UNSIGNED    NULL,
    `buyer_Name`        VARCHAR(64)     NULL,
    `paid_Currency`     VARCHAR(32)     NULL,
    `paid_Amount`       BIGINT          NULL,
    PRIMARY KEY (`id`),
    KEY `ix_market_listing_status` (`status`, `expires_At`),
    KEY `ix_market_listing_seller` (`seller_Account_Id`, `status`),
    KEY `ix_market_listing_buyer` (`buyer_Account_Id`),
    KEY `ix_market_listing_item` (`item_Guid`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `market_icon` (
    `icon_Id` INT UNSIGNED NOT NULL,
    `png`     MEDIUMBLOB   NULL,             -- NULL = the server couldn't read this icon
    PRIMARY KEY (`icon_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `market_meta` (
    `k` VARCHAR(64)  NOT NULL,
    `v` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`k`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
