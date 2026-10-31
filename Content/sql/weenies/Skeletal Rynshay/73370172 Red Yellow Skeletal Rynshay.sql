DELETE FROM `weenie` WHERE `class_Id` = 73370172;

INSERT INTO `weenie` (`class_Id`, `class_Name`, `type`, `last_Modified`)
VALUES (73370172, 'ace73370172-redyellowskeletalrynshay', 2, '2026-06-10 16:48:41') /* Clothing */;

INSERT INTO `weenie_properties_int` (`object_Id`, `type`, `value`)
VALUES (73370172,   1,          2) /* ItemType - Armor */
     , (73370172,   3,          4) /* PaletteTemplate - Brown */
     , (73370172,   4,       1024) /* ClothingPriority - OuterwearChest */
     , (73370172,   5,        420) /* EncumbranceVal */
     , (73370172,   8,        140) /* Mass */
     , (73370172,   9,        512) /* ValidLocations - ChestArmor */
     , (73370172,  16,          1) /* ItemUseable - No */
     , (73370172,  19,         80) /* Value */
     , (73370172,  27,          2) /* ArmorType - Leather */
     , (73370172,  28,         20) /* ArmorLevel */
     , (73370172,  93,       1044) /* PhysicsState - Ethereal, IgnoreCollisions, Gravity */
     , (73370172, 169,  118163214) /* TsysMutationData */;

INSERT INTO `weenie_properties_bool` (`object_Id`, `type`, `value`)
VALUES (73370172,  22, True ) /* Inscribable */
     , (73370172, 100, True ) /* Dyable */;

INSERT INTO `weenie_properties_float` (`object_Id`, `type`, `value`)
VALUES (73370172,  12, 0.6600000262260437) /* Shade */
     , (73370172,  13,       1) /* ArmorModVsSlash */
     , (73370172,  14, 0.800000011920929) /* ArmorModVsPierce */
     , (73370172,  15,       1) /* ArmorModVsBludgeon */
     , (73370172,  16,     0.5) /* ArmorModVsCold */
     , (73370172,  17,     0.5) /* ArmorModVsFire */
     , (73370172,  18, 0.30000001192092896) /* ArmorModVsAcid */
     , (73370172,  19, 0.6000000238418579) /* ArmorModVsElectric */
     , (73370172, 110, 1.6699999570846558) /* BulkMod */
     , (73370172, 111,     2.5) /* SizeMod */;

INSERT INTO `weenie_properties_string` (`object_Id`, `type`, `value`)
VALUES (73370172,   1, 'Red Yellow Skeletal Rynshay') /* Name */;

INSERT INTO `weenie_properties_d_i_d` (`object_Id`, `type`, `value`)
VALUES (73370172,   1,   33554642) /* Setup */
     , (73370172,   3,  536870932) /* SoundTable */
     , (73370172,   6,   67108990) /* PaletteBase */
     , (73370172,   7,  268437944) /* ClothingBase */
     , (73370172,   8,  100667350) /* Icon */
     , (73370172,  22,  872415275) /* PhysicsEffectTable */
     , (73370172,  36,  234881042) /* MutateFilter */
     , (73370172,  46,  939524146) /* TsysMutationFilter */;
