import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/core/state/services/store_service.dart';

class LoginController extends GetxController {
  final AuthProvider authProvider;
  LoginController({required this.authProvider});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  /// Logic Đăng nhập thường
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.loginErrorEmptyFieldsTitle.tr,
        message: TTexts.loginErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    isLoading.value = true;
    FullScreenLoaderUtils.openLoadingDialog(TTexts.loggingIn.tr);

    try {
      final res = await authProvider
          .login(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      final user = res.user;

      if (user == null) throw Exception("Unknown error occurred");

      if (user.emailConfirmedAt == null) {
        await Supabase.instance.client.auth.signOut();
        FullScreenLoaderUtils.stopLoading();
        TSnackbarsWidget.warning(
          title: TTexts.loginWarningUnverifiedTitle.tr,
          message: TTexts.loginWarningUnverifiedMessage.tr,
        );
        return;
      }

      // 1. Tạo Profile & Nạp RAM (Các bước bắt buộc phải chờ để có data UI)
      await UserProfileProvider().createUserProfile();
      await Get.find<UserService>().fetchAndSaveProfile();

      // 2. Chạy song song các tác vụ background (Tối ưu tốc độ)
      _runBackgroundTasks(email, password, rememberMe.value);

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
        title: TTexts.loginSuccessTitle.tr,
        message:
            TTexts.loginSuccessMessage.trParams({'name': email.split('@')[0]}),
      );

      Get.offAllNamed(AppRoutes.storeSelection);
    } catch (e) {
      _handleLoginError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Logic Đăng nhập Google
  Future<void> loginWithGoogle() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loggingIn.tr);
      final response = await authProvider.signInWithGoogle();

      if (response == null || response.user == null) {
        FullScreenLoaderUtils.stopLoading();
        return;
      }

      final user = response.user!;
      final String displayName = user.userMetadata?['full_name'] ??
          user.email?.split('@')[0] ??
          'User';

      // 1. Đồng bộ dữ liệu Profile & Nạp RAM
      await UserProfileProvider().createUserProfile(fullName: displayName);
      await Get.find<UserService>().fetchAndSaveProfile();

      // 2. Chạy song song các tác vụ background
      _runBackgroundTasks(user.email ?? "", "google_dummy_password", true);

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({'name': displayName}),
      );

      Get.offAllNamed(AppRoutes.storeSelection);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.loginFailedTitle.tr, message: e.toString());
    }
  }

  /// Tác vụ chạy song song không block UI
  void _runBackgroundTasks(String email, String password, bool remember) {
    Future.wait([
      NotificationService.registerTokenWithBackend(),
      Get.find<AuthService>().saveUserLogin(email, password, remember),
      Get.find<StoreService>().clearWorkspaceData(),
      // ignore: invalid_return_type_for_catch_error
    ]).catchError((e) => debugPrint("Background Tasks Error: $e"));
  }

  void _handleLoginError(dynamic e) {
    FullScreenLoaderUtils.stopLoading();

    if (e is AuthException) {
      String errorMessage = TTexts.errorUnknownMessage.tr;

      final errorStr = e.message.toLowerCase();

      if (errorStr.contains('invalid login credentials')) {
        errorMessage = TTexts.loginErrorInvalidCredentialsMessage.tr;
      } else if (errorStr.contains('email not confirmed')) {
        errorMessage = TTexts.loginWarningUnverifiedMessage.tr;
      } else if (errorStr.contains('user not found')) {
        errorMessage = TTexts.userNotFound.tr;
      } else if (errorStr.contains('too many requests') ||
          errorStr.contains('rate limit')) {
        errorMessage = TTexts.errorTooManyRequestsMessage.tr;
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMessage = TTexts.netErrorDescription.tr;
      } else {
        errorMessage = e.message;
      }

      TSnackbarsWidget.error(
        title: TTexts.loginFailedTitle.tr,
        message: errorMessage,
      );
    } else if (e is TimeoutException) {
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } else {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts
            .errorUnknownMessage.tr, // Tránh quăng e.toString() thô ra màn hình
      );
    }
  }
}
