/* JawnTide: chests opened by the Sturdy Iron Key (6876, lock code keychesthigh, single use) relock and refill as soon
   as they are closed (ChestRegenOnClose), instead of 2 minutes after opening. Only this one property is added, so the
   rest of each stock chest is untouched. The Reinforced Door (29940) shares the lock and is left alone.
   The Sturdy Steel Chest (24476, Sturdy Steel Key) gets the same flag in Content/sql/weenies/Chests/.
   If one of these chests ever gets its own full weenie file in Content, put the flag in that file too. */
INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (2544, 86, True) /* Chest */
     , (3960, 86, True) /* Chest */
     , (3969, 86, True) /* Chest */
     , (3985, 86, True) /* Chest */
     , (3988, 86, True) /* Chest */
     , (3991, 86, True) /* Chest */
     , (3994, 86, True) /* Chest */
     , (4810, 86, True) /* Sarcophagus */
     , (4828, 86, True) /* Sarcophagus */
     , (4860, 86, True) /* Sarcophagus */
     , (4866, 86, True) /* Sarcophagus */
     , (4872, 86, True) /* Sarcophagus */
     , (4878, 86, True) /* Sarcophagus */
     , (7297, 86, True) /* Chest */
     , (8999, 86, True) /* Steel Chest */
     , (9001, 86, True) /* Reinforced Steel Chest */
     , (9168, 86, True) /* Chest */
     , (29059, 86, True) /* Old Chest */
     , (29060, 86, True) /* Old Chest */
     , (29061, 86, True) /* Old Chest */
     , (29062, 86, True) /* Old Chest */
     , (29063, 86, True) /* Old Chest */
ON DUPLICATE KEY UPDATE `value` = True;
