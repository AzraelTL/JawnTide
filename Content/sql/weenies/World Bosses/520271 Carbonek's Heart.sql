DELETE FROM `weenie` WHERE `class_Id` = 520271;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520271, 'carboneksheart', 1, '2026-11-26 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520271,   1,        128) /* ItemType - Misc */
     , (520271,   5,         10) /* EncumbranceVal */
     , (520271,   8,         10) /* Mass */
     , (520271,  16,          1) /* ItemUseable - No */
     , (520271,  18,        128) /* UiEffects - Frost */
     , (520271,  19,          0) /* Value */
     , (520271,  33,         -1) /* Bonded - Slippery */
     , (520271,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520271,  22, True ) /* Inscribable */
     , (520271,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520271,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520271,   1, 'Carbonek''s Heart') /* Name */
     , (520271,  16, 'The flawless diamond heart of Carbonek, the Diamond Colossus. It is cold enough to burn.') /* LongDesc */
     , (520271,  33, 'CarboneksHeart') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520271,   1, 0x02000E74) /* Setup - the gift box the older world boss tokens use */
     , (520271,   3, 0x20000014) /* SoundTable */
     , (520271,   6, 0x04000BEF) /* PaletteBase */
     , (520271,   7, 0x10000178) /* ClothingBase */
     , (520271,   8, 0x06003497) /* Icon (Ivory Gromnie Tooth) */
     , (520271,  22, 0x3400002B) /* PhysicsEffectTable */;
