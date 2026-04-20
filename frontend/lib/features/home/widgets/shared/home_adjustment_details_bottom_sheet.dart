import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class HomeAdjustmentDetailsBottomSheet extends StatelessWidget {
  final String icon;
  final String productName;
  final DateTime date;
  final int oldQty;
  final int newQty;
  final int difference;
  final String note;

  const HomeAdjustmentDetailsBottomSheet({
    super.key,
    required this.icon,
    required this.productName,
    required this.date,
    required this.oldQty,
    required this.newQty,
    required this.difference,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    // Xử lý logic màu sắc cho phần chênh lệch
    final isPositive = difference > 0;
    final diffText = "${isPositive ? '+' : ''}$difference";
    final diffColor = isPositive ? AppColors.stockIn : AppColors.alertText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Icon Header
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.softGrey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: AppSizes.p16),

        // 2. Title
        Text(
          TTexts.checkDetails.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 24),

        // 3. Khung thông tin
        Container(
          padding: const EdgeInsets.all(AppSizes.p16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _buildInfoRow(TTexts.productName.tr, productName,
                  isHighlight: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                    height: 1, thickness: 1, color: AppColors.background),
              ),

              _buildInfoRow(
                TTexts.transactionDate.tr,
                DateFormat('dd MMM yyyy, HH:mm').format(date),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                    height: 1, thickness: 1, color: AppColors.background),
              ),

              // Row Quantity với Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    TTexts.qty.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.subText,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          "$oldQty → $newQty",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: diffColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            diffText,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: diffColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                    height: 1, thickness: 1, color: AppColors.background),
              ),

              _buildInfoRow(
                TTexts.note.tr,
                note.isEmpty ? TTexts.na.tr : note,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.subText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? AppColors.primaryText
                  : AppColors.primaryText.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}
