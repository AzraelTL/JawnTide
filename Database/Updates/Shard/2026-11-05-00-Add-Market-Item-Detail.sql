/* JawnTide Marketplace: full details (same JSON as market_listing.details) of items in players' mules, so the website's
   My Market page can show the in-game style ID panel before an item is listed. Filled by the game server when a mule is
   summoned or something is put in it. Applied automatically at server start (AutoApplyDatabaseUpdates). */

CREATE TABLE IF NOT EXISTS `market_item_detail` (
    `item_Guid`  INT UNSIGNED NOT NULL,
    `details`    MEDIUMTEXT   NOT NULL,
    `updated_At` DATETIME     NOT NULL,
    PRIMARY KEY (`item_Guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
