DELETE FROM `weenie` WHERE `class_Id` = 73370171;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (73370171, 'ace73370171-yellowgreenskeletalrynshay', 2, '2026-06-10 16:35:18') /* Clothing */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (73370171,   1,          2) /* ItemType - Armor */
     , (73370171,   3,          4) /* PaletteTemplate - Brown */
     , (73370171,   4,       1024) /* ClothingPriority - OuterwearChest */
     , (73370171,   5,        420) /* EncumbranceVal */
     , (73370171,   8,        140) /* Mass */
     , (73370171,   9,        512) /* ValidLocations - ChestArmor */
     , (73370171,  16,          1) /* ItemUseable - No */
     , (73370171,  19,         80) /* Value */
     , (73370171,  27,          2) /* ArmorType - Leather */
     , (73370171,  28,         20) /* ArmorLevel */
     , (73370171,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (73370171, 169,  118163214) /* TsysMutationData */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (73370171,  22, True ) /* Inscribable */
     , (73370171, 100, True ) /* Dyable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (73370171,  12, 0.6600000262260437) /* Shade */
     , (73370171,  13,       1) /* ArmorModVsSlash */
     , (73370171,  14, 0.800000011920929) /* ArmorModVsPierce */
     , (73370171,  15,       1) /* ArmorModVsBludgeon */
     , (73370171,  16,     0.5) /* ArmorModVsCold */
     , (73370171,  17,     0.5) /* ArmorModVsFire */
     , (73370171,  18, 0.30000001192092896) /* ArmorModVsAcid */
     , (73370171,  19, 0.6000000238418579) /* ArmorModVsElectric */
     , (73370171, 110, 1.6699999570846558) /* BulkMod */
     , (73370171, 111,     2.5) /* SizeMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (73370171,   1, 'Yellow Green Skeletal Rynshay') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (73370171,   1,   33554642) /* Setup */
     , (73370171,   3,  536870932) /* SoundTable */
     , (73370171,   6,   67108990) /* PaletteBase */
     , (73370171,   7,  268437943) /* ClothingBase */
     , (73370171,   8,  100667350) /* Icon */
     , (73370171,  22,  872415275) /* PhysicsEffectTable */
     , (73370171,  36,  234881042) /* MutateFilter */
     , (73370171,  46,  939524146) /* TsysMutationFilter */;
