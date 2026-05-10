import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class FullScreenLoaderUtils {
  // BIẾN KHÓA: Theo dõi xem loading có đang mở hay không
  static bool _isLoaderShowing = false;

  static void openLoadingDialog(String text) {
    // NẾU ĐANG CÓ LOADING RỒI THÌ BỎ QUA, KHÔNG MỞ THÊM ĐỂ CHỐNG KẸT
    if (_isLoaderShowing) return;

    _isLoaderShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p32,
              vertical: AppSizes.p24,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  radius: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.p16),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      useSafeArea: false,
    ).then((_) {
      // Đảm bảo khi dialog bị tắt (dù bằng code hay lỗi) thì khóa cũng được mở
      _isLoaderShowing = false;
    });
  }

  static void stopLoading() {
    if (_isLoaderShowing) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _isLoaderShowing = false; // Mở khóa
    } else {
      // Đề phòng trường hợp gọi stop quá nhanh khi dialog chưa kịp render xong
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_isLoaderShowing && (Get.isDialogOpen ?? false)) {
          Get.back();
          _isLoaderShowing = false;
        }
      });
    }
  }
}
