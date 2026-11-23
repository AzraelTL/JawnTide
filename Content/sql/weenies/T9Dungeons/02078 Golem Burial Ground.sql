-- JawnTide: stock ACE portal again (the T9 version is 520300).
DELETE FROM `weenie` WHERE `class_Id` = 2078;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (2078, 'portalgolemgrounds', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (2078, 1, True)
     , (2078, 11, False)
     , (2078, 12, True)
     , (2078, 13, True)
     , (2078, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (2078, 1, 33555923)
     , (2078, 2, 150994947)
     , (2078, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (2078, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (2078, 1, 65536)
     , (2078, 16, 32)
     , (2078, 86, 10)
     , (2078, 93, 3084)
     , (2078, 111, 1)
     , (2078, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (2078, 2, 28574000, 87.0588, -6.76988, 0.005, 0.317305, 0, 0, -0.948324);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (2078, 1, 'Golem Burial Ground');
