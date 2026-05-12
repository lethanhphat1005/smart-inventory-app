import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class OutboundProductSelectionOverflowDialogWidget extends StatelessWidget {
  final VoidCallback onCapAtMax;
  final VoidCallback? onAddValidOnly;
  final VoidCallback onReviewAgain;

  const OutboundProductSelectionOverflowDialogWidget({
    super.key,
    required this.onCapAtMax,
    this.onAddValidOnly,
    required this.onReviewAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius24)),
      backgroundColor: AppColors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Center(
                  child: Text("⚠️", style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(TTexts.overflowLimitTitle.tr,
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.p12),
            Text(TTexts.outboundOverflowLimitDesc.tr,
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 14,
                    color: AppColors.subText,
                    height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.p32),
            _buildPrimaryButton(
                text: TTexts.capAtMaxBtn.tr, onPressed: onCapAtMax),
            if (onAddValidOnly != null) ...[
              const SizedBox(height: AppSizes.p12),
              _buildPrimaryButton(
                  text: TTexts.addValidOnlyBtn.tr, onPressed: onAddValidOnly!),
            ],
            const SizedBox(height: AppSizes.p12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onReviewAgain,
                style: TextButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radius12))),
                child: Text(TTexts.reviewAgainBtn.tr,
                    style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
      {required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12)),
          elevation: 0,
        ),
        child: Text(text,
            style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white)),
      ),
    );
  }
}
