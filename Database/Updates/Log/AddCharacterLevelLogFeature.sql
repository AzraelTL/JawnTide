USE `ace_log`;

--
-- JawnTide: when each character first reached each level (written by the server on level up).
-- One row per character per level; if a character somehow reaches a level again, the first time is kept.
-- "Who hit 126 first": SELECT characterName, reachedAtUtc FROM character_level_log WHERE level = 126 ORDER BY reachedAtUtc;
--

CREATE TABLE IF NOT EXISTS `character_level_log` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `characterId` INT UNSIGNED NOT NULL,
  `characterName` VARCHAR(255) NOT NULL,
  `accountId` INT UNSIGNED NOT NULL,
  `level` INT NOT NULL,
  `totalExperience` BIGINT NOT NULL DEFAULT 0 COMMENT 'total XP right after the level up',
  `ageSeconds` INT NOT NULL DEFAULT 0 COMMENT 'played time (seconds) at the level up',
  `reachedAtUtc` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uidx_character_level` (`characterId`, `level`),
  KEY `idx_level_time` (`level`, `reachedAtUtc`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
