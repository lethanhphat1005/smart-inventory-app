import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/auth/controllers/verify_otp_controller.dart';
import 'package:get/get.dart';

class VerifyOTPButtonWidget extends StatelessWidget {
  final VerifyOtpController controller;

  const VerifyOTPButtonWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nút Xác nhận
        Obx(() => TPrimaryButtonWidget(
              text:
                  controller.isLoading.value ? 'Đang xác thực...' : 'Xác nhận',
              onPressed:
                  controller.isLoading.value ? null : controller.verifyOtp,
            )),

        const SizedBox(height: AppSizes.p16),

        // Nút Mở Gmail
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.openEmailApp,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                ),
                side: BorderSide(color: Colors.grey.shade300)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  TImages.appLogos.gmailLogo,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: AppSizes.p12),
                Text(
                  TTexts.goToGmail.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSizes.p16),

        // Nút Quay lại
        TPrimaryButtonWidget(
          text: 'Quay lại',
          isOutlined: true,
          textColor: AppColors.primaryText,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}
