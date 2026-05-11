import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class LanguageSelectItemWidget extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageSelectItemWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // Animation cực ngắn (150ms) chỉ để đổi màu mượt mà, không làm giật layout
        duration: const Duration(milliseconds: 50),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: 22,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          // Chỉ thay đổi màu viền và độ dày viền
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag Emoji
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSizes.p16),

            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryText,
                    ),
                  ),
                  if (subTitle != null && subTitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subTitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subText,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Icon Tick Gradient
            if (isSelected)
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      AppColors.toastSuccessGradientStart,
                      AppColors.toastSuccessGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
