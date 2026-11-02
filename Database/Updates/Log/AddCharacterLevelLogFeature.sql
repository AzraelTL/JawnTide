USE `ace_log`;

--
-- JawnTide: when each character first reached each level (written by the server on level up).
-- One row per character per level; if a character somehow reaches a level again, the first time is kept.
-- "Who hit 126 first": SELECT characterName, reachedAtUtc FROM character_level_log WHERE level = 126 ORDER BY reachedAtUtc;
--
-- NOT applied automatically: ACE's auto-patching covers Authentication, Shard and World only, not Log. Run it once by hand
-- against each server's ace_log (live already has it, made by Ops/tools/level-backfill). Safe to run again.
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
  `estimated` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = filled in afterwards from backups and monitor history',
  `windowMinutes` INT NULL COMMENT 'estimated rows: minutes between the two samples the time falls between',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uidx_character_level` (`characterId`, `level`),
  KEY `idx_level_time` (`level`, `reachedAtUtc`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
