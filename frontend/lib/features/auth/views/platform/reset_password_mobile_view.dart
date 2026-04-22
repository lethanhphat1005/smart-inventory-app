import 'package:flutter/material.dart';
import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:get/get.dart';

import 'package:frontend/features/auth/controllers/reset_password_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/ui/widgets/t_image_widget.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';

class ResetPasswordMobileView extends GetView<ResetPasswordController> {
  const ResetPasswordMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AuthStandardLayout(
      title: 'Thiết lập mật khẩu mới',
      // Đưa lời nhắc lên làm subtitle của Header
      subtitle:
          'Vui lòng nhập mật khẩu mới của bạn để hoàn tất quá trình khôi phục.',
      // Quá trình đổi mật khẩu thường không cho quay lại bước nhập OTP nữa để tránh lỗi logic
      showBackButton: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh minh họa
            Center(
              child: TImageWidget(
                image: TImages.authImages.forgotPasswordContent1,
                height: (size.height * 0.22).clamp(120.0, 200.0),
              ),
            ),

            SizedBox(height: size.height * 0.04),

            // Ô nhập mật khẩu mới
            TTextFormFieldWidget(
              controller: controller.passwordController,
              label: 'Mật khẩu mới',
              hintText: 'Nhập mật khẩu mới',
              isObscure: true,
            ),

            const SizedBox(height: AppSizes.p16),

            // Ô nhập xác nhận mật khẩu
            TTextFormFieldWidget(
              controller: controller.confirmPasswordController,
              label: 'Xác nhận mật khẩu',
              hintText: 'Nhập lại mật khẩu mới',
              isObscure: true,
            ),

            const SizedBox(height: AppSizes.p32),

            // Nút Cập nhật mật khẩu
            Obx(() => TPrimaryButtonWidget(
                  text: controller.isLoading.value
                      ? 'Đang cập nhật...'
                      : 'Cập nhật mật khẩu',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
                )),

            const SizedBox(height: AppSizes.p16),

            // Nút Hủy bỏ
            TPrimaryButtonWidget(
              text: 'Hủy bỏ',
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
