import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';

class ProfileStoreCardWidget extends StatelessWidget {
  const ProfileStoreCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: controller.goToEditStoreProfile,
            borderRadius: BorderRadius.circular(AppSizes.radius20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius20),
                border: Border.all(
                  color: AppColors.gradientOrangeStart.withOpacity(0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryText.withOpacity(0.05),
                    blurRadius: AppSizes.p16,
                    offset: const Offset(0, AppSizes.p8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CURRENT STORE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSizes.p52,
                        height: AppSizes.p52,
                        decoration: BoxDecoration(
                          color:
                              AppColors.gradientOrangeStart.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius16),
                        ),
                        child: const Icon(
                          Iconsax.shop_copy,
                          color: AppColors.primary,
                          size: AppSizes.p24,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TTexts.editStoreCurrentStore.tr,
                              style: const TextStyle(
                                fontSize: AppSizes.p12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gradientOrangeStart,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p6),
                            Obx(
                              () => Text(
                                controller.storeName.value.isEmpty
                                    ? TTexts.profileStoreName.tr
                                    : controller.storeName.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: AppSizes.p16,
                                  color: AppColors.primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p4),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Container(
                        width: AppSizes.p36,
                        height: AppSizes.p36,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.arrow_right_3_copy,
                          size: AppSizes.p16,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.p12),

                  /// SWITCH STORE
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: controller.goToStoreSelect,
                      borderRadius: BorderRadius.circular(AppSizes.radius14),
                      child: Container(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.p12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.gradientOrangeStart.withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius14),
                          border: Border.all(
                            color:
                                AppColors.gradientOrangeStart.withOpacity(0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.refresh_copy,
                              color: AppColors.primary,
                              size: AppSizes.p16,
                            ),
                            const SizedBox(width: AppSizes.p6),
                            Text(
                              TTexts.profileBtnSwitchStore.tr,
                              style: const TextStyle(
                                color: AppColors.primary,
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
          ),
        ],
      ),
    );
  }
}
