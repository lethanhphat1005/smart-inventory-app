import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class SearchTransactionHeaderWidget extends GetView<TSearchController> {
  const SearchTransactionHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.filter_search_copy,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              TTexts.filterTransactions.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryText,
              ),
            ),
          ),
          InkWell(
            onTap: controller.openTransactionFilterSheet,
            child: const Icon(Iconsax.setting_4_copy,
                color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }
}
