/* JawnTide Stage 2: world boss jewelry already in the world gets the Epic cantrips that new pieces have
   (Content/sql/weenies/World Bosses 490001, 490003, 490048). Pieces made during Stage 1 carry the Major versions:
     Band of Thought (490001):        Major Focus 2574 -> Epic 3964,     Major Willpower 2577 -> Epic 4227
     Ring of the Heart (490003):      Major Strength 2576 -> Epic 3965,  Major Endurance 2573 -> Epic 4226
     Bracelet of Dexterity (490048):  Major Quickness 2575 -> Epic 4019, Major Coordination 2572 -> Epic 3963
   Runs at server start, before anyone logs in, so nothing in memory can write the old spells back. Safe to re-run.

   A piece that is being worn has its Majors active on the wearer. Those are removed here, because taking the piece
   off would no longer remove them (it removes the spells the piece has now). The wearer gets the Epics the next time
   they put the piece on. */

DELETE e FROM `biota_properties_enchantment_registry` e
  JOIN `biota` b ON b.`id` = e.`caster_Object_Id`
 WHERE (b.`weenie_Class_Id` = 490001 AND e.`spell_Id` IN (2574, 2577))
    OR (b.`weenie_Class_Id` = 490003 AND e.`spell_Id` IN (2576, 2573))
    OR (b.`weenie_Class_Id` = 490048 AND e.`spell_Id` IN (2575, 2572));

INSERT IGNORE INTO `biota_properties_spell_book` (`object_Id`, `spell`, `probability`)
SELECT s.`object_Id`,
       CASE s.`spell` WHEN 2574 THEN 3964 WHEN 2577 THEN 4227 WHEN 2576 THEN 3965 WHEN 2573 THEN 4226 WHEN 2575 THEN 4019 WHEN 2572 THEN 3963 END,
       s.`probability`
  FROM `biota_properties_spell_book` s
  JOIN `biota` b ON b.`id` = s.`object_Id`
 WHERE (b.`weenie_Class_Id` = 490001 AND s.`spell` IN (2574, 2577))
    OR (b.`weenie_Class_Id` = 490003 AND s.`spell` IN (2576, 2573))
    OR (b.`weenie_Class_Id` = 490048 AND s.`spell` IN (2575, 2572));

DELETE s FROM `biota_properties_spell_book` s
  JOIN `biota` b ON b.`id` = s.`object_Id`
 WHERE (b.`weenie_Class_Id` = 490001 AND s.`spell` IN (2574, 2577))
    OR (b.`weenie_Class_Id` = 490003 AND s.`spell` IN (2576, 2573))
    OR (b.`weenie_Class_Id` = 490048 AND s.`spell` IN (2575, 2572));
