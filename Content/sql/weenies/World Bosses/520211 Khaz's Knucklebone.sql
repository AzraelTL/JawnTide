DELETE FROM `weenie` WHERE `class_Id` = 520211;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520211, 'khazsknucklebone', 1, '2026-10-27 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520211,   1,        128) /* ItemType - Misc */
     , (520211,   5,         10) /* EncumbranceVal */
     , (520211,   8,         10) /* Mass */
     , (520211,  16,          1) /* ItemUseable - No */
     , (520211,  18,        128) /* UiEffects - Frost */
     , (520211,  19,          0) /* Value */
     , (520211,  33,         -1) /* Bonded - Slippery */
     , (520211,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520211,  22, True ) /* Inscribable */
     , (520211,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520211,  39,     0.33) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520211,   1, 'Khaz''s Knucklebone') /* Name */
     , (520211,  16, 'A knucklebone the size of a human fist, pried from the hand of Khaz'', the Lugian Titan.') /* LongDesc */
     , (520211,  33, 'KhazsKnucklebone') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520211,   1, 0x02000871) /* Setup (Undead Thighbone 7041) */
     , (520211,   3, 0x20000014) /* SoundTable */
     , (520211,   8, 0x06001CD9) /* Icon (Undead Thighbone) */
     , (520211,  22, 0x3400002B) /* PhysicsEffectTable */;
