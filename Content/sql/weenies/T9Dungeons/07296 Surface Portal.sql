-- JawnTide: stock ACE portal again (the T9 version is 520313).
DELETE FROM `weenie` WHERE `class_Id` = 7296;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7296, 'portalgolemheimshoexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7296, 1, True)
     , (7296, 11, False)
     , (7296, 12, True)
     , (7296, 13, True)
     , (7296, 14, True)
     , (7296, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7296, 1, 33554867)
     , (7296, 2, 150994947)
     , (7296, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7296, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7296, 1, 65536)
     , (7296, 16, 32)
     , (7296, 93, 3084)
     , (7296, 111, 1)
     , (7296, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7296, 2, 1160904718, 28.7, 126.5, 70, 0.92388, 0, 0, -0.382684);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7296, 1, 'Surface Portal');
