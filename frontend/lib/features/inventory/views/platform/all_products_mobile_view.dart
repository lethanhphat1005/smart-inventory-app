import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_expandable_fab_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';

import 'package:frontend/features/inventory/controllers/all_products_controller.dart';
// Các component nội bộ
import 'package:frontend/features/inventory/widgets/all_products/all_products_search_bar_widget.dart';
import 'package:frontend/features/inventory/widgets/all_products/all_products_category_chip_widget.dart';
// Component tái sử dụng
import 'package:frontend/features/inventory/widgets/shared/inventory_category_detail_product_item_widget.dart';

class AllProductsMobileView extends GetView<AllProductsController> {
  const AllProductsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.viewAllProducts.tr,
        showBackArrow: true,
      ),
      floatingActionButton: TExpandableFabWidget(
          isStaffMode: !controller.canManageProduct,
          onManualAdd: () {
            Get.toNamed(AppRoutes.productForm)?.then((_) {
              controller.refreshData();
            });
          },
          onScanAdd: () {
            Get.to(() => const TBarcodeScannerLayout())?.then((_) {
              controller.refreshData();
            });
          }),
      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchData(isRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topOffset + 16)),

            // 1. THANH SEARCH
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
              sliver: SliverToBoxAdapter(child: AllProductsSearchBarWidget()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.p16)),

            // 2. THANH CATEGORY CHIP (Kiểu Youtube)
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return const SliverToBoxAdapter(
                  child: AllProductsCategoryChipWidget());
            }),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.p8)),

            // 3. BỘ ĐẾM
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final count = controller.filteredProducts.length;
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p24, vertical: AppSizes.p8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "${TTexts.totalActiveProducts.tr}: $count ${TTexts.items.tr}",
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subText,
                    ),
                  ),
                ),
              );
            }),

            // 4. DANH SÁCH SẢN PHẨM / EMPTY STATE
            Obx(() {
              if (controller.isLoading.value) {
                return _buildSliverShimmerList();
              }

              final productsList = controller.filteredProducts;

              if (productsList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: TEmptyStateWidget(
                    icon: Iconsax.box_remove_copy,
                    title: TTexts.noProductsFound.tr,
                    subtitle: controller.searchQuery.value.isNotEmpty
                        ? TTexts.noResultsMessage.tr
                        : TTexts.noProductsAssigned.tr,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                sliver: SliverList.builder(
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    final product = productsList[index];
                    return InventoryCategoryDetailProductItemWidget(
                      product: product,
                      onTap: () => controller.goToProductDetail(product),
                    );
                  },
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverShimmerList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      sliver: SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.p12),
          child: TFormSkeletonWidget(),
        ),
      ),
    );
  }
}
