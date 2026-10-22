DELETE FROM `landblock_instance` WHERE `landblock` = 0xB54A;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A011, 15759, 0xB54A001D, 86.0167, 110.633, 117.999, 0.998266, 0, 0, -0.05886, False, '2022-06-21 15:22:25'); /* Linkable Item Generator */
/* @teleloc 0xB54A001D [86.016701 110.633003 117.999001] 0.998266 0.000000 0.000000 -0.058860 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7B54A011, 0x7B54A012, '2022-06-21 15:22:25') /* Token of the New Paragon (53479) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A012, 53479, 0xB54A001D, 86.0167, 110.633, 117.999, 0.998266, 0, 0, -0.05886,  True, '2022-06-21 15:22:25'); /* Token of the New Paragon */
/* @teleloc 0xB54A001D [86.016701 110.633003 117.999001] 0.998266 0.000000 0.000000 -0.058860 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A013,  1154, 0xB54A0021, 113.183, 1.83517, 27.0228, 0.974881, 0, 0, 0.222727, False, '2022-06-21 15:22:25'); /* Linkable Monster Generator */
/* @teleloc 0xB54A0021 [113.182999 1.835170 27.022800] 0.974881 0.000000 0.000000 0.222727 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7B54A013, 0x7B54A015, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A016, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A017, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A019, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A01A, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A01F, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A022, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A024, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A026, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */
     , (0x7B54A013, 0x7B54A027, '2022-06-21 15:22:25') /* Sath'tik Eyestalk (53375) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A015, 53375, 0xB54A003A, 174.412, 34.1043, 19.982, 0.848695, 0, 0, -0.528883,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A003A [174.412003 34.104301 19.982000] 0.848695 0.000000 0.000000 -0.528883 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A016, 53375, 0xB54A0020, 80.4467, 190.72, 15.0648, 0.669118, 0, 0, 0.743157,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0020 [80.446701 190.720001 15.064800] 0.669118 0.000000 0.000000 0.743157 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A017, 53375, 0xB54A0028, 112.509, 191.229, 11.1019, 0.669118, 0, 0, 0.743157,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0028 [112.509003 191.229004 11.101900] 0.669118 0.000000 0.000000 0.743157 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A019, 53375, 0xB54A0038, 152.219, 174.835, 9.982, 0.731321, 0, 0, 0.682033,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0038 [152.218994 174.835007 9.982000] 0.731321 0.000000 0.000000 0.682033 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A01A, 53375, 0xB54A0040, 174.788, 171.798, 11.5644, 0.314811, 0, 0, 0.949154,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0040 [174.787994 171.798004 11.564400] 0.314811 0.000000 0.000000 0.949154 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A01F, 53375, 0xB54A0028, 113.878, 187.973, 10.3311, 0.669118, 0, 0, 0.743157,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0028 [113.877998 187.973007 10.331100] 0.669118 0.000000 0.000000 0.743157 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A022, 53375, 0xB54A003A, 177.362, 30.6245, 19.982, 0.848695, 0, 0, -0.528883,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A003A [177.362000 30.624500 19.982000] 0.848695 0.000000 0.000000 -0.528883 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A024, 53375, 0xB54A0038, 151.717, 176.987, 9.982, 0.731321, 0, 0, 0.682033,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0038 [151.716995 176.987000 9.982000] 0.731321 0.000000 0.000000 0.682033 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A026, 53375, 0xB54A0040, 180.376, 174.562, 12.7164, 0.314811, 0, 0, 0.949154,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0040 [180.376007 174.561996 12.716400] 0.314811 0.000000 0.000000 0.949154 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7B54A027, 53375, 0xB54A0020, 82.778, 190.577, 14.8467, 0.669118, 0, 0, 0.743157,  True, '2022-06-21 15:22:25'); /* Sath'tik Eyestalk */
/* @teleloc 0xB54A0020 [82.778000 190.576996 14.846700] 0.669118 0.000000 0.000000 0.743157 */
