-- JawnTide: the Bandit Hilt Morph Gem (Blade Hilt, 490026) now works only on Finesse Weapons daggers imbued with Critical Strike, Armor Rending or Crippling Blow (making them Triple-Strike).
-- The code change is in MorphGem.cs; this only updates its description. Safe to re-run.

UPDATE `weenie_properties_string`
SET `value` = 'A well-balanced blade hilt. Affix this hilt to a Finesse dagger imbued with Critical Strike, Armor Rending or Crippling Blow to make it a Triple-Strike weapon.'
WHERE `object_Id` = 490026 AND `type` = 16;
