-- JawnTide: stock ACE portal again (the T9 version is 520304).
DELETE FROM `weenie` WHERE `class_Id` = 25281;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (25281, 'portallugiancitadelndires', 7, '2005-02-09 10:00:00');

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (25281, 1, True)
     , (25281, 11, False)
     , (25281, 12, True)
     , (25281, 13, True)
     , (25281, 15, True);

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (25281, 1, 33555924)
     , (25281, 2, 150994947)
     , (25281, 8, 100667499);

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (25281, 54, -0.1);

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (25281, 1, 65536)
     , (25281, 16, 32)
     , (25281, 93, 3084)
     , (25281, 111, 1)
     , (25281, 133, 4);

INSERT INTO `weenie_properties_position` (`object_Id`, `position_Type`, `obj_Cell_Id`, `origin_X`, `origin_Y`, `origin_Z`, `angles_W`, `angles_X`, `angles_Y`, `angles_Z`)
VALUES (25281, 2, 1632043346, 140, -130, 0, 1, 0, 0, 0);

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (25281, 1, 'Mountain Citadel Portal');
