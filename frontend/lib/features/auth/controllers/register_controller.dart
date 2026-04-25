import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase để bắt AuthException

import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class RegisterController extends GetxController {
  final AuthProvider authProvider;
  RegisterController({required this.authProvider});

  // UI Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Biến trạng thái (State)
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  final RxInt passwordStrength = 0.obs;

  // --- HÀM XỬ LÝ GIAO DIỆN ---
  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

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

  // --- HÀM XỬ LÝ LOGIC API ---
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.registerErrorEmptyFieldsTitle.tr,
        message: TTexts.registerErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    // 2. Validate: Kiểm tra định dạng Email
    if (!GetUtils.isEmail(email)) {
      TSnackbarsWidget.error(
        title: TTexts.loginErrorInvalidEmailTitle.tr,
        message: TTexts.loginErrorInvalidEmailMessage.tr,
      );
      return;
    }

    // 3. Validate: Mật khẩu xác nhận phải khớp
    if (password != confirmPassword) {
      TSnackbarsWidget.error(
        title: TTexts.registerErrorPasswordMismatchTitle.tr,
        message: TTexts.registerErrorPasswordMismatchMessage.tr,
      );
      return;
    }

    try {
      isLoading.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.registering.tr);

      // GỌI API KÈM TIMEOUT 15 GIÂY
      final response = await authProvider
          .register(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      FullScreenLoaderUtils.stopLoading();

      if (response.user != null) {
        // Hiện thông báo thành công
        TSnackbarsWidget.success(
          title: TTexts.registerSuccessTitle.tr,
          message: TTexts.registerSuccessMessage.tr,
        );
        // Chuyển hướng sang trang Xác thực Email (Gửi kèm email qua Arguments)
        Get.toNamed(AppRoutes.verifyEmail, arguments: email);
      }
    } on AuthException catch (e) {
      // BẮT LỖI TỪ SUPABASE (Trùng email, mật khẩu yếu...)
      FullScreenLoaderUtils.stopLoading();
      final errorMsg = e.message.toLowerCase();

      if (errorMsg.contains('already registered') ||
          errorMsg.contains('already exists')) {
        TSnackbarsWidget.error(
          title: TTexts.registerErrorUserExistsTitle.tr,
          message: TTexts.registerErrorUserExistsMessage.tr,
        );
      } else if (errorMsg.contains('weak password') ||
          errorMsg.contains('password should be')) {
        TSnackbarsWidget.error(
          title: TTexts.registerErrorWeakPasswordTitle.tr,
          message: TTexts.registerErrorWeakPasswordMessage.tr,
        );
      } else {
        TSnackbarsWidget.error(
          title: TTexts.registerFailedTitle.tr,
          message: e.message,
        );
      }
    } on TimeoutException catch (_) {
      // BẮT LỖI QUÁ HẠN THỜI GIAN
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } on SocketException catch (_) {
      // BẮT LỖI MẤT MẠNG LÚC ĐANG GỌI API
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      // BẮT CÁC LỖI KHÁC
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Đăng ký/Đăng nhập bằng Google
  Future<void> registerWithGoogle() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.registering.tr);

      final response = await authProvider.signInWithGoogle();

      if (response == null || response.user == null) {
        FullScreenLoaderUtils.stopLoading();
        return;
      }

      final user = response.user!;

      if (user.identities != null && user.identities!.isEmpty) {
        FullScreenLoaderUtils.stopLoading();
        TSnackbarsWidget.error(
          title: TTexts.registerFailedTitle.tr,
          message: TTexts.registerErrorEmailExistsMessage.tr,
        );
        return;
      }

      final String displayName = user.userMetadata?['full_name'] ??
          user.email?.split('@')[0] ??
          'User';

      // 1. TẠO PROFILE TRONG DATABASE
      await UserProfileProvider().createUserProfile(fullName: displayName);

      // 2. LƯU KÉT SẮT CỤC BỘ
      await Get.find<AuthService>().saveUserLogin(
        user.email ?? "",
        "google_dummy_password",
        true,
      );

      // 3. ĐĂNG KÝ FCM TOKEN
      await NotificationService.registerTokenWithBackend();

      // 4. NẠP DỮ LIỆU USER VÀO RAM
      final isProfileLoaded =
          await Get.find<UserService>().fetchAndSaveProfile();
      if (!isProfileLoaded) {
        debugPrint(
            "Cảnh báo: Không thể tải profile vào RAM lúc đăng ký Google");
      }

      // 5. XÓA DATA CŨ STORE
      final storeService = Get.find<StoreService>();
      await storeService.clearWorkspaceData();

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: TTexts.registerSuccessTitle.tr,
        message: TTexts.registerGoogleSuccessMessage.tr,
      );

      // 6. CHUYỂN THẲNG VÀO APP CHỨ KHÔNG QUAY LẠI LOGIN
      Get.offAllNamed(AppRoutes.storeSelection);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.registerFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
