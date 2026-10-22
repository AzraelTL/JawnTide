@echo off
rem JawnTest (OLD PC) only: imports the Stage 1 files changed on Oct 21 into jt_world.
rem Run from anywhere with the JawnTest server stopped; asks once for the MariaDB root password.
cd /d "%~dp0..\.."
type "Content\sql\weenies\Arena Patch\480607 Darkbeat's Storage Locker.sql" "Content\sql\weenies\lumcasinopatch\490320 Hera.sql" "Content\sql\weenies\World Bosses\490076 Aidoneus.sql" "Content\sql\landblocks\01C9.sql" "Content\sql\patches\10007 Darkbeats Storage Locker Stage 1 Loot Profile.sql" | C:\MariaDB118\bin\mariadb -u root -p jt_world
if errorlevel 1 (echo IMPORT FAILED - see the error above) else (echo IMPORT OK - 5 files)
