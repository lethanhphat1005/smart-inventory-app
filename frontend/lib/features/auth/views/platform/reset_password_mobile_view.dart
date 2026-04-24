import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:get/get.dart';

import 'package:frontend/features/auth/controllers/reset_password_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';

class ResetPasswordMobileView extends GetView<ResetPasswordController> {
  const ResetPasswordMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AuthStandardLayout(
      title: TTexts.resetPasswordTitle.tr,
      subtitle: TTexts.resetPasswordSubtitle.tr,
      showBackButton: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.04),
            TTextFormFieldWidget(
              controller: controller.passwordController,
              label: TTexts.newPasswordLabel.tr,
              hintText: TTexts.newPasswordHint.tr,
              isObscure: true,
            ),
            const SizedBox(height: AppSizes.p16),
            TTextFormFieldWidget(
              controller: controller.confirmPasswordController,
              label: TTexts.confirmPasswordLabel.tr,
              hintText: TTexts.confirmPasswordHint.tr,
              isObscure: true,
            ),
            const SizedBox(height: AppSizes.p32),
            Obx(() => TPrimaryButtonWidget(
                  text: controller.isLoading.value
                      ? TTexts.updatingPassword.tr
                      : TTexts.updatePasswordBtn.tr,
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
                )),
            const SizedBox(height: AppSizes.p16),
            TPrimaryButtonWidget(
              text: TTexts.cancel.tr,
              isOutlined: true,
              textColor: AppColors.primaryText,
              onPressed: controller.cancelReset,
            ),
          ],
        ),
      ),
    );
  }
}
