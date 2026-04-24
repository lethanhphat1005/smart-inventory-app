import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

import 'package:frontend/features/profile/controllers/profile_controller.dart';

class ProfileLogoutButtonWidget extends StatelessWidget {
  const ProfileLogoutButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Get.dialog(
              TCustomDialogWidget(
                title: TTexts.profileDialogTitleLogout.tr,
                description: TTexts.profileDialogDescriptionLogout.tr,

                icon:
                    const Text('🚪', style: TextStyle(fontSize: AppSizes.p40)),
                // Nút Logout
                primaryButtonText: TTexts.profileDialogBtnLogout.tr,
                onPrimaryPressed: () {
                  Get.back();
                  Get.find<ProfileController>().executeLogout();
                },

                // Nút cancel
                secondaryButtonText: TTexts.cancel.tr,
                onSecondaryPressed: () {
                  Get.back();
                },
              ),
              barrierDismissible: false, // không cho bấm ngoài
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gradientOrangeStart,
            foregroundColor: AppColors.whiteText,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.logout_1_copy, size: AppSizes.p20),
              const SizedBox(width: AppSizes.p8),
              Text(
                TTexts.profileBtnLogout.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.p16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
