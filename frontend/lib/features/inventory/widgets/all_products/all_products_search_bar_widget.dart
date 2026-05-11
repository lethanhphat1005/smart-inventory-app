import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/all_products_controller.dart';

class AllProductsSearchBarWidget extends GetView<AllProductsController> {
  const AllProductsSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.searchQuery.value = value,
        cursorColor: AppColors.primary,
        style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 12,
            color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: TTexts.searchItemsPackages.tr,
          hintStyle: const TextStyle(color: AppColors.subText, fontSize: 12),
          prefixIcon: const Icon(Iconsax.search_normal_1_copy,
              color: AppColors.softGrey, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchQuery.value = "";
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
