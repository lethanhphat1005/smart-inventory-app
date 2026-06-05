import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InboundProductSelectionBottomBarWidget extends StatelessWidget {
  final int totalItems;
  final double totalPrice;
  final VoidCallback onCartTap;
  final VoidCallback onConfirm;

  const InboundProductSelectionBottomBarWidget({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.onCartTap,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p20, vertical: AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onCartTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.task_square_copy,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$totalItems ${TTexts.labelItemsCount.tr}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryText)),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                              CurrencyFormatterUtils.formatFull(totalPrice),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary))),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_up_rounded,
                        color: AppColors.subText),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),

            // NÚT XÁC NHẬN
            SizedBox(
              width: 100,
              height: 48,
              child: TPrimaryButtonWidget(
                text: TTexts.done.tr,
                onPressed: onConfirm,
                fontSize: 15.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
