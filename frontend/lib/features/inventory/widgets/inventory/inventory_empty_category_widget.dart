import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

class InventoryEmptyCategoryWidget extends GetView<InventoryController> {
  const InventoryEmptyCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p20, vertical: AppSizes.p24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.folder_add_copy,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(
            TTexts.noCategoriesFound.tr,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            TTexts.emptyCategoryMessage.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.subText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.p24),
          ElevatedButton.icon(
            onPressed: controller.goToAddCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Iconsax.add_circle_copy, size: 18),
            label: Text(
              TTexts.addNewCategory.tr,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: AppFonts.mainFont),
            ),
          ),
        ],
      ),
    );
  }
}
