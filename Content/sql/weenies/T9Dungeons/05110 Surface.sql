-- JawnTide: stock ACE portal again (the T9 version is 520311).
DELETE FROM `weenie` WHERE `class_Id` = 5110;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (5110, 'portalfroreexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (5110, 1, True)
     , (5110, 11, False)
     , (5110, 12, True)
     , (5110, 13, True)
     , (5110, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (5110, 1, 33554867)
     , (5110, 2, 150994947)
     , (5110, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (5110, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (5110, 1, 65536)
     , (5110, 16, 32)
     , (5110, 93, 3084)
     , (5110, 111, 33)
     , (5110, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (5110, 2, 2261581832, 19.427, 189.157, 113.369, -0.244309, 0, 0, -0.969698);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (5110, 1, 'Surface');
