#!/usr/bin/env bash
# Run on your LIVE server to capture the data that is NOT in the schema scripts.
# Output goes to ./export. These files contain game data (and possibly player data):
# do NOT commit them to a public repository.
set -euo pipefail
mkdir -p export
read -r -s -p "MariaDB root password: " MYSQL_PWD; echo; export MYSQL_PWD

# 1. All of ace_world (stock + your custom weenies, quests, recipes, landblocks)
mysqldump -u root --single-transaction ace_world > export/ace_world_full.sql

# 2. Server settings (content_folder, town_control_alleglist, arena settings, etc.)
mysqldump -u root --single-transaction ace_shard \
  config_properties_boolean config_properties_double config_properties_long config_properties_string \
  > export/ace_shard_server_properties.sql

# 3. Town control towns (owners, reward amounts, respite lengths)
mysqldump -u root --single-transaction --no-create-info --replace ace_town_control town \
  > export/ace_town_control_towns.sql

echo "Done. Files in ./export"
