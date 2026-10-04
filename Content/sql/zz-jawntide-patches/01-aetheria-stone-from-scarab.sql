-- JawnTide patch: Morgana Le Fay (NPC 32000110) hands out an Aetheria Mana Stone (42645)
-- every time a Platinum Scarab (8897) is shown to her.
--
-- The scarab is a "Refuse" emote (category 1), so she hands the scarab back and it is never used up.
-- A new Give action (type 3) is added to the END of that emote set. Emote ids are auto-numbered and
-- differ on every fresh database, so the set is found by NPC + category + item, never by id.
--
-- Safe to run repeatedly: it adds the action only if the set does not already give the stone.
-- Runs against whichever database the importer is connected to (ace_world); no database prefix on purpose.

INSERT INTO `weenie_properties_emote_action`
    (`emote_Id`, `order`, `type`, `delay`, `extent`, `weenie_Class_Id`, `stack_Size`, `palette`, `shade`)
SELECT e.`id`,
       (SELECT IFNULL(MAX(a.`order`), -1) + 1 FROM `weenie_properties_emote_action` a WHERE a.`emote_Id` = e.`id`),
       3, 1, 1, 42645, 1, 0, 0
FROM `weenie_properties_emote` e
WHERE e.`object_Id` = 32000110
  AND e.`category` = 1
  AND e.`weenie_Class_Id` = 8897
  AND NOT EXISTS (SELECT 1 FROM `weenie_properties_emote_action` x
                  WHERE x.`emote_Id` = e.`id` AND x.`type` = 3 AND x.`weenie_Class_Id` = 42645);
