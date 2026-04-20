import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SearchSimpleItemWidget extends StatelessWidget {
  final InventoryInsightDisplayModel displayItem;
  final VoidCallback onTap;

  const SearchSimpleItemWidget({
    super.key,
    required this.displayItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final package = displayItem.inventory.productPackage;
    final product = displayItem.product;

    final bool isCategory = product != null && product.productId.isEmpty;
    final bool isBaseProduct =
        product != null && product.productId.isNotEmpty && package == null;
    final bool isPackage = package != null;

    String title = TTexts.unknownProduct.tr;
    String subtitle = '';

    if (isPackage) {
      title = package.displayName;
      subtitle = "${TTexts.barcodeLabel.tr}: ${package.barcodeValue ?? '---'}";
    } else if (isBaseProduct) {
      title = product.name;
      subtitle = "${TTexts.brand.tr}: ${product.brand ?? '---'}";
    } else if (isCategory) {
      title = product.name;
      subtitle = TTexts.categoryCatalog.tr;
    }

    final String? imageUrl =
        UrlHelperUtils.normalizeImageUrl(product?.imageUrl);

    Widget leadingWidget;

    if (isCategory) {
      leadingWidget = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.softGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Iconsax.folder_2_copy,
            color: AppColors.softGrey, size: 22),
      );
    } else {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const TNoImageWidget(
                  width: 44,
                  height: 44,
                  borderRadius: 8,
                  iconSize: 20,
                ),
              )
            : const TNoImageWidget(
                width: 44,
                height: 44,
                borderRadius: 8,
                iconSize: 20,
              ),
      );
    }

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: leadingWidget,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.primaryText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.subText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
