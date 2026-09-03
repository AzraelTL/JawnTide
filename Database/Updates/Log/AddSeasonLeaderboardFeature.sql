USE `ace_log`;

-- Weekly milestone snapshot header (one row per Sunday 00:00 UTC milestone).
CREATE TABLE IF NOT EXISTS `season_milestone` (
  `id`                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `week_number`       INT NOT NULL,
  `snapshot_datetime` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_week` (`week_number`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;

-- One row per (milestone x category x rank) top-10 entry; tracks reward-bundle claims.
CREATE TABLE IF NOT EXISTS `season_milestone_leader` (
  `id`                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `milestone_id`      INT UNSIGNED NOT NULL,
  `week_number`       INT NOT NULL,
  `category`          VARCHAR(32) NOT NULL,
  `rank`              INT NOT NULL,
  `character_id`      INT UNSIGNED NOT NULL,
  `character_name`    VARCHAR(64),
  `score`             BIGINT NOT NULL DEFAULT 0,
  `reward_claimed`    BIT NOT NULL DEFAULT 0,
  `claimed_datetime`  DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `idx_milestone_cat_rank` (`milestone_id`, `category`, `rank`),
  KEY `idx_char_claimed` (`character_id`, `reward_claimed`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;

-- Cumulative Season Champion points per character (one row per character).
CREATE TABLE IF NOT EXISTS `season_champion_points` (
  `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `character_id`   INT UNSIGNED NOT NULL,
  `character_name` VARCHAR(64),
  `points`         BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uidx_character` (`character_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
