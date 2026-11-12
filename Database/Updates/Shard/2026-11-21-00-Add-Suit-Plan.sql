/* JawnTide Suit Builder: suits saved on the website (/suit). In game, /mule suit CODE filters the open mule window to
   that suit's items. items = comma-separated item GUIDs. Applied automatically at server start; safe to re-run. */

CREATE TABLE IF NOT EXISTS `suit_plan` (
    `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    `account_Id`  INT UNSIGNED  NOT NULL,
    `code`        CHAR(6)       NOT NULL,
    `name`        VARCHAR(64)   NOT NULL,
    `items`       VARCHAR(1024) NOT NULL,
    `created_At`  DATETIME      NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `ux_suit_plan_code` (`account_Id`, `code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
