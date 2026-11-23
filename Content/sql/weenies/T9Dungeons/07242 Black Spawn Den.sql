-- JawnTide: stock ACE portal again (the T9 version is 520302).
DELETE FROM `weenie` WHERE `class_Id` = 7242;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7242, 'portalblackdrudgespawnalu', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7242, 1, True)
     , (7242, 11, False)
     , (7242, 12, True)
     , (7242, 13, True)
     , (7242, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7242, 1, 33555923)
     , (7242, 2, 150994947)
     , (7242, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7242, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7242, 1, 65536)
     , (7242, 16, 32)
     , (7242, 86, 20)
     , (7242, 93, 3084)
     , (7242, 111, 1)
     , (7242, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7242, 2, 17105781, 100, -210, 0, 0.707107, 0, 0, -0.707107);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7242, 1, 'Black Spawn Den');
