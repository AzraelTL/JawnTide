/* JawnTide My Mule: one row per account, shared by every character on that account.
   container_Id = head GUID of the account's mule storage container chain (0 = no mule summoned yet).
   visual_Variant = the account's mule look, picked the first time it is summoned (-1 = not picked yet).
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

CREATE TABLE IF NOT EXISTS `account_mule` (
    `account_Id`     INT UNSIGNED NOT NULL,
    `container_Id`   INT UNSIGNED NOT NULL DEFAULT 0,
    `visual_Variant` INT          NOT NULL DEFAULT -1,
    PRIMARY KEY (`account_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
