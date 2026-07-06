import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';

class LoginTermsCheckboxWidget extends StatelessWidget {
  const LoginTermsCheckboxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Obx(() {
      final hasError = controller.showCheckboxError.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: hasError ? Colors.red.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius8),
          border: Border.all(
            color: hasError ? Colors.red.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: controller.isTermsAccepted.value,
                onChanged: (val) {
                  controller.isTermsAccepted.value = val ?? false;
                  if (controller.isTermsAccepted.value) {
                    controller.showCheckboxError.value = false;
                  }
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: hasError ? Colors.red : Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: TTexts.termsAgreePrefix.tr,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    color: AppColors.subText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: TTexts.termsOfService.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => controller.goToLegalDocument(true),
                    ),
                    TextSpan(
                      text: TTexts.termsAnd.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        color: AppColors.subText,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: TTexts.privacyPolicy.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => controller.goToLegalDocument(false),
                    ),
                    TextSpan(
                      text: TTexts.termsAgreeSuffix.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        color: AppColors.subText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
