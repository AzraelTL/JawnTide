-- JawnTide dupe check: a read-only report on the live databases. Changes nothing (only temporary tables).
-- Run on the Linux server (writes ~/dupe-report-DATE.txt):
--   cd ~/jawntide-server && git -C ~/JawnTide fetch -q origin dupe-check && git -C ~/JawnTide show origin/dupe-check:Ops/sql-snippets/dupe-check.sql | docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -t' > ~/dupe-report-$(date +%F).txt
--
-- Sections:
--   1. Stacks bigger than the item's maximum stack size (can't happen legitimately)
--   2. Twins: randomly generated loot (it has a workmanship its weenie doesn't) that exists more than once with exactly
--      the same rolled stats and spells. Two separate drops almost never match, so a twin is very likely a copy.
--   3. Biggest holders of pyreals (coins, trade notes and MMDs, plus the bank), PK Trophies and keys, per account,
--      so a sudden jump stands out when you compare reports from different days.
--   4. Every Darkbeat / Hera / Shimmering Skeleton key stack, largest first.
-- "Held by" follows each item up through packs to whoever has it: a character, a mule, a house chest, market
-- storage, or another container (a corpse or a world chest). Items lying on the ground aren't included.

SET SESSION group_concat_max_len = 1000000;
SET SESSION max_recursive_iterations = 100000;
USE ace_shard;

SET @market_storage := (SELECT CAST(v AS UNSIGNED) FROM market_meta WHERE k = 'storage_container');

-- ---------------------------------------------------------------- where every contained item is

DROP TEMPORARY TABLE IF EXISTS jt_top;
CREATE TEMPORARY TABLE jt_top (item INT UNSIGNED PRIMARY KEY, top INT UNSIGNED NOT NULL) ENGINE=InnoDB;

INSERT INTO jt_top (item, top)
WITH RECURSIVE up (item, cur, depth) AS (
    SELECT p.object_Id, p.value, 1 FROM biota_properties_i_i_d p WHERE p.type IN (2, 3)   -- Container, Wielder
    UNION ALL
    SELECT up.item, p.value, up.depth + 1
    FROM up JOIN biota_properties_i_i_d p ON p.object_Id = up.cur AND p.type IN (2, 3)
    WHERE up.depth < 12
)
SELECT item, CAST(SUBSTRING_INDEX(GROUP_CONCAT(cur ORDER BY depth DESC), ',', 1) AS UNSIGNED)
FROM up GROUP BY item;

-- mule containers and their accounts (each mule container can chain to the next one)
DROP TEMPORARY TABLE IF EXISTS jt_mule;
CREATE TEMPORARY TABLE jt_mule (container INT UNSIGNED PRIMARY KEY, account_Id INT UNSIGNED NOT NULL) ENGINE=InnoDB;

INSERT IGNORE INTO jt_mule (container, account_Id)
WITH RECURSIVE chain (account_Id, container_Id, depth) AS (
    SELECT account_Id, container_Id, 0 FROM account_mule WHERE container_Id <> 0
    UNION ALL
    SELECT c.account_Id, n.value, c.depth + 1 FROM chain c
    JOIN biota_properties_i_i_d n ON n.object_Id = c.container_Id AND n.type = 20003
    WHERE c.depth < 20
)
SELECT container_Id, account_Id FROM chain;

-- who each top-level holder is
DROP TEMPORARY TABLE IF EXISTS jt_holder;
CREATE TEMPORARY TABLE jt_holder (top INT UNSIGNED PRIMARY KEY, account_Id INT UNSIGNED NULL, held_by VARCHAR(120) NOT NULL) ENGINE=InnoDB;

INSERT INTO jt_holder (top, account_Id, held_by)
SELECT t.top,
       COALESCE(ch.account_Id, m.account_Id, hc.account_Id),
       CASE
           WHEN ch.id IS NOT NULL THEN CONCAT(ch.name, IF(ch.is_Deleted, ' (deleted)', ''))
           WHEN m.container IS NOT NULL THEN CONCAT('mule of account ', m.account_Id)
           WHEN hc.id IS NOT NULL THEN CONCAT('house chest of ', hc.name)
           WHEN t.top = @market_storage THEN 'market storage'
           ELSE CONCAT('other container 0x', HEX(t.top), ' (', COALESCE(tn.value, '?'), ')')
       END
FROM (SELECT DISTINCT top FROM jt_top) t
LEFT JOIN `character` ch ON ch.id = t.top
LEFT JOIN jt_mule m ON m.container = t.top
LEFT JOIN (
    SELECT b.id, c.account_Id, c.name
    FROM biota b
    JOIN biota_properties_i_i_d o ON o.object_Id = b.id AND o.type = 32          -- HouseOwner
    JOIN `character` c ON c.id = o.value
    WHERE b.weenie_Type = 57                                                     -- Storage
) hc ON hc.id = t.top
LEFT JOIN biota_properties_string tn ON tn.object_Id = t.top AND tn.type = 1;

-- every contained item with its weenie, name, stack size and holder
DROP TEMPORARY TABLE IF EXISTS jt_item;
CREATE TEMPORARY TABLE jt_item (
    item INT UNSIGNED PRIMARY KEY, wcid INT UNSIGNED NOT NULL, name VARCHAR(255) NULL, stack INT NOT NULL,
    account_Id INT UNSIGNED NULL, held_by VARCHAR(120) NOT NULL, KEY (wcid)
) ENGINE=InnoDB;

INSERT INTO jt_item (item, wcid, name, stack, account_Id, held_by)
SELECT t.item, b.weenie_Class_Id, n.value, COALESCE(s.value, 1), h.account_Id, h.held_by
FROM jt_top t
JOIN biota b ON b.id = t.item
JOIN jt_holder h ON h.top = t.top
LEFT JOIN biota_properties_string n ON n.object_Id = t.item AND n.type = 1
LEFT JOIN biota_properties_int s ON s.object_Id = t.item AND s.type = 12;          -- StackSize

-- ---------------------------------------------------------------- 1. oversized stacks

SELECT '1. STACKS BIGGER THAN THE MAXIMUM (impossible without a bug or a dupe)' AS `Section`;

SELECT CONCAT('0x', HEX(i.item)) AS item, i.name, i.stack, mx.value AS max_stack, i.held_by, i.account_Id AS account
FROM jt_item i
JOIN ace_world.weenie_properties_int mx ON mx.object_Id = i.wcid AND mx.type = 11                  -- MaxStackSize
WHERE mx.value > 0 AND i.stack > mx.value
ORDER BY i.stack / mx.value DESC
LIMIT 200;

-- ---------------------------------------------------------------- 2. twins

SELECT '2. TWINS: random loot with identical rolled stats and spells, more than one copy (likely duped)' AS `Section`;

-- loot rolled by the server: it has a workmanship, but its weenie doesn't define one (fixed quest/vendor items do)
DROP TEMPORARY TABLE IF EXISTS jt_loot;
CREATE TEMPORARY TABLE jt_loot (item INT UNSIGNED PRIMARY KEY, wcid INT UNSIGNED NOT NULL) ENGINE=InnoDB;

INSERT INTO jt_loot (item, wcid)
SELECT i.item, i.wcid
FROM jt_item i
JOIN biota_properties_int w ON w.object_Id = i.item AND w.type = 105                                 -- ItemWorkmanship
LEFT JOIN ace_world.weenie_properties_int ww ON ww.object_Id = i.wcid AND ww.type = 105
WHERE ww.object_Id IS NULL;

-- fingerprint of everything the loot roll decides (not wear: structure, current mana, wielded slot)
DROP TEMPORARY TABLE IF EXISTS jt_print;
CREATE TEMPORARY TABLE jt_print (item INT UNSIGNED PRIMARY KEY, wcid INT UNSIGNED NOT NULL, spells INT NOT NULL, fp MEDIUMTEXT NOT NULL) ENGINE=InnoDB;

INSERT INTO jt_print (item, wcid, spells, fp)
SELECT l.item, l.wcid, COALESCE(sp.n, 0),
       CONCAT(l.wcid, '|', COALESCE(pi.v, ''), '|', COALESCE(pf.v, ''), '|', COALESCE(sp.v, ''))
FROM jt_loot l
LEFT JOIN (
    SELECT object_Id, GROUP_CONCAT(CONCAT(type, '=', value) ORDER BY type) AS v
    FROM biota_properties_int
    WHERE object_Id IN (SELECT item FROM jt_loot)
      AND type IN (19, 28, 44, 45, 105, 106, 108, 109, 131, 158, 159, 160, 166, 171, 179, 204, 265, 315, 316, 317, 318,
                   370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390)
    GROUP BY object_Id
) pi ON pi.object_Id = l.item
LEFT JOIN (
    SELECT object_Id, GROUP_CONCAT(CONCAT(type, '=', ROUND(value, 5)) ORDER BY type) AS v
    FROM biota_properties_float
    WHERE object_Id IN (SELECT item FROM jt_loot)
      AND type IN (13, 14, 15, 16, 17, 18, 19, 22, 29, 39, 62, 63, 136, 144, 147, 149, 150, 151, 152, 155, 156, 157)
    GROUP BY object_Id
) pf ON pf.object_Id = l.item
LEFT JOIN (
    SELECT object_Id, COUNT(*) AS n, GROUP_CONCAT(spell ORDER BY spell) AS v
    FROM biota_properties_spell_book
    WHERE object_Id IN (SELECT item FROM jt_loot)
    GROUP BY object_Id
) sp ON sp.object_Id = l.item;

DROP TEMPORARY TABLE IF EXISTS jt_twin;
CREATE TEMPORARY TABLE jt_twin (fp_hash CHAR(32) PRIMARY KEY, copies INT NOT NULL, spells INT NOT NULL) ENGINE=InnoDB;

INSERT INTO jt_twin (fp_hash, copies, spells)
SELECT MD5(fp), COUNT(*), MAX(spells) FROM jt_print GROUP BY MD5(fp) HAVING COUNT(*) > 1;

SELECT DENSE_RANK() OVER (ORDER BY tw.spells DESC, tw.copies DESC, tw.fp_hash) AS `group`,
       tw.copies, tw.spells, CONCAT('0x', HEX(i.item)) AS item, i.name, i.held_by, i.account_Id AS account
FROM jt_twin tw
JOIN jt_print p ON MD5(p.fp) = tw.fp_hash
JOIN jt_item i ON i.item = p.item
ORDER BY tw.spells DESC, tw.copies DESC, tw.fp_hash, i.item
LIMIT 500;

-- ---------------------------------------------------------------- 3. biggest holders per account

SELECT '3. BIGGEST HOLDERS PER ACCOUNT (items in characters, mules and house chests, plus the bank)' AS `Section`;

DROP TEMPORARY TABLE IF EXISTS jt_money;
CREATE TEMPORARY TABLE jt_money (account_Id INT UNSIGNED PRIMARY KEY, pyreals BIGINT NOT NULL DEFAULT 0, trophies BIGINT NOT NULL DEFAULT 0, keys_ BIGINT NOT NULL DEFAULT 0) ENGINE=InnoDB;

INSERT INTO jt_money (account_Id, pyreals, trophies, keys_)
SELECT account_Id,
       SUM(CASE wcid WHEN 273 THEN stack
                     WHEN 2621 THEN stack * 100 WHEN 2622 THEN stack * 500 WHEN 2623 THEN stack * 1000
                     WHEN 2624 THEN stack * 5000 WHEN 2625 THEN stack * 10000 WHEN 7374 THEN stack * 15000
                     WHEN 7375 THEN stack * 20000 WHEN 7376 THEN stack * 25000 WHEN 2626 THEN stack * 50000
                     WHEN 7377 THEN stack * 75000 WHEN 2627 THEN stack * 100000 WHEN 20628 THEN stack * 150000
                     WHEN 20629 THEN stack * 200000 WHEN 20630 THEN stack * 250000 ELSE 0 END),
       SUM(IF(wcid = 1000002, stack, 0)),
       SUM(IF(wcid IN (480608, 490364, 30258), stack, 0))
FROM jt_item
WHERE account_Id IS NOT NULL
GROUP BY account_Id;

INSERT INTO jt_money (account_Id, pyreals, trophies, keys_)
SELECT account_Id,
       SUM(IF(currency = 'pyreals', amount, 0)),
       SUM(IF(currency = 'pk_trophies', amount, 0)),
       SUM(IF(currency IN ('key_darkbeat', 'key_hera', 'key_skeleton'), amount, 0))
FROM account_bank
GROUP BY account_Id
ON DUPLICATE KEY UPDATE pyreals = jt_money.pyreals + VALUES(pyreals), trophies = jt_money.trophies + VALUES(trophies), keys_ = jt_money.keys_ + VALUES(keys_);

DROP TEMPORARY TABLE IF EXISTS jt_names;
CREATE TEMPORARY TABLE jt_names (account_Id INT UNSIGNED PRIMARY KEY, characters VARCHAR(500) NULL) ENGINE=InnoDB;
INSERT INTO jt_names
SELECT account_Id, GROUP_CONCAT(name ORDER BY name SEPARATOR ', ') FROM `character` WHERE is_Deleted = 0 GROUP BY account_Id;

SELECT 'Pyreals (coins + trade notes + MMDs + bank), top 25' AS `Holders`;
SELECT m.account_Id AS account, FORMAT(m.pyreals, 0) AS pyreals, FORMAT(m.pyreals / 250000, 1) AS in_MMDs, LEFT(n.characters, 80) AS characters
FROM jt_money m LEFT JOIN jt_names n ON n.account_Id = m.account_Id
ORDER BY m.pyreals DESC LIMIT 25;

SELECT 'PK Trophies (items + bank), top 25' AS `Holders`;
SELECT m.account_Id AS account, FORMAT(m.trophies, 0) AS pk_trophies, LEFT(n.characters, 80) AS characters
FROM jt_money m LEFT JOIN jt_names n ON n.account_Id = m.account_Id
ORDER BY m.trophies DESC LIMIT 25;

SELECT 'Darkbeat, Hera and Shimmering Skeleton keys (items + bank), top 25' AS `Holders`;
SELECT m.account_Id AS account, m.keys_ AS `keys`, LEFT(n.characters, 80) AS characters
FROM jt_money m LEFT JOIN jt_names n ON n.account_Id = m.account_Id
ORDER BY m.keys_ DESC LIMIT 25;

-- ---------------------------------------------------------------- 4. key stacks

SELECT '4. KEY STACKS, largest first' AS `Section`;

SELECT CONCAT('0x', HEX(i.item)) AS item, i.name, i.stack, i.held_by, i.account_Id AS account
FROM jt_item i
WHERE i.wcid IN (480608, 490364, 30258)
ORDER BY i.stack DESC, i.item
LIMIT 50;

SELECT 'End of report' AS `Section`;
