import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:frontend/features/inventory/widgets/product_catalog_detail/product_catalog_detail_package_item_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog_detail/product_catalog_detail_header_widget.dart';

class ProductCatalogDetailMobileView
    extends GetView<ProductCatalogDetailController> {
  const ProductCatalogDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchPackages(isRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            const ProductCatalogDetailHeaderWidget(),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p20, vertical: AppSizes.p12),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TÊN SẢN PHẨM
                        Text(
                          controller.rxName.value,
                          style: TextStyle(
                              fontFamily: AppFonts.mainFont,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 12),

                        // HÀNG INFO CHIPS ĐỒNG BỘ
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Chip Danh mục
                            _buildInfoChip(
                              icon: Iconsax.category_2_copy,
                              label: controller.rxCategoryName.value,
                              color: AppColors.primary,
                            ),

                            // Chip Thương hiệu
                            _buildInfoChip(
                              icon: Iconsax.verify_copy,
                              label: controller.rxBrand.value.isNotEmpty
                                  ? controller.rxBrand.value
                                  : TTexts.na.tr,
                              color: AppColors.softGrey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: AppColors.divider, thickness: 0.5),
                      ],
                    )),
              ),
            ),

            // HEADER CỦA DANH SÁCH PACKAGES
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p20, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(TTexts.packagesOrVariants.tr,
                        style: TextStyle(
                            fontFamily: AppFonts.mainFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),

                    // NÚT ADD ĐÃ ĐƯỢC THAY BẰNG GRADIENT PILL BUTTON
                    if (controller.canManageProduct)
                      GestureDetector(
                        onTap: () => controller.addNewPackage(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            // SỬ DỤNG GRADIENT CAM CHUẨN CỦA APP
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.gradientOrangeStart,
                                AppColors.gradientOrangeEnd
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.add_circle_copy,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                TTexts.add.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // DANH SÁCH PACKAGES
            // (Tự động load Shimmer và hiện Data mới khi fetchPackages() chạy)
            Obx(() {
              if (controller.isLoadingPackages.value) {
                return _buildShimmerPackages();
              }

              if (controller.packages.isEmpty) {
                return SliverToBoxAdapter(
                  child: TEmptyStateWidget(
                    icon: Iconsax.box_remove_copy,
                    title: TTexts.noPackagesFound.tr,
                    subtitle: TTexts.addPackageSubtitle.tr,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p20, vertical: 12),
                sliver: SliverList.builder(
                  itemCount: controller.packages.length,
                  itemBuilder: (context, index) {
                    final currentPkg = controller.packages[index];
                    return ProductCatalogDetailPackageItemWidget(
                      package: currentPkg,
                      onEdit: () => controller.editPackage(currentPkg),
                      onDelete: () => controller.deletePackage(currentPkg),
                      onGoToInventory: () => controller.goToInventoryDetail(currentPkg),
                    );
                  },
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color == AppColors.softGrey ? AppColors.subText : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPackages() {
    return SliverPadding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 12),
      sliver: SliverList.builder(
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TFormSkeletonWidget(),
        ),
      ),
    );
  }
}
