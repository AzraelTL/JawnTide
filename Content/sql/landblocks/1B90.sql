-- JawnTide: normal world content (stock ACE), Black Spawn Den entrance. Its stock portal is back now that the T9 dungeons run in their own copies.
DELETE FROM `landblock_instance` WHERE `landblock` = 0x1B90 AND `variation_id` IS NULL;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x71B90000, 7242, 0x1B900000, 122.404, 87.4296, 30.005, 0.008428, 0, 0, 0.999964, False, '2005-02-09 10:00:00'); /* Black Spawn Den */
/* @teleloc 0x1B900000 [122.403999 87.429604 30.004999] 0.008428 0.000000 0.000000 0.999964 */
