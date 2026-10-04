-- JawnTide patch: luminance aura tokens respawn about a second after pickup.
--
-- Tokens are children of the placed generator weenie 15759. Respawn time = the profile delay
-- (weenie_properties_generator, template row whose item is the placeholder weenie 3666)
-- plus the generator's RegenerationInterval (PropertyFloat 41).
-- Both were 10 seconds; they are set to 0 and 1.
--
-- NOTE: weenie 15759 is shared by roughly 200 placed instances, so this speeds up every one of them.
-- Safe to run repeatedly. No database prefix on purpose (see the other patch file).

UPDATE `weenie_properties_generator`
SET `delay` = 0
WHERE `object_Id` = 15759 AND `weenie_Class_Id` = 3666;

UPDATE `weenie_properties_float`
SET `value` = 1
WHERE `object_Id` = 15759 AND `type` = 41;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
SELECT 15759, 41, 1
WHERE EXISTS (SELECT 1 FROM `weenie` WHERE `class_Id` = 15759)
  AND NOT EXISTS (SELECT 1 FROM `weenie_properties_float` WHERE `object_Id` = 15759 AND `type` = 41);
