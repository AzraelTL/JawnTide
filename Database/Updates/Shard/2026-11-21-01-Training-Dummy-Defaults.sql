/* JawnTide Target Drudge defaults: the training_dummy row with dummy_Guid 0 is the setup a drudge starts with the first time
   it's in the world (armor, defenses, ratings, buffs). Set it on the LAN admin page's Target Drudge tab. Safe to re-run. */

INSERT IGNORE INTO `training_dummy` (`dummy_Guid`, `armor`, `armor_Extremities`, `melee_Defense`, `missile_Defense`, `magic_Defense`,
    `damage_Resist_Rating`, `crit_Damage_Resist_Rating`, `pk_Damage_Resist_Rating`, `spells`, `worn_Items`, `description`, `updated_At`)
VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0, '', NULL, 'Defaults for new Target Drudges', UTC_TIMESTAMP());
