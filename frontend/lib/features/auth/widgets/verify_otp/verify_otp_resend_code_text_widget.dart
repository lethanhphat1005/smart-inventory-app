import 'package:flutter/material.dart';
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
            const Text(
              'Chưa nhận được mã? ',
              style: TextStyle(color: AppColors.subText, fontSize: 14),
            ),
            GestureDetector(
              onTap: controller.canResend.value ? controller.resendOtp : null,
              child: Text(
                controller.canResend.value
                    ? 'Gửi lại ngay'
                    : 'Gửi lại sau (${controller.countdown.value}s)',
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
