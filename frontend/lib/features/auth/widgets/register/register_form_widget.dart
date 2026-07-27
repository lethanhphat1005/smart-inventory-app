import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/register/register_password_strength_indicator_widget.dart';
import 'package:frontend/features/auth/widgets/register/register_terms_checkbox_widget.dart';
import 'package:frontend/features/auth/widgets/shared/auth_social_button_widget.dart';
import 'package:frontend/features/auth/widgets/shared/auth_tab_toggle_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/auth/controllers/register_controller.dart';

class RegisterFormWidget extends GetView<RegisterController> {
  const RegisterFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthTabToggleWidget(isLogin: false),
        const SizedBox(height: AppSizes.p24),

        // 1. Email
        TTextFormFieldWidget(
          controller: controller.emailController,
          label: TTexts.emailLabel.tr,
          hintText: TTexts.emailHint.tr,
        ),
        const SizedBox(height: AppSizes.p24),

        // 2. Password + Thanh đo
        Obx(() => Column(
              children: [
                TTextFormFieldWidget(
                  controller: controller.passwordController,
                  label: TTexts.passwordLabel.tr,
                  hintText: TTexts.passwordHint.tr,
                  isObscure: controller.isPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.subText,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  onChanged: (value) => controller.checkPasswordStrength(value),
                ),
                RegisterPasswordStrengthIndicatorWidget(
                    strength: controller.passwordStrength.value),
              ],
            )),
        const SizedBox(height: AppSizes.p16),

        // 3. Confirm Password
        Obx(() => TTextFormFieldWidget(
              controller: controller.confirmPasswordController,
              label: TTexts.confirmPasswordLabel.tr,
              hintText: TTexts.confirmPasswordHint.tr,
              isObscure: controller.isConfirmPasswordHidden.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordHidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.subText,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            )),
        const SizedBox(height: AppSizes.p32),

        // 4. Nút Đăng ký
        Obx(() => TPrimaryButtonWidget(
              text: controller.isLoading.value
                  ? TTexts.registering.tr
                  : TTexts.registerBtn.tr,
              backgroundColor: AppColors.primary,
              onPressed:
                  controller.isLoading.value ? null : controller.register,
            )),
        const SizedBox(height: AppSizes.p24),

        // 5. Divider "Or"
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Text(
                TTexts.authOrDivider.tr,
                style: const TextStyle(color: AppColors.subText, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          ],
        ),
        const SizedBox(height: AppSizes.p16),

        // 6. Nút Register với Google
        AuthSocialButtonWidget(
          title: TTexts.registerWithGoogle.tr,
          onPressed: () => controller.registerWithGoogle(),
        ),
        
        const SizedBox(height: AppSizes.p16),
        const RegisterTermsCheckboxWidget(),
        const SizedBox(height: AppSizes.p24),
      ],
    );
  }
}
