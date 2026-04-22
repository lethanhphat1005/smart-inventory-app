import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ProfileSectionTitleWidget extends StatelessWidget {
  final String title;

  const ProfileSectionTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.p24,
        bottom: AppSizes.p8,
        top: AppSizes.p8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.tr.toUpperCase(),
          style: const TextStyle(
            fontSize: AppSizes.p11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.subText,
          ),
        ),
      ),
    );
  }
}
