DELETE FROM `weenie` WHERE `class_Id` = 8142017;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (8142017, 'tinkeringtrinket', 1, '2021-11-17 16:56:08') /* Generic */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (8142017,   1,          8) /* ItemType - Jewelry */
     , (8142017,   5,         60) /* EncumbranceVal */
     , (8142017,   9,   67108864) /* ValidLocations - TrinketOne */
     , (8142017,  16,          1) /* ItemUseable - No */
     , (8142017,  18,          1) /* UI Effects Magical */
     , (8142017,  19,         10) /* Value */
     , (8142017,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (8142017, 106,         50) /* ItemSpellcraft */
     , (8142017, 107,       120000) /* ItemCurMana */
     , (8142017, 108,       120000) /* ItemMaxMana */
     , (8142017,  33,          1) /* Bonded */
     , (8142017, 114,          1) /* Attuned */
     , (8142017, 109,         15) /* ItemDifficulty */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (8142017,  11, True ) /* IgnoreCollisions */
     , (8142017,  13, True ) /* Ethereal */
     , (8142017,  14, True ) /* GravityStatus */
     , (8142017,  19, True ) /* Attackable */
     , (8142017,  22, True ) /* Inscribable */
     , (8142017,  91, False) /* Retained */
     , (8142017,  99, False) /* Ivoryable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (8142017,   5,  -0.049) /* ManaRate */
     , (8142017,  39,    0.67) /* DefaultScale */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (8142017,   1, 'Trinket of Tinkering') /* Name */
     , (8142017,  16, 'A trinket made for enhanced tinkering and trade crafts.') /* LongDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (8142017,   1, 0x02000179) /* Setup */
     , (8142017,   3, 0x20000014) /* SoundTable */
     , (8142017,   8, 100668277) /* Icon */
     , (8142017,  52, 100673920) /* IconUnderlay */
     , (8142017,  22, 0x3400002B) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
  VALUES (8142017, 2058, 2) /* Coordination Other VII */
, (8142017, 2060, 2) /* Endurance Other VII */
, (8142017, 2066, 2) /* Focus Other VII */
, (8142017, 2080, 2) /* Quickness Other VII */
, (8142017, 2086, 2) /* Strength Other VII */
, (8142017, 2090, 2) /* Willpower Other VII */
, (8142017, 2190, 2) /* Alchemy Mastery Other VII */
, (8142017, 2196, 2) /* Armor Tinkering Expertise Other VII */
, (8142017, 2210, 2) /* Cooking Mastery Other VII */
, (8142017, 2236, 2) /* Fletching Mastery Other VII */
, (8142017, 2250, 2) /* Item Tinkering Expertise Other VII */
, (8142017, 2270, 2) /* Lockpick Mastery Other VII */
, (8142017, 2276, 2) /* Magic Item Tinkering Expertise Other VII */
, (8142017, 2324, 2) /* Weapon Tinkering Expertise Other VII */
, (8142017, 2348, 2) /* Brilliance Other */
/* Major cantrips — attributes */
, (8142017, 2576, 2) /* Major Strength */
, (8142017, 2573, 2) /* Major Endurance */
, (8142017, 2572, 2) /* Major Coordination */
, (8142017, 2575, 2) /* Major Quickness */
, (8142017, 2574, 2) /* Major Focus */
, (8142017, 2577, 2) /* Major Willpower */
/* Major cantrips — tinkering skills */
, (8142017, 2517, 2) /* Major Item Tinkering */
, (8142017, 2523, 2) /* Major Magic Item Tinkering */
, (8142017, 2503, 2) /* Major Armor Tinkering */
, (8142017, 2535, 2) /* Major Weapon Tinkering */
;
