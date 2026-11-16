-- JawnTide Allegiance Mule: a My Mule that hangs on a mansion hook (Player_HookMule.cs). Sold by the Town Treasurers for 1500 PK Trophies.
DELETE FROM `weenie` WHERE `class_Id` = 8144004;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8144004, 'ace8144004-allegiancemule', 64, '2026-11-16 00:00:00') /* Hooker */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8144004,   1,        128) /* ItemType - Misc */
     , (8144004,   5,        150) /* EncumbranceVal */
     , (8144004,   8,         25) /* Mass */
     , (8144004,   9,          0) /* ValidLocations - None */
     , (8144004,  16,         32) /* ItemUseable - Remote */
     , (8144004,  18,          1) /* UiEffects - Magical */
     , (8144004,  19,       1500) /* Value (1500 PK Trophies at the Town Treasurers) */
     , (8144004,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (8144004, 150,        103) /* HookPlacement - Hook */
     , (8144004, 151,         11) /* HookType - Floor, Wall, Yard */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8144004,  13, True ) /* Ethereal */
     , (8144004,  22, True ) /* Inscribable */
     , (8144004,  69, False) /* IsSellable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8144004,  39,     2.0) /* DefaultScale */
     , (8144004,  54,       3) /* UseRadius */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8144004,   1, 'Allegiance Mule') /* Name */
     , (8144004,  14, 'Hang this on a mansion hook and use it to open a mule that holds 5000 items. Whoever may open the mansion''s storage chests may use it. It can''t be taken down while anything is stored in it, and it stays with the mansion, contents and all.') /* Use */
     , (8144004,  16, 'A mule for the whole allegiance, kept in the mansion. It works only on a mansion''s hooks.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8144004,   1, 0x02000179) /* Setup */
     , (8144004,   3, 0x20000014) /* SoundTable */
     , (8144004,   6, 0x04000BEF) /* PaletteBase */
     , (8144004,   8, 100674444) /* Icon - same as My Mule */
     , (8144004,  22, 0x3400002B) /* PhysicsEffectTable */
     , (8144004,  52, 0x06005B0C) /* IconUnderlay */;
