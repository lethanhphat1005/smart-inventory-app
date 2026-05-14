import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TransactionCategoryChipWidget extends StatelessWidget {
  final List<String> categories;
  final String activeCategory;
  final Function(String) onCategorySelected;

  const TransactionCategoryChipWidget({
    super.key,
    required this.categories,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final item = categories[index];
            final isSelected = activeCategory == item;

            return GestureDetector(
              onTap: () => onCategorySelected(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: AppSizes.p12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryText : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radius24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryText
                        : AppColors.softGrey.withOpacity(0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item == TTexts.allItems ? item.tr : item,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.subText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ));
  }
}
