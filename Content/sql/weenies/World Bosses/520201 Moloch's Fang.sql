DELETE FROM `weenie` WHERE `class_Id` = 520201;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520201, 'molochsfang', 1, '2026-10-27 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520201,   1,        128) /* ItemType - Misc */
     , (520201,   5,         10) /* EncumbranceVal */
     , (520201,   8,         10) /* Mass */
     , (520201,  16,          1) /* ItemUseable - No */
     , (520201,  18,         32) /* UiEffects - Fire */
     , (520201,  19,          0) /* Value */
     , (520201,  33,         -1) /* Bonded - Slippery */
     , (520201,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520201,  22, True ) /* Inscribable */
     , (520201,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520201,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520201,   1, 'Moloch''s Fang') /* Name */
     , (520201,  16, 'A jagged fang torn from the jaw of Moloch, the Drudge Warlord. It still reeks of blood and old campfires.') /* LongDesc */
     , (520201,  33, 'MolochsFang') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520201,   1, 0x02000181) /* Setup (Ivory Gromnie Tooth 3675) */
     , (520201,   3, 0x20000014) /* SoundTable */
     , (520201,   6, 0x04000BEF) /* PaletteBase */
     , (520201,   7, 0x10000178) /* ClothingBase */
     , (520201,   8, 0x06003497) /* Icon (Ivory Gromnie Tooth) */
     , (520201,  22, 0x3400002B) /* PhysicsEffectTable */;
