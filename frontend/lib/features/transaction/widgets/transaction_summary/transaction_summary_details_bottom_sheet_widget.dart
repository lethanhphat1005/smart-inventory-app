import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/transaction_summary_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionSummaryDetailsBottomSheetWidget
    extends GetView<TransactionSummaryController> {
  const TransactionSummaryDetailsBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            controller.isAdjustment
                ? TTexts.adjustmentId.tr
                : TTexts.transactionNumber.tr,
            controller.transaction.transactionId ?? TTexts.na.tr),
        const SizedBox(height: 8),
        _buildInfoRow(TTexts.transactionDate.tr, controller.dateStr),

        const SizedBox(height: 16),

        // ==========================================
        // NẾU LÀ ADJUSTMENT -> HIỂN THỊ VẮN TẮT
        // ==========================================
        if (controller.isAdjustment)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    TTexts.adjustmentSummaryBrief.tr,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryText,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          )
        else
          // ==========================================
          // INBOUND/OUTBOUND -> HIỂN THỊ LIST CHI TIẾT
          // ==========================================
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: controller.transaction.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.transaction.items[index];
              return Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Iconsax.box_1_copy,
                        size: 20, color: AppColors.subText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.packageInfo?.displayName ?? TTexts.product.tr,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryText)),
                        Text('${TTexts.qty.tr}: ${item.quantity}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.subText)),
                      ],
                    ),
                  ),
                  Text(
                      '\$${(item.quantity * item.unitPrice).abs().toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              );
            },
          ),

        // PHẦN HIỂN THỊ NOTE TỔNG (Vẫn giữ cho Adjustment)
        if (controller.transaction.note != null &&
            controller.transaction.note!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 18, color: AppColors.subText),
                  const SizedBox(width: 4),
                  Text(TTexts.noteLabel.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.subText)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.transaction.note!,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryText,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),

        // Tổng tiền (Lệch)
        if (!controller.isAdjustment) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.total.tr.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.subText)),
              Text(controller.moneyDisplay,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 18)),
            ],
          ),
        ],

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: TPrimaryButtonWidget(
            text: TTexts.goBack.tr,
            backgroundColor: AppColors.primary,
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.subText)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }
}
