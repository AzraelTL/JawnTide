/* JawnTide live events: weapon for the event boss only, built from the stock 41638 with its stats +10% (keeps Bael'Zharon's Hate: human slayer). No wield or arcane requirements; attuned and bonded; nothing sells or drops it (@ci 520110). */
DELETE FROM `weenie` WHERE `class_Id` = 520110;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520110, 'jawntide-shadowreaver', 6, '2021-11-01 00:00:00') /* MeleeWeapon */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520110,   1,          1) /* ItemType - MeleeWeapon */
     , (520110,   5,        650) /* EncumbranceVal */
     , (520110,   9,   33554432) /* ValidLocations - TwoHanded */
     , (520110,  16,          1) /* ItemUseable - No */
     , (520110,  18,          1) /* UiEffects - Magical */
     , (520110,  19,          0) /* Value */
     , (520110,  33,          1) /* Bonded - Bonded */
     , (520110,  36,       9999) /* ResistMagic */
     , (520110,  44,         52) /* Damage */
     , (520110,  45,          1) /* DamageType - Slash */
     , (520110,  46,          8) /* DefaultCombatStyle - TwoHanded */
     , (520110,  47,          4) /* AttackType - Slash */
     , (520110,  48,         41) /* WeaponSkill - TwoHandedCombat */
     , (520110,  49,          1) /* WeaponTime */
     , (520110,  51,          5) /* CombatUse - TwoHanded */
     , (520110,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520110, 106,        300) /* ItemSpellcraft */
     , (520110, 107,        800) /* ItemCurMana */
     , (520110, 108,        800) /* ItemMaxMana */
     , (520110, 114,          1) /* Attuned - Attuned */
     , (520110, 151,          2) /* HookType - Wall */
     , (520110, 166,         31) /* SlayerCreatureType - Human */
     , (520110, 179,         12) /* ImbuedEffect - ArmorRending, SlashRending */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520110,  22, True ) /* Inscribable */
     , (520110,  69, False) /* IsSellable */
     , (520110,  99, True ) /* Ivoryable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520110,   5,  -0.025) /* ManaRate */
     , (520110,  21,       0) /* WeaponLength */
     , (520110,  22,     0.5) /* DamageVariance */
     , (520110,  26,       0) /* MaximumVelocity */
     , (520110,  29,   1.298) /* WeaponDefense */
     , (520110,  62,   1.353) /* WeaponOffense */
     , (520110,  63,       1) /* DamageMod */
     , (520110, 138,    3.74) /* SlayerDamageBonus */
     , (520110, 151,       1) /* IgnoreShield */
     , (520110, 155,       1) /* IgnoreArmor */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520110,   1, 'Shadow Reaver') /* Name */
     , (520110,  16, 'A greatsword infused with the Heart of the Innocent, carried only by champions of shadow.') /* LongDesc */
     , (520110,  15, 'A greatsword infused with the Heart of the Innocent.The weapon appears to be guided by a preternatural force seeking flesh and blood with great tenacity.') /* ShortDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520110,   1, 0x020018BB) /* Setup */
     , (520110,   3, 0x20000014) /* SoundTable */
     , (520110,   8, 0x06006B6D) /* Icon */
     , (520110,  22, 0x3400002B) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520110,  5074,      2)  /* Moderate Two Handed Combat Aptitude */;
