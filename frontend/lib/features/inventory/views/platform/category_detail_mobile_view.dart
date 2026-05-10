import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/inventory/widgets/category_detail/category_detail_action_menu_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_category_detail_product_item_widget.dart';
import 'package:frontend/features/inventory/widgets/category_detail/category_detail_add_product_widget.dart'; // Import widget thêm SP

class CategoryDetailMobileView extends GetView<CategoryDetailController> {
  const CategoryDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        titleWidget: Obx(() => Text(
              controller.rxCategory.value.name,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.mainFont,
              ),
            )),
        showBackArrow: true,
        actions: const [CategoryDetailActionMenuWidget()],
      ),
      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchProducts(isRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topOffset + 16)),

            // 1. HEADER: Thông tin Category
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p20, vertical: AppSizes.p8),
              sliver: SliverToBoxAdapter(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.rxCategory.value.name,
                          style: TextStyle(
                              fontFamily: AppFonts.mainFont,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // Kiểm tra rỗng chuẩn xác
                          (controller.rxCategory.value.description != null &&
                                  controller
                                      .rxCategory.value.description!.isNotEmpty)
                              ? controller.rxCategory.value.description!
                              : TTexts.noCategoryDescription.tr,
                          style: TextStyle(
                              fontFamily: AppFonts.mainFont,
                              fontSize: 12,
                              height: 1.5,
                              color: AppColors.subText),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 8),
                      ],
                    )),
              ),
            ),
            // 2. MAIN CONTENT
            Obx(() {
              if (controller.isLoading.value) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  sliver: SliverList.builder(
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.p12),
                      child: TFormSkeletonWidget(),
                    ),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  // NÚT THÊM SẢN PHẨM MỚI (CHỈ MANAGER THẤY)
                  if (controller.canManageProduct)
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      sliver: SliverToBoxAdapter(
                        child: CategoryDetailAddProductWidget(
                          onTap: () => controller.addNewProduct(),
                        ),
                      ),
                    ),

                  // TRẠNG THÁI TRỐNG SẢN PHẨM
                  if (controller.products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: TEmptyStateWidget(
                        icon: Iconsax.box_remove_copy,
                        title: TTexts.noProductsFound.tr,
                        subtitle: TTexts.noProductsAssigned.tr,
                      ),
                    )
                  // DANH SÁCH SẢN PHẨM
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      sliver: SliverList.builder(
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          final product = controller.products[index];
                          return InventoryCategoryDetailProductItemWidget(
                            product: product,
                            onTap: () => controller.goToProductDetail(product),
                          );
                        },
                      ),
                    ),
                ],
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
