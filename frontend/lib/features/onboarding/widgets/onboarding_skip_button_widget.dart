import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';

/// Widget nút 'Skip' cho phép bỏ qua các màn hình giới thiệu
class OnboardingSkipButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const OnboardingSkipButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        // Cấp không gian cho hiệu ứng ripple lan tỏa
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p8,
        ),
      ),
      child: Text(
        TTexts.onboardingSkip.tr,
        style: TextStyle(
          fontFamily: AppFonts.mainFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}
