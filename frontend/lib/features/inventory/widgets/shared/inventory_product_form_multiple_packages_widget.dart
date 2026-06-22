import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_package_form_fields_widget.dart';
import 'inventory_product_form_package_item_widget.dart';

class InventoryProductFormMultiplePackagesWidget
    extends GetView<ProductFormController> {
  const InventoryProductFormMultiplePackagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('multiple_packages'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Nút "Add variants" dạng Outlined
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              controller.clearPackageForm();
              TBottomSheetWidget.show(
                title: TTexts.addPackageTitle.tr,
                child: Column(
                  children: [
                    const InventoryProductPackageFormFieldsWidget(),
                    const SizedBox(height: 24),
                    TPrimaryButtonWidget(
                      text: TTexts.addPackageBtn.tr,
                      onPressed: () => controller.addPackageToList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Iconsax.add_circle_copy, size: 20),
            label: Text(
              TTexts.addNewPackage.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Đường gạch ngang phân cách mỏng gọn
        const Divider(color: AppColors.divider, thickness: 1),
        const SizedBox(height: 16),

        // 3. Tiêu đề danh sách
        Text(
          TTexts.addedVariantsHeader.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),

        // 4. Danh sách các Package hiển thị bằng Widget riêng lẻ biệt
        Obx(() {
          if (controller.packageDrafts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: Text(
                  TTexts.noPackagesFound.tr,
                  style: const TextStyle(color: AppColors.subText),
                ),
              ),
            );
          }

          return ListView.builder(
            // Dùng builder thay vì separated
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.packageDrafts.length,
            itemBuilder: (context, index) {
              final draft = controller.packageDrafts[index];

              final String fallbackName =
                  "${TTexts.variantLabel.tr} ${index + 1}";
              final String titleText =
                  "${draft.variant.isNotEmpty ? draft.variant : fallbackName} - ${draft.unitName}";
              final String subtitleText =
                  "${TTexts.salePrice.tr}: ${draft.salePrice} | ${TTexts.stockQuantityLabel.tr}: ${draft.quantity}";

              return InventoryProductFormPackageItemWidget(
                title: titleText,
                subtitle: subtitleText,
                onTap: () => controller.editPackageInList(index),
                onDelete: () => controller.removePackageDraft(index),
              );
            },
          );
        }),
      ],
    );
  }
}
