import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/profile/controllers/profile_change_password_controller.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ChangePasswordFormWidget
    extends GetView<ProfileChangePasswordController> {
  const ChangePasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileChangePasswordController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            // OLD PASSWORD
            Obx(() => TTextFormFieldWidget(
                  controller: controller.oldPasswordController,
                  label: TTexts.changePasswordOldPassword.tr,
                  hintText: TTexts.changePasswordHintOldPassword.tr,
                  isObscure: controller.isOldPasswordHidden.value,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isOldPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.subText,
                    ),
                    onPressed: controller
                        .toggleOldPasswordVisibility, // Gọi hàm đổi trạng thái
                  ),
                )),
            const SizedBox(height: AppSizes.p8),

            // NEW PASSWORD
            Obx(() => TTextFormFieldWidget(
                  controller: controller.newPasswordController,
                  label: TTexts.changePasswordNewPassword.tr,
                  hintText: TTexts.changePasswordHintNewPassword.tr,
                  isObscure: controller.isNewPasswordHidden.value,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isNewPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.subText,
                    ),
                    onPressed: controller
                        .toggleNewPasswordVisibility, // Gọi hàm đổi trạng thái
                  ),
                )),

            const SizedBox(height: AppSizes.p8),

            // CONFIRM PASSWORD
            Obx(
              () => TTextFormFieldWidget(
                  controller: controller.confirmPasswordController,
                  label: TTexts.changePasswordConfirm.tr,
                  hintText: TTexts.changePasswordHintConfirmPassword.tr,
                  isObscure: controller.isConfirmPasswordHidden.value,
                  prefixIcon: Icons.lock_reset,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.subText,
                    ),
                    onPressed: controller
                        .toggleConfirmPasswordVisibility, // Gọi hàm đổi trạng thái
                  )),
            ),
            const SizedBox(height: AppSizes.p8),
          ],
        ),
      ),
    );
  }
}
