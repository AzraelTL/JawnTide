-- Darkbeat's Storage Locker (480607), Stage 1: its own copy of profile 10000, so the locker's
-- loot quality can be lowered without changing the Exquisite Casino Chest, which keeps 10000.
-- No database prefix: it is imported into whichever world database the import names.
DELETE FROM treasure_death WHERE treasure_Type = 10007;

INSERT INTO treasure_death
(
  treasure_Type,
  tier,
  loot_Quality_Mod,
  unknown_Chances,
  item_Chance,
  item_Min_Amount,
  item_Max_Amount,
  item_Treasure_Type_Selection_Chances,
  magic_Item_Chance,
  magic_Item_Min_Amount,
  magic_Item_Max_Amount,
  magic_Item_Treasure_Type_Selection_Chances,
  mundane_Item_Chance,
  mundane_Item_Min_Amount,
  mundane_Item_Max_Amount,
  mundane_Item_Type_Selection_Chances
)
VALUES
(  
  10007,
  8,
  0.95875,
  19,
  0,
  0,
  1,
  11,
  100,
  25,
  35,
  22,
  0,
  0,
  1,
  7
);
