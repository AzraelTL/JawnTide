/* JawnTide bank audit and economy stats.
   transfer_log     = every value moving between two accounts: bank sends, direct gives, trades, and items dropped by one
                      account and picked up by another. flags is set when the transfer looked suspicious.
   account_bank_ban = accounts an admin closed the bank to (/bankaudit ban).
   economy_daily    = per day, currency and source: how much entered or left the game (/economystats).
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

CREATE TABLE IF NOT EXISTS `transfer_log` (
    `id`                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `logged_At`           DATETIME        NOT NULL,
    `kind`                VARCHAR(16)     NOT NULL,
    `from_Account_Id`     INT UNSIGNED    NOT NULL,
    `from_Character_Id`   INT UNSIGNED    NOT NULL DEFAULT 0,
    `from_Character_Name` VARCHAR(64)     NULL,
    `from_Ip`             VARCHAR(45)     NULL,
    `to_Account_Id`       INT UNSIGNED    NOT NULL,
    `to_Character_Id`     INT UNSIGNED    NOT NULL DEFAULT 0,
    `to_Character_Name`   VARCHAR(64)     NULL,
    `to_Ip`               VARCHAR(45)     NULL,
    `item_Wcid`           INT UNSIGNED    NOT NULL DEFAULT 0,
    `item_Guid`           INT UNSIGNED    NOT NULL DEFAULT 0,
    `item_Name`           VARCHAR(128)    NULL,
    `quantity`            BIGINT          NOT NULL DEFAULT 1,
    `value`               BIGINT          NOT NULL DEFAULT 0,
    `flags`               VARCHAR(128)    NULL,
    PRIMARY KEY (`id`),
    KEY `ix_transfer_log_from` (`from_Account_Id`, `logged_At`),
    KEY `ix_transfer_log_to` (`to_Account_Id`, `logged_At`),
    KEY `ix_transfer_log_time` (`logged_At`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `account_bank_ban` (
    `account_Id` INT UNSIGNED NOT NULL,
    `banned_At`  DATETIME     NOT NULL,
    `banned_By`  VARCHAR(64)  NULL,
    `reason`     VARCHAR(255) NULL,
    PRIMARY KEY (`account_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `economy_daily` (
    `day`          DATE         NOT NULL,
    `currency`     VARCHAR(32)  NOT NULL,
    `source`       VARCHAR(48)  NOT NULL,
    `amount`       BIGINT       NOT NULL DEFAULT 0,
    `transactions` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`day`, `currency`, `source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
