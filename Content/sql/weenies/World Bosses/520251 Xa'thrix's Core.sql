DELETE FROM `weenie` WHERE `class_Id` = 520251;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520251, 'xathrixscore', 1, '2026-11-26 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520251,   1,        128) /* ItemType - Misc */
     , (520251,   5,         10) /* EncumbranceVal */
     , (520251,   8,         10) /* Mass */
     , (520251,  16,          1) /* ItemUseable - No */
     , (520251,  18,         64) /* UiEffects - Lightning */
     , (520251,  19,          0) /* Value */
     , (520251,  33,         -1) /* Bonded - Slippery */
     , (520251,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520251,  22, True ) /* Inscribable */
     , (520251,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520251,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520251,   1, 'Xa''thrix''s Core') /* Name */
     , (520251,  16, 'The still-humming core of Xa''thrix, the K''nath Brood Empress. Sparks crawl across its surface.') /* LongDesc */
     , (520251,  33, 'XathrixsCore') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520251,   1, 0x02000E74) /* Setup - the gift box the older world boss tokens use */
     , (520251,   3, 0x20000014) /* SoundTable */
     , (520251,   6, 0x04000BEF) /* PaletteBase */
     , (520251,   7, 0x10000178) /* ClothingBase */
     , (520251,   8, 0x06006814) /* Icon (K'nath Core) */
     , (520251,  22, 0x3400002B) /* PhysicsEffectTable */;
