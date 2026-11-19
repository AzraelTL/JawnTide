DELETE FROM `weenie` WHERE `class_Id` = 490028;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (490028, 'cloaktatteredvmartine', 1, '2005-02-09 10:00:00') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (490028,   1,        128) /* ItemType - Misc */
     , (490028,   3,         13) /* PaletteTemplate - Purple */
     , (490028,   5,         10) /* EncumbranceVal */
     , (490028,   8,        200) /* Mass */
     , (490028,   9,          0) /* ValidLocations - None */
     , (490028,  16,          1) /* ItemUseable - No */
     , (490028,  19,          0) /* Value */
     , (490028,  33,          -1) /* Bonded - Bonded */
     , (490028,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (490028,  22, True ) /* Inscribable */
     , (490028,  23, True ) /* DestroyOnSell */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (490028,  39,       1) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (490028,   1, 'Martine''s Tattered Cloak') /* Name */
     , (490028,  15, 'A fragment of Martine''s Cloak.') /* ShortDesc */
     , (490028,  33, 'MartinesTatteredCloak') /* Quest */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (490028,   1, 0x02000A7F) /* Setup - gift box (A Box 510000) */
     , (490028,   3, 0x20000014) /* SoundTable */
     , (490028,   8, 0x0600218D) /* Icon - gift box (A Box 510000) */
     , (490028,  22, 0x3400002B) /* PhysicsEffectTable */;
