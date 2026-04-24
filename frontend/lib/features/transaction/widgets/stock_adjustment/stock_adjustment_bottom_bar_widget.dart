import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentBottomBarWidget
    extends GetView<StockAdjustmentController> {
  const StockAdjustmentBottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          // ignore: unused_local_variable
          final _ = controller.filteredItems.length;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(TTexts.checkedItems.tr,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '${controller.checkedItemsCount}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange)),
                        TextSpan(
                            text: '/${controller.totalItems}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.subText)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TPrimaryButtonWidget(
                  text: TTexts.saveAll.tr,
                  backgroundColor: controller.canSave
                      ? AppColors.primary
                      : AppColors.softGrey.withOpacity(0.5),
                  onPressed: controller.canSave
                      ? controller.handleSaveAdjustment
                      : () {},
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
