-- JawnTide: put stock housing costs back on every placed slumlord (houses, apartments, cottages, villas, mansions).
-- Placed slumlords keep their own copy of the buy (destination 16) and rent (destination 32) lists in ace_shard;
-- this replaces those copies with the lists from their weenies in ace_world (Content/sql/weenies/Housing/, stock ACE costs).
-- Run with the game server STOPPED (a running server would save its cached slumlords back over it). Safe to run repeatedly.

USE ace_shard;

DELETE cl FROM ace_shard.biota_properties_create_list cl
JOIN ace_shard.biota b ON b.id = cl.object_Id
JOIN ace_world.weenie w ON w.class_Id = b.weenie_Class_Id AND w.`type` = 55
WHERE cl.destination_Type IN (16, 32);

INSERT INTO ace_shard.biota_properties_create_list (object_Id, destination_Type, weenie_Class_Id, stack_Size, palette, shade, try_To_Bond)
SELECT b.id, c.destination_Type, c.weenie_Class_Id, c.stack_Size, c.palette, c.shade, c.try_To_Bond
FROM ace_shard.biota b
JOIN ace_world.weenie w ON w.class_Id = b.weenie_Class_Id AND w.`type` = 55
JOIN ace_world.weenie_properties_create_list c ON c.object_Id = w.class_Id AND c.destination_Type IN (16, 32);

SELECT c.destination_Type AS list, c.weenie_Class_Id AS item, COUNT(*) AS slumlords
FROM ace_shard.biota_properties_create_list c
JOIN ace_shard.biota b ON b.id = c.object_Id
JOIN ace_world.weenie w ON w.class_Id = b.weenie_Class_Id AND w.`type` = 55
WHERE c.destination_Type IN (16, 32)
GROUP BY c.destination_Type, c.weenie_Class_Id
ORDER BY c.destination_Type, slumlords DESC;
