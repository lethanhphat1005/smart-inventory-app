import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class ResetPasswordController extends GetxController {
  final AuthProvider authProvider;

  ResetPasswordController({required this.authProvider});

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var isLoading = false.obs;

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void resetPassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // 1. Validate dữ liệu đầu vào
    if (password.isEmpty || password.length < 6) {
      TSnackbarsWidget.error(
          title: 'Lỗi hợp lệ', message: 'Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    if (password != confirmPassword) {
      TSnackbarsWidget.error(
          title: 'Lỗi hợp lệ', message: 'Mật khẩu xác nhận không khớp.');
      return;
    }

    isLoading.value = true;

    try {
      // 2. Bắt đầu loading
      FullScreenLoaderUtils.openLoadingDialog('Đang cập nhật mật khẩu...');

      // 3. Gọi Supabase để update mật khẩu (yêu cầu user đang có session hợp lệ từ bước verify OTP)
      await authProvider.updatePassword(password);

      // 4. Đăng xuất để đảm bảo bảo mật, yêu cầu user đăng nhập lại bằng mật khẩu mới
      await authProvider.logout();

      FullScreenLoaderUtils.stopLoading();

      // 5. Thông báo thành công
      TSnackbarsWidget.success(
        title: 'Thành công',
        message: 'Mật khẩu đã được thay đổi. Vui lòng đăng nhập lại.',
      );

      // 6. Xóa stack và đưa về trang đăng nhập
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(title: 'Cập nhật thất bại', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void cancelReset() {
    // Hủy bỏ và quay về đăng nhập
    Get.offAllNamed(AppRoutes.login);
  }
}
