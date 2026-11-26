DELETE FROM `weenie` WHERE `class_Id` = 520272;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520272, 'ace520272-carbonekheartgen', 1, '2026-11-26 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520272,  81,         33) /* MaxGeneratedObjects */
     , (520272,  82,         33) /* InitGeneratedObjects */
     , (520272,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520272, 103,          2) /* GeneratorDestructionType - Destroy */
     , (520272, 145,          2) /* GeneratorEndDestructionType - Destroy */
     , (520272, 267,        180) /* Lifespan */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520272,   1, True ) /* Stuck */
     , (520272,  11, True ) /* IgnoreCollisions */
     , (520272,  18, True ) /* Visibility */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520272,  41,      1000) /* RegenerationInterval */
     , (520272,  43,      30) /* GeneratorRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520272,   1, 'Carbonek''s Heart Gen') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520272,   1, 0x0200026B) /* Setup */
     , (520272,   8, 0x06001066) /* Icon */;

/* Same drops as the Olthoi King, Martine and Bael'Zharon loot generators (490072-490074): 9 boss tokens, 9 Darkbeat's Lost Storage Keys, 10 piles of world boss treasure (10025), and 8359 */
INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520272, -1, 520271, 0, 9, 9, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Carbonek's Heart (520271) (x9) - Scatter */
     , (520272, -1, 480608, 0, 9, 9, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate Darkbeat's Lost Storage Key (480608) (x9) - Scatter */
     , (520272, -1, 10025, 0, 10, 10, 1, 64, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* World boss treasure (10025) x10 */
     , (520272, -1, 8359, 0, 1, 1, 1, 4, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
