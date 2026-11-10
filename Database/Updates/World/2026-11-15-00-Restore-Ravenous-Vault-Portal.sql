-- JawnTide: the Ravenous Vault portal (92.8N, 48.9W, landblock 42F3) is back.
-- It was removed in Sept 2024 when the Ravenous Vault (039D) became the One Ten arena. Arena matches now run in private
-- copies of 039D (2026-11-07-00-Instanced-Arenas.sql) and the normal dungeon has its stock content, so the stock portal
-- can come back. Safe to re-run.

INSERT IGNORE INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (1949249536, 28802, 1123221524, 54.3933, 91.5131, 4.97414, -0.99999, 0, 0, -0.004526, False, '2021-11-01 00:00:00'); /* Ravenous Vault (0x742F3000 at 0x42F30014) */
