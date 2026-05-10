import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

/// Header chuẩn cho mọi màn hình Auth (Nền cam, Logo, Tiêu đề)
class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false, // Hữu ích cho màn hình Quên mật khẩu/Đăng ký
  });

  final String title;
  final String subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppSizes.p64,
        left: AppSizes.p24,
        right: AppSizes.p24,
        bottom: AppSizes.p48,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(TImages.authImages.authBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          if (showBackButton) const SizedBox(height: AppSizes.p24),

          // 1. Logo SI (Tăng size và ép sát lề trái tuyệt đối)
          Image.asset(
            TImages.appLogos.appLogoWhiteCS,
            height: 80,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),

          // 2. Tiêu đề
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSizes.p12),

          // Phụ đề
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
