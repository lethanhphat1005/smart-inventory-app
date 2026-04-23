import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatCardChooseProduct extends StatelessWidget {
  final ChatMessage message;

  const ChatCardChooseProduct({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.data;
    if (data == null || data['items'] == null) return const SizedBox.shrink();

    final List<dynamic> items = data['items'];
    final controller = Get.find<ChatbotUiController>();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.85),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiêu đề
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // Danh sách Option
            ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100, indent: 56),
              itemBuilder: (context, index) {
                final item = items[index];
                final pkg = item['productPackage'] ?? item;

                final displayName = pkg['displayName'] ??
                    pkg['product']?['name'] ??
                    'Unknown product';
                final quantity = item['quantity'] ?? pkg['quantity'] ?? 0;
                final unit = pkg['unit']?['name'] ?? '';

                // Lấy threshold từ backend
                final threshold = int.tryParse(
                        item['reorder_threshold']?.toString() ??
                            item['reorderThreshold']?.toString() ??
                            pkg['reorder_threshold']?.toString() ??
                            '10') ??
                    10;

                // LOGIC 3 MÀU
                Color stockColor;
                String stockText;

                if (quantity == 0) {
                  stockColor = AppColors.stockOut; // Đỏ
                  stockText = "Out of stock";
                } else if (quantity <= threshold) {
                  stockColor = AppColors.primary; // Cam gốc cảnh báo
                  stockText = "Low: $quantity $unit".trim();
                } else {
                  stockColor = AppColors.stockIn; // Xanh lá
                  stockText = "Left: $quantity $unit".trim();
                }

                return InkWell(
                  onTap: () {
                    if (message.isResolved) return;
                    final originalIntent = data['originalIntent'];
                    final qty = data['quantity'] ?? 1;

                    String command = "";
                    if (originalIntent == 'get_product_info') {
                      command = "Check exact info of \"$displayName\"";
                    } else if (originalIntent == 'create_import') {
                      command = "Import $qty of exactly \"$displayName\"";
                    } else if (originalIntent == 'create_export') {
                      command = "Export $qty of exactly \"$displayName\"";
                    }

                    message.isResolved = true;
                    controller.messages.refresh();
                    controller.textController.text = command;
                    controller.sendMessage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Icon Box thay vì hình vuông nhạt
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Icon(Iconsax.box,
                              size: 18,
                              color: message.isResolved
                                  ? Colors.grey
                                  : AppColors.subText),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: message.isResolved
                                      ? Colors.grey
                                      : AppColors.primaryText,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stockText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: message.isResolved
                                      ? Colors.grey
                                      : stockColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: message.isResolved
                              ? Colors.grey.shade300
                              : AppColors.primary,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
