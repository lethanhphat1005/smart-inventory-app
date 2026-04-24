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
              fontSize: AppSizes.p18,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          Obx(
            () {
              final isOwner =
                  editStoreController.currentUserStoreRole.value == 'owner';

              return Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppSizes.p1_2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: AppSizes.p18,
                      offset: const Offset(0, AppSizes.p8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON BOX
                    Container(
                      width: AppSizes.p56,
                      height: AppSizes.p56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radius18),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.lightOrange,
                            AppColors.lightOrangeGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Iconsax.shop_copy,
                        color: AppColors.primary,
                        size: AppSizes.p28,
                      ),
                    ),

                    const SizedBox(width: AppSizes.p14),

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
                                      : TTexts.profileStoreName.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: AppSizes.p17,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.p10),

                          // ADDRESS
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: AppSizes.p2),
                                child: Icon(
                                  Iconsax.location_copy,
                                  size: AppSizes.p15,
                                  color: AppColors.subText,
                                ),
                              ),
                              const SizedBox(width: AppSizes.p8),
                              Expanded(
                                child: Text(
                                  editStoreController
                                          .storeAddress.value.isNotEmpty
                                      ? editStoreController.storeAddress.value
                                      : TTexts.profileNoAddress.tr,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: AppSizes.p13,
                                    height: 1.45,
                                    color: AppColors.subText,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.p8),

                          // MEMBERS
                          Row(
                            children: [
                              const Icon(
                                Iconsax.profile_2user_copy,
                                size: AppSizes.p15,
                                color: AppColors.subText,
                              ),
                              const SizedBox(width: AppSizes.p8),
                              Text(
                                "${editStoreController.memberCount.value} ${TTexts.profileMembers.tr}",
                                style: const TextStyle(
                                  fontSize: AppSizes.p13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.p14),

                          // EDIT BUTTON
                          if (isOwner)
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
                                    horizontal: AppSizes.p14,
                                    vertical: AppSizes.p8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.18),
                                        blurRadius: AppSizes.p12,
                                        offset: const Offset(0, AppSizes.p4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Iconsax.edit_2_copy,
                                        size: AppSizes.p14,
                                        color: AppColors.whiteText,
                                      ),
                                      const SizedBox(width: AppSizes.p6),
                                      Text(
                                        TTexts.editStoreBtnEdit.tr,
                                        style: const TextStyle(
                                          color: AppColors.whiteText,
                                          fontSize: AppSizes.p13,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
