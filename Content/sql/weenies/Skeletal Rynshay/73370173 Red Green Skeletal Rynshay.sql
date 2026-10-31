DELETE FROM `weenie` WHERE `class_Id` = 73370173;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (73370173, 'ace73370173-redgreenskeletalrynshay', 2, '2026-06-10 16:48:41') /* Clothing */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (73370173,   1,          2) /* ItemType - Armor */
     , (73370173,   3,          4) /* PaletteTemplate - Brown */
     , (73370173,   4,       1024) /* ClothingPriority - OuterwearChest */
     , (73370173,   5,        420) /* EncumbranceVal */
     , (73370173,   8,        140) /* Mass */
     , (73370173,   9,        512) /* ValidLocations - ChestArmor */
     , (73370173,  16,          1) /* ItemUseable - No */
     , (73370173,  19,         80) /* Value */
     , (73370173,  27,          2) /* ArmorType - Leather */
     , (73370173,  28,         20) /* ArmorLevel */
     , (73370173,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (73370173, 169,  118163214) /* TsysMutationData */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (73370173,  22, True ) /* Inscribable */
     , (73370173, 100, True ) /* Dyable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (73370173,  12, 0.6600000262260437) /* Shade */
     , (73370173,  13,       1) /* ArmorModVsSlash */
     , (73370173,  14, 0.800000011920929) /* ArmorModVsPierce */
     , (73370173,  15,       1) /* ArmorModVsBludgeon */
     , (73370173,  16,     0.5) /* ArmorModVsCold */
     , (73370173,  17,     0.5) /* ArmorModVsFire */
     , (73370173,  18, 0.30000001192092896) /* ArmorModVsAcid */
     , (73370173,  19, 0.6000000238418579) /* ArmorModVsElectric */
     , (73370173, 110, 1.6699999570846558) /* BulkMod */
     , (73370173, 111,     2.5) /* SizeMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (73370173,   1, 'Red Green Skeletal Rynshay') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (73370173,   1,   33554642) /* Setup */
     , (73370173,   3,  536870932) /* SoundTable */
     , (73370173,   6,   67108990) /* PaletteBase */
     , (73370173,   7,  268437945) /* ClothingBase */
     , (73370173,   8,  100667350) /* Icon */
     , (73370173,  22,  872415275) /* PhysicsEffectTable */
     , (73370173,  36,  234881042) /* MutateFilter */
     , (73370173,  46,  939524146) /* TsysMutationFilter */;
