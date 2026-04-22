import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
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

    if (password.isEmpty || password.length < 6) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.passwordLengthError.tr,
      );
      return;
    }

    if (password != confirmPassword) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.registerErrorPasswordMismatchMessage.tr,
      );
      return;
    }

    isLoading.value = true;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.updatingPassword.tr);

      await authProvider.updatePassword(password);

      await authProvider.logout();

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.passwordChangedSuccess.tr,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.resetPasswordFailedTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancelReset() {
    Get.offAllNamed(AppRoutes.login);
  }
}
