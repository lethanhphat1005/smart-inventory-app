import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart'; // ĐÃ IMPORT APPSIZES
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryInsightCategoryChipWidget
    extends GetView<InventoryInsightController> {
  const InventoryInsightCategoryChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Obx(() {
        final List<String> chipItems = [TTexts.allItems];
        chipItems.addAll(controller.categories.map((c) => c.name));

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          itemCount: chipItems.length,
          itemBuilder: (context, index) {
            final item = chipItems[index];

            return GestureDetector(
              onTap: () => controller.setCategory(item),
              child: Obx(() {
                final isSelected = controller.activeCategory.value == item;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: AppSizes.p12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryText : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryText
                          : AppColors.softGrey.withOpacity(0.2),
                    ),
                    // boxShadow: isSelected
                    //     ? [
                    //         BoxShadow(
                    //             color: AppColors.primaryText.withOpacity(0.2),
                    //             blurRadius: 8,
                    //             offset: const Offset(0, 4))
                    //       ]
                    //     : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item == TTexts.allItems ? item.tr : item,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.subText,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
            );
          },
        );
      }),
    );
  }
}
