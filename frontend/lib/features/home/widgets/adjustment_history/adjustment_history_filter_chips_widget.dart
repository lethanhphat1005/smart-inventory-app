import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/adjustment_history_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdjustmentHistoryFilterChipsWidget
    extends GetView<AdjustmentHistoryController> {
  const AdjustmentHistoryFilterChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDateFiltered = controller.selectedDate.value != null;

      if (!isDateFiltered) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TTexts.filtered.tr,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.subText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isDateFiltered)
                    _buildChip(
                        DateFormat('dd/MM/yyyy')
                            .format(controller.selectedDate.value!),
                        'date'),
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
      onDeleted: () => controller.clearDateFilter(),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
