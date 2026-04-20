import 'package:flutter/material.dart';
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
                        Text(
                          controller.rxName.value,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${TTexts.brand.tr}: ${controller.rxBrand.value.isNotEmpty ? controller.rxBrand.value : TTexts.na.tr}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.subText),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.divider),
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
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17,
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
                                  fontSize: 13,
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
