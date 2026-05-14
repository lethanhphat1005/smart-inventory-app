import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/settings_controller.dart';
import 'package:frontend/features/profile/widgets/settings/settings_language_dropdown_widget.dart';
// import 'package:frontend/features/profile/widgets/settings/settings_currency_dropdown_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class SettingsMobileView extends GetView<SettingsController> {
  const SettingsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TBlurAppBarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Text(
                TTexts.settingsTitle.tr,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                TTexts.settingsSubtitle.tr,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.subText, height: 1.5),
              ),
              const SizedBox(height: AppSizes.p32),

              // --- DROPDOWN NGÔN NGỮ ---
              const SettingsLanguageDropdownWidget(),
              const SizedBox(height: AppSizes.p24),

              // --- DROPDOWN TIỀN TÊ ---
              // const SettingsCurrencyDropdownWidget(),
              // const SizedBox(height: AppSizes.p20),
            ],
          ),
        ),
      ),
    );
  }
}
