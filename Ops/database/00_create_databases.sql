-- =====================================================================
-- ZaiusTide: create the databases
-- Databases used by the ZaiusTide server (see Config.js "MySql" section).
-- Safe to re-run: existing tables and rows are left alone.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `ace_auth`         DEFAULT CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS `ace_shard`        DEFAULT CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS `ace_world`        DEFAULT CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS `ace_log`          DEFAULT CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS `ace_town_control` DEFAULT CHARACTER SET utf8mb4;

-- Optional: a dedicated database user instead of root. Change the password, then
-- remove the leading "-- " from the lines below and re-run this file.
-- CREATE USER IF NOT EXISTS 'ace'@'localhost' IDENTIFIED BY 'CHANGE_ME';
-- GRANT ALL PRIVILEGES ON `ace_auth`.*         TO 'ace'@'localhost';
-- GRANT ALL PRIVILEGES ON `ace_shard`.*        TO 'ace'@'localhost';
-- GRANT ALL PRIVILEGES ON `ace_world`.*        TO 'ace'@'localhost';
-- GRANT ALL PRIVILEGES ON `ace_log`.*          TO 'ace'@'localhost';
-- GRANT ALL PRIVILEGES ON `ace_town_control`.* TO 'ace'@'localhost';
-- FLUSH PRIVILEGES;
