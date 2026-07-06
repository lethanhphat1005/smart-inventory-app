import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/auth/widgets/login/login_terms_checkbox_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import '../shared/auth_divider_widget.dart';
import '../shared/auth_social_button_widget.dart';
import '../shared/auth_tab_toggle_widget.dart';
import 'login_remember_me_widget.dart';
import '../../controllers/login_controller.dart';

class LoginFormWidget extends GetView<LoginController> {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AuthTabToggleWidget(isLogin: true),
        const SizedBox(height: AppSizes.p24),

        // 2. Ô Email
        TTextFormFieldWidget(
          controller: controller.emailController,
          label: TTexts.emailLabel.tr,
          hintText: TTexts.emailHint.tr,
        ),
        const SizedBox(height: AppSizes.p16),

        // 3. Ô Password
        Obx(
          () => TTextFormFieldWidget(
            controller: controller.passwordController,
            label: TTexts.passwordLabel.tr,
            hintText: TTexts.passwordHint.tr,
            isObscure: controller.isPasswordHidden.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordHidden.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed:
                  controller.togglePasswordVisibility, // Gọi hàm đổi trạng thái
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        // 4. Remember Me & Forgot Password
        const LoginRememberMeWidget(),
        const SizedBox(height: AppSizes.p24),

        // 5. Nút Login (Gọi hàm login của controller, ở trong controller đã có bước check policy rồi)
        TPrimaryButtonWidget(
          text: TTexts.loginBtn.tr,
          onPressed: () => controller.login(),
        ),
        const SizedBox(height: AppSizes.p24),

        const AuthDividerWidget(),
        const SizedBox(height: AppSizes.p24),

        AuthSocialButtonWidget(
            title: TTexts.continueWithGoogle.tr,
            onPressed: () => controller.loginWithGoogle()),
            
        const SizedBox(height: AppSizes.p16),
        const LoginTermsCheckboxWidget(),
      ],
    );
  }
}
