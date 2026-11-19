DELETE FROM `weenie` WHERE `class_Id` = 520232;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520232, 'goopscoopichorgen', 1, '2021-11-01 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520232,  81,          33) /* MaxGeneratedObjects */
     , (520232,  82,          33) /* InitGeneratedObjects */
     , (520232,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520232, 103,          2) /* GeneratorDestructionType - Destroy */
     , (520232, 145,          2) /* GeneratorEndDestructionType - Destroy */
     , (520232, 267,        180) /* Lifespan */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520232,   1, True ) /* Stuck */
     , (520232,  11, True ) /* IgnoreCollisions */
     , (520232,  18, True ) /* Visibility */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520232,  41,      1000) /* RegenerationInterval */
     , (520232,  43,      30) /* GeneratorRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520232,   1, 'Goop Scoop''s Ichor Gen') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520232,   1, 0x0200026B) /* Setup */
     , (520232,   8, 0x06001066) /* Icon */;

INSERT INTO `weenie_properties_generator` (`object_Id`, `probability`, `weenie_Class_Id`, `delay`, `init_Create`, `max_Create`, `when_Create`, `where_Create`, `stack_Size`, `palette_Id`, `shade`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (520232, -1, 520231, 0, 9, 9, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate (x9 up to max of 9) - Regenerate upon Destruction - Location to (re)Generate: Scatter */
, (520232, -1, 480608, 0, 9, 9, 1, 2, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0) /* Generate (x9 up to max of 9) - Regenerate upon Destruction - Location to (re)Generate: Scatter */
, (520232, -1, 10025, 0, 10, 10, 1, 64, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
, (520232, -1, 8359, 0, 1, 1, 1, 4, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);