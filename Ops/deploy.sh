#!/usr/bin/env bash
# Build the latest code from GitHub on the Linux server and swap it in.
# Usage:  ./deploy.sh            (builds branch "master")
#         ./deploy.sh some-branch
#
# Layout it expects (change the variables below to match yours):
#   ~/JawnTide       the git clone (never edited by hand on this machine)
#   ~/ace-config     Config.js and log4net.config live here, OUTSIDE the repo
#   ~/ace-live       the folder the server actually runs from
set -euo pipefail

REPO="$HOME/JawnTide"
CONFIG_DIR="$HOME/ace-config"
LIVE="$HOME/ace-live"
NEW="$HOME/ace-new"
PREV="$HOME/ace-prev"
BRANCH="${1:-master}"

cd "$REPO"
git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"
COMMIT="$(git rev-parse --short HEAD)"
echo "Building commit $COMMIT on branch $BRANCH"
git log -1 --format='  %h %s (%ci)'

# Build into a fresh folder so a failed build never touches the running server
rm -rf "$NEW"
dotnet publish Source/ACE.Server -c Release -o "$NEW"

# Your real settings, kept outside the repo
cp "$CONFIG_DIR/Config.js"       "$NEW/Config.js"
cp "$CONFIG_DIR/log4net.config"  "$NEW/log4net.config"

# Stamp the build so you can always tell what is running
echo "commit $COMMIT, branch $BRANCH, built $(date -Is)" > "$NEW/BUILD_INFO.txt"

echo
echo "Build finished. STOP the server now, then press Enter to swap it in."
read -r _

rm -rf "$PREV"
[ -d "$LIVE" ] && mv "$LIVE" "$PREV"
mv "$NEW" "$LIVE"

echo
echo "Swapped in commit $COMMIT. Previous version kept in $PREV (for rollback)."
echo "Start it with:  cd $LIVE && dotnet ACE.Server.dll"
echo "To roll back:   stop the server, then:  rm -rf $LIVE && mv $PREV $LIVE"
