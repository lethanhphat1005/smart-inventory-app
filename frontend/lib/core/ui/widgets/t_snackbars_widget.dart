import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Tiện ích hiển thị các thông báo (Toast/Snackbar) toàn cục
class TSnackbarsWidget {
  static void _showToast({
    required String title,
    required String message,
    required Color bgColor,
    required Gradient iconGradient, // Thay Color thành Gradient
    required IconData icon,
    String? actionText, // Đưa Action Text lên base
    VoidCallback? onActionPressed, // Đưa Action Callback lên base
  }) {
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
          backgroundColor: Colors.white, // Nền trắng để nổi bật trên nền pastel
        ),
        child: Text(
          actionText,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500, // Đậm vừa phải
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
          // 1. Icon Box (Linear Gradient)
          Container(
            width: 36, // Thu nhỏ lại chút cho cân đối với chữ 14
            height: 36,
            decoration: BoxDecoration(
              gradient: iconGradient, // Áp dụng Gradient từ AppColors
              borderRadius: BorderRadius.circular(10), // Bo góc Squircle
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // 2. Nội dung Text (Title: 14, Message: 12)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14, // CHUẨN YÊU CẦU: Tiêu đề 14
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

          // 3. Nút Action (Dành cho TẤT CẢ các loại Toast)
          if (actionBtn != null) ...[actionBtn, const SizedBox(width: 12)],

          // 4. Nút X (Close)
          IconButton(
            onPressed: () => Get.closeCurrentSnackbar(),
            icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),

      // -- CẤU HÌNH KHUNG SNACKBAR --
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
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // ==========================================
  // CÁC HÀM GỌI TOAST CHI TIẾT
  // ==========================================

  /// 1. Toast Thành công
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

  /// 2. Toast Thông tin
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

  /// 3. Toast Cảnh báo
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
      icon: Icons.priority_high_rounded, // Icon chấm than như hình
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

  /// 4. Toast Lỗi
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

  /// 5. SnackBar Hoàn tác (Undo) dùng Native ScaffoldMessenger để bắt sự kiện Timeout
  static SnackBar undoSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonName,
    required VoidCallback onUndo,
  }) {
    return SnackBar(
      backgroundColor: Colors.transparent, // Nền trong suốt
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      duration: const Duration(seconds: 5), // Đếm ngược 5s
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.toastInfoBg, // Nền pastel xanh
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
            // Icon
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

            // Text
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

            // Nút Action
            OutlinedButton(
              onPressed: () {
                onUndo(); // Gọi hàm rollback truyền từ ngoài vào
                // Tắt snackbar ngay lập tức và báo là do Action
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
