import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_image_widget.dart';

import '../../widgets/splash_footer.dart';
import '../../widgets/splash_loading_bar.dart';
import '../../controllers/splash_controller.dart';

class SplashMobileView extends StatelessWidget {
  const SplashMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy controller đã được inject
    final controller = Get.find<SplashController>();

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TImageWidget(image: TImages.appLogos.appLogo, width: 200),
              const SizedBox(height: AppSizes.p16),
              Text(
                TTexts.splashSlogan.tr,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryText.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),

              const SizedBox(width: 250, child: SplashLoadingBar()),

              const SizedBox(
                height: AppSizes.p12,
              ), // Khoảng cách từ thanh load đến chữ
              // DÒNG CHỮ TRẠNG THÁI LOADING ĐỘNG
              Obx(
                () => Text(
                  controller.loadingMessage.value,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SplashFooter(),
      ],
    );
  }
}
