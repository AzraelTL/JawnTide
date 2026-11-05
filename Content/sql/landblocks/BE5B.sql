DELETE FROM `landblock_instance` WHERE `landblock` = 0xBE5B;

/* The Banderling Conquest Dungeon portal stood here; the dungeon is now an arena. A Banderling Mace Shaft
   lies on the ground in its place so the quest can still be done, and respawns 25 seconds after pickup. */

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7BE5B000,  5085, 0xBE5B001A, 84.927895, 36.547455, 6.005, 0.905814, 0, 0, 0.423676, False, '2026-10-23 00:00:00'); /* Linkable Item Gen - 25 seconds */
/* @teleloc 0xBE5B001A [84.927895 36.547455 6.005000] 0.905814 0.000000 0.000000 0.423676 */

INSERT INTO `landblock_instance_link` (`parent_GUID`, `child_GUID`, `last_Modified`)
VALUES (0x7BE5B000, 0x7BE5B001, '2026-10-23 00:00:00') /* Banderling Mace Shaft (8365) */;

INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7BE5B001,  8365, 0xBE5B001A, 84.927895, 36.547455, 6.005, 0.905814, 0, 0, 0.423676, True, '2026-10-23 00:00:00'); /* Banderling Mace Shaft */

-- JawnTide: the stock Banderling Conquest Dungeon portal is back (the dungeon is normal content again; the Tusker Queen fights in a private copy)
INSERT INTO `landblock_instance` (`guid`, `weenie_Class_Id`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`, `is_Link_Child`, `last_Modified`)
VALUES (0x7BE5B002, 8379, 0xBE5B0000, 99.8725, 28.6991, 6.005, -0.619617, 0, 0, 0.784904, False, '2005-02-09 10:00:00'); /* Banderling Conquest Dungeon */
/* @teleloc 0xBE5B0000 [99.872498 28.699100 6.005000] -0.619617 0.000000 0.000000 0.784904 */
