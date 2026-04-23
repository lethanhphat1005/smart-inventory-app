import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatCardLowStockProduct extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ChatCardLowStockProduct({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    final pkg = itemData['productPackage'] ?? itemData;
    final product = pkg['product'];

    final displayName =
        pkg['displayName'] ?? product?['name'] ?? 'Unknown product';
    final quantity = itemData['quantity'] ?? pkg['quantity'] ?? 0;
    final unitName = pkg['unit']?['name'] ?? '';

    // Quét threshold
    final threshold = int.tryParse(itemData['reorder_threshold']?.toString() ??
            itemData['reorderThreshold']?.toString() ??
            '10') ??
        10;

    // Quét ảnh
    final String rawUrl = product?['imageUrl']?.toString() ??
        pkg?['imageUrl']?.toString() ??
        itemData['imageUrl']?.toString() ??
        '';
    final String finalImageUrl = UrlHelperUtils.normalizeImageUrl(rawUrl) ?? '';

    final productId = product?['productId'] ?? pkg['productId'];
    final packageId = pkg['productPackageId'];
    final barcode = pkg['barcodeValue'] ?? '';

    // --- LOGIC 3 TRẠNG THÁI TỒN KHO ---
    Color stockColor;
    String stockText;

    if (quantity == 0) {
      stockColor = AppColors.stockOut; // Đỏ
      stockText = "Out of stock";
    } else if (quantity <= threshold) {
      stockColor = AppColors.primary; // Cam / Vàng
      stockText = "Low: $quantity $unitName".trim();
    } else {
      stockColor = AppColors.stockIn; // Xanh lá
      stockText = "Left: $quantity $unitName".trim();
    }

    return GestureDetector(
      onTap: () {
        if (productId != null) {
          Get.toNamed(AppRoutes.inventoryDetail,
              arguments: productId,
              parameters: {
                'packageId': packageId?.toString() ?? '',
                'barcode': barcode?.toString() ?? '',
              });
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE BOX ---
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: finalImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: finalImageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // --- TEXT DETAILS ---
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.primaryText,
                      height: 1.4,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // BADGE THEO 3 TRẠNG THÁI KHO
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.box, color: stockColor, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            stockText,
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const TNoImageWidget(iconSize: 32);
  }
}
