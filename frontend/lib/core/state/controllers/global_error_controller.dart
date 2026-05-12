import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/routes/app_routes.dart';

class GlobalErrorController extends GetxController {
  static GlobalErrorController get instance => Get.find();

  bool _isCrashDialogOpen = false;
  bool _isServerDownDialogOpen = false;

  void handleGlobalError(dynamic error, StackTrace stackTrace) {
    debugPrint("🚨 GLOBAL ERROR TRAP CAUGHT: $error");

    // 1. Nếu bắt được lỗi Server Sập (Trường hợp dev quên viết try-catch)
    if (error is DioException && _isServerTimeout(error)) {
      showServerConnectionErrorDialog();
      return;
    }

    // 2. Các lỗi Crash app bình thường
    _showCrashPreventDialog(error.toString());
  }

  // Hàm kiểm tra lỗi Server
  bool _isServerTimeout(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  // ===================================================================
  // BUNG DIALOG LỖI SERVER XUYÊN SUỐT APP (LIVE)
  // ===================================================================
  void showServerConnectionErrorDialog() {
    if (_isServerDownDialogOpen) return;
    _isServerDownDialogOpen = true;

    Get.dialog(
      PopScope(
        canPop: false, // Bắt buộc user phải bấm nút
        child: TCustomDialogWidget(
          icon: const Text('☁️', style: TextStyle(fontSize: 40)),
          title: TTexts.errorServerTitle.tr,
          description: TTexts.errorServerMessage.tr,
          primaryButtonText: TTexts.understood.tr, // Nút "Understood" (Đã hiểu)
          onPrimaryPressed: () {
            _isServerDownDialogOpen = false;
            Get.back(); // Chỉ đóng Dialog, user có thể tự thử lại hành động vừa rồi
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCrashPreventDialog(String errorDetail) {
    if (_isCrashDialogOpen) return;
    _isCrashDialogOpen = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: TCustomDialogWidget(
          icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
          title: TTexts.errorUnknownTitle.tr,
          description: TTexts.errorUnknownMessage.tr,
          primaryButtonText: TTexts.backToHome.tr,
          onPrimaryPressed: () {
            _closeCrashDialog();
            Get.offAllNamed(AppRoutes.main);
          },
          secondaryButtonText: TTexts.ignore.tr,
          onSecondaryPressed: () {
            _closeCrashDialog();
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _closeCrashDialog() {
    if (_isCrashDialogOpen) {
      Get.back();
      _isCrashDialogOpen = false;
    }
  }
}
