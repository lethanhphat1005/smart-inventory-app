import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog/product_catalog_action_menu_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog/product_catalog_category_list_item_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog/product_catalog_search_bar_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog/product_catalog_add_category_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog/product_catalog_view_all_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';

class ProductCatalogMobileView extends GetView<ProductCatalogController> {
  const ProductCatalogMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tính toán độ cao của màn hình + AppBar để đẩy UI xuống
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.categoryCatalog.tr,
        showBackArrow: true,
        actions: const [
          ProductCatalogActionMenuWidget(),
        ],
      ),
      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.refreshCategories(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: topOffset + 16),
            ),

            // 1. THANH SEARCH
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
              sliver: SliverToBoxAdapter(
                child: ProductCatalogSearchBarWidget(),
              ),
            ),

            // 2. BỘ ĐẾM SỐ LƯỢNG
            Obx(() {
              if (controller.isLoading) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 16, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "${TTexts.totalCategories.tr}: ${controller.totalCategories} ${TTexts.categoriesUnit.tr}",
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.softGrey,
                    ),
                  ),
                ),
              );
            }),

            // 3. DANH SÁCH HOẶC SHIMMER
            Obx(() {
              if (controller.isLoading) return _buildSliverShimmerList();

              final groupedData = controller.groupedCategories;

              return SliverMainAxisGroup(
                slivers: [
                  // THÊM VÀO ĐÂY: ITEM "VIEW ALL PRODUCTS" (Luôn hiện ở đầu nếu không search)
                  if (controller.searchQuery.value.isEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      sliver: SliverToBoxAdapter(
                        child: ProductCatalogViewAllWidget(
                          onTap: () => controller.goToAllProducts(),
                        ),
                      ),
                    ),

                  // ITEM "ADD NEW CATEGORY" (Giữ nguyên của bạn)
                  if (controller.canManageCategory &&
                      controller.searchQuery.value.isEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      sliver: SliverToBoxAdapter(
                        child: ProductCatalogAddCategoryWidget(
                          onTap: () => controller.addNewCategory(),
                        ),
                      ),
                    ),

                  // EMPTY STATE
                  if (groupedData.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: TEmptyStateWidget(
                        icon: Iconsax.box_search_copy,
                        title: TTexts.noCategoriesFound.tr,
                        subtitle: TTexts.emptyCategoryMessage.tr,
                      ),
                    )

                  // DANH SÁCH ALPHABET
                  else
                    ...groupedData.entries.map((entry) {
                      final String letter = entry.key;
                      final items = entry.value;

                      return SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 12, left: 24, right: 24),
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontFamily: AppFonts.mainFont,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p20),
                            sliver: SliverList.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                int indexInAll =
                                    _getGlobalIndex(groupedData, letter, index);
                                return ProductCatalogCategoryListItemWidget(
                                  category: items[index],
                                  index: indexInAll,
                                  onTap: () => controller
                                      .goToCategoryDetail(items[index]),
                                );
                              },
                            ),
                          ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: AppSizes.p8)),
                        ],
                      );
                    }),
                ],
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
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 16),
      sliver: SliverList.builder(
        itemCount: 8,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.p12),
          child: TFormSkeletonWidget(),
        ),
      ),
    );
  }

  int _getGlobalIndex(
      Map<String, List> grouped, String currentLetter, int itemIndex) {
    int total = 0;
    for (var entry in grouped.entries) {
      if (entry.key == currentLetter) break;
      total += entry.value.length;
    }
    return total + itemIndex;
  }
}
