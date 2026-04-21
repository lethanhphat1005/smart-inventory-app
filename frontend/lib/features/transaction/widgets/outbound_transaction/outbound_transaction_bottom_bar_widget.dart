import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:get/get.dart';

class OutboundTransactionBottomBarWidget
    extends GetView<OutboundTransactionController> {
  const OutboundTransactionBottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final isEmpty = controller.cartItems.isEmpty;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TTexts.total.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '${controller.totalItems} ${TTexts.items.tr.toLowerCase()} • \$${controller.totalFunds.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isEmpty ? AppColors.softGrey : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TPrimaryButtonWidget(
                  text: TTexts.completeExport.tr,
                  backgroundColor: isEmpty
                      ? AppColors.softGrey.withOpacity(0.5)
                      : AppColors.primary,
                  onPressed:
                      isEmpty ? () {} : () => controller.completeExport(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
