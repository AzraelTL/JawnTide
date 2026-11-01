/* JawnTide: places the three Mule Imprint Token NPCs, a few steps from the life stone in each starter town.
   Runs after Content/sql/landblocks (which rebuild these landblocks), so the NPCs are added back on every start.
   Fixed guids, safe to run repeatedly. Move them by changing the coordinates below. */

DELETE FROM `landblock_instance` WHERE `guid` IN (0x7A9B4F00, 0x7DE51F00, 0x77D64F00);

/* Holtburg (Aluvian) - Imprinter Aldric Hale */
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7A9B4F00, 8143001, 0xA9B40019, 84.3304, 14.7974, 94.005, 0.839091, 0, 0, -0.543991, False, '2026-11-01 00:00:00');
/* @teleloc 0xA9B40019 [84.330399 14.797400 94.005000] 0.839091 0.000000 0.000000 -0.543991 */

/* Shoushi (Sho) - Imprinter Mei Shou-Lin */
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7DE51F00, 8143002, 0xDE51000D, 30.1355, 104.376, 17.3011, -0.321188, 0, 0, -0.947015, False, '2026-11-01 00:00:00');
/* @teleloc 0xDE51000D [30.135500 104.376000 17.301100] -0.321188 0.000000 0.000000 -0.947015 */

/* Yaraq (Gharundim) - Imprinter Farid ibn Rashad */
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x77D64F00, 8143003, 0x7D64000D, 40.7105, 108.788, 12.005, 0.660946, 0, 0, -0.750434, False, '2026-11-01 00:00:00');
/* @teleloc 0x7D64000D [40.710499 108.788002 12.005000] 0.660946 0.000000 0.000000 -0.750434 */
