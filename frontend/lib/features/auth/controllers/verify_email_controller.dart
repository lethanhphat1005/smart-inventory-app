import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:open_mail_app_plus/open_mail_app_plus.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class VerifyEmailController extends GetxController {
  final AuthProvider authProvider;
  VerifyEmailController({required this.authProvider});

  String email = '';
  var timerCountdown = 45.obs;
  var isResending = false.obs;

  // Khai báo biến Timer để quản lý việc đếm ngược
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments ?? '';
    startTimer();
  }

  @override
  void onClose() {
    // RẤT QUAN TRỌNG: Phải hủy timer khi thoát màn hình để tránh tràn RAM (Memory Leak)
    _countdownTimer?.cancel();
    super.onClose();
  }

  void startTimer() {
    timerCountdown.value = 45;
    _countdownTimer?.cancel(); // Hủy timer cũ nếu có

    // Mỗi 1 giây (1000ms) sẽ chạy hàm bên trong 1 lần
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerCountdown.value > 0) {
        timerCountdown.value--; // Trừ đi 1 giây
      } else {
        timer.cancel(); // Khi về 0 thì dừng lại
      }
    });
  }

  void resendEmail() async {
    if (timerCountdown.value > 0) return;

    isResending.value = true;

    try {
      isResending.value = true;
      await authProvider.sendVerificationEmail(email);

      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.resendEmailSuccessMessage.trParams({'email': email}),
      );

      // Gửi thành công thì bắt đầu đếm ngược lại 45s
      startTimer();
    } on AuthException catch (e) {
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('rate limit') ||
          errorMsg.contains('too many requests')) {
        TSnackbarsWidget.warning(
          title: TTexts.errorTooManyRequestsTitle.tr,
          message: TTexts.errorTooManyRequestsMessage.tr,
        );
      } else {
        TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: e.message,
        );
      }
    } on TimeoutException catch (_) {
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } on SocketException catch (_) {
      TSnackbarsWidget.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isResending.value = false;
    }
  }

  Future<void> openMailApp() async {
    var result = await OpenMailAppPlus.openMailApp();

    if (!result.didOpen && !result.canOpen) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.emailAppNotFound.tr,
      );
    } else if (!result.didOpen && result.canOpen) {
      showDialog(
        context: Get.context!,
        builder: (_) {
          return MailAppPickerDialog(
            mailApps: result.options,
            title: TTexts.pickEmailApp.tr,
          );
        },
      );
    }
  }
}
