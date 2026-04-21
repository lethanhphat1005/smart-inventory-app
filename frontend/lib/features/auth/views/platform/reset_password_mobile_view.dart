import 'package:flutter/material.dart';
import 'package:frontend/features/auth/controllers/reset_password_controller.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';

class ResetPasswordMobileView extends GetView<ResetPasswordController> {
  const ResetPasswordMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề
        const Center(
          child: Text(
            'Thiết lập mật khẩu mới',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ),

        const SizedBox(height: AppSizes.p24),

        // Hình ảnh minh họa (dùng tạm ảnh trong assets của bạn hoặc thay ảnh khác)
        // Center(
        //   child: TImageWidget(
        //     image: TImages.authImages.resetPasswordContent, // Thay bằng đường dẫn ảnh đúng của bạn
        //     height: 200,
        //   ),
        // ),

        const SizedBox(height: AppSizes.p32),

        // Lời nhắc
        const Text(
          'Vui lòng nhập mật khẩu mới của bạn để hoàn tất quá trình khôi phục.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.secondPrimary),
        ),

        const SizedBox(height: AppSizes.p32),

        // Ô nhập mật khẩu mới
        TTextFormFieldWidget(
          controller: controller.passwordController,
          label: 'Mật khẩu mới',
          hintText: 'Nhập mật khẩu mới',
          isObscure: true, // Ẩn mật khẩu thành dấu chấm
        ),

        const SizedBox(height: AppSizes.p16),

        // Ô nhập xác nhận mật khẩu
        TTextFormFieldWidget(
          controller: controller.confirmPasswordController,
          label: 'Xác nhận mật khẩu',
          hintText: 'Nhập lại mật khẩu mới',
          isObscure: true, // Ẩn mật khẩu
        ),

        const SizedBox(height: AppSizes.p32),

        // Nút Cập nhật mật khẩu
        Obx(() => TPrimaryButtonWidget(
              text: controller.isLoading.value
                  ? 'Đang cập nhật...'
                  : 'Cập nhật mật khẩu',
              onPressed:
                  controller.isLoading.value ? null : controller.resetPassword,
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
    );
  }
}
