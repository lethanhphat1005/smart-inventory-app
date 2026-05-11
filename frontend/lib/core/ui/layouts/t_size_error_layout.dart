import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_image_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:get/get.dart';

class TSizeErrorLayout extends StatelessWidget {
  const TSizeErrorLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          final double imageSize = isSmallScreen ? 280 : 450;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Hình ảnh minh họa
                  TImageWidget(
                    image: TImages.coreImages.deviceNotSupported,
                    width: imageSize,
                  ),

                  const SizedBox(height: AppSizes.p32),

                  // 2. Tiêu đề
                  Text(
                    TTexts.errorAccessRestrictedTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: isSmallScreen ? 26 : 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: AppSizes.p16),

                  // 3. Nội dung thông báo
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: Text(
                      TTexts.errorAccessRestrictedSubtitle.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontSize: 16,
                        color: AppColors.subText,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSizes.p48,
                  ), // Khoảng cách lớn trước nút bấm
                  // 4. Nút thoát ứng dụng
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TPrimaryButtonWidget(
                      text: TTexts.exit
                          .tr, // Bạn có thể đưa vào TTexts.exit.tr nếu muốn localization
                      backgroundColor:
                          AppColors.primary, // Màu xám nhẹ cho nút phụ
                      textColor: AppColors.whiteText,
                      onPressed: () => SystemNavigator.pop(), // Thoát ứng dụng
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
