import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/onboarding/controllers/language_select_controller.dart';
import 'package:frontend/features/onboarding/widgets/language_select/language_select_item_widget.dart';
import 'package:get/get.dart';

class LanguageSelectMobileView extends GetView<LanguageSelectController> {
  const LanguageSelectMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.p20),

              Text(
                TTexts.languageSelectTitle.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                TTexts.languageSelectSubtitle.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.subText, height: 1.5),
              ),
              const SizedBox(height: AppSizes.p32),

              // List Ngôn ngữ
              Expanded(
                child: ListView.separated(
                  itemCount: controller.supportedLanguages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSizes.p16),
                  itemBuilder: (context, index) {
                    final lang = controller.supportedLanguages[index];

                    return Obx(() {
                      final isSelected =
                          controller.selectedIndex.value == index;

                      return LanguageSelectItemWidget(
                        title: lang.name,
                        subTitle: lang.subName ?? '',
                        flag: lang.flagEmoji,
                        isSelected: isSelected,
                        onTap: () => controller.selectLanguage(index),
                      );
                    });
                  },
                ),
              ),

              // Nút Tiếp tục
              TPrimaryButtonWidget(
                text: TTexts.languageSelectBtnContinue.tr,
                onPressed: () => controller.continueToNextScreen(),
                fontSize: 14,
                height: 55,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
