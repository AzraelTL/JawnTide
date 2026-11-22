/* JawnTide Stage 2: Rings of Protection (490052) already in the world get the Epic cantrips that new ones have
   (Content/sql/weenies/World Bosses/490052). Rings handed out by Aidoneus before 2026-11-22 carry the Legendary versions:
     Legendary Armor 6102 -> Epic Armor 4911,   Legendary Storm Ward 6079 -> Epic Storm Ward 4679
   Runs at server start, before anyone logs in, so nothing in memory can write the old spells back. Safe to re-run.

   A ring that is being worn has its Legendaries active on the wearer. Those are removed here, because taking the ring
   off would no longer remove them (it removes the spells the ring has now). The wearer gets the Epics the next time
   they put the ring on. */

DELETE e FROM `biota_properties_enchantment_registry` e
  JOIN `biota` b ON b.`id` = e.`caster_Object_Id`
 WHERE b.`weenie_Class_Id` = 490052 AND e.`spell_Id` IN (6102, 6079);

INSERT IGNORE INTO `biota_properties_spell_book` (`object_Id`, `spell`, `probability`)
SELECT s.`object_Id`, CASE s.`spell` WHEN 6102 THEN 4911 WHEN 6079 THEN 4679 END, s.`probability`
  FROM `biota_properties_spell_book` s
  JOIN `biota` b ON b.`id` = s.`object_Id`
 WHERE b.`weenie_Class_Id` = 490052 AND s.`spell` IN (6102, 6079);

DELETE s FROM `biota_properties_spell_book` s
  JOIN `biota` b ON b.`id` = s.`object_Id`
 WHERE b.`weenie_Class_Id` = 490052 AND s.`spell` IN (6102, 6079);
