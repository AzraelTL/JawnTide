-- JawnTide: the Bandit Hilt Morph Gem (Blade Hilt, 490026) works on Light Weapons and Finesse Weapons daggers that are already Multi-Strike (imbued or not).
-- The code change is in MorphGem.cs; this only updates its description. Safe to re-run.

UPDATE `weenie_properties_string`
SET `value` = 'A well-balanced blade hilt. Affix this hilt to a Multi-Strike Light Weapon or Finesse Weapon dagger to make it a Triple-Strike weapon.'
WHERE `object_Id` = 490026 AND `type` = 16;
