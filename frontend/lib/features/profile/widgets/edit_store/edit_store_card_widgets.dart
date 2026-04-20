import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_edit_custom_dialog_widgets.dart/t_edit_store_custom_dialog_widgets.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';

class EditStoreCardWidgets extends StatelessWidget {
  const EditStoreCardWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    final editStoreController = Get.isRegistered<ProfileEditStoreController>()
        ? Get.find<ProfileEditStoreController>()
        : Get.put(ProfileEditStoreController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.editStoreCurrentStore.tr,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ICON BOX
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFE7D1),
                          Color(0xFFFFD3A8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Iconsax.shop_copy,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NAME
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.storeName.value.isNotEmpty
                                    ? controller.storeName.value
                                    : 'Store name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ADDRESS
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Iconsax.location_copy,
                                size: 15,
                                color: AppColors.subText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                editStoreController
                                        .storeAddress.value.isNotEmpty
                                    ? editStoreController.storeAddress.value
                                    : "Chưa có địa chỉ",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: AppColors.subText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // MEMBERS
                        Row(
                          children: [
                            const Icon(
                              Iconsax.profile_2user_copy,
                              size: 15,
                              color: AppColors.subText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${editStoreController.memberCount.value} members",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // EDIT BUTTON
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Get.dialog(
                                const TEditStoreCustomDialogWidgets(),
                                barrierDismissible: false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.edit_2_copy,
                                    size: 14,
                                    color: AppColors.whiteText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    TTexts.editStoreBtnEdit.tr,
                                    style: const TextStyle(
                                      color: AppColors.whiteText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
