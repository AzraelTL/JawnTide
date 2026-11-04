#!/usr/bin/env bash
# One-time (safe to re-run) marketplace setup on the Linux server, AFTER the game server with the marketplace has started once
# (that creates the ace_shard market tables). Runs as root inside ace-db and gives the website (web) only what /market needs:
#   read  ace_shard.market_listing, market_icon, market_request; add rows to market_request (the game server does the rest)
#   read  ace_web.market_mule_item: a view of mule contents (name, stack, icons, attuned/bonded, details) and nothing else about items
# Grants go to every host entry web already has. Prints the grants it made.
set -euo pipefail
cd ~/jawntide-server
docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD"' <<'SQL'
CREATE DATABASE IF NOT EXISTS ace_web;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW ace_web.market_mule_item AS
WITH RECURSIVE chain (account_Id, container_Id, depth) AS (
    SELECT account_Id, container_Id, 0 FROM ace_shard.account_mule WHERE container_Id <> 0
    UNION ALL
    SELECT c.account_Id, n.value, c.depth + 1 FROM chain c
    JOIN ace_shard.biota_properties_i_i_d n ON n.object_Id = c.container_Id AND n.type = 20003
    WHERE c.depth < 20
)
SELECT c.account_Id,
       i.object_Id                        AS item_Guid,
       nm.value                           AS name,
       mt.value                           AS material,
       IFNULL(st.value, 1)                AS stack_Size,
       IFNULL(it.value, 0)                AS item_Type,
       IFNULL(ic.value, 0)                AS icon_Id,
       IFNULL(o1.value, 0)                AS icon_Overlay_Id,
       IFNULL(o2.value, 0)                AS icon_Overlay2_Id,
       IFNULL(ul.value, 0)                AS icon_Underlay_Id,
       IFNULL(ui.value, 0)                AS ui_Effects,
       IFNULL(at.value, 0)                AS attuned,
       IFNULL(bo.value, 0)                AS bonded,
       dt.details                         AS details
FROM chain c
JOIN ace_shard.biota_properties_i_i_d i       ON i.type = 2 AND i.value = c.container_Id
JOIN ace_shard.biota_properties_string nm     ON nm.object_Id = i.object_Id AND nm.type = 1
LEFT JOIN ace_shard.biota_properties_int st   ON st.object_Id = i.object_Id AND st.type = 12
LEFT JOIN ace_shard.biota_properties_int it   ON it.object_Id = i.object_Id AND it.type = 1
LEFT JOIN ace_shard.biota_properties_int ui   ON ui.object_Id = i.object_Id AND ui.type = 18
LEFT JOIN ace_shard.biota_properties_int at   ON at.object_Id = i.object_Id AND at.type = 114
LEFT JOIN ace_shard.biota_properties_int bo   ON bo.object_Id = i.object_Id AND bo.type = 33
LEFT JOIN ace_shard.biota_properties_d_i_d ic ON ic.object_Id = i.object_Id AND ic.type = 8
LEFT JOIN ace_shard.biota_properties_d_i_d o1 ON o1.object_Id = i.object_Id AND o1.type = 50
LEFT JOIN ace_shard.biota_properties_d_i_d o2 ON o2.object_Id = i.object_Id AND o2.type = 51
LEFT JOIN ace_shard.biota_properties_d_i_d ul ON ul.object_Id = i.object_Id AND ul.type = 52
LEFT JOIN ace_shard.market_item_detail dt    ON dt.item_Guid = i.object_Id
LEFT JOIN (SELECT b.object_Id, CASE b.value
              WHEN 1 THEN 'Ceramic' WHEN 2 THEN 'Porcelain' WHEN 4 THEN 'Linen' WHEN 5 THEN 'Satin' WHEN 6 THEN 'Silk' WHEN 7 THEN 'Velvet' WHEN 8 THEN 'Wool'
              WHEN 10 THEN 'Agate' WHEN 11 THEN 'Amber' WHEN 12 THEN 'Amethyst' WHEN 13 THEN 'Aquamarine' WHEN 14 THEN 'Azurite' WHEN 15 THEN 'Black Garnet'
              WHEN 16 THEN 'Black Opal' WHEN 17 THEN 'Bloodstone' WHEN 18 THEN 'Carnelian' WHEN 19 THEN 'Citrine' WHEN 20 THEN 'Diamond' WHEN 21 THEN 'Emerald'
              WHEN 22 THEN 'Fire Opal' WHEN 23 THEN 'Green Garnet' WHEN 24 THEN 'Green Jade' WHEN 25 THEN 'Hematite' WHEN 26 THEN 'Imperial Topaz' WHEN 27 THEN 'Jet'
              WHEN 28 THEN 'Lapis Lazuli' WHEN 29 THEN 'Lavender Jade' WHEN 30 THEN 'Malachite' WHEN 31 THEN 'Moonstone' WHEN 32 THEN 'Onyx' WHEN 33 THEN 'Opal'
              WHEN 34 THEN 'Peridot' WHEN 35 THEN 'Red Garnet' WHEN 36 THEN 'Red Jade' WHEN 37 THEN 'Rose Quartz' WHEN 38 THEN 'Ruby' WHEN 39 THEN 'Sapphire'
              WHEN 40 THEN 'Smoky Quartz' WHEN 41 THEN 'Sunstone' WHEN 42 THEN 'Tiger Eye' WHEN 43 THEN 'Tourmaline' WHEN 44 THEN 'Turquoise' WHEN 45 THEN 'White Jade'
              WHEN 46 THEN 'White Quartz' WHEN 47 THEN 'White Sapphire' WHEN 48 THEN 'Yellow Garnet' WHEN 49 THEN 'Yellow Topaz' WHEN 50 THEN 'Zircon' WHEN 51 THEN 'Ivory'
              WHEN 52 THEN 'Leather' WHEN 53 THEN 'Armoredillo Hide' WHEN 54 THEN 'Gromnie Hide' WHEN 55 THEN 'Reed Shark Hide' WHEN 57 THEN 'Brass' WHEN 58 THEN 'Bronze'
              WHEN 59 THEN 'Copper' WHEN 60 THEN 'Gold' WHEN 61 THEN 'Iron' WHEN 62 THEN 'Pyreal' WHEN 63 THEN 'Silver' WHEN 64 THEN 'Steel' WHEN 66 THEN 'Alabaster'
              WHEN 67 THEN 'Granite' WHEN 68 THEN 'Marble' WHEN 69 THEN 'Obsidian' WHEN 70 THEN 'Sandstone' WHEN 71 THEN 'Serpentine' WHEN 73 THEN 'Ebony'
              WHEN 74 THEN 'Mahogany' WHEN 75 THEN 'Oak' WHEN 76 THEN 'Pine' WHEN 77 THEN 'Teak' END AS value
           FROM ace_shard.biota_properties_int b WHERE b.type = 131) mt ON mt.object_Id = i.object_Id;
SQL
docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "
  SELECT CONCAT(\"GRANT SELECT ON ace_shard.market_listing TO web@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"web\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT ON ace_shard.market_icon TO web@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"web\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT, INSERT ON ace_shard.market_request TO web@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"web\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT ON ace_web.market_mule_item TO web@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"web\"" > /tmp/market-grants.sql
  cat /tmp/market-grants.sql; mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" < /tmp/market-grants.sql; rm -f /tmp/market-grants.sql'
echo "marketplace ready for the website"
