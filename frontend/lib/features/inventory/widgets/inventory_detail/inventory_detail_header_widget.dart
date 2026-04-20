import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_action_menu_widget.dart';

class InventoryDetailHeaderWidget extends GetView<InventoryDetailController> {
  const InventoryDetailHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: AppColors.background.withOpacity(0.7),
      elevation: 0,
      leadingWidth: 64,
      leading: InkWell(
        onTap: () => controller.goBack(),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.arrow_left_2_copy,
                color: AppColors.primaryText, size: 20),
          ],
        ),
      ),
      actions: const [
        InventoryDetailActionMenuWidget(),
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
              child: Hero(
                tag:
                    'hero_image_${controller.barcode}_${controller.currentDisplayItem.value?.product?.productId ?? ""}',
                child: controller.imageUrl != null &&
                        controller.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: controller.imageUrl!,
                        fit: BoxFit.contain,
                        // Hiển thị vòng xoay loading nhỏ xíu trong lúc đợi tải ảnh
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                        ),
                        // Nếu link ảnh tèo (lỗi 404, lỗi mạng) thì ném ra cái hình No Image
                        errorWidget: (context, url, error) {
                          return const TNoImageWidget(
                              iconSize: 64, borderRadius: 0);
                        },
                      )
                    : const TNoImageWidget(iconSize: 64, borderRadius: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
