import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailBasicInfoWidget
    extends GetView<InventoryDetailController> {
  const InventoryDetailBasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final thresholdStr = controller.threshold > 0
        ? "${controller.threshold} ${TTexts.items.tr}"
        : TTexts.noLimit.tr;
    final qtyStr = "${controller.quantity} ${TTexts.items.tr}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // THẺ 1: THRESHOLD
        _buildInfoCard(
          title: TTexts.thresholdTitle.tr,
          value: thresholdStr,
          icon: Iconsax.warning_2_copy,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.p12),
        // THẺ 2: TOTAL STOCK
        _buildInfoCard(
          title: TTexts.totalStockTitle.tr,
          value: qtyStr,
          icon: Iconsax.box_copy,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                          fontFamily: AppFonts.mainFont)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
