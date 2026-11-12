/* JawnTide My Mule guests: characters on other accounts that may use an account's mule while one of its characters
   has it summoned (/mule storage add NAME). Applied automatically at server start; safe to re-run. */

CREATE TABLE IF NOT EXISTS `mule_guest` (
    `account_Id` INT UNSIGNED NOT NULL,
    `guest_Id`   INT UNSIGNED NOT NULL,
    `guest_Name` VARCHAR(64)  NOT NULL,
    `added_By`   VARCHAR(64)  NULL,
    `added_At`   DATETIME     NOT NULL,
    PRIMARY KEY (`account_Id`, `guest_Id`),
    KEY `ix_mule_guest_guest` (`guest_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
