-- JawnTide: stock ACE portal again (the T9 version is 520310).
DELETE FROM `weenie` WHERE `class_Id` = 2079;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (2079, 'portalgolemgroundsexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (2079, 1, True)
     , (2079, 11, False)
     , (2079, 12, True)
     , (2079, 13, True)
     , (2079, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (2079, 1, 33554867)
     , (2079, 2, 150994947)
     , (2079, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (2079, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (2079, 1, 65536)
     , (2079, 16, 32)
     , (2079, 93, 3084)
     , (2079, 111, 1)
     , (2079, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (2079, 2, 3544121383, 105.536, 150.378, 202, -0.707107, 0, 0, -0.707107);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (2079, 1, 'Surface');
