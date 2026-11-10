/* JawnTide Target Drudge on the LAN admin page.
   training_dummy.description  = its setup in words (buff and item names), written by the game server for the page.
   training_dummy_request      = changes made on the page; the game server applies them within a few seconds and fills in status.
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

ALTER TABLE `training_dummy` ADD COLUMN IF NOT EXISTS `description` VARCHAR(2048) NULL;

CREATE TABLE IF NOT EXISTS `training_dummy_request` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `requested_At` DATETIME        NOT NULL,
    `requested_By` VARCHAR(64)     NULL,
    `dummy_Guid`   INT UNSIGNED    NOT NULL,
    `request`      TEXT            NOT NULL,
    `status`       VARCHAR(16)     NOT NULL DEFAULT 'pending',
    `applied_At`   DATETIME        NULL,
    `message`      VARCHAR(255)    NULL,
    PRIMARY KEY (`id`),
    KEY `ix_training_dummy_request_status` (`status`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
