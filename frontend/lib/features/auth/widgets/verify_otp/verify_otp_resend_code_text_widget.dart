import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/auth/controllers/verify_otp_controller.dart';
import 'package:get/get.dart';

class VerifyOTPResendCodeTextWidget extends StatelessWidget {
  final VerifyOtpController controller;

  const VerifyOTPResendCodeTextWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              TTexts.verifyOtpNotReceived.tr,
              style: const TextStyle(color: AppColors.subText, fontSize: 14),
            ),
            GestureDetector(
              onTap: controller.canResend.value ? controller.resendOtp : null,
              child: Text(
                controller.canResend.value
                    ? TTexts.verifyOtpResendNow.tr
                    : '${TTexts.verifyOtpResendLater.tr} (${controller.countdown.value}s)',
                style: TextStyle(
                  color: controller.canResend.value
                      ? AppColors.primary
                      : AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
