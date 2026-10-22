# Stock vendors (read-only reference)

The 439 stock Asheron's Call vendors (weenie type Vendor) as SQL files, copied from ACE's world data:
ACEmulator/ACE-World-16PY-Patches, `Database/Patches/9 WeenieDefaults/Vendor/Creature`, commit f5edf9b (Oct 8, 2026).

This folder is outside `Content/sql`, so nothing here is ever imported. The Loot Editor lists these on
Vendors > Stock vendors. To change one, use "Copy into Content to edit": the file is copied to
`Content/sql/weenies/Stock Vendors/`, where it becomes a JawnTide vendor that overrides the stock one when
imported. Edit, test on JawnTest and merge it like any other Content change.

The live and JawnTest world databases came from an ACE world release, so a stock vendor there can differ
slightly from this copy; copying one into Content makes this version the one the server uses.
