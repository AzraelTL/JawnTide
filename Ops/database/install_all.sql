-- Run this FROM THIS FOLDER:   mysql -u root -p < install_all.sql
--                       or:    sudo mariadb < install_all.sql     (Debian, root via sudo)
-- (SOURCE paths are relative to the folder you run the command in.)
SOURCE 00_create_databases.sql;
SOURCE 01_ace_auth.sql;
SOURCE 02_ace_shard.sql;
SOURCE 03_ace_world.sql;
SOURCE 04_ace_world_dungeon_info.sql;
SOURCE 05_ace_log.sql;
SOURCE 06_ace_town_control.sql;
SOURCE 07_ace_world_version_seed.sql;
