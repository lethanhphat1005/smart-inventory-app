import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:frontend/features/notification/utils/notification_constants.dart';
import 'package:get/get.dart';

class NotificationFilterTabWidget extends StatelessWidget {
  const NotificationFilterTabWidget({
    super.key,
    required this.controller,
  });

  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterChip(TTexts.filterAll.tr, 'ALL', controller),
          const SizedBox(width: 8),
          _buildFilterChip(
              TTexts.filterLowStock.tr,
              "${NotificationTypes.lowStock},${NotificationTypes.batchLowStock}",
              controller),
          const SizedBox(width: 8),
          _buildFilterChip(TTexts.filterDiscrepancy.tr,
              NotificationTypes.inventoryDiscrepancy, controller),
          const SizedBox(width: 8),
          _buildFilterChip(TTexts.filterReorder.tr,
              NotificationTypes.reorderSuggestion, controller),
          const SizedBox(width: 8),
          _buildFilterChip(
              TTexts.filterImport.tr, NotificationTypes.import, controller),
          const SizedBox(width: 8),
          _buildFilterChip(
              TTexts.filterExport.tr, NotificationTypes.export, controller),
        ],
      ),
    );
  }
}

Widget _buildFilterChip(
    String label, String value, NotificationController controller) {
  return Obx(() {
    final isSelected = controller.selectedFilter.value == value;
    return InkWell(
      onTap: () => controller.changeFilter(value),
      borderRadius: BorderRadius.circular(AppSizes.radius24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.subText,
          ),
        ),
      ),
    );
  });
}
