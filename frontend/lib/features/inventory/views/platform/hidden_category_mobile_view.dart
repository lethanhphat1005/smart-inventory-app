import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/inventory/controllers/hidden_category_controller.dart';
import 'package:frontend/features/inventory/widgets/hidden_category/hidden_category_list_item_widget.dart';
import 'package:frontend/features/inventory/widgets/hidden_category/hidden_category_shimmer_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HiddenCategoryMobileView extends GetView<HiddenCategoryController> {
  const HiddenCategoryMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => TAppBarWidget(
              title: controller.isSelectMode.value
                  ? "${controller.selectedIds.length} ${TTexts.selected.tr}"
                  : TTexts.hiddenCategories.tr,
              showBackArrow: true,
              actions: [
                IconButton(
                  icon: Icon(
                      controller.isSelectMode.value
                          ? Icons.close
                          : Icons.checklist_rtl_rounded,
                      color: AppColors.primaryText),
                  onPressed: controller.toggleSelectMode,
                )
              ],
            )),
      ),

      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchHiddenCategories(),
        child: Obx(() {
          // Loading State
          if (controller.isLoading.value) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  EdgeInsets.only(top: topOffset + 16, left: 20, right: 20),
              itemCount: 8,
              itemBuilder: (_, __) => const HiddenCategoryShimmerWidget(),
            );
          }

          // Empty State
          if (controller.hiddenCategories.isEmpty) {
            return ListView(
              // Đảm bảo Pull-to-refresh luôn hoạt động dù màn hình trống
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: EdgeInsets.only(top: topOffset + 80),
              children: [
                TEmptyStateWidget(
                  icon: Iconsax.box_tick_copy,
                  title: TTexts.noHiddenCategories.tr,
                  subtitle: TTexts.noHiddenCategoriesDesc.tr,
                ),
              ],
            );
          }

          // 3. TRẠNG THÁI CÓ DỮ LIỆU
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: EdgeInsets.only(
                top: topOffset + 16, left: 20, right: 20, bottom: 100),
            itemCount: controller.hiddenCategories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final category = controller.hiddenCategories[index];
              return HiddenCategoryListItemWidget(
                category: category,
                index: index,
              );
            },
          );
        }),
      ),

      // Bottom Bar
      bottomNavigationBar: Obx(() => controller.selectedIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radius24)),
              ),
              child: SafeArea(
                child: TPrimaryButtonWidget(
                  text: TTexts.restoreSelected.tr,
                  onPressed: controller.confirmBatchRestore,
                ),
              ),
            )
          : const SizedBox.shrink()),
    );
  }
}
