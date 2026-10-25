/* JawnTide live events: dropped by Shadow Minions (520101). Stackable, attuned and bonded. Aidoneus trades 10 for a Hera's Vault Key. */
DELETE FROM `weenie` WHERE `class_Id` = 520120;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520120, 'jawntide-shadowessence', 51, '2026-10-24 00:00:00') /* Stackable */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520120,   1,        128) /* ItemType - Misc */
     , (520120,   5,          0) /* EncumbranceVal */
     , (520120,   8,          1) /* Mass */
     , (520120,   9,          0) /* ValidLocations - None */
     , (520120,  11,       1000) /* MaxStackSize */
     , (520120,  12,          1) /* StackSize */
     , (520120,  13,          0) /* StackUnitEncumbrance */
     , (520120,  14,          1) /* StackUnitMass */
     , (520120,  15,          0) /* StackUnitValue */
     , (520120,  16,          1) /* ItemUseable - No */
     , (520120,  19,          0) /* Value */
     , (520120,  33,          1) /* Bonded - Bonded */
     , (520120,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520120, 114,          1) /* Attuned - Attuned */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520120,  69, False) /* IsSellable */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520120,   1, 'Shadow Essence') /* Name */
     , (520120,  14, 'Bring 10 to Aidoneus for a Hera''s Vault Key.') /* Use */
     , (520120,  16, 'A wisp of darkness left behind by a fallen shadow minion. Aidoneus collects them.') /* LongDesc */
     , (520120,  20, 'Shadow Essences') /* PluralName */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520120,   1, 0x02000181) /* Setup */
     , (520120,   8, 0x06001227) /* Icon */
     , (520120,  50, 0x06007428) /* IconOverlay */;
