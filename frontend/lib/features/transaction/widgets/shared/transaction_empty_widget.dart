import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';

class TransactionEmptyWidget extends StatelessWidget {
  const TransactionEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(TImages.coreImages.noItem,
                width: 200, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(TTexts.emptyTransactionTitle.tr,
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(TTexts.emptyTransactionSubtitle.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 14,
                      color: AppColors.subText,
                      height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
