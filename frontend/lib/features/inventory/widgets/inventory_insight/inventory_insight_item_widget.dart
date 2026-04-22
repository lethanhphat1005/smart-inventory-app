import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryInsightItemWidget extends GetView<InventoryInsightController> {
  final InventoryInsightDisplayModel displayItem;

  const InventoryInsightItemWidget({super.key, required this.displayItem});

  @override
  Widget build(BuildContext context) {
    final inventory = displayItem.inventory;
    final product = displayItem.product;
    final pkg = inventory.productPackage;

    final name = pkg?.displayName ?? TTexts.unknownProduct.tr;
    final brand =
        product?.brand?.isNotEmpty == true ? product!.brand! : TTexts.na.tr;
    final price = pkg?.sellingPrice ?? 0.0;
    final imageUrl = product?.imageUrl;
    final qty = inventory.quantity;
    final threshold = inventory.reorderThreshold;

    Color statusColor = AppColors.stockIn;
    String statusText = "${TTexts.inStock.tr}: $qty";

    if (qty == 0) {
      statusColor = AppColors.alertText;
      statusText = TTexts.tabOutStock.tr;
    } else if (qty <= threshold) {
      statusColor = AppColors.primary;
      statusText = "${TTexts.tabLowStock.tr}: $qty";
    }

    // SỬ DỤNG MATERIAL + INKWELL ĐỂ BẮT SỰ KIỆN NHẠY HƠN
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.goToDetail(displayItem),
          borderRadius: BorderRadius.circular(AppSizes.radius20),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radius20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const TNoImageWidget(
                                    iconSize: 24, borderRadius: 12),
                          )
                        : const TNoImageWidget(iconSize: 24, borderRadius: 12),
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryText)),
                      const SizedBox(height: AppSizes.p4),
                      Text("${TTexts.brand.tr}: $brand",
                          style: const TextStyle(
                              color: AppColors.subText, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: AppColors.primaryText)),
                    const SizedBox(height: AppSizes.p8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius8)),
                      child: Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
