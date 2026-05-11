import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TCustomFadeOverlayWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;

  const TCustomFadeOverlayWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppSizes.radius24)),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radius24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface.withOpacity(0.0), // Trong suốt
                AppColors.gradientOrangeEnd.withOpacity(0.15), // Cam nhạt mờ
                AppColors.gradientOrangeStart
                    .withOpacity(0.4), // Cam đậm hơn ở đáy
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
