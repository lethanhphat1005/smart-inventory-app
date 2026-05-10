import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart'; // Nút bấm chuẩn của bạn
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TDataErrorLayout extends StatelessWidget {
  final VoidCallback onPressed;
  final String? title;
  final String? message;
  final String? buttonText;

  const TDataErrorLayout({
    super.key,
    required this.onPressed,
    this.title,
    this.message,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Icon cảnh báo (Box rỗng)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.alertBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.box_remove_copy,
                size: 64,
                color: AppColors.alertText,
              ),
            ),
            const SizedBox(height: AppSizes.p32),

            // 2. Tiêu đề lỗi
            Text(
              title ?? TTexts.errorNotFoundTitle.tr,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // 3. Nội dung thông báo
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                message ?? TTexts.errorNotFoundMessage.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 14,
                  color: AppColors.subText,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p48),

            // 4. Nút quay lại / Thử lại
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: TPrimaryButtonWidget(
                text: buttonText ?? TTexts.goBack.tr,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
