-- JawnTide: Town Control version of 0x4FF1 (variation 2). Spawns only inside a running event's private copy.
-- Guids are the DocTide guids + 0x800 so they don't clash with the stock (normal world) guids.
DELETE FROM `landblock_instance` WHERE `landblock` = 0x4FF1 AND `variation_id` = 2;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
VALUES (0x74FF1BF3, 73068, 0x4FF10128, 80.9026, 107.106, 79.2034, -1, 0, 0, 0, False, '2021-11-01 00:00:00', 2); /* Dardante's Keep */
/* @teleloc 0x4FF10128 [80.902603 107.106003 79.203400] -1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
VALUES (0x74FF1BF4,   412, 0x4FF10124, 78.5016, 110.517, 84.082, -1, 0, 0, 0, False, '2021-11-01 00:00:00', 2); /* Door */
/* @teleloc 0x4FF10124 [78.501602 110.516998 84.082001] -1.000000 0.000000 0.000000 0.000000 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
VALUES (0x74FF1BF5, 4200012, 0x4FF1001B, 84.1818, 61.7537, 84.055, -0.009572, 0, 0, -0.999954, False, '2023-01-21 20:07:55', 2); /* towncontrolevent2 */
/* @teleloc 0x4FF1001B [84.181801 61.753700 84.055000] -0.009572 0.000000 0.000000 -0.999954 */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`, `variation_id`)
VALUES (0x74FF1BF6, 80007, 0x4FF1001C, 84.52084, 72.12319, 84.05501, 0.044328, 0, 0, -0.999017, False, '2023-02-19 12:32:10', 2); /* Landblock KeepAlive */
/* @teleloc 0x4FF1001C [84.520844 72.123192 84.055008] 0.044328 0.000000 0.000000 -0.999017 */
