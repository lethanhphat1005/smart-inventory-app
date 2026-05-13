import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class RestockItemRow extends StatelessWidget {
  final dynamic item;
  const RestockItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Dùng TTexts.product.tr nếu không có tên
                  item['productName'] ?? TTexts.product.tr,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  // Sử dụng Localization cho "Tồn hiện tại"
                  "${TTexts.currentStock.tr}: ${item['currentStock']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "+${item['suggestedQuantity']}",
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
