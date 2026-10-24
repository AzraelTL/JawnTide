/* JawnTide live events: weapon for the event boss only. No wield requirements; attuned and bonded so it can never be traded, dropped or sold. Nothing sells or drops it: an admin creates it with @ci 520110. Built from stock 40760. */
DELETE FROM `weenie` WHERE `class_Id` = 520110;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520110, 'jawntide-shadowreaver', 6, '2021-11-01 00:00:00') /* MeleeWeapon */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520110,   1,          1) /* ItemType - MeleeWeapon */
     , (520110,   3,         20) /* PaletteTemplate - Silver */
     , (520110,   5,        550) /* EncumbranceVal */
     , (520110,   9,   33554432) /* ValidLocations - TwoHanded */
     , (520110,  16,          1) /* ItemUseable - No */
     , (520110,  19,          0) /* Value */
     , (520110,  33,          1) /* Bonded - Bonded */
     , (520110,  44,         60) /* Damage */
     , (520110,  45,          1) /* DamageType - Slash */
     , (520110,  46,          8) /* DefaultCombatStyle - TwoHanded */
     , (520110,  47,          4) /* AttackType - Slash */
     , (520110,  48,         41) /* WeaponSkill - TwoHandedCombat */
     , (520110,  49,         40) /* WeaponTime */
     , (520110,  51,          5) /* CombatUse - TwoHanded */
     , (520110,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520110, 114,          1) /* Attuned - Attuned */
     , (520110, 169,  285804546) /* TsysMutationData */
     , (520110, 292,          2) /* Cleaving */
     , (520110, 353,         11) /* WeaponType - TwoHanded */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520110,  22, True ) /* Inscribable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520110,  21,       1) /* WeaponLength */
     , (520110,  22,     0.5) /* DamageVariance */
     , (520110,  29,    1.25) /* WeaponDefense */
     , (520110,  62,    1.25) /* WeaponOffense */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520110,   1, 'Shadow Reaver') /* Name */
     , (520110,  16, 'A greatsword forged in darkness, wielded only by champions of shadow.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520110,   1, 0x020018BB) /* Setup */
     , (520110,   3, 0x20000014) /* SoundTable */
     , (520110,   6, 0x04000BEF) /* PaletteBase */
     , (520110,   7, 0x10000787) /* ClothingBase */
     , (520110,   8, 0x06006B6D) /* Icon */
     , (520110,  22, 0x3400002B) /* PhysicsEffectTable */;
