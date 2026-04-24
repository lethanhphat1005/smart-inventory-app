import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/workspace/controllers/store_selection_controller.dart';
import 'package:frontend/features/workspace/widgets/store_selection/store_selection_action_buttons_widget.dart';
import 'package:frontend/features/workspace/widgets/store_selection/store_selection_card_widget.dart';
import 'package:frontend/features/workspace/widgets/store_selection/store_selection_skeleton_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:shimmer/shimmer.dart';

class StoreSelectionMobileView extends GetView<StoreSelectionController> {
  const StoreSelectionMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: TRefreshIndicatorWidget(
          onRefresh: controller.refreshStores,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // --- PHẦN 1: HEADER ---
              SliverPadding(
                padding: const EdgeInsets.only(
                    top: AppSizes.p48,
                    left: AppSizes.p24,
                    right: AppSizes.p24,
                    bottom: AppSizes.p32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TTexts.workspaceSelectionTitle.tr,
                        style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        TTexts.workspaceSelectionSubtitle.tr,
                        style: const TextStyle(
                            color: AppColors.subText,
                            fontSize: 16,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              // --- PHẦN 2: DANH SÁCH THẺ ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                sliver: SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Shimmer.fromColors(
                        baseColor: AppColors.softGrey.withOpacity(0.1),
                        highlightColor: AppColors.white,
                        child: Column(
                          children: List.generate(
                            3,
                            (index) => const StoreSelectionSkeletonWidget(),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...controller.stores.map((store) {
                          final roleLowerCase = store.role.toLowerCase();

                          String roleText = TTexts.roleStaff.tr;
                          IconData roleIcon = Iconsax.user_octagon_copy;
                          Color roleColor = AppColors.toastSuccessGradientStart;

                          if (roleLowerCase == 'owner') {
                            roleText = TTexts.roleOwner.tr;
                            roleIcon = Iconsax.crown_1_copy;
                            roleColor = AppColors.primary;
                          } else if (roleLowerCase == 'manager') {
                            roleText = TTexts.roleManager.tr;
                            roleIcon = Iconsax.security_user_copy;
                            roleColor = AppColors.toastWarningGradientEnd;
                          }

                          final bool isActive =
                              controller.currentStoreId.isNotEmpty &&
                                  store.storeId == controller.currentStoreId;

                          return StoreSelectionCardWidget(
                            title: store.name,
                            role: roleText,
                            icon: roleIcon,
                            iconColor: roleColor,
                            isActive: isActive, // Truyền isActive vào Card
                            onTap: () => controller.selectStore(store),
                          );
                        }),

                        const SizedBox(height: AppSizes.p8),

                        // --- THẺ REQUEST ACCESS ---
                        Material(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: controller.goToJoinStore,
                            splashColor: AppColors.primary.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.p20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.softGrey.withOpacity(0.2)),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radius16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSizes.p12),
                                    decoration: const BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle),
                                    child: const Icon(Iconsax.scan_barcode_copy,
                                        color: AppColors.softGrey),
                                  ),
                                  const SizedBox(width: AppSizes.p16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          TTexts.requestAccess.tr,
                                          style: const TextStyle(
                                              color: AppColors.primaryText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: AppSizes.p4),
                                        Text(
                                          TTexts.requestAccessDesc.tr,
                                          style: const TextStyle(
                                              color: AppColors.subText,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // --- PHẦN 3: ACTION BUTTONS ---
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSizes.p24,
                      right: AppSizes.p24,
                      bottom: AppSizes.p24,
                      top: AppSizes.p24,
                    ),
                    child: StoreSelectionActionButtonsWidget(
                      onJoinTap: controller.showHelpBottomSheet,
                      onCreateTap: controller.goToCreateStore,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
