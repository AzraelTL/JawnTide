-- Seed the world version row so the server's AutoUpdateWorldDatabase can build the world.
--
-- On startup the server reads the `version` table (row id 1) before it does anything else.
-- With no row, the check fails, the world download never starts, and the server crashes a moment
-- later because the world tables are empty. Version 0.0.0 makes the server see it as out of date,
-- download the latest stock world release (v0.9.x), import it, and then apply Content/sql.
--
-- INSERT IGNORE: safe to run repeatedly, and it never overwrites a real version row.
USE `ace_world`;
INSERT IGNORE INTO `version` (`id`, `base_Version`, `patch_Version`) VALUES (1, '0.0.0', '0.0.0');
