import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';

class TransactionSuccessWidget extends StatelessWidget {
  final VoidCallback onDone;
  const TransactionSuccessWidget({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(TImages.coreImages.successTransaction,
              width: 250, height: 250),
          const SizedBox(height: 24),
          Text(TTexts.transactionCompletedTitle.tr,
              style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText)),
          const SizedBox(height: 12),
          Text(TTexts.transactionCompletedSubtitle.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subText)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
            child: Text(TTexts.backToHome.tr,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
