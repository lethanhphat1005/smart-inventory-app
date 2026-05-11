import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
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
        pkg['displayName'] ?? product?['name'] ?? TTexts.unknownProduct.tr;
    final quantity = (itemData['quantity'] ?? pkg['quantity'] ?? 0) as int;
    final unitName = pkg['unit']?['name'] ?? '';

    final threshold =
        int.tryParse(itemData['reorder_threshold']?.toString() ?? '20') ?? 20;

    final String rawUrl =
        product?['imageUrl']?.toString() ?? pkg?['imageUrl']?.toString() ?? '';
    final String finalImageUrl = UrlHelperUtils.normalizeImageUrl(rawUrl) ?? '';

    final productId = product?['productId'] ?? pkg['productId'];
    final packageId = pkg['productPackageId'];
    final barcode = pkg['barcodeValue'] ?? '';

    double progress = threshold > 0 ? quantity / threshold : 0.0;
    if (progress > 1.0) progress = 1.0;

    return GestureDetector(
      onTap: () {
        if (productId != null) {
          Get.toNamed(AppRoutes.inventoryDetail,
              arguments: productId,
              parameters: {
                'packageId': packageId?.toString() ?? '',
                'barcode': barcode?.toString() ?? ''
              });
        }
      },
      child: Container(
        width: Get.width * 0.82,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: finalImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: finalImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder())
                    : _buildImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppColors.primaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFAEEDA),
                            borderRadius: BorderRadius.circular(100)),
                        child: Text("$quantity / $threshold $unitName",
                            style: const TextStyle(
                                color: Color(0xFF854F0B),
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFEF9F27)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey.shade400)
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() => const TNoImageWidget(iconSize: 20);
}
