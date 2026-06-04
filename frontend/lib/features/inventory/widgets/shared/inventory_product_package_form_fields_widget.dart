import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_package_unit_dropdown_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_barcode_item_widget.dart';
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
    return Obx(() {
      final isView = controller.formMode.value == 'view_package';
      final isEdit = controller.formMode.value == 'edit_package';

      return Form(
        key: controller.packageFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CHỌN ĐƠN VỊ
            IgnorePointer(
              ignoring: isView,
              child: const InventoryProductPackageUnitDropdownWidget(),
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

            // 3. VARIANT
            TTextFormFieldWidget(
              label: TTexts.variantLabel.tr,
              hintText: TTexts.variantHint.tr,
              readOnly: isView,
              controller: controller.packageVariantNameController,
            ),
            const SizedBox(height: 24),

            // 4. GIÁ NHẬP & GIÁ BÁN
            Row(
              children: [
                Expanded(
                  child: TTextFormFieldWidget(
                    label: TTexts.importCost.tr,
                    hintText: '0',
                    isRequired: true,
                    readOnly: isView,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: controller.importPriceController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TTextFormFieldWidget(
                    label: TTexts.salePrice.tr,
                    hintText: '0',
                    isRequired: true,
                    readOnly: isView,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: controller.salePriceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. THRESHOLD & INITIAL QUANTITY
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CỘT 1: THRESHOLD ---
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TTextFormFieldWidget(
                          label: TTexts.reorderThresholdLabel.tr,
                          hintText: TTexts.zero.tr,
                          keyboardType: TextInputType.number,
                          readOnly: isView,
                          controller: controller.thresholdController,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final parsed = int.tryParse(v.trim());
                              if (parsed == null) {
                                return TTexts.invalidNumber.tr;
                              }
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
                        padding: const EdgeInsets.only(
                            top: 8), // Chỉnh lại padding để icon cân bằng
                        child: Tooltip(
                          message: TTexts.leaveEmptyForNoLimit.tr,
                          triggerMode: TooltipTriggerMode.tap,
                          preferBelow: false,
                          decoration: BoxDecoration(
                            color: AppColors.primaryText.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.mainFont,
                              fontSize: 12),
                          child: const Icon(Iconsax.info_circle_copy,
                              color: AppColors.softGrey, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- CỘT 2: INITIAL QUANTITY (CHỈ HIỆN KHI TẠO MỚI) ---
                if (!isEdit && !isView) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TTextFormFieldWidget(
                      label: TTexts.initialQuantityLabel.tr,
                      hintText: TTexts.initialQuantityHint.tr,
                      keyboardType: TextInputType.number,
                      controller: controller.quantityController,
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final parsed = int.tryParse(v.trim());
                          if (parsed == null || parsed < 0) {
                            return TTexts.invalidNumber.tr;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ] else ...[
                  const Expanded(flex: 2, child: SizedBox.shrink()),
                ]
              ],
            ),
            const SizedBox(height: 24),

            // 6. BARCODE INPUT
            if (!isView) ...[
              TTextFormFieldWidget(
                label: TTexts.barcodeLabel.tr,
                hintText: TTexts.enterBarcodeHint.tr,
                controller: controller.barcodeInputController,
                onFieldSubmitted: (val) {
                  if (val.isNotEmpty) {
                    controller.addBarcode(val);
                  }
                },
                suffixIcon: IconButton(
                  icon: const Icon(Iconsax.scan_barcode_copy,
                      size: 24, color: AppColors.primary),
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    Get.to(() => TBarcodeScannerLayout(
                          // title: TTexts.homeScanBarcode.tr,
                          onScanned: (code) {
                            // Đóng màn hình camera trước tiên
                            Get.back();

                            // Đợi màn hình thu về rồi mới add code
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              controller.addBarcode(code);
                            });
                          },
                        ));
                  },
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              if (controller.packageBarcodes.isEmpty) ...[
                TTextFormFieldWidget(
                  label: TTexts.barcodeLabel.tr,
                  hintText: TTexts.noBarcode.tr,
                  readOnly: true,
                  controller: TextEditingController(),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Text(
                  TTexts.barcodeLabel.tr,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
                const SizedBox(height: 8),
              ]
            ],

            // 7. DANH SÁCH MÃ VẠCH (LIST VIEW)
            if (controller.packageBarcodes.isEmpty)
              const SizedBox.shrink()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.packageBarcodes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final code = controller.packageBarcodes[index];

                  return Obx(() {
                    final isMarkedDeleted =
                        controller.pendingDeleteBarcodes.contains(code);

                    return InventoryProductBarcodeItemWidget(
                      barcode: code,
                      isDeleted: isMarkedDeleted,
                      isView: isView,
                      onRemove: () => controller.removeOrMarkBarcode(code),
                      onUndo: () => controller.undoMarkBarcode(code),
                    );
                  });
                },
              ),
          ],
        ),
      );
    });
  }
}
