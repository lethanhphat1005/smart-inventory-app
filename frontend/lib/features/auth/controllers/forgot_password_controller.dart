import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Thêm dòng này
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class ForgotPasswordController extends GetxController {
  final AuthProvider authProvider;

  ForgotPasswordController({required this.authProvider});

  final emailController = TextEditingController();
  var isLoading = false.obs;

  void sendResetLink() async {
    final email = emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      TSnackbarsWidget.error(
        title: TTexts.loginErrorInvalidEmailTitle.tr,
        message: TTexts.loginErrorInvalidEmailMessage.tr,
      );
      return;
    }

    isLoading.value = true;

    try {
      FullScreenLoaderUtils.openLoadingDialog(
          TTexts.emailSending.tr); // Dùng chữ Sending thay vì Checking

      // GỌI API KÈM TIMEOUT 15 GIÂY
      await authProvider
          .sendResetPasswordEmail(email)
          .timeout(const Duration(seconds: 15));

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: TTexts.emailSentTitle.tr,
        message: TTexts.emailSentMessage.trParams({'email': email}),
      );

      // Get.toNamed(AppRoutes.verifyEmail, arguments: email);
      Get.toNamed(AppRoutes.verifyOTP, arguments: email);
    } on AuthException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      final errorMsg = e.message.toLowerCase();

      // Bẫy lỗi nhấn quá nhiều lần (Rate Limit của Supabase)
      if (errorMsg.contains('rate limit') ||
          errorMsg.contains('too many requests')) {
        TSnackbarsWidget.warning(
          title: TTexts.errorTooManyRequestsTitle.tr,
          message: TTexts.errorTooManyRequestsMessage.tr,
        );
      } else {
        TSnackbarsWidget.error(
          title: TTexts.emailSendFailed.tr,
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

  static void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
