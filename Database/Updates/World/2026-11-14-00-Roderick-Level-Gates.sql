-- JawnTide: Roderick (38034) was given a level 180 check on every quest item turn-in (2026-10-24 level gates), but most of his
-- turn-ins are lower-level quests. Only the Falatacot Blood Prophetess Trinket and the Void Crystal keep the level 180 check.
-- The Reign of Alfrega (Mount Lethe Recall), the Broken Staff and Slag (Impious Staff) and the Rose Quartz Wedding Ring
-- (Rose of Celdon) have no level check again, like stock. Safe to re-run.

UPDATE `weenie_properties_emote_action` a
JOIN `weenie_properties_emote` e ON e.`id` = a.`emote_Id`
SET a.`min` = 1
WHERE e.`object_Id` = 38034 AND a.`type` = 36
  AND a.`message` IN ('JT_LevelGate_180_5681_9', 'JT_LevelGate_180_5936_10', 'JT_LevelGate_180_5939_11', 'JT_LevelGate_180_31977_12');
