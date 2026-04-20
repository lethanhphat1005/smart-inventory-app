import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:frontend/features/inventory/models/inventory_history_model.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailHistoryWidget extends GetView<InventoryDetailController> {
  const InventoryDetailHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.inventoryHistory;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              child: Center(
                child: Text(TTexts.noHistoryAvailable.tr,
                    style: const TextStyle(
                        color: AppColors.subText, fontStyle: FontStyle.italic)),
              ),
            )
          else
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSizes.p20,
                      right: AppSizes.p20,
                      bottom: history.length > 5 ? 60 : AppSizes.p8),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                    itemCount: history.length > 5 ? 5 : history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildHistoryCard(item, index);
                    },
                  ),
                ),
                if (history.length > 5)
                  TCustomFadeOverlayWidget(
                    text: TTexts.homeTapToViewMoreHistory.tr,
                    onTap: controller.viewAllHistory,
                  ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildHistoryCard(InventoryHistoryModel item, int index) {
    final isOut = item.type == InventoryActionType.stockOut;
    final isAdjust = item.type == InventoryActionType.adjust;

    // Logic xác định dấu và màu sắc dựa trên giá trị qty
    String displayQty = "";
    Color displayColor = AppColors.primary;

    if (isAdjust) {
      displayQty = item.qty > 0 ? "+${item.qty}" : "${item.qty}";
      displayColor = item.qty > 0
          ? AppColors.stockIn
          : (item.qty < 0 ? AppColors.alertText : AppColors.primary);
    } else if (isOut) {
      displayQty = "-${item.qty.abs()}";
      displayColor = AppColors.alertText;
    } else {
      displayQty = "+${item.qty.abs()}";
      displayColor = AppColors.stockIn;
    }

    return GestureDetector(
      onTap: () => controller.openHistoryDetails(index),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(
            color: isAdjust
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.divider.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: isAdjust
                    ? AppColors.primary.withOpacity(0.1)
                    : (isOut
                        ? AppColors.toastWarningBg
                        : AppColors.toastSuccessBg),
                shape: BoxShape.circle),
            child: Icon(
                isAdjust
                    ? Icons.sync_alt_rounded
                    : (isOut
                        ? Iconsax.arrow_up_3_copy
                        : Iconsax.arrow_down_copy),
                color: isAdjust
                    ? AppColors.primary
                    : (isOut ? AppColors.alertText : AppColors.stockIn),
                size: 18),
          ),
          title: Text(item.note,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isAdjust ? FontWeight.bold : FontWeight.w600)),
          subtitle: Text(item.date,
              style: const TextStyle(fontSize: 12, color: AppColors.subText)),
          trailing: Text(displayQty,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: displayColor,
                  fontFamily: 'Poppins')),
        ),
      ),
    );
  }
}
