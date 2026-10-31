#!/usr/bin/env bash
# One-time (safe to re-run) wiki database setup on the Linux server: creates ace_wiki from wiki-schema.sql and grants
#   web (the website):  SELECT, INSERT, UPDATE, DELETE on ace_wiki.*
#   ace (game server):  SELECT, UPDATE on ace_wiki.link_code only (for /wiki CODE)
# Grants go to every host entry those users already have. Runs as root inside ace-db; prints the grants it made.
set -euo pipefail
cd ~/jawntide-server
docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD"' < ~/JawnTide/Ops/website/wiki-schema.sql
docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "
  SELECT CONCAT(\"GRANT SELECT, INSERT, UPDATE, DELETE ON ace_wiki.* TO web@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"web\"
  UNION ALL
  SELECT CONCAT(\"GRANT SELECT, UPDATE ON ace_wiki.link_code TO ace@\", QUOTE(host), \";\") FROM mysql.user WHERE user = \"ace\"" > /tmp/wiki-grants.sql
  cat /tmp/wiki-grants.sql; mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" < /tmp/wiki-grants.sql; rm -f /tmp/wiki-grants.sql'
echo "ace_wiki ready"
