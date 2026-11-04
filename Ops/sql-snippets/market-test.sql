-- JawnTide Marketplace: test the game server side without the website (JawnTest: USE jt_shard; live: USE ace_shard).
-- Each block is one step. Change the account ids / ids, run it, wait ~5 seconds, then run the "check" block.

USE jt_shard;

-- 1. Items in an account's mule (account 9 = patriots1). Pick an item_guid to list.
SELECT i.object_Id AS item_guid, s.value AS name, IFNULL(st.value, 1) AS stack
FROM biota_properties_i_i_d i
JOIN biota_properties_string s ON s.object_Id = i.object_Id AND s.type = 1
LEFT JOIN biota_properties_int st ON st.object_Id = i.object_Id AND st.type = 12
WHERE i.type = 2 AND i.value IN (
    SELECT container_Id FROM account_mule WHERE account_Id = 9
    UNION SELECT n.value FROM biota_properties_i_i_d n JOIN account_mule m ON n.object_Id = m.container_Id WHERE n.type = 20003)
ORDER BY name LIMIT 50;

-- 2. List an item (replace 0 with the item_guid): 2 MMDs or 50 PK Trophies.
INSERT INTO market_request (created_At, account_Id, character_Name, kind, item_Guid, price_Mmd, price_Trophies)
VALUES (UTC_TIMESTAMP(), 9, 'Az', 'list', 0, 2, 50);

-- 3. Buy it from another account (account 132 = cabamelee), paying with trophies (or 'mmd'). Replace 0 with the listing id.
INSERT INTO market_request (created_At, account_Id, character_Name, kind, listing_Id, pay_With)
VALUES (UTC_TIMESTAMP(), 132, 'Silas Renner', 'buy', 0, 'trophies');

-- 4. Cancel (item back to the seller's mule) or relist (30 more days). Replace 0 with the listing id.
INSERT INTO market_request (created_At, account_Id, character_Name, kind, listing_Id) VALUES (UTC_TIMESTAMP(), 9, 'Az', 'cancel', 0);
INSERT INTO market_request (created_At, account_Id, character_Name, kind, listing_Id) VALUES (UTC_TIMESTAMP(), 9, 'Az', 'relist', 0);

-- check
SELECT id, kind, status, result FROM market_request ORDER BY id DESC LIMIT 10;
SELECT id, name, stack_Size, status, price_Mmd, price_Trophies, expires_At, buyer_Name, paid_Currency, paid_Amount FROM market_listing ORDER BY id DESC LIMIT 10;
SELECT icon_Id, LENGTH(png) AS png_bytes FROM market_icon ORDER BY icon_Id LIMIT 20;
SELECT logged_At, account_Id, action, currency, amount, balance_After, details FROM account_bank_log WHERE action LIKE 'market%' ORDER BY id DESC LIMIT 10;
