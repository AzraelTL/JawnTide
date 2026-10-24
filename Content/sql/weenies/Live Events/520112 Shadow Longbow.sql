/* JawnTide live events: weapon for the event boss only, built from the stock 24199 with its stats +10% (keeps Bael'Zharon's Hate: human slayer). No wield or arcane requirements; attuned and bonded; nothing sells or drops it (@ci 520112). */
DELETE FROM `weenie` WHERE `class_Id` = 520112;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (520112, 'jawntide-shadowlongbow', 3, '2021-11-17 16:56:08') /* MissileLauncher */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (520112,   1,        256) /* ItemType - MissileWeapon */
     , (520112,   5,        950) /* EncumbranceVal */
     , (520112,   8,        140) /* Mass */
     , (520112,   9,    4194304) /* ValidLocations - MissileWeapon */
     , (520112,  16,          1) /* ItemUseable - No */
     , (520112,  18,          1) /* UiEffects - Magical */
     , (520112,  19,          0) /* Value */
     , (520112,  33,          1) /* Bonded - Bonded */
     , (520112,  36,       9999) /* ResistMagic */
     , (520112,  44,         29) /* Damage */
     , (520112,  46,         16) /* DefaultCombatStyle - Bow */
     , (520112,  48,         47) /* WeaponSkill - MissileWeapons */
     , (520112,  49,         10) /* WeaponTime */
     , (520112,  50,          1) /* AmmoType - Arrow */
     , (520112,  51,          2) /* CombatUse - Missile */
     , (520112,  52,          2) /* ParentLocation - LeftHand */
     , (520112,  53,          3) /* PlacementPosition - LeftHand */
     , (520112,  60,        175) /* WeaponRange */
     , (520112,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (520112, 106,        300) /* ItemSpellcraft */
     , (520112, 107,        800) /* ItemCurMana */
     , (520112, 108,        800) /* ItemMaxMana */
     , (520112, 114,          1) /* Attuned - Attuned */
     , (520112, 150,        103) /* HookPlacement - Hook */
     , (520112, 151,          2) /* HookType - Wall */
     , (520112, 166,         31) /* SlayerCreatureType - Human */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (520112,  22, True ) /* Inscribable */
     , (520112,  69, False) /* IsSellable */
     , (520112,  99, True ) /* Ivoryable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (520112,   5,  -0.025) /* ManaRate */
     , (520112,  21,       0) /* WeaponLength */
     , (520112,  22,       0) /* DamageVariance */
     , (520112,  26,      50) /* MaximumVelocity */
     , (520112,  29,   1.298) /* WeaponDefense */
     , (520112,  62,     1.1) /* WeaponOffense */
     , (520112,  63,   2.398) /* DamageMod */
     , (520112, 138,    3.19) /* SlayerDamageBonus */
     , (520112, 151,       1) /* IgnoreShield */
     , (520112, 155,       1) /* IgnoreArmor */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (520112,   1, 'Shadow Longbow') /* Name */
     , (520112,  16, 'A bow infused with the Heart of the Innocent, carried only by champions of shadow.') /* LongDesc */
     , (520112,  15, 'A bow infused with the Heart of the Innocent.The weapon appears to be guided by a preternatural force seeking flesh and blood with great tenacity.') /* ShortDesc */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (520112,   1, 0x02000F14) /* Setup */
     , (520112,   3, 0x20000014) /* SoundTable */
     , (520112,   8, 0x06002AE0) /* Icon */
     , (520112,  22, 0x3400002B) /* PhysicsEffectTable */;

INSERT INTO `weenie_properties_spell_book` (`object_Id`, `spell`, `probability`)
VALUES (520112,  2687,      2)  /* Moderate Missile Weapon Aptitude */;
