/* JawnTide Allegiance Mule: who may use a mansion's Allegiance Mule (/amule storage add NAME, /amule storage allegiance on).
   Its own list, separate from the mansion's storage chests. guest_Id 0 = the owner's allegiance.
   owner_Id is the mansion owner who granted it: rows from a previous owner don't count. Applied automatically at server start; safe to re-run. */

CREATE TABLE IF NOT EXISTS `hook_mule_access` (
    `house_Id`   INT UNSIGNED NOT NULL,
    `guest_Id`   INT UNSIGNED NOT NULL,
    `guest_Name` VARCHAR(64)  NOT NULL,
    `owner_Id`   INT UNSIGNED NOT NULL,
    `added_By`   VARCHAR(64)  NULL,
    `added_At`   DATETIME     NOT NULL,
    PRIMARY KEY (`house_Id`, `guest_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
