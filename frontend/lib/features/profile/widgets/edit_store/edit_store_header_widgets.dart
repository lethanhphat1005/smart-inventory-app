import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';

class EditStoreHeaderWidget extends StatelessWidget {
  const EditStoreHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.editStoreTitle.tr,
          style: const TextStyle(
            fontSize: AppSizes.p28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          TTexts.editStoreSubtitle.tr,
          style: const TextStyle(
            fontSize: AppSizes.p16,
            color: AppColors.subText,
          ),
        ),
      ],
    );
  }
}
