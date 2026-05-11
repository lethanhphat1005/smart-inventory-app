import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';

class InventoryProductFormActionButtonsWidget
    extends GetView<ProductFormController> {
  const InventoryProductFormActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSizes.p20, right: AppSizes.p20, bottom: 48, top: 16),
      child: Obx(() {
        final mode = controller.formMode.value;
        final step = controller.currentStep.value;

        // 1. CÁC NÚT BẤM DÀNH CHO CHẾ ĐỘ CHỈNH SỬA (LẺ TẺ)
        if (mode == 'info') {
          return TPrimaryButtonWidget(
              text: TTexts.saveChanges.tr,
              onPressed: () => controller.saveProductInfo());
        }
        if (mode == 'image') {
          return TPrimaryButtonWidget(
              text: TTexts.saveImage.tr,
              onPressed: () => controller.saveProductImage());
        }
        if (mode == 'edit_package' || mode == 'add_package') {
          return TPrimaryButtonWidget(
              text: TTexts.savePackage.tr,
              onPressed: () => controller.savePackageData());
        }

        // 2. CÁC NÚT BẤM DÀNH CHO WIZARD TẠO MỚI HOÀN TOÀN (CREATE)
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // NÚT TRÁI (BACK HOẶC CANCEL)
                Expanded(
                  flex: 1,
                  child: TPrimaryButtonWidget(
                    text: step == 1 ? TTexts.cancel.tr : TTexts.previousStep.tr,
                    backgroundColor: AppColors.softGrey.withOpacity(0.15),
                    textColor: AppColors.primaryText,
                    onPressed: () => step == 1
                        ? controller.confirmExit()
                        : controller.previousStep(),
                  ),
                ),
                const SizedBox(width: 16),

                // NÚT PHẢI (NEXT HOẶC CREATE FULL PRODUCT)
                Expanded(
                  flex: 2,
                  child: TPrimaryButtonWidget(
                    text: step == 3
                        ? TTexts.createFullProduct.tr
                        : TTexts.nextStep.tr,
                    onPressed: () {
                      if (step == 3) {
                        controller
                            .saveProduct(); // Hàm này sẽ gọi Dialog xác nhận
                      } else {
                        controller.nextStep();
                      }
                    },
                  ),
                ),
              ],
            ),

            // NÚT SKIP CHỈ XUẤT HIỆN Ở BƯỚC 3 NẰM BÊN DƯỚI
            if (step == 3) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => controller.confirmSkipAndCreateProductOnly(),
                child: Text(
                  TTexts.skipAndCreate.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subText, // Màu xám nhẹ
                    decoration: TextDecoration.underline, // Gạch chân mảnh
                    decorationColor: AppColors.softGrey,
                  ),
                ),
              ),
            ]
          ],
        );
      }),
    );
  }
}
