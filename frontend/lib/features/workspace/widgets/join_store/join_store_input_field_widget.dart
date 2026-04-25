import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/workspace/controllers/join_store_controller.dart';

class JoinStoreInputFieldWidget extends GetView<JoinStoreController> {
  const JoinStoreInputFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.enterInviteCodeLabel.tr,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: AppSizes.p12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextSelectionTheme(
            data: TextSelectionThemeData(
              cursorColor: AppColors.primary,
              selectionColor: AppColors.primary.withOpacity(0.3),
              selectionHandleColor: AppColors.primary,
            ),
            child: TextFormField(
              controller: controller.inviteCodeController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4.0,
                  color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: TTexts.enterInviteCodeHint.tr,
                hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: AppColors.softGrey.withOpacity(0.5),
                    letterSpacing: 2.0),
                counterText: "",
                filled: true,
                fillColor: Colors.transparent,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSizes.p24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text,
      selection: newValue.selection,
    );
  }
}
