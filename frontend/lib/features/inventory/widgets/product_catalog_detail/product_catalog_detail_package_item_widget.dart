import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ProductCatalogDetailPackageItemWidget
    extends GetView<ProductCatalogDetailController> {
  final ProductPackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCatalogDetailPackageItemWidget({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String fullDisplayName = package.variant?.isNotEmpty == true
        ? '${package.displayName} ${package.variant}'
        : package.displayName;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Slidable(
        enabled: controller.canManageProduct,
        key: ValueKey(package.productPackageId),
        endActionPane: ActionPane(
          motion: const BehindMotion(), // Animation lộ diện từ dưới card
          extentRatio: 0.4,
          children: [
            const SizedBox(width: 8),

            // NÚT SỬA - Màu xanh Pastel
            SlidableAction(
              onPressed: (context) => onEdit(),
              backgroundColor: AppColors.toastInfoBg, // Nền xanh nhạt
              foregroundColor: AppColors.toastInfoGradientEnd, // Icon xanh
              icon: Iconsax.edit_2_copy,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),

            const SizedBox(width: 8),

            // NÚT XÓA - Màu đỏ Pastel
            SlidableAction(
              onPressed: (context) => onDelete(),
              backgroundColor: AppColors.toastErrorBg, // Nền đỏ nhạt
              foregroundColor: AppColors.alertText, // Icon đỏ
              icon: Iconsax.trash_copy,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.p16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius12),
            border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullDisplayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: AppSizes.p12),
              Row(
                children: [
                  const Icon(Iconsax.barcode_copy,
                      size: 16, color: AppColors.softGrey),
                  const SizedBox(width: 6),
                  Text(
                    package.barcodeValue?.isNotEmpty == true
                        ? package.barcodeValue!
                        : TTexts.noBarcode.tr,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.subText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceItem(TTexts.importCost.tr, package.importPrice,
                      AppColors.subText),
                  _buildPriceItem(TTexts.salePrice.tr, package.sellingPrice,
                      AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, double price, Color priceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.softGrey,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}', // Trả về định dạng Đô-la chuẩn
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: priceColor),
        ),
      ],
    );
  }
}
