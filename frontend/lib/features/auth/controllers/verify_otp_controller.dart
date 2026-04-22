import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/auth/controllers/verify_email_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class VerifyOtpController extends GetxController {
  final AuthProvider authProvider;

  VerifyOtpController({required this.authProvider});

  final otpController = TextEditingController();

  final String email = Get.arguments ?? '';
  var isLoading = false.obs;

  var countdown = 60.obs;
  var canResend = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }

  void startTimer() {
    canResend.value = false;
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() async {
    if (!canResend.value) return;

    try {
      FullScreenLoaderUtils.openLoadingDialog('Đang gửi lại mã...');

      await authProvider.sendResetPasswordEmail(email);

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
          title: 'Thành công',
          message: 'Mã OTP mới đã được gửi đến email của bạn.');

      startTimer();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(title: 'Lỗi', message: 'Không thể gửi lại mã: $e');
    }
  }

  void verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 8) {
      TSnackbarsWidget.error(
          title: 'Lỗi', message: 'Vui lòng nhập đủ 8 chữ số mã OTP.');
      return;
    }

    isLoading.value = true;

    try {
      FullScreenLoaderUtils.openLoadingDialog('Đang xác thực mã OTP...');

      await authProvider.verifyRecoveryOtp(email: email, otp: otp);

      FullScreenLoaderUtils.stopLoading();

      Get.toNamed(AppRoutes.resetPassword);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.error(
        title: 'Xác thực thất bại',
        message: 'Mã OTP không chính xác hoặc đã hết hạn. Vui lòng thử lại.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openEmailApp() async {
    await VerifyEmailController(authProvider: authProvider).openMailApp();
  }
}
