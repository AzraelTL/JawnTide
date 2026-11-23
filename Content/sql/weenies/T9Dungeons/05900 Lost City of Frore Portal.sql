-- JawnTide: stock ACE portal again (the T9 version is 520301).
DELETE FROM `weenie` WHERE `class_Id` = 5900;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (5900, 'portallostcity', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (5900, 1, True)
     , (5900, 11, False)
     , (5900, 12, True)
     , (5900, 13, True)
     , (5900, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (5900, 1, 33555923)
     , (5900, 2, 150994947)
     , (5900, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (5900, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (5900, 1, 65536)
     , (5900, 16, 32)
     , (5900, 86, 20)
     , (5900, 93, 3084)
     , (5900, 111, 17)
     , (5900, 133, 1);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (5900, 2, 20447616, 40, -280, -6, 1, 0, 0, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (5900, 1, 'Lost City of Frore Portal');
