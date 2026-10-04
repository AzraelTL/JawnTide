-- =====================================================================
-- ace_town_control: towns, conflict events, archive
-- Holtburg (72), Shoushi (91) and Yaraq (102) are inserted by default.
-- Safe to re-run: existing tables and rows are left alone.
-- =====================================================================

-- Host: localhost    Database: ace_town_control
-- ------------------------------------------------------
-- Server version	8.0.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `ace_town_control`
--


CREATE DATABASE IF NOT EXISTS `ace_town_control` DEFAULT CHARACTER SET utf8mb4;

USE `ace_town_control`;

--
-- Table structure for table `town`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `town` (
  `town_id` INT UNSIGNED NOT NULL COMMENT 'Unique Id of the town from world points_of_interest',
  `town_name` TEXT NOT NULL COMMENT 'Name of the town',
  `owner_Id` INT UNSIGNED NULL COMMENT 'character id of the monarch who owns the town', 
  `is_in_conflict` BIT(1) NOT NULL DEFAULT 0,
  `last_conflict_start_time` DATETIME NULL,
  `conflict_length` INT UNSIGNED NOT NULL COMMENT 'length of time in seconds the conflict lasts before a winner is declared',
  `conflict_respite_length` INT UNSIGNED NOT NULL COMMENT 'length of time in seconds before a new conflict can be initiated since the last one was started',
  `attacker_awards_individual` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'max trophies awarded to each attacker on a successful attack',
  `attacker_awards_total` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'total trophies split among attackers',
  `defender_awards_individual` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'max trophies awarded to each defender on a successful defense',
  `defender_awards_total` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'total trophies split among defenders',
  PRIMARY KEY (`town_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

INSERT IGNORE INTO `town`
(
  `town_id`,
  `town_name`,
  `owner_Id`, 
  `is_in_conflict`,
  `last_conflict_start_time`,
  `conflict_length`,
  `conflict_respite_length`
) 
VALUES 
( 
  91,
  'Shoushi',
  NULL,
  0,
  NULL,
  1800,/*30 mins*/
  129600 /*36 hrs*/
);

INSERT IGNORE INTO `town`
(
  `town_id`,
  `town_name`,
  `owner_Id`, 
  `is_in_conflict`,
  `last_conflict_start_time`,
  `conflict_length`,
  `conflict_respite_length`
) 
VALUES 
( 
  72,
  'Holtburg',
  NULL,
  0,
  NULL,
  1800,/*30 mins*/
  129600 /*36 hrs*/
);

INSERT IGNORE INTO `town`
(
  `town_id`,
  `town_name`,
  `owner_Id`, 
  `is_in_conflict`,
  `last_conflict_start_time`,
  `conflict_length`,
  `conflict_respite_length`
) 
VALUES 
( 
  102,
  'Yaraq',
  NULL,
  0,
  NULL,
  1800,/*30 mins*/
  129600 /*36 hrs*/
);


--
-- Table structure for table `town_control_event`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `town_control_event` (
  `event_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique Id of the town control event',
  `town_id` INT UNSIGNED NOT NULL,
  `event_start_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `event_end_time` DATETIME NULL,
  `attacker_id` INT UNSIGNED NOT NULL COMMENT 'character id of the monarch who clan is attacking the town', 
  `attacker_clan_name` TEXT NOT NULL COMMENT 'name of the clan who is attacking the town',
  `defender_id` INT UNSIGNED NULL COMMENT 'character id of the monarch whose clan is defending the town', 
  `defender_clan_name` TEXT NULL COMMENT 'name of the clan who is defending the town',
  `is_attack_success` BIT(1) NULL,
  PRIMARY KEY (`event_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- ---- Town control event archive ----
CREATE TABLE IF NOT EXISTS `town_control_event_archive` (
  `event_id` INT UNSIGNED NOT NULL COMMENT 'Unique Id of the town control event',
  `town_id` INT UNSIGNED NOT NULL,
  `event_start_time` DATETIME NOT NULL,
  `event_end_time` DATETIME NULL,
  `attacker_id` INT UNSIGNED NOT NULL COMMENT 'character id of the monarch who clan is attacking the town',
  `attacker_clan_name` TEXT NOT NULL COMMENT 'name of the clan who is attacking the town',
  `defender_id` INT UNSIGNED NULL COMMENT 'character id of the monarch whose clan is defending the town',
  `defender_clan_name` TEXT NULL COMMENT 'name of the clan who is defending the town',
  `is_attack_success` BIT(1) NULL,
  PRIMARY KEY (`event_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;

-- ---- Upgrade for databases created before the reward columns existed ----
-- (No-op on a fresh install. The server's Town entity maps these four columns.)
ALTER TABLE `town`
  ADD COLUMN IF NOT EXISTS `attacker_awards_individual` INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `attacker_awards_total`      INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `defender_awards_individual` INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `defender_awards_total`      INT UNSIGNED NOT NULL DEFAULT 0;

-- Reward amounts default to 0 (no trophies). Set real values per town, for example:
-- UPDATE `town` SET attacker_awards_individual = 10, attacker_awards_total = 100,
--                   defender_awards_individual = 10, defender_awards_total = 100;
