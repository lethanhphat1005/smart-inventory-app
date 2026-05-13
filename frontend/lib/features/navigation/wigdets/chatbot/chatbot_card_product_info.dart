import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
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
        pkg['displayName'] ?? product?['name'] ?? TTexts.unknownProduct.tr;
    final quantity = item['quantity'] ?? pkg['quantity'] ?? 0;
    final unitName = pkg['unit']?['name'] ?? '';

    final threshold = int.tryParse(
          item['reorder_threshold']?.toString() ??
              item['reorderThreshold']?.toString() ??
              pkg['reorder_threshold']?.toString() ??
              '10',
        ) ??
        10;

    final currentLocale = Get.locale?.languageCode == 'vi' ? 'vi_VN' : 'en_US';

    final formatCurrency = NumberFormat.decimalPattern(currentLocale);

    final sellingPrice = formatCurrency
        .format(num.tryParse(pkg['sellingPrice']?.toString() ?? '0') ?? 0);
    final importPrice = formatCurrency
        .format(num.tryParse(pkg['importPrice']?.toString() ?? '0') ?? 0);
    final hasImportPrice =
        (num.tryParse(pkg['importPrice']?.toString() ?? '0') ?? 0) > 0;

    final String rawUrl = product?['imageUrl']?.toString() ??
        pkg?['imageUrl']?.toString() ??
        item['imageUrl']?.toString() ??
        '';
    final String finalImageUrl = UrlHelperUtils.normalizeImageUrl(rawUrl) ?? '';

    final productId = product?['productId'] ?? pkg['productId'];
    final packageId = pkg['productPackageId'];
    final barcode = pkg['barcodeValue'] ?? '';

    Color stockColor;
    String stockText;
    IconData stockIcon;

    if (quantity == 0) {
      stockColor = AppColors.stockOut;
      stockText = TTexts.chatbotOutOfStock.tr;
      stockIcon = Iconsax.close_circle;
    } else if (quantity <= threshold) {
      stockColor = AppColors.primary;
      stockText =
          '${TTexts.chatbotLowStockAlert.tr} $quantity $unitName'.trim();
      stockIcon = Iconsax.warning_2;
    } else {
      stockColor = AppColors.stockIn;
      stockText =
          '${TTexts.chatbotInStockPrefix.tr} $quantity $unitName'.trim();
      stockIcon = Iconsax.tick_circle;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
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
          constraints: BoxConstraints(maxWidth: Get.width * 0.85),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top: image + info ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFF4F5F7),
                        child: finalImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: finalImageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    _buildImagePlaceholder(),
                              )
                            : _buildImagePlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                              height: 1.4,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Stock badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(stockIcon, size: 13, color: stockColor),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    stockText,
                                    style: TextStyle(
                                      color: stockColor,
                                      fontSize: 11.5,
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

              // ── Divider ──
              Divider(height: 1, color: Colors.grey.shade100),

              // ── Price row ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPriceCol(
                        label: TTexts.chatbotSellingPrice.tr,
                        value: sellingPrice,
                        valueColor: AppColors.primary,
                      ),
                    ),
                    if (hasImportPrice) ...[
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey.shade100,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        child: _buildPriceCol(
                          label: TTexts.chatbotImportPrice.tr,
                          value: importPrice,
                          valueColor: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Tap hint ──
              if (productId != null)
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.link,
                        size: 13,
                        color: AppColors.subText.withOpacity(0.6),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        TTexts.chatbotViewDetail.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText.withOpacity(0.6),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCol({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.subText.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() => const TNoImageWidget(iconSize: 28);
}
