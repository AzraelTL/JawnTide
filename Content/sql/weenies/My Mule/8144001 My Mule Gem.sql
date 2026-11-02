-- JawnTide: ported from ClassicPvP feature/my-mule (Supershoff/ClassicPvP), weenie ids moved from 490400/490408/490409 to 8144001-8144003.
DELETE FROM `weenie` WHERE `class_Id` = 8144001;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8144001, 'ace8144001-mule', 38, '2026-08-11 00:00:00') /* Gem */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8144001,   1,    2048) /* ItemType - Gem */
     , (8144001,   5,       0) /* EncumbranceVal */
     , (8144001,  16,       8) /* ItemUseable - Contained */
     , (8144001,  18,       1) /* UiEffects - Magical */
     , (8144001,  19,       0) /* Value */
     , (8144001,  33,       1) /* Bonded - Bonded */
     , (8144001,  63,       1) /* UnlimitedUse */
     , (8144001,  93,    1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (8144001, 114,       1) /* Attuned - Attuned */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8144001,   1, False) /* Stuck */
     , (8144001,  11, True ) /* IgnoreCollisions */
     , (8144001,  13, True ) /* Ethereal */
     , (8144001,  14, True ) /* GravityStatus */
     , (8144001,  19, True ) /* Attackable */
     , (8144001,  63, True ) /* UnlimitedUse */
     , (8144001,  69, False) /* IsSellable */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8144001,   1, 'My Mule') /* Name */
     , (8144001,  16, 'Summons your personal mule -- a private storage vendor, shared account-wide across every character on your account, that only you can deposit to or withdraw from. It disappears if you leave the landblock, and can only be summoned on a landblock with player housing. Reusable.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8144001,   1, 0x02000179) /* Setup */
     , (8144001,   3, 0x20000014) /* SoundTable */
     , (8144001,   6, 0x04000BEF) /* PaletteBase */
     , (8144001,   8, 100674444) /* Icon - Gem of Greater Protection */
     , (8144001,  22, 0x3400002B) /* PhysicsEffectTable */
     , (8144001,  27, 0x13000081) /* UseUserAnimation - MimeEat */
     , (8144001,  52, 0x06005B0C) /* IconUnderlay */;
