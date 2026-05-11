import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/features/profile/widgets/profile/profile_menu_item_widgets.dart';
import 'package:frontend/features/profile/widgets/profile/profile_section_tiltle_widgets.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/utils.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<ProfileController>();
      final isStaff =
          controller.currentUserStoreRole.value.trim().toLowerCase() == 'staff';
      final isManager =
          controller.currentUserStoreRole.value.trim().toLowerCase() ==
              'manager';

      return Column(
        children: [
          // ACCOUNT
          ProfileSectionTitleWidget(title: TTexts.profileAccount.tr),

          ProfileMenuItemWidget(
            icon: Iconsax.user_copy,
            title: TTexts.profileMyAccount,
            onTap: () => controller.goToEditProfile(),
          ),
          ProfileMenuItemWidget(
            icon: Iconsax.lock_copy,
            title: TTexts.profileChangePassword,
            onTap: () => controller.goToChangePasswordProfile(),
          ),

          const SizedBox(height: AppSizes.p16),

          // MANAGEMENT
          if (!isStaff && !isManager) ...[
            ProfileSectionTitleWidget(title: TTexts.profileManagement.tr),
            ProfileMenuItemWidget(
              icon: Iconsax.security_safe_copy,
              title: TTexts.profileUserManagement,
              onTap: () => controller.goToAssignsRoleProfile(),
            ),
          ],

          const SizedBox(height: AppSizes.p16),

          // APP SETTINGS
          ProfileSectionTitleWidget(title: TTexts.profileAppSettings.tr),

          ProfileMenuItemWidget(
            icon: Iconsax.setting_2_copy,
            title: TTexts.settingsTitle,
            onTap: () => controller.goToSettings(),
          ),
        ],
      );
    });
  }
}
