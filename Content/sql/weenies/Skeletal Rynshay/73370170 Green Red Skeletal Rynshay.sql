DELETE FROM `weenie` WHERE `class_Id` = 73370170;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (73370170, 'ace73370170-greenredskeletalrynshay', 2, '2026-06-10 16:35:18') /* Clothing */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (73370170,   1,          2) /* ItemType - Armor */
     , (73370170,   3,          4) /* PaletteTemplate - Brown */
     , (73370170,   4,       1024) /* ClothingPriority - OuterwearChest */
     , (73370170,   5,        420) /* EncumbranceVal */
     , (73370170,   8,        140) /* Mass */
     , (73370170,   9,        512) /* ValidLocations - ChestArmor */
     , (73370170,  16,          1) /* ItemUseable - No */
     , (73370170,  19,         80) /* Value */
     , (73370170,  27,          2) /* ArmorType - Leather */
     , (73370170,  28,         20) /* ArmorLevel */
     , (73370170,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (73370170, 169,  118163214) /* TsysMutationData */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (73370170,  22, True ) /* Inscribable */
     , (73370170, 100, True ) /* Dyable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (73370170,  12, 0.6600000262260437) /* Shade */
     , (73370170,  13,       1) /* ArmorModVsSlash */
     , (73370170,  14, 0.800000011920929) /* ArmorModVsPierce */
     , (73370170,  15,       1) /* ArmorModVsBludgeon */
     , (73370170,  16,     0.5) /* ArmorModVsCold */
     , (73370170,  17,     0.5) /* ArmorModVsFire */
     , (73370170,  18, 0.30000001192092896) /* ArmorModVsAcid */
     , (73370170,  19, 0.6000000238418579) /* ArmorModVsElectric */
     , (73370170, 110, 1.6699999570846558) /* BulkMod */
     , (73370170, 111,     2.5) /* SizeMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (73370170,   1, 'Green Red Skeletal Rynshay') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (73370170,   1,   33554642) /* Setup */
     , (73370170,   3,  536870932) /* SoundTable */
     , (73370170,   6,   67108990) /* PaletteBase */
     , (73370170,   7,  268437942) /* ClothingBase */
     , (73370170,   8,  100667350) /* Icon */
     , (73370170,  22,  872415275) /* PhysicsEffectTable */
     , (73370170,  36,  234881042) /* MutateFilter */
     , (73370170,  46,  939524146) /* TsysMutationFilter */;
