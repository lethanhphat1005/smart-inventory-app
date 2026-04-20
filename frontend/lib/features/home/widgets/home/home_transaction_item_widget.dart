import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class HomeTransactionItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final DateTime? time;
  final String amount;
  final bool isPositive;
  final String? qtyInfo;

  const HomeTransactionItemWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.time,
    required this.amount,
    required this.isPositive,
    this.qtyInfo,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DayFormatterUtils.formatDate(time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(formattedTime,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.softGrey)),
                    if (qtyInfo != null) ...[
                      const SizedBox(width: 12),
                      Text(qtyInfo!,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subText)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? AppColors.stockIn : AppColors.stockOut)),
        ],
      ),
    );
  }
}
