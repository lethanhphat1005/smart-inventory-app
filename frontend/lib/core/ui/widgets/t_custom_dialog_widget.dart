import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

/// Hộp thoại (Dialog) tùy chỉnh tái sử dụng (Chuẩn UI UI/UX xếp dọc)
class TCustomDialogWidget extends StatelessWidget {
  const TCustomDialogWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.content, // Hỗ trợ widget tùy chỉnh (như danh sách thay đổi giá)
  });

  final String title;
  final String description;
  final Widget icon;
  final Widget? content;

  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;

  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==========================================
              // 1. KHUNG CHỨA ICON
              // ==========================================
              Container(
                padding: const EdgeInsets.all(AppSizes.p20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                ),
                child: icon,
              ),
              const SizedBox(height: AppSizes.p24),

              // ==========================================
              // 2. TIÊU ĐỀ & MÔ TẢ
              // ==========================================
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.p12),

              Text(
                description,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // ==========================================
              // 3. NỘI DUNG TÙY CHỈNH (Danh sách giá thay đổi)
              // ==========================================
              if (content != null) ...[
                const SizedBox(height: AppSizes.p16),
                content!,
              ],

              const SizedBox(height: AppSizes.p32),

              // ==========================================
              // 4. KHU VỰC NÚT BẤM
              // ==========================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                  ),
                  child: Text(
                    primaryButtonText,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              if (secondaryButtonText != null) ...[
                const SizedBox(height: AppSizes.p12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onSecondaryPressed ?? () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.p16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius12),
                      ),
                    ),
                    child: Text(
                      secondaryButtonText!,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
