/* JawnTide live events: weapon for the event boss only, built from the stock 24207 with its stats +10% (keeps Bael'Zharon's Hate: human slayer). No wield or arcane requirements; attuned and bonded; nothing sells or drops it (@ci 520111). */
DELETE FROM `weenie` WHERE `class_Id` = 520111;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520111, 'jawntide-shadowwand', 35, '2021-11-01 00:00:00') /* Caster */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520111,   1,      32768) /* ItemType - Caster */
     , (520111,   5,        150) /* EncumbranceVal */
     , (520111,   8,         10) /* Mass */
     , (520111,   9,   16777216) /* ValidLocations - Held */
     , (520111,  16,    6291464) /* ItemUseable - SourceContainedTargetRemoteNeverWalk */
     , (520111,  18,          1) /* UiEffects - Magical */
     , (520111,  19,          0) /* Value */
     , (520111,  33,          1) /* Bonded - Bonded */
     , (520111,  36,       9999) /* ResistMagic */
     , (520111,  46,        512) /* DefaultCombatStyle - Magic */
     , (520111,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520111,  94,         16) /* TargetType - Creature */
     , (520111, 106,        325) /* ItemSpellcraft */
     , (520111, 107,        800) /* ItemCurMana */
     , (520111, 108,        800) /* ItemMaxMana */
     , (520111, 114,          1) /* Attuned - Attuned */
     , (520111, 117,         60) /* ItemManaCost */
     , (520111, 150,        103) /* HookPlacement - Hook */
     , (520111, 151,          2) /* HookType - Wall */
     , (520111, 166,         31) /* SlayerCreatureType - Human */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520111,  22, True ) /* Inscribable */
     , (520111,  69, False) /* IsSellable */
     , (520111,  99, True ) /* Ivoryable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520111,   5,  -0.025) /* ManaRate */
     , (520111,  29,     1.1) /* WeaponDefense */
     , (520111,  39,       1) /* DefaultScale */
     , (520111, 138,    1.54) /* SlayerDamageBonus */
     , (520111, 144,   0.022) /* ManaConversionMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520111,   1, 'Shadow Wand') /* Name */
     , (520111,  16, 'A wand infused with the Heart of the Innocent, carried only by champions of shadow.') /* LongDesc */
     , (520111,  15, 'A wand infused with the Heart of the Innocent.The wand appears to be guided by a preternatural force seeking flesh and blood with great tenacity.') /* ShortDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520111,   1, 0x02000F1C) /* Setup */
     , (520111,   3, 0x20000014) /* SoundTable */
     , (520111,   8, 0x06002AD9) /* Icon */
     , (520111,  22, 0x3400002B) /* PhysicsEffectTable */
     , (520111,  27, 0x400000E1) /* UseUserAnimation - UseMagicWand */
     , (520111,  28,       2970) /* Spell - Hunter's Lash */
     , (520111,  36, 0x0E000016) /* MutateFilter */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520111,   616,      2)  /* Life Magic Mastery Other VI */
     , (520111,   640,      2)  /* War Magic Mastery Other VI */
     , (520111,  1426,      2)  /* Focus Self VI */
     , (520111,  1450,      2)  /* Willpower Self VI */
     , (520111,  2691,      2)  /* Moderate Mana Conversion Prowess */;
