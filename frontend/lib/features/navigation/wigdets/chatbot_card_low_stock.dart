import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatCardLowStock extends StatelessWidget {
  final ChatMessage message;

  const ChatCardLowStock({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = [];

    if (message.data is List) {
      // Trường hợp backend trả thẳng mảng (data: inventories.items)
      items = message.data as List<dynamic>;
    } else if (message.data is Map) {
      // Trường hợp backend bọc trong object (data: { items: [...] } hoặc data: { data: [...] })
      items = (message.data['data'] ?? message.data['items'] ?? [])
          as List<dynamic>;
    }

    // Nếu không có dữ liệu mảng thì trả về dạng bong bóng text thường
    if (items.isEmpty) {
      return _buildFallbackBubble(message.text);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.88),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header cảnh báo (Thu gọn padding và thay text ngắn gọn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      // Tự động generate text ngắn gọn dựa trên số lượng item
                      "Chú ý: Có ${items.length} mặt hàng sắp hết",
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Danh sách sản phẩm
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 4), // Ép margin nhỏ lại
              child: ListView.separated(
                padding: EdgeInsets
                    .zero, // QUAN TRỌNG: Xoá padding mặc định của ListView
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                      height: 1, color: AppColors.divider.withOpacity(0.4)),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final pkg = item['productPackage'];

                  final displayName =
                      pkg?['displayName'] ?? 'Sản phẩm không xác định';
                  final quantity = item['quantity'] ?? 0;
                  final unitName = pkg?['unit']?['name'] ?? '';

                  return Padding(
                    // Giảm vertical padding của từng dòng xuống còn 10
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4), // Làm nhỏ badge tồn kho lại
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.15)),
                          ),
                          child: Text(
                            "Còn: $quantity $unitName".trim(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
