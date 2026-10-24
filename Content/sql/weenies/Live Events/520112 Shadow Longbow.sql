/* JawnTide live events: weapon for the event boss only. No wield requirements; attuned and bonded so it can never be traded, dropped or sold. Nothing sells or drops it: an admin creates it with @ci 520112. Built from stock 30625. */
DELETE FROM `weenie` WHERE `class_Id` = 520112;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520112, 'jawntide-shadowlongbow', 3, '2021-11-01 00:00:00') /* MissileLauncher */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520112,   1,        256) /* ItemType - MissileWeapon */
     , (520112,   3,         21) /* PaletteTemplate - Gold */
     , (520112,   5,        980) /* EncumbranceVal */
     , (520112,   8,        140) /* Mass */
     , (520112,   9,    4194304) /* ValidLocations - MissileWeapon */
     , (520112,  16,          1) /* ItemUseable - No */
     , (520112,  19,          0) /* Value */
     , (520112,  33,          1) /* Bonded - Bonded */
     , (520112,  44,          0) /* Damage */
     , (520112,  46,         16) /* DefaultCombatStyle - Bow */
     , (520112,  48,         47) /* WeaponSkill - MissileWeapons */
     , (520112,  49,         30) /* WeaponTime */
     , (520112,  50,          1) /* AmmoType - Arrow */
     , (520112,  51,          2) /* CombatUse - Missile */
     , (520112,  52,          2) /* ParentLocation - LeftHand */
     , (520112,  53,          3) /* PlacementPosition - LeftHand */
     , (520112,  60,        175) /* WeaponRange */
     , (520112,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520112, 114,          1) /* Attuned - Attuned */
     , (520112, 150,        103) /* HookPlacement - Hook */
     , (520112, 151,          2) /* HookType - Wall */
     , (520112, 169,  285737994) /* TsysMutationData */
     , (520112, 353,          8) /* WeaponType - Bow */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520112,  22, True ) /* Inscribable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520112,  26,    27.3) /* MaximumVelocity */
     , (520112,  29,    1.25) /* WeaponDefense */
     , (520112,  62,    1.25) /* WeaponOffense */
     , (520112,  63,     2.5) /* DamageMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520112,   1, 'Shadow Longbow') /* Name */
     , (520112,  16, 'A bow strung with shadow; its arrows find their mark.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520112,   1, 0x02001306) /* Setup */
     , (520112,   3, 0x20000014) /* SoundTable */
     , (520112,   6, 0x04001A23) /* PaletteBase */
     , (520112,   7, 0x1000060C) /* ClothingBase */
     , (520112,   8, 0x06005CC6) /* Icon */
     , (520112,  22, 0x3400002B) /* PhysicsEffectTable */
     , (520112,  36, 0x0E00001D) /* MutateFilter */
     , (520112,  46, 0x38000008) /* TsysMutationFilter */;
