import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onLongPress,
    required this.timeAgo,
    required this.onTap,
  });

  final dynamic notification;
  final VoidCallback onLongPress;
  final Function onTap;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final iconConfig = _getIconConfig(notification.type, isUnread);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: BoxBorder.all(
            color: isUnread ? AppColors.secondPrimary : Colors.transparent),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      0.03), // Bóng siêu mờ chuẩn phong cách của bạn
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [], // Không có shadow nếu đã đọc
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          onTap: () {
            onTap();
          },
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconConfig['bg'],
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                  child: Center(
                    child: Icon(
                      iconConfig['icon'],
                      size: 24,
                      color: iconConfig['color'],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: isUnread
                              ? AppColors.primaryText
                              : AppColors.subText,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: isUnread
                              ? AppColors.subText
                              : AppColors.softGrey.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w400,
                          color: isUnread
                              ? AppColors.primary
                              : AppColors.softGrey.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: AppSizes.p12),
                  Container(
                    margin: const EdgeInsets.only(top: AppSizes.p4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================
  // HELPER: Phân cấp Ưu tiên, Icon & Màu sắc
  // =====================================
  Map<String, dynamic> _getIconConfig(String type, bool isUnread) {
    // 0. NẾU ĐÃ ĐỌC: Chuyển về trạng thái xám mờ (Low Focus)
    if (!isUnread) {
      return {
        'icon': Iconsax.notification_bing_copy,
        'color': AppColors.softGrey.withOpacity(0.5),
        'bg': AppColors.surface, // Nền xám F8F9FA
      };
    }

    // NẾU CHƯA ĐỌC: Phân rã theo cấp độ ưu tiên (Priority Hierarchy)
    switch (type) {
      // CẤP 1 - URGENT (Khẩn cấp / Lỗi: Màu Đỏ Pastel)
      case 'DISCREPANCY_ALERT':
      case 'LOW_STOCK':
        return {
          // Lệch kho dùng icon Warning, Hết hàng dùng icon Box Remove
          'icon': type == 'DISCREPANCY_ALERT'
              ? Iconsax.warning_2_copy
              : Iconsax.box_remove_copy,
          'color': AppColors.toastErrorGradientEnd,
          'bg': AppColors.toastErrorBg,
        };

      // CẤP 2 - WARNING / ACTION (Cảnh báo / Gợi ý: Màu Vàng Cam Pastel)
      case 'REORDER_SUGGESTION':
      case 'ROLE_UPDATED':
      case 'SYSTEM':
        return {
          // Gợi ý dùng bóng đèn (idea), role/system dùng icon info
          'icon': type == 'REORDER_SUGGESTION'
              ? Iconsax.lamp_on_copy
              : Iconsax.info_circle_copy,
          'color': AppColors.toastWarningGradientEnd,
          'bg': AppColors.toastWarningBg,
        };

      // CẤP 3 - SUCCESS / TRANSACTION (Giao dịch thành công: Màu Xanh Pastel)
      case 'ORDER_CREATED':
      case 'IMPORT':
      case 'EXPORT':
        return {
          // Import/Tạo đơn dùng icon thêm hộp, Export dùng icon hộp có dấu tick
          'icon':
              type == 'EXPORT' ? Iconsax.box_tick_copy : Iconsax.box_add_copy,
          'color': AppColors.toastSuccessGradientEnd,
          'bg': AppColors.toastSuccessBg,
        };

      // CẤP 4 - BATCH / DEFAULT (Thông báo gộp / Chung: Màu Primary Brand)
      case 'BATCH_LOW_STOCK':
      default:
        return {
          // Batch (nhiều sản phẩm) dùng icon xếp lớp (layer)
          'icon': type == 'BATCH_LOW_STOCK'
              ? Iconsax.layer_copy
              : Iconsax.notification_1_copy,
          'color': AppColors.primary, // Cam đặc trưng của App
          'bg': AppColors.primary.withOpacity(0.1),
        };
    }
  }
}
