import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';

class SearchInputFieldWidget extends GetView<TSearchController> {
  const SearchInputFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGrey.withOpacity(0.3)),
      ),
      child: Obx(() {
        return TextField(
          controller: controller.textController,
          focusNode: controller.focusNode,
          onChanged: controller.onSearchChanged,
          cursorColor: AppColors.primary,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: controller.dynamicHint,
            hintStyle: const TextStyle(color: AppColors.softGrey),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
            prefixIcon: const Icon(Iconsax.search_normal_copy,
                color: AppColors.softGrey, size: 20),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.currentSearchQuery.value.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.softGrey, size: 20),
                    onPressed: controller.clearSearch,
                  ),
                IconButton(
                  icon: const Icon(Iconsax.scan_barcode_copy,
                      color: AppColors.primary, size: 20),
                  onPressed: controller.openScanner,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        );
      }),
    );
  }
}
