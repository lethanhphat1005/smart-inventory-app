import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Widget hiển thị tiêu đề Onboarding với chữ 'S' được cách điệu
class OnboardingTitleWidget extends StatelessWidget {
  const OnboardingTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: AppFonts.mainFont,
          fontSize: 42,
          color: AppColors.primaryText,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: TTexts.onboardingTitle1Part1.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: TTexts.onboardingTitle1Part2.tr,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: TTexts.onboardingTitle1Part3.tr,
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'SuezOne',
              fontSize: 54,
            ),
          ),
          TextSpan(
            text: TTexts.onboardingTitle1Part4.tr,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
