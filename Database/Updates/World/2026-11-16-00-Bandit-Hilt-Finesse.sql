-- JawnTide: the Bandit Hilt Morph Gem (Blade Hilt, 490026) also works on any Finesse Weapons dagger (imbued or not), as well as multi-strike Light Weapons.
-- The code change is in MorphGem.cs; this only updates its description. Safe to re-run.

UPDATE `weenie_properties_string`
SET `value` = 'A well-balanced blade hilt. Affix this hilt to a multi-strike Light Weapon or to a Finesse dagger to make it a Triple-Strike weapon.'
WHERE `object_Id` = 490026 AND `type` = 16;
