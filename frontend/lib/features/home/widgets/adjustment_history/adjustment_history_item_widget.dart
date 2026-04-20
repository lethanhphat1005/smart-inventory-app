import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/model/adjustment_history_model.dart';
import 'package:get/get.dart';

class AdjustmentHistoryItemWidget extends StatelessWidget {
  final AdjustmentHistoryModel model;
  final VoidCallback onTap;

  const AdjustmentHistoryItemWidget({
    super.key,
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DayFormatterUtils.formatTime(model.performedAt);
    final diffStr = model.difference == 0
        ? '0'
        : (model.isPositive ? '+${model.difference}' : '${model.difference}');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p12),
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: const Icon(Icons.sync_alt_rounded,
                  size: 24, color: Colors.orange),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.softGrey),
                      const SizedBox(width: 4),
                      Text(timeStr,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.softGrey)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            "${TTexts.qty.tr}: ${model.oldQuantity} → ${model.newQuantity}",
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subText)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              diffStr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    model.isPositive ? AppColors.stockIn : AppColors.stockOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
