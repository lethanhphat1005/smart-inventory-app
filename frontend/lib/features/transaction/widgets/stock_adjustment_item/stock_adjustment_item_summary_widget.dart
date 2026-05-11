import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_item_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentItemSummaryWidget
    extends GetView<StockAdjustmentItemController> {
  const StockAdjustmentItemSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final spread = controller.spread;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.system.tr,
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 14,
                      color: AppColors.subText)),
              Text("${controller.item.systemQty}",
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subText)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.actual.tr,
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 14,
                      color: AppColors.subText)),
              Text("${controller.tempActualQty.value}",
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: spread != 0
                          ? AppColors.stockOut
                          : AppColors.subText)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.spread.tr,
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText)),
              Text("${spread > 0 ? '+' : ''}$spread",
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: spread > 0
                          ? AppColors.stockIn
                          : (spread < 0
                              ? AppColors.stockOut
                              : AppColors.primaryText))),
            ],
          ),
        ],
      );
    });
  }
}
