import 'package:flutter/material.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_package_unit_dropdown_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';

class InventoryProductPackageFormFieldsWidget
    extends GetView<ProductFormController> {
  const InventoryProductPackageFormFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // KHAI BÁO BIẾN Ở ĐÂY, KHÔNG CẦN DÙNG OBX CHO BIẾN TĨNH
    final isEditMode = controller.packageToEdit != null;

    return Form(
      key: controller.packageFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHỌN ĐƠN VỊ (BỊ KHÓA NẾU LÀ EDIT MODE)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IgnorePointer(
                ignoring: isEditMode,
                child: Opacity(
                  opacity: isEditMode ? 0.6 : 1.0,
                  child: const InventoryProductPackageUnitDropdownWidget(),
                ),
              ),
              if (isEditMode)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    TTexts.unitLockedMessage.tr,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.alertText,
                        fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. TÊN HIỂN THỊ PREVIEW
          TTextFormFieldWidget(
            label: TTexts.displayNameLabel.tr,
            hintText: TTexts.displayNameHint.tr,
            isRequired: true,
            readOnly: true,
            controller: controller.packageDisplayNameController,
          ),
          const SizedBox(height: 16),

          // 3. SUFFIX NAME (Phần cho phép User sửa)
          TTextFormFieldWidget(
            label: TTexts.displayNameSuffixLabel.tr,
            hintText: TTexts.displayNameSuffixHint.tr,
            controller: controller.packageVariantNameController,
          ),

          // THANH GỢI Ý CHIPS (Đoạn này giữ nguyên Obx vì selectedUnitId là Rx)
          Obx(() {
            final suggestions = controller.variantNameSuggestions;
            if (suggestions.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: suggestions
                      .map((suggestion) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(suggestion,
                                  style: const TextStyle(
                                      fontSize: 12, fontFamily: 'Poppins')),
                              backgroundColor: AppColors.surface,
                              side: BorderSide(
                                  color: AppColors.primary.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onPressed: () => controller
                                  .selectVariantSuggestion(suggestion),
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // 4. GIÁ NHẬP & GIÁ BÁN
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TTextFormFieldWidget(
                  label: TTexts.importPriceLabel.tr,
                  hintText: '0.0',
                  keyboardType: TextInputType.number,
                  controller: controller.importPriceController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TTextFormFieldWidget(
                  label: TTexts.sellingPriceLabel.tr,
                  hintText: '0.0',
                  keyboardType: TextInputType.number,
                  controller: controller.salePriceController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. NGƯỠNG CẢNH BÁO TỒN KHO (>0 hoặc Null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: TTextFormFieldWidget(
                  label: TTexts.reorderThresholdLabel.tr,
                  hintText: TTexts.zero.tr,
                  keyboardType: TextInputType.number,
                  controller: controller.thresholdController,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final parsed = int.tryParse(v.trim());
                      if (parsed == null) return TTexts.invalidNumber.tr;
                      if (parsed <= 0) {
                        return TTexts.thresholdMustBeGreaterThanZero.tr;
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Tooltip(
                  message: TTexts.leaveEmptyForNoLimit.tr,
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  decoration: BoxDecoration(
                    color: AppColors.primaryText.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 12),
                  child: const Icon(Iconsax.info_circle_copy,
                      color: AppColors.softGrey, size: 22),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 24),

          // 6. BARCODE
          TTextFormFieldWidget(
            label: TTexts.barcodeLabel.tr,
            hintText: TTexts.scanOrTypeBarcode.tr,
            controller: controller.barcodeController,
            isRequired: true,
            suffixIcon: IconButton(
              icon: const Icon(Iconsax.scan_barcode_copy,
                  color: AppColors.primary),
              onPressed: () {
                Get.to(() => TBarcodeScannerLayout(
                      title: TTexts.homeScanBarcode.tr,
                      onScanned: (code) {
                        controller.barcodeController.text = code;
                        Get.back();
                      },
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
