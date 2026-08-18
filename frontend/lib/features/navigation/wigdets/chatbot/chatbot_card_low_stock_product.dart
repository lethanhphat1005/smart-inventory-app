import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
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

    // final displayName =
    //     pkg['displayName'] ?? product?['name'] ?? TTexts.unknownProduct.tr;
    final displayName = DisplayNameUtils.getFullPackageDisplayNameFromJson(pkg);
    final quantity = (itemData['quantity'] ?? pkg['quantity'] ?? 0) as num;
    final unitName = pkg['unit']?['name'] ?? '';

    final threshold = (int.tryParse(
              itemData['reorder_threshold']?.toString() ??
                  itemData['reorderThreshold']?.toString() ??
                  '10',
            ) ??
            10)
        .toDouble();

    final String rawUrl = product?['imageUrl']?.toString() ??
        pkg?['imageUrl']?.toString() ??
        itemData['imageUrl']?.toString() ??
        '';
    final String finalImageUrl = UrlHelperUtils.normalizeImageUrl(rawUrl) ?? '';

    final productId = product?['productId'] ?? pkg['productId'];
    final packageId = pkg['productPackageId'];
    final barcode = pkg['barcodeValue'] ?? '';

    // Progress ratio: tồn kho / ngưỡng tối đa ước tính (2× threshold = đầy đủ)
    final double maxExpected = threshold * 2;
    final double ratio = (quantity.toDouble() / maxExpected).clamp(0.0, 1.0);

    Color stockColor;
    String stockText;
    IconData stockIcon;

    if (quantity == 0) {
      stockColor = AppColors.stockOut;
      stockText = TTexts.chatbotOutOfStock.tr;
      stockIcon = Iconsax.close_circle;
    } else if (quantity <= threshold) {
      stockColor = AppColors.primary;
      stockText = '${quantity.toInt()} / ${threshold.toInt()} $unitName'.trim();
      stockIcon = Iconsax.warning_2;
    } else {
      stockColor = AppColors.stockIn;
      stockText =
          '${TTexts.chatbotLeftPrefix.tr} ${quantity.toInt()} $unitName'.trim();
      stockIcon = Iconsax.tick_circle;
    }

    return GestureDetector(
      onTap: () {
        if (productId != null) {
          Get.toNamed(
            AppRoutes.inventoryDetail,
            arguments: productId,
            parameters: {
              'packageId': packageId?.toString() ?? '',
              'barcode': barcode?.toString() ?? '',
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 52,
                height: 52,
                color: const Color(0xFFF4F5F7),
                child: finalImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: finalImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // Info + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Stock badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: stockColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(stockIcon, size: 12, color: stockColor),
                            const SizedBox(width: 4),
                            Text(
                              stockText,
                              style: TextStyle(
                                color: stockColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 4,
                            backgroundColor: Colors.grey.shade100,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(stockColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() => const TNoImageWidget(iconSize: 24);
}
