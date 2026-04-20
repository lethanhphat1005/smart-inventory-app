import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class LowStockOverviewWidget extends StatelessWidget {
  final int outCount;
  final int lowCount;
  final String activeFilter;
  final Function(String) onToggle;

  const LowStockOverviewWidget({
    super.key,
    required this.outCount,
    required this.lowCount,
    required this.activeFilter,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p24),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleCard(
              title: TTexts.tabOutStock.tr,
              count: outCount,
              color: AppColors.alertText,
              icon: Iconsax.warning_2_copy,
              isSelected: activeFilter == TTexts.tabOutStock,
              onTap: () => onToggle(TTexts.tabOutStock),
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: _buildToggleCard(
              title: TTexts.tabLowStock.tr,
              count: lowCount,
              color: Colors.orange,
              icon: Iconsax.trend_down_copy,
              isSelected: activeFilter == TTexts.tabLowStock,
              onTap: () => onToggle(TTexts.tabLowStock),
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p12, horizontal: AppSizes.p8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(
              color: isSelected ? color : color.withOpacity(0.2), width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 22),
            const SizedBox(height: AppSizes.p8),
            Text(
              "$count",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.subText,
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
