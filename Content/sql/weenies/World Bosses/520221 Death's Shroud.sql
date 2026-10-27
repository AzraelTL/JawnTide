DELETE FROM `weenie` WHERE `class_Id` = 520221;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520221, 'deathsshroud', 1, '2026-10-27 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520221,   1,        128) /* ItemType - Misc */
     , (520221,   3,         39) /* PaletteTemplate - Black */
     , (520221,   5,         10) /* EncumbranceVal */
     , (520221,   8,         10) /* Mass */
     , (520221,  16,          1) /* ItemUseable - No */
     , (520221,  19,          0) /* Value */
     , (520221,  33,         -1) /* Bonded - Slippery */
     , (520221,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520221,  22, True ) /* Inscribable */
     , (520221,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520221,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520221,   1, 'Death''s Shroud') /* Name */
     , (520221,  16, 'A tattered scrap of living darkness, all that remains of the Umbris Shadow called Death. It is cold to the touch.') /* LongDesc */
     , (520221,  33, 'DeathsShroud') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520221,   1, 0x02000E74) /* Setup */
     , (520221,   3, 0x20000014) /* SoundTable */
     , (520221,   6, 0x04000BEF) /* PaletteBase */
     , (520221,   7, 0x10000178) /* ClothingBase */
     , (520221,   8, 0x06001F94) /* Icon */
     , (520221,  52, 0x06005B0C) /* IconUnderlay */
     , (520221,  22, 0x34000074) /* PhysicsEffectTable */;
