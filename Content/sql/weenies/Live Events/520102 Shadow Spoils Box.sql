/* JawnTide live events: dropped around the event boss when it dies (event_boss_reward_boxes); hand it to the Shadow Warden (520103) for a random reward. Model and icon from the Common Mystery Box. */
DELETE FROM `weenie` WHERE `class_Id` = 520102;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520102, 'jawntide-shadowspoilsbox', 1, '2026-10-24 00:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520102,   1,        128) /* ItemType - Misc */
     , (520102,   5,          1) /* EncumbranceVal */
     , (520102,  16,          1) /* ItemUseable - No */
     , (520102,  19,          0) /* Value */
     , (520102,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520102,  22, False) /* Inscribable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520102,  39,    0.38) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520102,   1, 'Shadow Spoils Box') /* Name */
     , (520102,  14, 'Bring this to the Shadow Warden to see what it holds.') /* Use */
     , (520102,  16, 'Spoils from the fall of a great shadow. The Shadow Warden knows how to open it.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520102,   1, 0x0200011E) /* Setup */
     , (520102,   3, 0x20000014) /* SoundTable */
     , (520102,   8, 0x060012F8) /* Icon */
     , (520102,  22, 0x3400002B) /* PhysicsEffectTable */;
