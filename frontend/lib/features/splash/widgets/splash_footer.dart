import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';

class SplashFooter extends StatelessWidget {
  const SplashFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSizes.p32,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            '${TTexts.splashVersion.tr} 1.0.0',
            style: TextStyle(
              color: AppColors.primaryText.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            TTexts.fourMonkeysStudio.tr,
            style: TextStyle(
              color: AppColors.primaryText.withOpacity(0.5),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
