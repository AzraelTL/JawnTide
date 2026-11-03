/* JawnTide: find anything in the WORLD database that can still create an Experience Certificate (480611),
   a Water of Enlightenment (490070) or a Boxed Water of Enlightenment (490310). Read-only.
   Run against the world database (ace_world on live, jt_world on JawnTest). Every result is a source to remove. */
SELECT 'generator' AS source, object_Id, weenie_Class_Id, probability FROM weenie_properties_generator WHERE weenie_Class_Id IN (480611, 490070, 490310)
UNION ALL
SELECT 'create list', object_Id, weenie_Class_Id, shade FROM weenie_properties_create_list WHERE weenie_Class_Id IN (480611, 490070, 490310)
UNION ALL
SELECT 'emote give', e.object_Id, a.weenie_Class_Id, e.probability FROM weenie_properties_emote_action a JOIN weenie_properties_emote e ON e.id = a.emote_Id WHERE a.weenie_Class_Id IN (480611, 490070, 490310)
UNION ALL
SELECT 'placed in world', landblock, weenie_Class_Id, NULL FROM landblock_instance WHERE weenie_Class_Id IN (480611, 490070, 490310);
