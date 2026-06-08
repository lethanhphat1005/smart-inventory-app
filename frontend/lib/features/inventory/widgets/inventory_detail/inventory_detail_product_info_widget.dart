import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InventoryDetailProductInfoWidget
    extends GetView<InventoryDetailController> {
  const InventoryDetailProductInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        child: Column(
          children: [
            Text(controller.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    height: 1.3)),
            const SizedBox(height: AppSizes.p8),
            Text("${TTexts.barcodeLabel.tr}: ${controller.barcode}",
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                    fontWeight: FontWeight.w400)),
            const SizedBox(height: AppSizes.p12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: controller.tags
                  .map((tag) => Chip(
                        label: Text(tag,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.divider),
                        padding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
