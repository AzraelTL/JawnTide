-- JawnTide: stock ACE portal again (the T9 version is 520303).
DELETE FROM `weenie` WHERE `class_Id` = 7295;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7295, 'portalgolemheimsho', 7, '2021-11-08 06:01:47');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7295, 1, True)
     , (7295, 11, False)
     , (7295, 12, True)
     , (7295, 13, True)
     , (7295, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7295, 1, 33555923)
     , (7295, 2, 150994947)
     , (7295, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7295, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7295, 1, 65536)
     , (7295, 16, 32)
     , (7295, 86, 15)
     , (7295, 93, 3084)
     , (7295, 111, 1)
     , (7295, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7295, 2, 49611415, 100, -330, 0, 1, 0, 0, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7295, 1, 'Halls of Metos');
