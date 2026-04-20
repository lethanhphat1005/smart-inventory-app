import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/features/profile/widgets/profile/profile_menu_item_widgets.dart';
import 'package:frontend/features/profile/widgets/profile/profile_section_tiltle_widgets.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/utils.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ACCOUNT
        ProfileSectionTitleWidget(title: TTexts.profileAccount.tr),

        ProfileMenuItemWidget(
          icon: Iconsax.user_copy,
          title: TTexts.profileMyAccount.tr,
          onTap: () => Get.find<ProfileController>().goToEditProfile(),
        ),
        ProfileMenuItemWidget(
          icon: Iconsax.lock_copy,
          title: TTexts.profileChangePassword.tr,
          onTap: () =>
              Get.find<ProfileController>().goToChangePasswordProfile(),
        ),

        const SizedBox(height: AppSizes.p16),

        // MANAGEMENT
        ProfileSectionTitleWidget(title: TTexts.profileManagement.tr),

        ProfileMenuItemWidget(
          icon: Iconsax.security_safe_copy,
          title: TTexts.profileUserManagement.tr,
          onTap: () => Get.find<ProfileController>().goToAssignsRoleProfile(),
        ),
      ],
    );
  }
}
