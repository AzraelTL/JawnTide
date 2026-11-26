DELETE FROM `weenie` WHERE `class_Id` = 520292;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520292, 'ace520292-gorgluukidolgen', 1, '2026-11-26 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520292,  81,         33) /* MaxGeneratedObjects */
     , (520292,  82,         33) /* InitGeneratedObjects */
     , (520292,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520292, 103,          2) /* GeneratorDestructionType - Destroy */
     , (520292, 145,          2) /* GeneratorEndDestructionType - Destroy */
     , (520292, 267,        180) /* Lifespan */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520292,   1, True ) /* Stuck */
     , (520292,  11, True ) /* IgnoreCollisions */
     , (520292,  18, True ) /* Visibility */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520292,  41,      1000) /* RegenerationInterval */
     , (520292,  43,      30) /* GeneratorRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520292,   1, 'Gorgluuk''s Idol Gen') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520292,   1, 0x0200026B) /* Setup */
     , (520292,   8, 0x06001066) /* Icon */;

/* Same drops as the Olthoi King, Martine and Bael'Zharon loot generators (490072-490074): 9 boss tokens, 9 Darkbeat's Lost Storage Keys, 10 piles of world boss treasure (10025), and 8359 */
INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520292, -1, 520291, 0, 9, 9, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Gorgluuk's Idol (520291) (x9) - Scatter */
     , (520292, -1, 480608, 0, 9, 9, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Darkbeat's Lost Storage Key (480608) (x9) - Scatter */
     , (520292, -1, 10025, 0, 10, 10, 1, 64, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* World boss treasure (10025) x10 */
     , (520292, -1, 8359, 0, 1, 1, 1, 4, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
