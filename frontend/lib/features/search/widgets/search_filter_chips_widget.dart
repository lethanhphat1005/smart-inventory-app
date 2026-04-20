import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchFilterChipsWidget extends GetView<TSearchController> {
  const SearchFilterChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTypeFiltered = controller.filterType.value != TTexts.filterAll;
      final isDateFiltered = controller.filterDateRange.value != null;
      final isUserFiltered = controller.filterUserId.value.isNotEmpty;

      if (!isTypeFiltered && !isDateFiltered && !isUserFiltered) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TTexts.activeFilters.tr,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.subText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isTypeFiltered)
                    _buildChip(controller.filterType.value.tr, 'type'),
                  // ĐÃ XÓA CHIP STATUS
                  if (isDateFiltered)
                    _buildChip(
                        '${DateFormat('dd/MM').format(controller.filterDateRange.value!.start)} - ${DateFormat('dd/MM').format(controller.filterDateRange.value!.end)}',
                        'date'),
                  if (isUserFiltered)
                    _buildChip(
                        '${TTexts.userLabel.tr}: ${controller.filterUserName.value}',
                        'user'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChip(String label, String categoryKey) {
    return InputChip(
      label: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.primary)),
      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
      onDeleted: () => controller.removeFilter(categoryKey),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
