-- Viridian Rise is closed for launch (VRContent patch): everything in this landblock is held back.
-- The stock version to restore is Ops/loot-stages/VRContent/landblocks/5966.sql
DELETE FROM `landblock_instance` WHERE `landblock` = 0x5966;
