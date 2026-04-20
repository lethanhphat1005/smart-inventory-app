import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailInfoGridWidget extends GetView<InventoryDetailController> {
  const InventoryDetailInfoGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dòng 1: Giao diện Xám
        Row(
          children: [
            Expanded(
                child: _buildGridItem(TTexts.totalStockTitle.tr,
                    "${controller.quantity} ${TTexts.items.tr}")),
            const SizedBox(width: AppSizes.p12),
            Expanded(
                child: _buildGridItem(
                    TTexts.thresholdTitle.tr,
                    controller.threshold > 0
                        ? "${controller.threshold} ${TTexts.items.tr}"
                        : TTexts.noLimit.tr)),
          ],
        ),
        const SizedBox(height: AppSizes.p12),
        // Dòng 2: Giao diện Stand Out với Vibe Nhập/Xuất rõ ràng
        Obx(() => Row(
              children: [
                Expanded(
                    child: _buildHighlightGridItem(TTexts.totalStockInTitle.tr,
                        "${controller.totalStockIn} ${TTexts.items.tr}",
                        isStockIn: true)),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                    child: _buildHighlightGridItem(TTexts.totalStockOutTitle.tr,
                        "${controller.totalStockOut} ${TTexts.items.tr}",
                        isStockIn: false)),
              ],
            )),
      ],
    );
  }

  // --- WIDGET CHỈ SỐ BÌNH THƯỜNG ---
  Widget _buildGridItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.subText,
                  fontWeight: FontWeight.w500,
                  height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSizes.p4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CHỈ SỐ ĐẶC BIỆT  ---
  Widget _buildHighlightGridItem(String title, String value,
      {required bool isStockIn}) {
    final color = isStockIn ? AppColors.stockIn : AppColors.alertText;
    final bgColor = isStockIn ? AppColors.toastSuccessBg : AppColors.alertBg;
    final icon = isStockIn ? Iconsax.arrow_down_copy : Iconsax.arrow_up_3_copy;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}
