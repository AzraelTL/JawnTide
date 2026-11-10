/* JawnTide PvP balance tools.
   training_dummy         = the settings of each placed Target Drudge (armor, defenses, ratings, buffs), by its guid.
   training_dummy_session = one row per finished attack session on a Target Drudge: who, with what, the result,
                            the dummy's setup and every pvp_* setting in effect at the time.
   settings_request       = server setting changes made on the LAN admin page; the game server applies them
                            (like @modifydouble) within a few seconds and fills in status.
   Applied automatically at server start (AutoApplyDatabaseUpdates). */

CREATE TABLE IF NOT EXISTS `training_dummy` (
    `dummy_Guid`      INT UNSIGNED NOT NULL,
    `armor`           INT          NOT NULL DEFAULT 0,
    `melee_Defense`   INT          NOT NULL DEFAULT 0,
    `missile_Defense` INT          NOT NULL DEFAULT 0,
    `magic_Defense`   INT          NOT NULL DEFAULT 0,
    `damage_Resist_Rating`      INT NOT NULL DEFAULT 0,
    `crit_Damage_Resist_Rating` INT NOT NULL DEFAULT 0,
    `pk_Damage_Resist_Rating`   INT NOT NULL DEFAULT 0,
    `spells`          VARCHAR(1024) NULL,
    `updated_At`      DATETIME     NOT NULL,
    PRIMARY KEY (`dummy_Guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `training_dummy_session` (
    `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `started_At`       DATETIME        NOT NULL,
    `ended_At`         DATETIME        NOT NULL,
    `dummy_Guid`       INT UNSIGNED    NOT NULL,
    `character_Id`     INT UNSIGNED    NOT NULL,
    `character_Name`   VARCHAR(64)     NULL,
    `character_Level`  INT             NOT NULL DEFAULT 0,
    `seconds`          DOUBLE          NOT NULL DEFAULT 0,
    `attacks`          INT             NOT NULL DEFAULT 0,
    `hits`             INT             NOT NULL DEFAULT 0,
    `evaded`           INT             NOT NULL DEFAULT 0,
    `resisted`         INT             NOT NULL DEFAULT 0,
    `crits`            INT             NOT NULL DEFAULT 0,
    `damage`           BIGINT          NOT NULL DEFAULT 0,
    `dps`              DOUBLE          NOT NULL DEFAULT 0,
    `dummy_Setup`      VARCHAR(1024)   NULL,
    `sources`          TEXT            NULL,
    `settings`         TEXT            NULL,
    PRIMARY KEY (`id`),
    KEY `ix_training_dummy_session_time` (`ended_At`),
    KEY `ix_training_dummy_session_char` (`character_Id`, `ended_At`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `settings_request` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `requested_At` DATETIME        NOT NULL,
    `requested_By` VARCHAR(64)     NULL,
    `key`          VARCHAR(128)    NOT NULL,
    `type`         VARCHAR(8)      NOT NULL,
    `value`        VARCHAR(64)     NOT NULL,
    `status`       VARCHAR(16)     NOT NULL DEFAULT 'pending',
    `applied_At`   DATETIME        NULL,
    `message`      VARCHAR(255)    NULL,
    PRIMARY KEY (`id`),
    KEY `ix_settings_request_status` (`status`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
