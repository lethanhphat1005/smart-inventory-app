import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

import 'package:frontend/core/ui/widgets/t_image_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/auth/controllers/forgot_password_controller.dart';

class ForgotPasswordFormWidget extends GetView<ForgotPasswordController> {
  const ForgotPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            TTexts.forgotPasswordInnerTitle.tr,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ),

        const SizedBox(
          height: AppSizes.p24,
        ),

        Center(
          child: TImageWidget(
            image: TImages.authImages.forgotPasswordContent1,
            height: 200,
          ),
        ),
        const SizedBox(height: AppSizes.p32),

        TTextFormFieldWidget(
          controller: controller.emailController,
          label: TTexts.emailLabel.tr,
          hintText: TTexts.emailHint.tr,
        ),
        const SizedBox(height: AppSizes.p24),

        // Nút Gửi Email (Nút chính)
        Obx(() => TPrimaryButtonWidget(
              text: controller.isLoading.value
                  ? TTexts.emailSending.tr
                  : TTexts.forgotPasswordBtn.tr,
              onPressed:
                  controller.isLoading.value ? null : controller.sendResetLink,
            )),
        const SizedBox(height: AppSizes.p16),

        // Nút Quay Lại
        TPrimaryButtonWidget(
          text: TTexts.goBack.tr,
          isOutlined: true,
          textColor: AppColors.primaryText,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}
