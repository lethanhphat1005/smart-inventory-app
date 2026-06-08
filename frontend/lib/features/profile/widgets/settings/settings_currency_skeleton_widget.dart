import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class SettingsCurrencySkeletonWidget extends StatelessWidget {
  const SettingsCurrencySkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label tĩnh
        Text(
          TTexts.currencyLabel.tr,
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radius8),
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
          ),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.surface,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Shimmer.fromColors(
                baseColor: AppColors.surface,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
