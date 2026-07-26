import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:frontend/core/state/services/store_service.dart';

class EditStoreDeleteWidget extends GetView<ProfileEditStoreController> {
  const EditStoreDeleteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.trim().toLowerCase();

      if (role != 'owner') {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(
          //     bottom: AppSizes.p8,
          //     top: AppSizes.p32,
          //   ),
          //   child: Text(
          //     TTexts.deleteStoreTitle.tr.toUpperCase(),
          //     style: TextStyle(
          //       fontSize: AppSizes.p11,
          //       letterSpacing: 1.2,
          //       fontWeight: FontWeight.bold,
          //       color: AppColors.alertText.withOpacity(0.8),
          //     ),
          //   ),
          // ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              border: Border.all(
                color: AppColors.alertText.withOpacity(0.3),
              ),
            ),
            child: ListTile(
              onTap: () => controller.showDeleteConfirmDialog(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p4,
              ),
              leading: const Icon(
                Iconsax.trash,
                color: AppColors.alertText,
                size: AppSizes.p22,
              ),
              title: Text(
                TTexts.deleteStoreBtn.tr,
                style: const TextStyle(
                  fontSize: AppSizes.p13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.alertText,
                ),
              ),
              trailing: Icon(
                Iconsax.arrow_right_3_copy,
                size: AppSizes.p14,
                color: AppColors.alertText.withOpacity(0.5),
              ),
            ),
          ),
        ],
      );
    });
  }
}
