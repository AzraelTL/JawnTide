/* JawnTide live events: weapon for the event boss only. No wield requirements; attuned and bonded so it can never be traded, dropped or sold. Nothing sells or drops it: an admin creates it with @ci 520111. Built from stock 2472. */
DELETE FROM `weenie` WHERE `class_Id` = 520111;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520111, 'jawntide-shadowwand', 35, '2021-11-17 16:56:08') /* Caster */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520111,   1,      32768) /* ItemType - Caster */
     , (520111,   3,         82) /* PaletteTemplate - PinkPurple */
     , (520111,   5,         50) /* EncumbranceVal */
     , (520111,   8,         25) /* Mass */
     , (520111,   9,   16777216) /* ValidLocations - Held */
     , (520111,  16,          1) /* ItemUseable - No */
     , (520111,  19,          0) /* Value */
     , (520111,  33,          1) /* Bonded - Bonded */
     , (520111,  46,        512) /* DefaultCombatStyle - Magic */
     , (520111,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520111,  94,         16) /* TargetType - Creature */
     , (520111, 114,          1) /* Attuned - Attuned */
     , (520111, 150,        103) /* HookPlacement - Hook */
     , (520111, 151,          2) /* HookType - Wall */
     , (520111, 169,   84281091) /* TsysMutationData */
     , (520111, 353,          0) /* WeaponType - Undef */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520111,  11, True ) /* IgnoreCollisions */
     , (520111,  13, True ) /* Ethereal */
     , (520111,  14, True ) /* GravityStatus */
     , (520111,  19, True ) /* Attackable */
     , (520111,  22, True ) /* Inscribable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520111,  29,    1.25) /* WeaponDefense */
     , (520111, 144,     0.3) /* ManaConversionMod */
     , (520111, 152,    1.25) /* ElementalDamageMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520111,   1, 'Shadow Wand') /* Name */
     , (520111,  16, 'A wand of living shadow that amplifies destructive magic.') /* LongDesc */
     , (520111,  14, 'Use this item to cast its spell.') /* Use */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520111,   1, 0x0200017C) /* Setup */
     , (520111,   3, 0x20000014) /* SoundTable */
     , (520111,   6, 0x04000BEF) /* PaletteBase */
     , (520111,   7, 0x1000012E) /* ClothingBase */
     , (520111,   8, 0x06001578) /* Icon */
     , (520111,  22, 0x3400002B) /* PhysicsEffectTable */
     , (520111,  27, 0x400000E1) /* UseUserAnimation - UseMagicWand */
     , (520111,  36, 0x0E000016) /* MutateFilter */
     , (520111,  46, 0x38000030) /* TsysMutationFilter */;
