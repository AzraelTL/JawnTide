-- JawnTide: arena version of 0x02AA Desert March (variation 1): the drop room with its north and south exits walled off.
-- Spawns only inside arena match instances; the normal world Desert March is stock.
DELETE FROM `landblock_instance` WHERE `landblock` = 0x02AA AND `variation_id` = 1;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
VALUES (0x702AA800, 5000216, 0x02AA022C, 49.911003, -474.79715, 30.004999, -0.030716, 0, 0, 0.999528, False, '2026-11-05 00:00:00', 1) /* Gate - north exit */
     , (0x702AA801, 5000216, 0x02AA0230, 50.062916, -505.037689, 30.004999, 0.999497, 0, 0, 0.031715, False, '2026-11-05 00:00:00', 1) /* Gate - south exit */;
/* @teleloc 0x02AA022C [49.911003 -474.797150 30.004999] -0.030716 0.000000 0.000000 0.999528 */
/* @teleloc 0x02AA0230 [50.062916 -505.037689 30.004999] 0.999497 0.000000 0.000000 0.031715 */
