/* JawnTide /mule purge: purged mule items aren't deleted right away. They move into the account's purge bin (a container that
   isn't part of the mule) and are listed here; /mule purge undo brings a batch back. After mule_purge_hold_days the game server
   deletes them for good (status 'deleted'). Applied automatically at server start; safe to re-run. */

CREATE TABLE IF NOT EXISTS `mule_purge_bin` (
    `account_Id`   INT UNSIGNED NOT NULL,
    `container_Id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`account_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mule_purge` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_Id` INT UNSIGNED    NOT NULL,
    `batch_Id`   BIGINT UNSIGNED NOT NULL,
    `item_Guid`  INT UNSIGNED    NOT NULL,
    `item_Name`  VARCHAR(128)    NOT NULL,
    `stack_Size` INT             NOT NULL DEFAULT 1,
    `filter`     VARCHAR(255)    NULL,
    `purged_By`  VARCHAR(64)     NOT NULL,
    `purged_At`  DATETIME        NOT NULL,
    `status`     VARCHAR(16)     NOT NULL DEFAULT 'held',
    `done_At`    DATETIME        NULL,
    PRIMARY KEY (`id`),
    KEY `ix_mule_purge_account` (`account_Id`, `status`, `batch_Id`),
    KEY `ix_mule_purge_status` (`status`, `purged_At`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
