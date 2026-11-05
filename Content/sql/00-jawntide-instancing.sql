-- JawnTide instancing: landblock_instance.variation_id
-- NULL = normal world content. A value = content that only spawns in instanced copies (1 = arena matches).
-- Runs before the landblock files (sort order), so they can use the column.
ALTER TABLE `landblock_instance` ADD COLUMN IF NOT EXISTS `variation_id` INT NULL DEFAULT NULL COMMENT 'JawnTide instancing: NULL = normal world, otherwise content for instanced copies';
ALTER TABLE `landblock_instance` ADD INDEX IF NOT EXISTS `instance_variation_idx` (`variation_id`);
