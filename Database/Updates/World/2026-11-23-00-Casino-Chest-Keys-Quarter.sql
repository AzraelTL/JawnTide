/* JawnTide: the casino chest keys (Exquisite Casino Key, Grand Casino Key) come up a quarter as often from the Gamesmasters.
   Three quarters of each key's share becomes a losing pull, so no other prize gets more common. Safe to re-run. */

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9495 AND `category` = 6 AND `weenie_Class_Id` = 44717 AND ABS(`probability` - 0.80682) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9495, 6, 0.80682, 44717); /* High-Stakes Gambling Token: Exquisite Casino Key 4.54% -> 1.14% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9496 AND `category` = 6 AND `weenie_Class_Id` = 44717 AND ABS(`probability` - 0.80682) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9496, 6, 0.80682, 44717); /* High-Stakes Gambling Token: Exquisite Casino Key 4.54% -> 1.14% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9496 AND `category` = 6 AND `weenie_Class_Id` = 44717 AND ABS(`probability` - 0.99495) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9496, 6, 0.99495, 44717); /* High-Stakes Gambling Token: Grand Casino Key 2.02% -> 0.50% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9497 AND `category` = 6 AND `weenie_Class_Id` = 44717 AND ABS(`probability` - 0.80682) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9497, 6, 0.80682, 44717); /* High-Stakes Gambling Token: Exquisite Casino Key 4.54% -> 1.14% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9501 AND `category` = 6 AND `weenie_Class_Id` = 44716 AND ABS(`probability` - 0.40818) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9501, 6, 0.40818, 44716); /* Mid-Stakes Gambling Token: Grand Casino Key 4.64% -> 1.16% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9502 AND `category` = 6 AND `weenie_Class_Id` = 44716 AND ABS(`probability` - 0.40818) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9502, 6, 0.40818, 44716); /* Mid-Stakes Gambling Token: Grand Casino Key 4.64% -> 1.16% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');

DELETE FROM `weenie_properties_emote` WHERE `object_Id` = 9503 AND `category` = 6 AND `weenie_Class_Id` = 44716 AND ABS(`probability` - 0.40818) < 0.000005;
INSERT INTO `weenie_properties_emote` (`object_Id`, `category`, `probability`, `weenie_Class_Id`) VALUES (9503, 6, 0.40818, 44716); /* Mid-Stakes Gambling Token: Grand Casino Key 4.64% -> 1.16% */
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `weenie_properties_emote_action` (`emote_Id`, `order`, `type`, `delay`, `extent`, `message`) VALUES (@parent_id, 0, 12, 0, 1, NULL), (@parent_id, 1, 10, 1, 1, 'Let''s see what Dame Fortune has in store for you!'), (@parent_id, 2, 10, 1, 1, 'Not this time! Dame Fortune smiles on you another day.');
