/* JawnTide: the Target Drudge counts as a Human, the same as a player character, so human slayer weapons
   (Bael'Zharon's Hate on the weeping weapons) hit it as they hit players. It still looks like a drudge. Safe to re-run. */

UPDATE `weenie_properties_int` SET `value` = 31 WHERE `object_Id` = 4290001 AND `type` = 2;
