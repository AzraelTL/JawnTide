-- Viridian Rise is closed for launch (VRContent patch): everything in this landblock is held back.
-- The stock version to restore is Ops/loot-stages/VRContent/landblocks/B44A.sql
DELETE FROM `landblock_instance` WHERE `landblock` = 0xB44A;
