import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class VerifyEmailMessageWidget extends StatelessWidget {
  final String email;
  const VerifyEmailMessageWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(
          fontFamily: AppFonts.mainFont,
          fontSize: 13,
          color: AppColors.subText,
          height: 1.5,
        ),
        children: [
          TextSpan(text: TTexts.verifyEmailMessageP1.tr),
          TextSpan(
            text: email,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          TextSpan(text: TTexts.verifyEmailMessageP2.tr),
        ],
      ),
    );
  }
}
