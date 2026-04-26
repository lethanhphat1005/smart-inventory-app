import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class ProductCatalogCategoryListItemWidget extends StatelessWidget {
  const ProductCatalogCategoryListItemWidget({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> avatarColors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo
    ];

    final String name = category.name;
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final Color bgColor = avatarColors[index % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(color: AppColors.softGrey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        child: Stack(
          children: [
            // 1. Nội dung chính
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: AppColors.primary.withOpacity(0.1),
                highlightColor: AppColors.primary.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          firstLetter,
                          style: TextStyle(
                              color: bgColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (category.description != null &&
                                      category.description!.isNotEmpty)
                                  ? category.description!
                                  : TTexts.noCategoryDescription.tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  height: 1.3,
                                  color: AppColors.subText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.softGrey, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Tag vuông ở góc trái phía trên
            if (category.isDefault)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    TTexts.defaultCategory.tr.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
