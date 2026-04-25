import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog_detail/product_catalog_detail_action_menu_widget.dart';

class ProductCatalogDetailHeaderWidget
    extends GetView<ProductCatalogDetailController> {
  const ProductCatalogDetailHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: AppColors.background.withOpacity(0.7),
      elevation: 0,
      leadingWidth: 64,
      leading: InkWell(
        onTap: () => Get.back(),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.arrow_left_2_copy,
                color: AppColors.primaryText, size: 20)
          ],
        ),
      ),
      actions: const [
        ProductCatalogDetailActionMenuWidget(),
        SizedBox(width: AppSizes.p12),
      ],
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            background: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  bottom: AppSizes.p24),
              child: Obx(() {
                final imageUrl = controller.rxImageUrl.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: 'hero_image_catalog_${controller.product.productId}',
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const TNoImageWidget(
                                      iconSize: 64, borderRadius: 0),
                            )
                          : const TNoImageWidget(iconSize: 64, borderRadius: 0),
                    ),
                    if (controller.canManageProduct)
                      Positioned(
                        bottom: 0,
                        right: 24,
                        child: GestureDetector(
                          onTap: () => controller.editProductImage(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondPrimary
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: const Icon(Iconsax.camera_copy,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
