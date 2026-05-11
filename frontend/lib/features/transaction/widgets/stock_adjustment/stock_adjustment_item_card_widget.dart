import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:get/get.dart';

class StockAdjustmentItemCardWidget extends GetView<StockAdjustmentController> {
  final AdjustmentItemRx item;
  final int index;

  const StockAdjustmentItemCardWidget({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isChecked = item.isChecked.value;
      final isMismatched = item.isMismatched;

      final statusText = isChecked
          ? (isMismatched ? TTexts.mismatched.tr : TTexts.checked.tr)
          : TTexts.unchecked.tr;
      final statusColor = isChecked
          ? (isMismatched ? AppColors.stockOut : AppColors.stockIn)
          : Colors.orange;

      const Gradient checkedGradient =
          LinearGradient(colors: [Color(0xFF48CA93), Color(0xFF48BACA)]);
      const Gradient mismatchedGradient =
          LinearGradient(colors: [Color(0xFFE88B76), Color(0xFFCA5048)]);

      final imageUrl = controller.fetchedImages[item.packageId] ??
          item.packageInfo?.product?.imageUrl ??
          '';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHỐNG TRÀN TÊN SẢN PHẨM
            Text(
              "$index. ${item.name}",
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // HÌNH ẢNH
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const TNoImageWidget(),
                            errorWidget: (context, url, error) =>
                                const TNoImageWidget(),
                          )
                        : const TNoImageWidget(),
                  ),
                ),
                const SizedBox(width: 16),

                // THÔNG TIN SỐ LƯỢNG (ĐÃ FIX OVERFLOW)
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${TTexts.system.tr}: ${item.systemQty}",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "${TTexts.actual.tr}: ${item.actualQty.value}",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${TTexts.spread.tr}: ${item.spread > 0 ? '+' : ''}${item.spread}",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: item.spread == 0
                                      ? AppColors.subText
                                      : (item.spread > 0
                                          ? AppColors.stockIn
                                          : AppColors.stockOut)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text("${TTexts.status.tr}: ",
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.subText)),
                          Flexible(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // CÁC NÚT BẤM BÊN PHẢI
                Row(
                  children: [
                    if (isChecked)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isMismatched
                                ? mismatchedGradient
                                : checkedGradient),
                        child: Icon(
                            isMismatched ? Icons.priority_high : Icons.check,
                            color: Colors.white,
                            size: 16),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.goToItemAdjustmentPage(item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.orange, width: 1.5)),
                        child: const Icon(Icons.more_horiz,
                            color: Colors.orange, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // LÝ DO VÀ GHI CHÚ
            if (isMismatched &&
                (item.selectedReason.value.isNotEmpty ||
                    item.note.value.isNotEmpty)) ...[
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.divider)),
              Text(
                item.note.value.isNotEmpty
                    ? item.note.value
                    : "${TTexts.reason.tr}: ${item.selectedReason.value.tr}",
                style:
                    const TextStyle(fontSize: 12, color: AppColors.primaryText),
              ),  
            ]
          ],
        ),
      );
    });
  }
}
