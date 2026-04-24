import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TSnackbarsWidget {
  static DateTime? _lastSnackbarTime;
  static String? _lastMessage;

  static void _showToast({
    required String title,
    required String message,
    required Color bgColor,
    required Gradient iconGradient,
    required IconData icon,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    // 1. CƠ CHẾ CHỐNG SPAM
    final now = DateTime.now();
    // Nếu tin nhắn giống hệt nhau và xuất hiện cách nhau chưa tới 1.5 giây -> Bỏ qua
    if (_lastSnackbarTime != null && _lastMessage == message) {
      if (now.difference(_lastSnackbarTime!).inMilliseconds < 1500) {
        return;
      }
    }
    _lastSnackbarTime = now;
    _lastMessage = message;

    // 2. DỌN DẸP HÀNG ĐỢI: Tắt ngay lập tức tất cả snackbar đang có trên màn hình
    Get.closeAllSnackbars();

    // Khởi tạo nút Action nếu được truyền vào
    Widget? actionBtn;
    if (actionText != null && onActionPressed != null) {
      actionBtn = OutlinedButton(
        onPressed: onActionPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: Size.zero,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        ),
        child: Text(
          actionText,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.subText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (actionBtn != null) ...[actionBtn, const SizedBox(width: 12)],
          IconButton(
            onPressed: () => Get.closeCurrentSnackbar(),
            icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: bgColor,
      borderRadius: 16,
      snackPosition: SnackPosition.TOP,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3), // Chỉnh lại 3s cho nhanh gọn
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  static void success({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    _showToast(
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      bgColor: AppColors.toastSuccessBg,
      icon: Icons.check_rounded,
      iconGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.toastSuccessGradientStart,
          AppColors.toastSuccessGradientEnd,
        ],
      ),
    );
  }

  static void info({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    _showToast(
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      bgColor: AppColors.toastInfoBg,
      icon: Icons.info_outline_rounded,
      iconGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.toastInfoGradientStart,
          AppColors.toastInfoGradientEnd,
        ],
      ),
    );
  }

  static void warning({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    _showToast(
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      bgColor: AppColors.toastWarningBg,
      icon: Icons.priority_high_rounded,
      iconGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.toastWarningGradientStart,
          AppColors.toastWarningGradientEnd,
        ],
      ),
    );
  }

  static void error({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    _showToast(
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: onActionPressed,
      bgColor: AppColors.toastErrorBg,
      icon: Icons.close_rounded,
      iconGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.toastErrorGradientStart,
          AppColors.toastErrorGradientEnd,
        ],
      ),
    );
  }

  // --- GIỮ NGUYÊN HÀM UNDO SNACKBAR BÊN DƯỚI VÌ NÓ DÙNG SCAFFOLD MESSENGER ---
  static SnackBar undoSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonName,
    required VoidCallback onUndo,
  }) {
    return SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      duration: const Duration(seconds: 5),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.toastInfoBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.toastInfoGradientStart,
                    AppColors.toastInfoGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Iconsax.trash_copy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                onUndo();
                ScaffoldMessenger.of(context).hideCurrentSnackBar(
                  reason: SnackBarClosedReason.action,
                );
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.white,
              ),
              child: Text(
                buttonName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
