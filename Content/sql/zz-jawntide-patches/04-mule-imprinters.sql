/* JawnTide: places the three Mule Imprint Token NPCs in the starter towns (Holtburg and Shoushi spots picked in game).
   Runs after Content/sql/landblocks (which rebuild these landblocks), so the NPCs are added back on every start.
   Fixed guids, safe to run repeatedly. Move them by changing the coordinates below. */

/* 0x7DE51F00 was an early wrong Shoushi spot; it stays in the DELETE so old test databases are cleaned up */
DELETE FROM `landblock_instance` WHERE `guid` IN (0x7A9B4F00, 0x7DE51F00, 0x7DA55F00, 0x77D64F00);

/* Holtburg (Aluvian) - Imprinter Aldric Hale */
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7A9B4F00, 8143001, 0xA9B40022, 100.121597, 24.226934, 94.005005, 0.512091, 0, 0, 0.858931, False, '2026-11-01 00:00:00');
/* @teleloc 0xA9B40022 [100.121597 24.226934 94.005005] 0.512091 0.000000 0.000000 0.858931 */

/* Shoushi (Sho) - Imprinter Mei Shou-Lin */
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7DA55F00, 8143002, 0xDA55001D, 92.122597, 116.039787, 20.004999, 0.339815, 0, 0, 0.940492, False, '2026-11-01 00:00:00');
/* @teleloc 0xDA55001D [92.122597 116.039787 20.004999] 0.339815 0.000000 0.000000 0.940492 */

/* Yaraq (Gharundim) - Imprinter Farid ibn Rashad */
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x77D64F00, 8143003, 0x7D64000D, 40.7105, 108.788, 12.005, 0.660946, 0, 0, -0.750434, False, '2026-11-01 00:00:00');
/* @teleloc 0x7D64000D [40.710499 108.788002 12.005000] 0.660946 0.000000 0.000000 -0.750434 */
