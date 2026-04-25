import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart'; // ĐÃ IMPORT APPSIZES
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryInsightOverviewWidget
    extends GetView<InventoryInsightController> {
  const InventoryInsightOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p20, vertical: AppSizes.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TTexts.insightsOverview.tr,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subText)),
          const SizedBox(height: AppSizes.p12),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildToggleCard(
                      title: TTexts.tabOutStock.tr,
                      count: controller.getCount(TTexts.tabOutStock),
                      color: AppColors.alertText,
                      icon: Iconsax.warning_2_copy,
                      isSelected:
                          controller.activeFilter.value == TTexts.tabOutStock,
                      onTap: () => controller.toggleFilter(TTexts.tabOutStock),
                    )),
              ),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Obx(() => _buildToggleCard(
                      title: TTexts.tabLowStock.tr,
                      count: controller.getCount(TTexts.tabLowStock),
                      color: AppColors.primary,
                      icon: Iconsax.trend_down_copy,
                      isSelected:
                          controller.activeFilter.value == TTexts.tabLowStock,
                      onTap: () => controller.toggleFilter(TTexts.tabLowStock),
                    )),
              ),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Obx(() => _buildToggleCard(
                      title: TTexts.tabHealthy.tr,
                      count: controller.getCount(TTexts.tabHealthy),
                      color: AppColors.stockIn,
                      icon: Iconsax.tick_circle_copy,
                      isSelected:
                          controller.activeFilter.value == TTexts.tabHealthy,
                      onTap: () => controller.toggleFilter(TTexts.tabHealthy),
                    )),
              ),
            ],
          ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
