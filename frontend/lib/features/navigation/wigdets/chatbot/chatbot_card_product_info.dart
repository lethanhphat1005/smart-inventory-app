import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatCardProductInfo extends StatelessWidget {
  final ChatMessage message;

  const ChatCardProductInfo({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.data;
    if (data == null) return const SizedBox.shrink();

    final dynamic item = data is Map && data.containsKey('productPackage')
        ? data
        : (data['data'] ?? data);

    if (item == null || item['productPackage'] == null) {
      return const SizedBox.shrink();
    }

    final pkg = item['productPackage'];
    final product = pkg['product'];

    final displayName =
        pkg['displayName'] ?? product?['name'] ?? 'Unknown product';
    final quantity = item['quantity'] ?? pkg['quantity'] ?? 0;
    final unitName = pkg['unit']?['name'] ?? '';

    // Lấy Threshold từ mọi ngóc ngách
    final threshold = int.tryParse(item['reorder_threshold']?.toString() ??
            item['reorderThreshold']?.toString() ??
            pkg['reorder_threshold']?.toString() ??
            '10') ??
        10;

    final formatCurrency = NumberFormat.decimalPattern('en_US');
    final sellingPrice = formatCurrency
        .format(num.tryParse(pkg['sellingPrice']?.toString() ?? '0') ?? 0);

    // CỐ GẮNG QUÉT ẢNH TỪ MỌI CẤP ĐỘ DATA ĐỂ CHỐNG LỖI BACKEND QUÊN POPULATE
    final String rawUrl = product?['imageUrl']?.toString() ??
        pkg?['imageUrl']?.toString() ??
        item['imageUrl']?.toString() ??
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
      stockText = "Low stock: $quantity";
    } else {
      stockColor = AppColors.stockIn; // Xanh lá
      stockText = "In stock: $quantity";
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
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
          width: 250,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- 1. IMAGE BOX ---
              Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 16),

              // --- 2. PRODUCT NAME ---
              Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppColors.primaryText,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // --- 3. PRICE ($ + PRIMARY COLOR) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    "\$",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    sellingPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- 4. BADGES ---
              Row(
                children: [
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
                        Icon(Iconsax.box, size: 14, color: stockColor),
                        const SizedBox(width: 6),
                        Text(
                          stockText,
                          style: TextStyle(
                            color: stockColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (unitName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        unitName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const TNoImageWidget(iconSize: 32);
  }
}
