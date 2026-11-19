DELETE FROM `weenie` WHERE `class_Id` = 520231;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520231, 'goopscoopsichor', 1, '2026-11-19 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520231,   1,        128) /* ItemType - Misc */
     , (520231,   5,         10) /* EncumbranceVal */
     , (520231,   8,         10) /* Mass */
     , (520231,  16,          1) /* ItemUseable - No */
     , (520231,  18,        256) /* UiEffects - Acid */
     , (520231,  19,          0) /* Value */
     , (520231,  33,         -1) /* Bonded - Slippery */
     , (520231,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520231,  22, True ) /* Inscribable */
     , (520231,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520231,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520231,   1, 'Goop Scoop''s Ichor') /* Name */
     , (520231,  16, 'A vial of the acrid slime that kept the great larva Goop Scoop alive. It is still warm, and it is slowly eating through the glass.') /* LongDesc */
     , (520231,  33, 'GoopScoopsIchor') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520231,   1, 0x02000E74) /* Setup - the gift box the older world boss tokens use */
     , (520231,   3, 0x20000014) /* SoundTable */
     , (520231,   8, 0x060064B4) /* Icon */
     , (520231,  22, 0x34000074) /* PhysicsEffectTable */;
