import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_barcode_list_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';

class ProductCatalogDetailPackageItemWidget
    extends GetView<ProductCatalogDetailController> {
  final ProductPackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGoToInventory;

  const ProductCatalogDetailPackageItemWidget({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onDelete,
    required this.onGoToInventory,
  });

  @override
  Widget build(BuildContext context) {
    final String fullDisplayName = package.variant?.isNotEmpty == true
        ? '${package.displayName} ${package.variant}'
        : package.displayName;

    // Kiểm tra số lượng mã vạch
    final bool hasMultipleBarcodes = package.barcodes.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Slidable(
        enabled: controller.canManageProduct,
        key: ValueKey(package.productPackageId),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.55,
          children: [
            const SizedBox(width: 8),
            // 1. Nút đi đến Tồn kho
            SlidableAction(
              onPressed: (context) => onGoToInventory(),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
              icon: Iconsax.box_search_copy,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
            const SizedBox(width: 4),
            // 2. Nút Chỉnh sửa
            SlidableAction(
              onPressed: (context) => onEdit(),
              backgroundColor: AppColors.toastInfoBg,
              foregroundColor: AppColors.toastInfoGradientEnd,
              icon: Iconsax.edit_2_copy,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
            const SizedBox(width: 4),
            // 3. Nút Xóa
            SlidableAction(
              onPressed: (context) => onDelete(),
              backgroundColor: AppColors.toastErrorBg,
              foregroundColor: AppColors.alertText,
              icon: Iconsax.trash_copy,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
          ],
        ),
        // =========================================================
        // Dùng Builder để gọi Slidable.of(context) cực gọn
        // =========================================================
        child: Builder(
          builder: (context) {
            // Lấy trực tiếp controller có sẵn của thư viện
            final slidable = Slidable.of(context);

            return InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              onTap: () {
                // Nhấn vào thẻ để mở màn hình xem chi tiết
                controller.viewPackage(package);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                  border:
                      Border.all(color: AppColors.softGrey.withOpacity(0.1)),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            fullDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppFonts.mainFont,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText),
                          ),
                        ),
                        if (controller.canManageProduct)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                if (slidable != null) {
                                  // Nếu chưa kéo (ratio = 0) -> Mở ra
                                  if (slidable.ratio == 0) {
                                    slidable.openEndActionPane();
                                  } else {
                                    // Nếu đang mở -> Đóng lại
                                    slidable.close();
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 4),
                                    // AnimatedBuilder giúp icon mượt mà đổi chiều khi mở/đóng
                                    AnimatedBuilder(
                                      animation: slidable?.animation ??
                                          const AlwaysStoppedAnimation(0),
                                      builder: (context, child) {
                                        final isOpened =
                                            (slidable?.ratio ?? 0) != 0;
                                        return Icon(
                                          isOpened
                                              ? Icons
                                                  .keyboard_double_arrow_right_rounded
                                              : Icons
                                                  .keyboard_double_arrow_left_rounded,
                                          size: 18,
                                          color: AppColors.softGrey
                                              .withOpacity(0.6),
                                        );
                                      },
                                    ),
                                    Icon(Icons.more_vert_rounded,
                                        size: 18,
                                        color: AppColors.softGrey
                                            .withOpacity(0.4)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // KHU VỰC MÃ VẠCH
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: hasMultipleBarcodes
                            ? () {
                                TBottomSheetWidget.show(
                                  child: InventoryBarcodeListBottomSheetWidget(
                                      package: package),
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasMultipleBarcodes
                                ? AppColors.primary.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasMultipleBarcodes
                                  ? AppColors.primary.withOpacity(0.15)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.barcode_copy,
                                  size: 18,
                                  color: hasMultipleBarcodes
                                      ? AppColors.primary
                                      : AppColors.softGrey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  package.barcodeValue?.isNotEmpty == true
                                      ? package.barcodeValue!
                                      : TTexts.noBarcode.tr,
                                  style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 13,
                                    fontWeight: hasMultipleBarcodes
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: hasMultipleBarcodes
                                        ? AppColors.primaryText
                                        : AppColors.subText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasMultipleBarcodes) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '+${package.barcodes.length - 1}',
                                    style: TextStyle(
                                      fontFamily: AppFonts.mainFont,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Iconsax.arrow_down_1_copy,
                                    size: 16, color: AppColors.primaryText),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPriceItem(TTexts.importCost.tr,
                            package.importPrice, AppColors.subText),
                        _buildPriceItem(TTexts.salePrice.tr,
                            package.sellingPrice, AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 11,
            color: AppColors.softGrey,
          ),
        ),
        Text(
          CurrencyFormatterUtils.formatFull(price),
          style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: priceColor),
        ),
      ],
    );
  }
}
