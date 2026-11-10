-- JawnTide vendor item fixes. Safe to re-run.
-- Crate of Phials of Bloody Tears (Darkbeat): costs 12 phials (still gives 10).
UPDATE `weenie_properties_int` SET `value` = 12 WHERE `object_Id` = 490283 AND `type` = 19;

-- Yaraq Outpost house item: its description named the Holtburg Governor.
UPDATE `weenie_properties_string`
SET `value` = 'This item can be hooked to the Floor or Yard hooks of mansions. Use this item to be transported to the Yaraq Governor.'
WHERE `object_Id` = 480632 AND `type` = 14;

-- Dark Isle and Snowy Valley house items had their names saved under the wrong property type.
DELETE FROM `weenie_properties_string` WHERE `object_Id` IN (490018, 490019) AND `type` IN (0, 1);
INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`) VALUES (490018, 1, 'Dark Isle'), (490019, 1, 'Snowy Valley');
