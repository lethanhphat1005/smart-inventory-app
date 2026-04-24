import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_item_add_controller.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_item_add_controller.dart';

class TransactionProductInfoWidget extends StatelessWidget {
  const TransactionProductInfoWidget({super.key});

  dynamic get _controller {
    if (Get.isRegistered<InboundTransactionItemAddController>()) {
      return Get.find<InboundTransactionItemAddController>();
    } else if (Get.isRegistered<OutboundTransactionItemAddController>()) {
      return Get.find<OutboundTransactionItemAddController>();
    }
    throw Exception("Không tìm thấy Controller hợp lệ (Inbound/Outbound)");
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => Text(
                  controller.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      height: 1.3),
                )),
            const SizedBox(height: AppSizes.p8),
            Obx(() => Text(
                  '${TTexts.barcodeLabel.tr}: ${controller.barcode}',
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w500),
                )),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  // 1. CHIP DANH MỤC
                  _buildChip(controller.categoryName),
                  // 2. CHIP TÌNH TRẠNG KHO
                  _buildChip(
                    '${controller.healthStatusText} (${controller.currentStock})',
                    textColor: controller.healthStatusColor,
                    bgColor: controller.healthStatusColor.withOpacity(0.1),
                    hasBorder: false,
                  ),
                  // 3. CHIP THƯƠNG HIỆU (Kiểm tra rỗng trước khi hiện)
                  if (controller.brandName != 'No Brand' &&
                      controller.brandName.isNotEmpty)
                    _buildChip(controller.brandName),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label,
      {Color? textColor, Color? bgColor, bool hasBorder = true}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: hasBorder ? FontWeight.w600 : FontWeight.w700,
          color: textColor ?? AppColors.primaryText,
        ),
      ),
      backgroundColor: bgColor ?? AppColors.surface,
      side: hasBorder
          ? const BorderSide(color: AppColors.divider)
          : BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }
}
