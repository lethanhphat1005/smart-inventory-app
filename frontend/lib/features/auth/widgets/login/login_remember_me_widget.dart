import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class LoginRememberMeWidget extends GetView<LoginController> {
  const LoginRememberMeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Checkbox Remember Me
        Obx(
          () => Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: controller.toggleRememberMe,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                TTexts.rememberMe.tr,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 12,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
        ),
        // Nút Quên mật khẩu
        TextButton(
          onPressed: () {
            Get.toNamed(AppRoutes.forgotPassword);
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            TTexts.forgotPassword.tr,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
