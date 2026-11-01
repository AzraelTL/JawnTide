/* JawnTide: Mule Imprint Token. Code: WorldObjects/MuleImprintToken.cs (WeenieType 73 = MuleImprintToken).
   One per character, from the Imprinters in Holtburg, Shoushi and Yaraq.
   Attuned + Bonded + Retained + not sellable: it can never be dropped, given, traded, sold, salvaged,
   handed to an NPC or lost on death. The server also re-applies these every time the token loads. */

DELETE FROM `weenie` WHERE `class_Id` = 8143004;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8143004, 'muleimprinttoken', 73, '2026-11-01 00:00:00') /* MuleImprintToken */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8143004,   1,       2048) /* ItemType - Gem */
     , (8143004,   3,         36) /* PaletteTemplate - LightPurpleMetal */
     , (8143004,   5,          5) /* EncumbranceVal */
     , (8143004,   8,          5) /* Mass */
     , (8143004,  16,          8) /* ItemUseable - Contained */
     , (8143004,  18,          1) /* UiEffects - Magical */
     , (8143004,  19,          0) /* Value */
     , (8143004,  33,          1) /* Bonded - Bonded */
     , (8143004,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (8143004, 114,          1) /* Attuned - Attuned */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8143004,  22, False) /* Inscribable */
     , (8143004,  69, False) /* IsSellable */
     , (8143004,  91, True ) /* Retained */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8143004,   1, 'Mule Imprint Token') /* Name */
     , (8143004,  14, 'Use this token to imprint a character of level 5 or lower on your account as your mule. Once imprinted, use it to call or dismiss the Ghost of your mule.') /* Use */
     , (8143004,  16, 'A small token humming with spirit magic. Use it to imprint a character of level 5 or lower on your account as your mule. The imprint is permanent. Once imprinted, using the token calls the Ghost of your mule, which will carry anything you hand it to your mule''s pack. This token is bound to your soul and can never be given away, sold, dropped or destroyed.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8143004,   1,   33554802) /* Setup */
     , (8143004,   6,   67111919) /* PaletteBase */
     , (8143004,   7,  268435747) /* ClothingBase */
     , (8143004,   8,  100676408) /* Icon */;
