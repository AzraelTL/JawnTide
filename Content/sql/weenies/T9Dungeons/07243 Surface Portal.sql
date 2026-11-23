-- JawnTide: stock ACE portal again (the T9 version is 520312).
DELETE FROM `weenie` WHERE `class_Id` = 7243;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (7243, 'portalblackdrudgespawnaluexit', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (7243, 1, True)
     , (7243, 11, False)
     , (7243, 12, True)
     , (7243, 13, True)
     , (7243, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (7243, 1, 33554867)
     , (7243, 2, 150994947)
     , (7243, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (7243, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (7243, 1, 65536)
     , (7243, 16, 32)
     , (7243, 93, 3084)
     , (7243, 111, 17)
     , (7243, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (7243, 2, 462422061, 122.6, 111.8, 30, 0.707107, 0, 0, -0.707107);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (7243, 1, 'Surface Portal');
