import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductCatalogViewAllWidget extends StatelessWidget {
  final VoidCallback onTap;

  const ProductCatalogViewAllWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.highlightActionBg,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(
          color: AppColors.highlightActionBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.highlightAction.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.highlightAction.withOpacity(0.15),
          highlightColor: AppColors.highlightAction.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50, // Size 50x50 y chang
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.highlightAction,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Iconsax.box_1_copy,
                    color: AppColors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TTexts.viewAllProducts.tr,
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.highlightAction,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        TTexts.viewAllProductsSub.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 10,
                          height: 1.3,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.p8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.highlightAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
