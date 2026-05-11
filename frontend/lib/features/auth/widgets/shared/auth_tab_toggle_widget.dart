import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class AuthTabToggleWidget extends StatelessWidget {
  final bool isLogin;

  const AuthTabToggleWidget({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppSizes.radius12),
      ),
      child: Stack(
        children: [
          // LỚP ĐÁY: KHỐI NỀN TRẮNG
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radius8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LỚP TRÊN: CÁC NÚT BẤM (Bọc GestureDetector BÊN NGOÀI Expanded)
          Row(
            children: [
              // --- NÚT LOG IN ---
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior
                      .translucent, // Sửa thành translucent để chắc chắn bắt được
                  onTap: () {
                    if (!isLogin) {
                      // QUAN TRỌNG: Phải có noTransition để không bị chớp màn hình
                      Get.offNamed(AppRoutes.login);
                    }
                  },
                  child: Center(
                    child: Text(
                      TTexts.loginTab.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontWeight: isLogin ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isLogin ? AppColors.primaryText : AppColors.subText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // --- NÚT SIGN UP ---
              Expanded(
                child: GestureDetector(
                  behavior:
                      HitTestBehavior.translucent, // Sửa thành translucent
                  onTap: () {
                    if (isLogin) {
                      // QUAN TRỌNG: Phải có noTransition
                      Get.offNamed(AppRoutes.register);
                    }
                  },
                  child: Center(
                    child: Text(
                      TTexts.signupTab.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontWeight:
                            !isLogin ? FontWeight.w600 : FontWeight.w500,
                        color: !isLogin
                            ? AppColors.primaryText
                            : AppColors.subText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
