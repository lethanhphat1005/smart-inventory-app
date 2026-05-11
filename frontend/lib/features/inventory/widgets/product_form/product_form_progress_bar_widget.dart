import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';

class ProductFormProgressBarWidget extends GetView<ProductFormController> {
  const ProductFormProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
      child: Obx(() {
        final step = controller.currentStep.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BƯỚC 1: Tên (TTexts.stepProductBaseInfo.tr)
            _buildStepCircle(TTexts.one.tr, TTexts.stepProductBaseInfo.tr,
                isActive: step == 1, isCompleted: step > 1),

            // LINE 1-2
            Expanded(child: _buildLine(isActive: step > 1)),

            // BƯỚC 2: Ảnh (TTexts.stepProductImage.tr)
            _buildStepCircle(TTexts.two.tr, TTexts.stepProductImage.tr,
                isActive: step == 2, isCompleted: step > 2),

            // LINE 2-3
            Expanded(child: _buildLine(isActive: step > 2)),

            // BƯỚC 3: Giá (TTexts.stepProductPackage.tr)
            _buildStepCircle(TTexts.three.tr, TTexts.stepProductPackage.tr,
                isActive: step == 3, isCompleted: false),
          ],
        );
      }),
    );
  }

  // WIDGET VÒNG TRÒN VÀ CHỮ
  Widget _buildStepCircle(String stepNumber, String label,
      {required bool isActive, required bool isCompleted}) {
    Color circleColor = AppColors.surface;
    Color numberColor = AppColors.softGrey;
    Color labelColor = AppColors.softGrey;
    FontWeight labelWeight = FontWeight.normal;

    if (isActive || isCompleted) {
      circleColor = AppColors.primary;
      numberColor = Colors.white;
      labelColor = AppColors.primaryText;
      labelWeight = FontWeight.bold;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(stepNumber,
              style: TextStyle(
                  color: numberColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 11,
                color: labelColor,
                fontWeight: labelWeight)),
      ],
    );
  }

  // WIDGET ĐƯỜNG KẺ MỜ MẢNH
  Widget _buildLine({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 12, right: 12),
      height: 2,
      color: isActive ? AppColors.primary : AppColors.softGrey.withOpacity(0.3),
    );
  }
}
