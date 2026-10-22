-- Darkbeat's Storage Locker (480607), Stage 1: its own copy of profile 10000, so the locker's
-- loot quality can be lowered without changing the Exquisite Casino Chest, which keeps 10000.
-- No database prefix: it is imported into whichever world database the import names.
DELETE FROM treasure_death WHERE treasure_Type = 10007;

INSERT INTO treasure_death
SET
  treasure_Type = 10007,
  tier = 8,
  loot_Quality_Mod = 0.43111,
  unknown_Chances = 19,
  item_Chance = 0,
  item_Min_Amount = 0,
  item_Max_Amount = 1,
  item_Treasure_Type_Selection_Chances = 11,
  magic_Item_Chance = 100,
  magic_Item_Min_Amount = 15,
  magic_Item_Max_Amount = 25,
  magic_Item_Treasure_Type_Selection_Chances = 22,
  mundane_Item_Chance = 0,
  mundane_Item_Min_Amount = 0,
  mundane_Item_Max_Amount = 1,
  mundane_Item_Type_Selection_Chances = 7
;
