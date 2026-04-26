import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';

class RegisterController extends GetxController {
  final AuthProvider authProvider;
  RegisterController({required this.authProvider});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  final RxInt passwordStrength = 0.obs;

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  /// Đăng ký Email thường 
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // 1. Kiểm tra rỗng
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.registerErrorEmptyFieldsTitle.tr,
          message: TTexts.registerErrorEmptyFieldsMessage.tr);
      return;
    }

    // 2. Kiểm tra mật khẩu xác nhận
    if (password != confirmPassword) {
      TSnackbarsWidget.warning(
          title: TTexts.registerErrorPasswordMismatchTitle.tr,
          message: TTexts.registerErrorPasswordMismatchMessage.tr);
      return;
    }

    try {
      isLoading.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.registering.tr);

      final response = await authProvider
          .register(email: email, password: password)
          .timeout(const Duration(seconds: 15));

      FullScreenLoaderUtils.stopLoading();

      // 3. Email đã tồn tại
      if (response.user != null &&
          response.user!.identities != null &&
          response.user!.identities!.isEmpty) {
        TSnackbarsWidget.error(
            title: TTexts.registerErrorUserExistsTitle.tr,
            message: TTexts.registerErrorEmailExistsMessage.tr);
        return;
      }

      // 4. Thành công
      if (response.user != null) {
        TSnackbarsWidget.success(
            title: TTexts.registerSuccessTitle.tr,
            message: TTexts.registerSuccessMessage.tr);
        Get.toNamed(AppRoutes.verifyEmail, arguments: email);
      }
    } catch (e) {
      _handleRegisterError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Đăng ký/Đăng nhập Google (Tối ưu hóa: Vào thẳng App)
  Future<void> registerWithGoogle() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.registering.tr);
      final response = await authProvider.signInWithGoogle();

      if (response == null || response.user == null) {
        FullScreenLoaderUtils.stopLoading();
        return;
      }

      final user = response.user!;
      final String displayName = user.userMetadata?['full_name'] ??
          user.email?.split('@')[0] ??
          'User';

      // Tối ưu hóa: Thực hiện các bước khởi tạo bắt buộc
      await UserProfileProvider().createUserProfile(fullName: displayName);
      await Get.find<UserService>().fetchAndSaveProfile();

      // Chạy song song các tác vụ nền
      _runBackgroundTasks(user.email ?? "", "google_dummy_password");

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
          title: TTexts.registerSuccessTitle.tr,
          message: TTexts.registerGoogleSuccessMessage.tr);

      // Chuyển hướng thẳng vào chọn cửa hàng
      Get.offAllNamed(AppRoutes.storeSelection);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.registerFailedTitle.tr, message: e.toString());
    }
  }

  void _runBackgroundTasks(String email, String password) {
    Future.wait([
      NotificationService.registerTokenWithBackend(),
      Get.find<AuthService>().saveUserLogin(email, password, true),
      Get.find<StoreService>().clearWorkspaceData(),
      // ignore: invalid_return_type_for_catch_error
    ]).catchError((e) => debugPrint("Background Tasks Error: $e"));
  }

  void _handleRegisterError(dynamic e) {
    FullScreenLoaderUtils.stopLoading();
    if (e is AuthException) {
      TSnackbarsWidget.error(
          title: TTexts.registerFailedTitle.tr, message: e.message);
    } else if (e is TimeoutException) {
      TSnackbarsWidget.error(
          title: TTexts.errorTimeoutTitle.tr,
          message: TTexts.errorTimeoutMessage.tr);
    } else {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: e.toString());
    }
  }

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength.value = 0;
    } else if (password.length < 6) {
      passwordStrength.value = 1;
    } else if (password.length < 10) {
      passwordStrength.value = 2;
    } else if (!password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[A-Z]'))) {
      passwordStrength.value = 3;
    } else {
      passwordStrength.value = 4;
    }
  }
}
