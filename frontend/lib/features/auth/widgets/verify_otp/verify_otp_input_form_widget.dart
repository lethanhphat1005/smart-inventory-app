import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/auth/controllers/verify_otp_controller.dart';
import 'package:pinput/pinput.dart';

class VerifyOTPInputFormWidget extends StatelessWidget {
  final VerifyOtpController controller;

  const VerifyOTPInputFormWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final availableWidth = size.width - (AppSizes.p24 * 2) - (8 * 7);
    final dynamicPinWidth = (availableWidth / 8).clamp(30.0, 48.0);
    final dynamicPinHeight = dynamicPinWidth * 1.15;

    final defaultPinTheme = PinTheme(
      width: dynamicPinWidth,
      height: dynamicPinHeight,
      textStyle: const TextStyle(
        fontSize: 18,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
      borderRadius: BorderRadius.circular(AppSizes.radius8),
    );

    return Center(
      child: Pinput(
        controller: controller.otpController,
        length: 8,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        onCompleted: (pin) => controller.verifyOtp(),
      ),
    );
  }
}
