/* JawnTide Bank: account-wide balances, shared by every character on the account.
   account_bank     = one row per account and currency (pyreals, pk_trophies, luminance, key_darkbeat, key_hera, key_skeleton).
   account_bank_log = every deposit, withdrawal, transfer and refund, with the balance after the change.
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

CREATE TABLE IF NOT EXISTS `account_bank` (
    `account_Id` INT UNSIGNED NOT NULL,
    `currency`   VARCHAR(32)  NOT NULL,
    `amount`     BIGINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (`account_Id`, `currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `account_bank_log` (
    `id`                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `logged_At`            DATETIME        NOT NULL,
    `account_Id`           INT UNSIGNED    NOT NULL,
    `character_Id`         INT UNSIGNED    NOT NULL DEFAULT 0,
    `character_Name`       VARCHAR(64)     NULL,
    `action`               VARCHAR(16)     NOT NULL,
    `currency`             VARCHAR(32)     NOT NULL,
    `amount`               BIGINT          NOT NULL,
    `balance_After`        BIGINT          NOT NULL,
    `other_Account_Id`     INT UNSIGNED    NULL,
    `other_Character_Name` VARCHAR(64)     NULL,
    `details`              VARCHAR(255)    NULL,
    PRIMARY KEY (`id`),
    KEY `ix_account_bank_log_account` (`account_Id`, `logged_At`),
    KEY `ix_account_bank_log_other` (`other_Account_Id`, `logged_At`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
