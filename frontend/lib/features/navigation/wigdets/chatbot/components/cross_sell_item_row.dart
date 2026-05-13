import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class CrossSellItemRow extends StatelessWidget {
  final dynamic item;
  const CrossSellItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${item['productName']}", // Hiển thị tên đã JOIN từ Backend
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "${item['frequency']} lượt",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
