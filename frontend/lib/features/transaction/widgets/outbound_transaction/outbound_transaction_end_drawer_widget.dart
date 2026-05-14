import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class OutboundTransactionEndDrawerWidget
    extends GetView<OutboundTransactionController> {
  const OutboundTransactionEndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: Get.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(TTexts.options.tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back()),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // --- RECENT ---
                  Obx(() {
                    if (controller.drawerRecentItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(TTexts.recentOutboundItems.tr),
                        ...controller.drawerRecentItems
                            .map((item) => _buildCompactItem(item)),
                      ],
                    );
                  }),

                  // --- PRIORITY (Low stock warning) ---
                  const SizedBox(height: 16),
                  _buildSectionTitle(TTexts.lowStockPriority.tr),
                  Obx(() => Column(
                        children: controller.drawerPriorityItems
                            .map((item) => _buildCompactItem(item))
                            .toList(),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.subText)),
    );
  }

  Widget _buildCompactItem(InventoryModel item) {
    final pkgId = item.productPackageId.isNotEmpty
        ? item.productPackageId
        : item.productPackage?.productPackageId ?? '';
    final name = item.productPackage?.displayName ?? TTexts.product.tr;
    final imageUrl = item.productPackage?.product?.imageUrl;
    final stock = item.quantity;

    return Obx(() {
      final currentQty = controller.getItemQuantity(pkgId);
      final bool canAdd = stock > currentQty;

      return InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.outboundTransactionItemAdd, arguments: {
            'displayItem': InventoryInsightDisplayModel(
                product: item.productPackage?.product, inventory: item),
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.divider.withOpacity(0.3), width: 0.5))),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: UrlHelperUtils.normalizeImageUrl(imageUrl)!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const TNoImageWidget(width: 44, height: 44))
                      : const TNoImageWidget(width: 44, height: 44),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${TTexts.labelStock.tr}: $stock',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subText)),
                  ],
                ),
              ),
              _buildMiniSelector(pkgId, currentQty, item, canAdd),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMiniSelector(
      String pkgId, int currentQty, InventoryModel item, bool canAdd) {
    if (currentQty <= 0) {
      return GestureDetector(
        onTap: canAdd
            ? () => controller.addToCart({
                  'productPackageId': pkgId,
                  'packageInfo': item.productPackage,
                  'sellingPrice': item.productPackage?.sellingPrice ?? 0.0,
                  'currentStock': item.quantity,
                }, quantity: 1)
            : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: (canAdd ? AppColors.primary : AppColors.softGrey)
                  .withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(Icons.add,
              size: 18, color: canAdd ? AppColors.primary : AppColors.softGrey),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniBtn(Icons.remove,
              () => controller.updateItemQuantity(pkgId, currentQty - 1)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$currentQty',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary))),
          _buildMiniBtn(
              Icons.add,
              canAdd
                  ? () => controller.addToCart({
                        'productPackageId': pkgId,
                        'packageInfo': item.productPackage,
                        'sellingPrice':
                            item.productPackage?.sellingPrice ?? 0.0,
                        'currentStock': item.quantity,
                      }, quantity: 1)
                  : null),
        ],
      ),
    );
  }

  Widget _buildMiniBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon,
              size: 16,
              color: onTap != null ? AppColors.primary : AppColors.softGrey)),
    );
  }
}
