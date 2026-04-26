import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/auth/controllers/verify_email_controller.dart';

class VerifyEmailResendEmailButton extends GetView<VerifyEmailController> {
  const VerifyEmailResendEmailButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final isTimerZero = controller.timerCountdown.value == 0;
          final isResending = controller.isResending.value;

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed:
                  (isTimerZero && !isResending) ? controller.resendEmail : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: BorderSide(
                  color:
                      isTimerZero ? Colors.grey.shade300 : Colors.grey.shade100,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                ),
              ),
              child: isResending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      TTexts.resendEmail.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isTimerZero
                            ? AppColors.primaryText
                            : Colors.grey.shade400,
                      ),
                    ),
            ),
          );
        }),
        const SizedBox(height: AppSizes.p16),

        // Dòng chữ đếm ngược
        Obx(() {
          if (controller.timerCountdown.value > 0) {
            return RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.subText,
                ),
                children: [
                  TextSpan(text: TTexts.resendEmailIn.tr),
                  TextSpan(
                    text: '${controller.timerCountdown.value}s',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
