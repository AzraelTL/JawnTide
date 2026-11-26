DELETE FROM `weenie` WHERE `class_Id` = 520291;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520291, 'gorgluuksidol', 1, '2026-11-26 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520291,   1,        128) /* ItemType - Misc */
     , (520291,   5,         10) /* EncumbranceVal */
     , (520291,   8,         10) /* Mass */
     , (520291,  16,          1) /* ItemUseable - No */
     , (520291,  18,        256) /* UiEffects - Acid */
     , (520291,  19,          0) /* Value */
     , (520291,  33,         -1) /* Bonded - Slippery */
     , (520291,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520291,  22, True ) /* Inscribable */
     , (520291,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520291,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520291,   1, 'Gorgluuk''s Idol') /* Name */
     , (520291,  16, 'The war idol of Gorgluuk, the Burun Warking, slick with marsh acid.') /* LongDesc */
     , (520291,  33, 'GorgluuksIdol') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520291,   1, 0x02000E74) /* Setup - the gift box the older world boss tokens use */
     , (520291,   3, 0x20000014) /* SoundTable */
     , (520291,   6, 0x04000BEF) /* PaletteBase */
     , (520291,   7, 0x10000178) /* ClothingBase */
     , (520291,   8, 0x06003497) /* Icon (Ivory Gromnie Tooth) */
     , (520291,  22, 0x3400002B) /* PhysicsEffectTable */;
