import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/transaction/controllers/outbound_product_selection_controller.dart';
import 'package:frontend/features/transaction/widgets/inbound_product_selection/inbound_product_selection_shimmer_widget.dart'; // Dùng chung shimmer
import 'package:frontend/features/transaction/widgets/outbound_product_selection/outbound_product_selection_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/outbound_product_selection/outbound_product_selection_cart_bottom_sheet_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_category_chip_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_standard_search_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_cart_item_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class OutboundProductSelectionMobileView
    extends GetView<OutboundProductSelectionController> {
  const OutboundProductSelectionMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: TAppBarWidget(
          title: TTexts.selectProductsTitle.tr,
          showBackArrow: true,
          onBackPress: controller.handleBack,
        ),
        body: RefreshIndicator(
          edgeOffset: topOffset,
          color: AppColors.primary,
          onRefresh: () => controller.fetchProducts(isRefresh: true),
          child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topOffset + 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: Obx(() => AbsorbPointer(
                        absorbing: controller.isInitialLoading.value,
                        child: TransactionStandardSearchBarWidget(
                          hintText: TTexts.searchStandardHint.tr,
                          controller: controller.searchController,
                          onChanged: controller.searchProduct,
                        ),
                      )),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Obx(() => AbsorbPointer(
                        absorbing: controller.isInitialLoading.value,
                        child: TransactionCategoryChipWidget(
                          categories: controller.categoryList.toList(),
                          activeCategory: controller.activeCategory.value,
                          onCategorySelected: controller.setCategory,
                        ),
                      )),
                ),
              ),
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                      child: InboundProductSelectionShimmerWidget());
                }
                if (controller.allItems.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: TEmptyStateWidget(
                      icon: Iconsax.box_search_copy,
                      title: TTexts.noItemsFound.tr,
                      subtitle: TTexts.noItemsFoundDesc.tr,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.p20, 0, AppSizes.p20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == controller.allItems.length) {
                          return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary)));
                        }

                        final item = controller.allItems[index];
                        final pkgId = item.productPackage?.productPackageId ??
                            item.productPackageId;

                        return Obx(() {
                          final qty = controller.getQtyInDraft(pkgId);

                          String? bText;
                          Color? bColor;
                          if (item.quantity <= 0) {
                            bText = 'OUT';
                            bColor = AppColors.stockOut;
                          } else if (item.quantity <= (item.reorderThreshold)) {
                            bText = 'LOW';
                            bColor = Colors.orange;
                          }

                          final detail = TransactionDetailModel(
                            productPackageId: pkgId,
                            quantity: qty,
                            unitPrice: item.productPackage?.sellingPrice ?? 0.0,
                            currentStock: item.quantity,
                            reorderThreshold: item.reorderThreshold,
                            packageInfo: item.productPackage,
                          );

                          return TransactionCartItemWidget(
                            key: ValueKey('selection_out_$pkgId'),
                            item: detail,
                            isOutbound: true, // BẬT CỜ XUẤT KHO
                            imageUrl: item.productPackage?.product?.imageUrl,
                            stockBadgeText: bText,
                            stockBadgeColor: bColor,
                            onTap: () => controller.navigateToDetail(item),
                            onIncrease: () => controller.increaseItem(item),
                            onDecrease: () => controller.decreaseItem(item),
                            onQuantityChanged: (val) =>
                                controller.updateQuantity(item, val),
                            onDelete: () => controller.updateQuantity(item, 0),
                          );
                        });
                      },
                      childCount: controller.allItems.length +
                          (controller.isFetchingMore.value ? 1 : 0),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => OutboundProductSelectionBottomBarWidget(
              totalItems: controller.totalDraftItems,
              totalPrice: controller.totalDraftPrice,
              onCartTap: () => Get.bottomSheet(
                  const OutboundProductSelectionCartBottomSheetWidget(),
                  isScrollControlled: true),
              onConfirm: controller.confirmAndAddToMainCart,
            )),
      ),
    );
  }
}
