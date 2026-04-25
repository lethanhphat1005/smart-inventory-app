import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class LowStockOverviewWidget extends StatelessWidget {
  final String activeFilter;
  final Function(String) onToggle;

  const LowStockOverviewWidget({
    super.key,
    required this.activeFilter,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p24),
      child: Row(
        children: [
          // THẺ "HẾT HÀNG" (OUT OF STOCK)
          Expanded(
            child: _buildToggleCard(
              title: TTexts.tabOutStock.tr,
              color: AppColors.alertText, // Màu đỏ đặc trưng
              icon: Iconsax.warning_2_copy, // Icon cảnh báo
              isSelected: activeFilter == TTexts.tabOutStock,
              onTap: () => onToggle(TTexts.tabOutStock),
            ),
          ),
          const SizedBox(width: AppSizes.p12), // Khoảng cách giữa 2 thẻ

          // THẺ "SẮP HẾT" (LOW STOCK)
          Expanded(
            child: _buildToggleCard(
              title: TTexts.tabLowStock.tr,
              color: Colors.orange, // Màu cam cảnh báo nhẹ
              icon: Iconsax.trend_down_copy, // Icon xu hướng giảm
              isSelected: activeFilter == TTexts.tabLowStock,
              onTap: () => onToggle(TTexts.tabLowStock),
            ),
          ),
          const SizedBox(width: AppSizes.p12), // Khoảng cách tới cột trống

          // CỘT TRỐNG ĐỂ GIỮ BỐ CỤC 3 CỘT CÂN ĐỐI
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  /// Hàm xây dựng một thẻ Toggle riêng biệt với hiệu ứng Animation
  Widget _buildToggleCard({
    required String title,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Hiệu ứng chuyển mượt mà
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p16,
            horizontal: AppSizes.p8), // Tăng padding dọc
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(
              color: isSelected ? color : color.withOpacity(0.2), width: 1.5),
          // Chỉ đổ bóng khi được chọn (Active) để tạo chiều sâu
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]
              : [],
        ),
        child: Column(
          children: [
            // Icon to hơn đáng kể (size 28)
            Icon(icon, color: isSelected ? Colors.white : color, size: 28),
            const SizedBox(height: AppSizes.p12),
            // Chữ to hơn (size 14) và đậm hơn
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
