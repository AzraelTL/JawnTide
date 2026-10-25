/* JawnTide live events: each character can pick up one Shadow Spoils Box (event boss reward) every 4 hours */
DELETE FROM `quest` WHERE `name` = 'EventBossBoxPickup';

INSERT INTO `quest` (`name`, `min_Delta`, `max_Solves`, `message`, `last_Modified`)
VALUES ('EventBossBoxPickup', 14400, -1, 'Shadow Spoils Box', '2026-10-24 00:00:00');
