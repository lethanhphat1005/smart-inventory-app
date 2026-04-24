import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';

class StoreSelectionCardWidget extends StatelessWidget {
  final String title, role;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isActive;

  const StoreSelectionCardWidget({
    super.key,
    required this.title,
    required this.role,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: isActive
                  ? AppColors.primary
                      .withOpacity(0.15) // Tỏa bóng cam nhẹ nếu Active
                  : Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        // Lớp nền Gradient đóng vai trò làm viền nếu isActive = true
        gradient: isActive
            ? const LinearGradient(
                colors: [
                  Color(0xFFF8A875), // Cam nhạt
                  AppColors.primary, // Cam đậm hệ thống
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      // Padding chính là độ dày của viền Gradient (1.5px)
      padding: EdgeInsets.all(isActive ? 1.5 : 0),
      child: Material(
        color: AppColors.background,
        borderRadius:
            BorderRadius.circular(AppSizes.radius16 - (isActive ? 1.5 : 0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              // Nếu không Active thì giữ nguyên viền xám, nếu Active thì vô hiệu hóa để hiện viền Gradient
              border: isActive
                  ? null
                  : Border.all(color: AppColors.surface, width: 2),
              borderRadius: BorderRadius.circular(
                  AppSizes.radius16 - (isActive ? 1.5 : 0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryText)),
                      Text(role,
                          style: const TextStyle(
                              color: AppColors.subText, fontSize: 12)),
                    ],
                  ),
                ),
                // Hiển thị Badge "Current" nếu đang ở trong cửa hàng này
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      TTexts.activeStoreBadge.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Icon(Iconsax.arrow_right_3_copy,
                      color: AppColors.softGrey, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
