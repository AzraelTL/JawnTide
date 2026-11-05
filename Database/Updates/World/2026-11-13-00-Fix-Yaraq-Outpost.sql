-- JawnTide: the Yaraq Outpost (hooked in a mansion) teleported players to the Yaraq Governor and then straight to their lifestone.
-- Its teleport rotation wasn't a unit quaternion, so the position check after the teleport failed. Same fix the Outpost gem got
-- in a27caf7ef. Also its description named the Holtburg Governor. Safe to re-run.

UPDATE `weenie_properties_emote_action` a
JOIN `weenie_properties_emote` e ON e.`id` = a.`emote_Id`
SET a.`angles_Z` = -0.716226
WHERE e.`object_Id` = 480632 AND a.`type` = 99 AND ABS(a.`angles_Z` + 0.714859) < 0.000001;

UPDATE `weenie_properties_string`
SET `value` = 'This item can be hooked to the Floor or Yard hooks of mansions. Use this item to be transported to the Yaraq Governor.'
WHERE `object_Id` = 480632 AND `type` = 14;
