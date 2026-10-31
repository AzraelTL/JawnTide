#!/usr/bin/env bash
# One-time (safe to re-run) wiki database setup on the Linux server: creates ace_wiki from wiki-schema.sql and grants
#   web (the website):       read/write on the wiki tables, read-only on contributor (it can't make contributors)
#   ace (game server):       read contributor, SELECT/UPDATE link_code (for /wiki CODE)
#   monitor (LAN admin page): read/write contributor (the Wiki checkboxes on Levels), read wiki_user
# Grants go to every host entry those users already have. Runs as root inside ace-db; prints the grants it made.
set -euo pipefail
cd ~/jawntide-server
docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD"' < ~/JawnTide/Ops/website/wiki-schema.sql
docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "
  SELECT CONCAT(\"GRANT SELECT, INSERT, UPDATE, DELETE ON ace_wiki.\", t, \" TO web@\", QUOTE(host), \";\") FROM mysql.user
    JOIN (SELECT \"wiki_user\" t UNION SELECT \"link_code\" UNION SELECT \"session\" UNION SELECT \"page\" UNION SELECT \"revision\") x WHERE user = \"web\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT ON ace_wiki.contributor TO web@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"web\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT, UPDATE ON ace_wiki.link_code TO ace@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"ace\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT ON ace_wiki.contributor TO ace@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"ace\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT, INSERT, UPDATE, DELETE ON ace_wiki.contributor TO monitor@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"monitor\"
  UNION ALL SELECT CONCAT(\"GRANT SELECT ON ace_wiki.wiki_user TO monitor@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"monitor\"" > /tmp/wiki-grants.sql
  cat /tmp/wiki-grants.sql; mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" < /tmp/wiki-grants.sql; rm -f /tmp/wiki-grants.sql'
echo "ace_wiki ready"
