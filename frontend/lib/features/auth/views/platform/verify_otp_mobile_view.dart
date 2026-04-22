import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/verify_otp/verify_otp_action_button_widget.dart';
import 'package:frontend/features/auth/widgets/verify_otp/verify_otp_input_form_widget.dart';
import 'package:frontend/features/auth/widgets/verify_otp/verify_otp_resend_code_text_widget.dart';
import 'package:get/get.dart';

import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:frontend/features/auth/controllers/verify_otp_controller.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class VerifyOtpMobileView extends GetView<VerifyOtpController> {
  const VerifyOtpMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStandardLayout(
      title: 'Xác thực mã OTP',
      subtitle:
          'Mã xác thực đã được gửi đến địa chỉ email:\n${controller.email}',
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.p40),
            VerifyOTPInputFormWidget(controller: controller),
            const SizedBox(height: AppSizes.p24),
            VerifyOTPResendCodeTextWidget(controller: controller),
            const SizedBox(height: AppSizes.p40),
            VerifyOTPButtonWidget(controller: controller),
          ],
        ),
      ),
    );
  }
}
