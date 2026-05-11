import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart'; // THÊM IMPORT NÀY
import 'package:frontend/core/ui/theme/app_colors.dart';

class InventoryDetailPricingWidget extends GetView<InventoryDetailController> {
  const InventoryDetailPricingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: Row(
        children: [
          Expanded(
              child: _buildPricingCol(TTexts.importCost.tr,
                  controller.importPrice, AppColors.primaryText)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
              child: _buildPricingCol(
                  TTexts.salePrice.tr, controller.price, AppColors.primary)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(child: _buildMarginCol(controller.profitMargin)),
        ],
      ),
    );
  }

  Widget _buildPricingCol(String title, double price, Color color) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 10, color: AppColors.subText)),
        const SizedBox(height: 4),
        Text("\$${price.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: AppFonts.mainFont)),
      ],
    );
  }

  Widget _buildMarginCol(double margin) {
    final color = margin > 0
        ? AppColors.stockIn
        : (margin < 0 ? AppColors.alertText : AppColors.subText);
    return Column(
      children: [
        Text(TTexts.profitMargin.tr,
            style: const TextStyle(fontSize: 10, color: AppColors.subText)),
        const SizedBox(height: 4),
        Text(
            margin > 0
                ? "+${margin.toStringAsFixed(1)}%"
                : "${margin.toStringAsFixed(1)}%",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: AppFonts.mainFont)),
      ],
    );
  }
}
