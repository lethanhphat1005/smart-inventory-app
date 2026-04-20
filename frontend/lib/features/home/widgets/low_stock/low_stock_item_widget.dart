import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:get/get.dart';

class LowStockItemWidget extends StatelessWidget {
  final InventoryModel model;
  final VoidCallback? onTap;

  const LowStockItemWidget({
    super.key,
    required this.model,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = model.productPackage;
    final String productName =
        pkg?.displayName ?? pkg?.product?.name ?? TTexts.unknownProduct.tr;

    final String? imageUrl =
        UrlHelperUtils.normalizeImageUrl(pkg?.product?.imageUrl);

    final int qty = model.quantity;
    final bool isOutOfStock = qty <= 0;

    final Color statusColor =
        isOutOfStock ? AppColors.alertText : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p12),
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radius8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const TNoImageWidget(
                        width: 50,
                        height: 50,
                        borderRadius: 8,
                        iconSize: 24,
                      ),
                    )
                  : const TNoImageWidget(
                      width: 50,
                      height: 50,
                      borderRadius: 8,
                      iconSize: 24,
                    ),
            ),
            const SizedBox(width: AppSizes.p16),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        TTexts.stockLeft.tr,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.subText),
                      ),
                      Text(
                        "$qty",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
