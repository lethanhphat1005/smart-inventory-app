import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/transaction/controllers/transaction_summary_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionSummaryReceiptCardWidget
    extends GetView<TransactionSummaryController> {
  const TransactionSummaryReceiptCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // 1. MÃ GIAO DỊCH
          _buildRow(
            controller.isAdjustment
                ? TTexts.adjustmentId.tr
                : TTexts.transactionNumber.tr,
            controller.transaction.transactionId ?? TTexts.na.tr,
            rightWidget: _buildFakeBarcode(),
          ),
          const SizedBox(height: 20),

          // 2. NGÀY GIỜ VÀ LOẠI GIAO DỊCH (GỘP CHUNG)
          _buildRow(
            TTexts.transactionDate.tr,
            controller.dateStr,
            rightWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(TTexts.transactionType.tr,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subText)),
                const SizedBox(height: 4),
                Text(
                  controller.typeDisplay,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: controller.typeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. THỐNG KÊ ITEM VÀ TỔNG TIỀN (GỘP CHUNG)
          _buildRow(
            // ĐÃ FIX: Hiển thị Modified Products thay cho thẻ chung
            controller.isAdjustment
                ? TTexts.modifiedProducts.tr
                : TTexts.totalItemsTransaction.tr,
            '',
            customLeftWidget: Row(
              children: [
                Text(controller.itemsDisplay,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: controller.itemsColor)),

                // ĐÃ FIX: CHỈ HIỂN THỊ TIỀN NẾU KHÔNG PHẢI LÀ KIỂM KHO
                if (!controller.isAdjustment) ...[
                  const Text(" / ",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.subText)),
                  Text(controller.moneyDisplay,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: controller.moneyColor)),
                ],
              ],
            ),
            rightWidget: _buildCustomLayerIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String leftTitle, String leftValue,
      {Widget? customLeftWidget, Widget? rightWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftTitle,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subText)),
              const SizedBox(height: 4),
              customLeftWidget ??
                  Text(
                    leftValue,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
            ],
          ),
        ),
        if (rightWidget != null) ...[
          const SizedBox(width: AppSizes.p24),
          rightWidget,
        ],
      ],
    );
  }

  Widget _buildFakeBarcode() {
    final List<double> widths = [2, 4, 1.5, 3, 1, 5, 2, 1.5, 4, 2, 1, 3];
    final List<double> heights = [
      36,
      40,
      32,
      38,
      40,
      34,
      38,
      32,
      40,
      36,
      38,
      40
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
          widths.length,
          (index) => Container(
                width: widths[index],
                height: heights[index],
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryText,
                  borderRadius: BorderRadius.circular(1),
                ),
              )),
    );
  }

  Widget _buildCustomLayerIcon() {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child:
                Icon(Iconsax.layer_copy, color: controller.typeColor, size: 28),
          ),
          if (controller.isInbound)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: AppColors.stockIn, shape: BoxShape.circle),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 12, weight: 800),
              ),
            ),
          if (controller.isOutbound)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: AppColors.stockOut, shape: BoxShape.circle),
                child: const Icon(Icons.remove,
                    color: Colors.white, size: 12, weight: 800),
              ),
            ),
        ],
      ),
    );
  }
}
