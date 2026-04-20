import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class ReportTransactionDetailItemCardWidget extends StatelessWidget {
  final TransactionDetailModel item;

  const ReportTransactionDetailItemCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final priceStr = NumberFormat.currency(locale: 'en_US', symbol: '\$')
        .format(item.unitPrice);

    final String? imageUrl =
        UrlHelperUtils.normalizeImageUrl(item.packageInfo?.product?.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final pkgId =
                item.productPackageId ?? item.packageInfo?.productPackageId;
            final String? productId = item.packageInfo?.productId ??
                item.packageInfo?.product?.productId;
            final barcode = item.packageInfo?.barcodeValue ?? '';

            if (pkgId == null || pkgId.isEmpty) {
              TSnackbarsWidget.error(
                  title: TTexts.errorTitle.tr,
                  message: TTexts.itemDeletedOrUnavailable.tr);
              return;
            }

            Get.toNamed(
              AppRoutes.inventoryDetail,
              arguments: productId,
              parameters: {
                'packageId': pkgId,
                if (barcode.isNotEmpty) 'barcode': barcode,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.softGrey.withOpacity(0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary),
                            ),
                            errorWidget: (context, url, error) =>
                                const TNoImageWidget(
                              width: 52,
                              height: 52,
                              borderRadius: 11,
                              iconSize: 24,
                            ),
                          )
                        : const TNoImageWidget(
                            width: 52,
                            height: 52,
                            borderRadius: 11,
                            iconSize: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          item.packageInfo?.displayName ??
                              TTexts.unknownProduct.tr,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                          '${TTexts.barcodeLabel.tr}: ${item.packageInfo?.barcodeValue ?? TTexts.na.tr}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.subText)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(priceStr,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('x${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
