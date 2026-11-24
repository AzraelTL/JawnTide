-- JawnTide: the Master Statue of 'Freebooter Isle' Transport (41175, Society Masters) casts Travel to the Ruins of Degar'Alesh (4721).
-- Its stock destination rotation is (W 1, Z -1), which isn't a valid rotation, so every teleport failed with
-- "The location you have been teleported to was invalid". Normalized to (W 0.707107, Z -0.707107): same facing. Safe to re-run.
UPDATE `spell` SET `position_Angles_W` = 0.707107, `position_Angles_X` = 0, `position_Angles_Y` = 0, `position_Angles_Z` = -0.707107
WHERE `id` = 4721 AND `position_Angles_W` = 1 AND `position_Angles_Z` = -1;
