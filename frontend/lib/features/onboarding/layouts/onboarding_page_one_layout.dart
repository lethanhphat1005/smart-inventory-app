import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/ui/widgets/t_image_widget.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_next_button_widget.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_skip_button_widget.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_title_widget.dart';

/// Layout riêng biệt cho màn hình Onboarding đầu tiên (Trang 1)
class OnboardingPageOneLayout extends GetView<OnboardingController> {
  const OnboardingPageOneLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Đo kích thước tai thỏ (top) và 3 nút (bottom)
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: Stack(
        children: [
          // 1. Ảnh nền vẫn tràn viền
          Align(
            alignment: const FractionalOffset(1.2, 1.0),
            child: TImageWidget(
              image: TImages.onboardingImages.onboardingContent1,
            ),
          ),
          // 2. Bỏ SafeArea, dùng Padding tự động cộng dồn
          Padding(
            padding: EdgeInsets.only(
              left: AppSizes.p24,
              top: topPadding > 0 ? topPadding + 16 : AppSizes.p32,
              bottom: bottomPadding +
                  AppSizes.p32, // Cộng thêm bottomPadding vào lề dưới
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56.0),
                const OnboardingTitleWidget(),
                const SizedBox(height: AppSizes.p32),
                OnboardingNextButtonWidget(
                  onTap: controller.onNextPressed,
                  progress: 0.33,
                ),
                const Spacer(),
                const Spacer(),

                // Nút Skip
                const Spacer(),

                // Nút Skip
                OnboardingSkipButtonWidget(onTap: controller.onSkipPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
