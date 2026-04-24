import 'dart:async';
import 'dart:io';
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
import '../models/login_request_model.dart';

// QUAN TRỌNG: Import thêm StoreService
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
      final request = LoginRequestModel(email: email, password: password);

      // THÊM TIMEOUT 15 GIÂY CHO API CALL
      final res = await authProvider
          .login(
            email: request.email,
            password: request.password,
          )
          .timeout(const Duration(seconds: 15));

      final user = res.user;

      if (user == null) {
        throw Exception("Unknown error occurred");
      }

      // KIỂM TRA XÁC THỰC EMAIL
      if (user.emailConfirmedAt == null) {
        await Supabase.instance.client.auth.signOut();

        FullScreenLoaderUtils
            .stopLoading(); // Phải tắt loading trước khi hiện cảnh báo
        TSnackbarsWidget.warning(
          title: TTexts.loginWarningUnverifiedTitle.tr,
          message: TTexts.loginWarningUnverifiedMessage.tr,
        );
        return;
      }

      // TẠO PROFILE (Nếu đây là lần đầu)
      await UserProfileProvider().createUserProfile();

      // LOGIN THÀNH CÔNG -> ĐĂNG KÝ FCM TOKEN
      await NotificationService.registerTokenWithBackend();

      debugPrint(
          "Token: ${Supabase.instance.client.auth.currentSession!.accessToken}");

      // NẠP DỮ LIỆU USER VÀO RAM (UserService)
      final isProfileLoaded =
          await Get.find<UserService>().fetchAndSaveProfile();
      if (!isProfileLoaded) {
        debugPrint("Cảnh báo: Không thể tải profile vào RAM lúc đăng nhập");
      }

      // LƯU KÉT SẮT
      await Get.find<AuthService>().saveUserLogin(
        email,
        password,
        rememberMe.value,
      );
      final storeService = Get.find<StoreService>();
      await storeService.clearWorkspaceData();

      // TẮT LOADING KHI THÀNH CÔNG
      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': email.split('@')[0],
        }),
      );

      Get.offAllNamed(AppRoutes.storeSelection);
    } on AuthException catch (e) {
      FullScreenLoaderUtils.stopLoading();

      if (e.message.contains('Invalid login credentials') ||
          e.code == 'invalid_credentials') {
        TSnackbarsWidget.error(
          title: TTexts.loginErrorInvalidCredentialsTitle.tr,
          message: TTexts.loginErrorInvalidCredentialsMessage.tr,
        );
      } else {
        TSnackbarsWidget.error(
          title: TTexts.loginFailedTitle.tr,
          message: e.message,
        );
      }
    } on TimeoutException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } on SocketException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

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

      await UserProfileProvider().createUserProfile(fullName: displayName);

      debugPrint("=== THÔNG TIN SUPABASE TRẢ VỀ TỪ GOOGLE ===");
      debugPrint("Email: ${user.email}");
      debugPrint("Name: $displayName");
      debugPrint("=========================================");

      await Get.find<AuthService>().saveUserLogin(
        user.email ?? "",
        "google_dummy_password",
        true,
      );

      //  ĐĂNG NHẬP GOOGLE THÀNH CÔNG -> ĐĂNG KÝ FCM TOKEN
      await NotificationService.registerTokenWithBackend();

      final storeService = Get.find<StoreService>();
      await storeService.clearWorkspaceData();

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': displayName,
        }),
      );

      Get.offAllNamed(AppRoutes.storeSelection);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      debugPrint('❌ Google Auth Error: $e');

      TSnackbarsWidget.error(
        title: TTexts.loginFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
