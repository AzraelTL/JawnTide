/* JawnTide Suit Builder: a saved list can hold up to 500 items (the "beaten items" list), so items becomes TEXT. Safe to re-run. */
ALTER TABLE `suit_plan` MODIFY COLUMN `items` TEXT NOT NULL;
