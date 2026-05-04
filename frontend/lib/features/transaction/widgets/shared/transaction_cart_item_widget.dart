import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionCartItemWidget extends StatelessWidget {
  final TransactionDetailModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool isOutbound;
  final String? imageUrl;
  const TransactionCartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    this.isOutbound = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final name = item.packageInfo?.displayName ??
        '${TTexts.product.tr} #${item.productPackageId?.substring(0, 5) ?? TTexts.labelNoBarcode.tr}';

    final price = item.unitPrice.toStringAsFixed(2);

    final bool canIncrease = !isOutbound || (item.quantity < item.currentStock);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // 1. HIỂN THỊ HÌNH ẢNH
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (imageUrl != null && imageUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: UrlHelperUtils.normalizeImageUrl(imageUrl) ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) => const TNoImageWidget(
                        width: 60, height: 60, borderRadius: 12),
                  )
                : const TNoImageWidget(width: 60, height: 60, borderRadius: 12),
          ),
          const SizedBox(width: 12),

          // 2. THÔNG TIN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('\$$price',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.subText)),
              ],
            ),
          ),

          // 3. ĐIỀU CHỈNH SỐ LƯỢNG
          Row(
            children: [
              _buildQtyBtn(
                  icon: Iconsax.minus_copy,
                  onTap: onDecrease,
                  color: AppColors.softGrey.withOpacity(0.2)),
              Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text('${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              _buildQtyBtn(
                icon: Iconsax.add_copy,
                onTap: canIncrease
                    ? onIncrease
                    : null, // Vô hiệu hóa nếu vượt stock (Outbound)
                color: canIncrease
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.softGrey.withOpacity(0.1),
                iconColor: canIncrease ? AppColors.primary : AppColors.softGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(
      {required IconData icon,
      VoidCallback? onTap,
      required Color color,
      Color iconColor = AppColors.primaryText}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}
