import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class InboundTransactionEndDrawerWidget
    extends GetView<InboundTransactionController> {
  const InboundTransactionEndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
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
                      style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
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
                  // NÚT THÊM TẤT CẢ ƯU TIÊN CÓ XÁC NHẬN
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TPrimaryButtonWidget(
                      text: TTexts.addAllPriority.tr,
                      backgroundColor: AppColors.primaryText,
                      onPressed: () => controller.confirmAddAllPriority(),
                      height: 46,
                      fontSize: 14,
                    ),
                  ),

                  // ===================================
                  // HOẠT ĐỘNG GẦN ĐÂY (Tự ẩn nếu rỗng)
                  // ===================================
                  Obx(() {
                    if (controller.drawerRecentItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildSectionTitle(TTexts.recentActivities.tr),
                        ...controller.drawerRecentItems
                            .map((item) => _buildCompactItem(item)),
                      ],
                    );
                  }),

                  // ===================================
                  // DANH SÁCH ƯU TIÊN
                  // ===================================
                  const SizedBox(height: 16),
                  _buildSectionTitle(TTexts.priorityList.tr),
                  Obx(() {
                    if (controller.drawerPriorityItems.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(TTexts.stableInventoryMsg.tr,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.subText,
                                fontStyle: FontStyle.italic)),
                      );
                    }
                    return Column(
                      children: controller.drawerPriorityItems
                          .map((item) => _buildCompactItem(item))
                          .toList(),
                    );
                  }),
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
              color: AppColors.subText,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildCompactItem(InventoryModel item) {
    final pkgId = item.productPackageId.isNotEmpty
        ? item.productPackageId
        : item.productPackage?.productPackageId ?? '';
    // final name = item.productPackage?.displayName ?? TTexts.product.tr;
    final name =
        DisplayNameUtils.getFullPackageDisplayName(item.productPackage);
    final imageUrl = item.productPackage?.product?.imageUrl;
    final stock = item.quantity;

    return Obx(() {
      final currentQty = controller.getItemQuantity(pkgId);

      return InkWell(
        onTap: () {
          // BẤM VÀO THÂN ITEM MỞ CHI TIẾT
          Get.toNamed(AppRoutes.inboundTransactionItemAdd, arguments: {
            'displayItem': InventoryInsightDisplayModel(
                product: item.productPackage?.product, inventory: item),
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: AppColors.divider.withOpacity(0.3), width: 0.5)),
          ),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText)),
                    const SizedBox(height: 2),
                    Text('${TTexts.labelStock.tr}: $stock',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subText)),
                  ],
                ),
              ),

              // LOGIC BỘ ĐẾM SỐ LƯỢNG
              _buildMiniSelector(pkgId, currentQty, item),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMiniSelector(String pkgId, int currentQty, InventoryModel item) {
    if (currentQty <= 0) {
      // NẾU CHƯA CÓ TRONG GIỎ: Chỉ hiện 1 nút cộng hình tròn
      return InkWell(
        onTap: () => controller.addToCart({
          'productPackageId': pkgId,
          'packageInfo': item.productPackage,
          'importPrice': item.productPackage?.importPrice ?? 0.0,
          'currentStock': item.quantity,
          'reorderThreshold': item.reorderThreshold,
        }, quantity: 1),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 18, color: AppColors.primary),
        ),
      );
    }

    // NẾU ĐÃ CÓ TRONG GIỎ: Hiện bộ "- Số lượng +"
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
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
                    color: AppColors.primary)),
          ),
          _buildMiniBtn(
              Icons.add,
              () => controller.addToCart({
                    'productPackageId': pkgId,
                    'packageInfo': item.productPackage,
                    'importPrice': item.productPackage?.importPrice ?? 0.0,
                    'currentStock': item.quantity,
                    'reorderThreshold': item.reorderThreshold,
                  }, quantity: 1)),
        ],
      ),
    );
  }

  Widget _buildMiniBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
