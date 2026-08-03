import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_edit_custom_dialog_widgets.dart/t_edit_store_custom_dialog_widgets.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:frontend/core/state/services/store_service.dart';

class EditStoreCardWidgets extends StatelessWidget {
  const EditStoreCardWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    final editStoreController = Get.isRegistered<ProfileEditStoreController>()
        ? Get.find<ProfileEditStoreController>()
        : Get.put(ProfileEditStoreController());
    final storeService = Get.find<StoreService>();

    return Obx(
      () {
        final isOwner =
            storeService.currentRole.value.trim().toLowerCase() == 'owner';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p8,
            ),
            leading: Container(
              width: AppSizes.p40,
              height: AppSizes.p40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: const Icon(
                Iconsax.shop_copy,
                color: AppColors.primary,
                size: AppSizes.p20,
              ),
            ),
            title: Text(
              controller.storeName.value.isNotEmpty
                  ? controller.storeName.value
                  : TTexts.profileStoreName.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.p15,
                color: AppColors.primaryText,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSizes.p6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.location_copy,
                          size: AppSizes.p14, color: AppColors.subText),
                      const SizedBox(width: AppSizes.p4),
                      Expanded(
                        child: Text(
                          editStoreController.storeAddress.value.isNotEmpty
                              ? editStoreController.storeAddress.value
                              : TTexts.profileNoAddress.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppSizes.p12,
                            color: AppColors.subText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Row(
                    children: [
                      const Icon(Iconsax.profile_2user_copy,
                          size: AppSizes.p14, color: AppColors.subText),
                      const SizedBox(width: AppSizes.p4),
                      Text(
                        "${editStoreController.memberCount.value} ${TTexts.profileMembers.tr}",
                        style: const TextStyle(
                          fontSize: AppSizes.p12,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: isOwner
                ? IconButton(
                    onPressed: () {
                      Get.dialog(
                        const TEditStoreCustomDialogWidgets(),
                        barrierDismissible: false,
                      );
                    },
                    icon: const Icon(Iconsax.edit_2_copy,
                        color: AppColors.primary, size: AppSizes.p20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius8),
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
