import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryProductFormBaseInfoWidget
    extends GetView<ProductFormController> {
  const InventoryProductFormBaseInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.baseFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Ô CHỌN DANH MỤC
          GestureDetector(
            onTap: () {
              if (!controller.isCategoryLocked) {
                controller.openCategoryPicker();
              }
            },
            child: AbsorbPointer(
              child: Obx(() => TTextFormFieldWidget(
                    label: TTexts.selectCategory.tr,
                    hintText: controller.selectedCategory.value?.name ??
                        TTexts.tapToSelect.tr,
                    suffixIcon: controller.isCategoryLocked
                        ? const Icon(Iconsax.lock_1_copy,
                            size: 18, color: AppColors.softGrey)
                        : const Icon(Iconsax.arrow_down_1_copy, size: 20),
                    controller: TextEditingController(
                        text: controller.selectedCategory.value?.name ?? ''),
                  )),
            ),
          ),
          const SizedBox(height: 24),

          TTextFormFieldWidget(
              label: TTexts.productNameLabel.tr,
              hintText: TTexts.productNameSubLabel.tr,
              controller: controller.nameController,
              validator: (v) => (v == null || v.isEmpty)
                  ? TTexts.errorUnknownMessage.tr
                  : null),
          const SizedBox(height: 24),

          TTextFormFieldWidget(
              label: TTexts.brand.tr,
              hintText: TTexts.brandSub.tr,
              controller: controller.brandController),
        ],
      ),
    );
  }
}
