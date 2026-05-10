import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/auth/controllers/verify_email_controller.dart';

class VerifyEmailGoToGmailButtonWidget extends GetView<VerifyEmailController> {
  const VerifyEmailGoToGmailButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.openMailApp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ĐÃ FIX: Gọi đúng chuẩn class TImages của bạn
            Image.asset(
              TImages.appLogos.gmailLogo,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: AppSizes.p12),
            Text(
              TTexts.goToGmail.tr,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
