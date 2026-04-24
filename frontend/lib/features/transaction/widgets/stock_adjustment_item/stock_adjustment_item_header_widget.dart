import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_item_controller.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:get/get.dart';

class StockAdjustmentItemHeaderWidget
    extends GetView<StockAdjustmentItemController> {
  final AdjustmentItemRx item;

  const StockAdjustmentItemHeaderWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final imageUrl = controller.imageUrl;
      final displayBarcode = controller.displayBarcode.isNotEmpty
          ? controller.displayBarcode
          : TTexts.na.tr;
      final hasMultipleBarcodes = controller.hasMultipleBarcodes;
      final barcodeCount = controller.barcodeCount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.productInformation.tr,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText)),
              Text("${TTexts.currentStock.tr}: ${item.systemQty}",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subText)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              if (hasMultipleBarcodes) {
                controller.showBarcodeListBottomSheet();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const TNoImageWidget(),
                              errorWidget: (context, url, error) =>
                                  const TNoImageWidget(),
                            )
                          : const TNoImageWidget(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryText)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${TTexts.barcodeLabel.tr}: $displayBarcode",
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.subText),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasMultipleBarcodes) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '+${barcodeCount - 1}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
