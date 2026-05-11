import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
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

    final threshold = int.tryParse(item['reorder_threshold']?.toString() ??
            pkg['reorder_threshold']?.toString() ??
            '10') ??
        10;

    final formatCurrency = NumberFormat.decimalPattern('vi_VN');
    final sellingPrice = formatCurrency
        .format(num.tryParse(pkg['sellingPrice']?.toString() ?? '0') ?? 0);
    final importPrice = formatCurrency
        .format(num.tryParse(pkg['importPrice']?.toString() ?? '0') ?? 0);

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
    Color stockBgColor;

    if (quantity == 0) {
      stockColor = const Color(0xFFA32D2D);
      stockBgColor = const Color(0xFFFCEBEB);
      stockText = TTexts.chatbotOutOfStock.tr;
    } else if (quantity <= threshold) {
      stockColor = const Color(0xFF854F0B);
      stockBgColor = const Color(0xFFFAEEDA);
      stockText = "Còn $quantity $unitName";
    } else {
      stockColor = const Color(0xFF3B6D11);
      stockBgColor = const Color(0xFFEAF3DE);
      stockText = "$quantity $unitName";
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
                  'barcode': barcode?.toString() ?? ''
                });
          }
        },
        child: Container(
          width: Get.width * 0.82,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: finalImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: finalImageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  _buildImagePlaceholder())
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: AppColors.primaryText,
                                height: 1.4,
                                fontFamily: 'Poppins'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: stockBgColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: stockColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text(stockText,
                                  style: TextStyle(
                                      color: stockColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Giá bán",
                          style: TextStyle(
                              fontSize: 11, color: AppColors.subText)),
                      const SizedBox(height: 2),
                      Text(sellingPrice,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Giá nhập",
                          style: TextStyle(
                              fontSize: 11, color: AppColors.subText)),
                      const SizedBox(height: 2),
                      Text(importPrice,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText)),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.export_3, size: 14, color: AppColors.subText),
                    SizedBox(width: 4),
                    Text("Xem chi tiết tồn kho",
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subText,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() => const TNoImageWidget(iconSize: 24);
}
