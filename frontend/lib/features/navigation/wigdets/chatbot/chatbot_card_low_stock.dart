import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_message_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_low_stock_product.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

/// Low Stock Card — hiển thị list sản phẩm sắp hết hàng theo bố cục dọc.
/// Bỏ horizontal scroll carousel cũ (chiếm 320px cứng) sang list dọc
/// gọn gàng hơn, dễ scan hơn trên mobile.
class ChatCardLowStock extends StatelessWidget {
  final ChatMessage message;

  const ChatCardLowStock({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = [];
    int totalCount = 0;

    if (message.data is List) {
      items = message.data as List<dynamic>;
      totalCount = items.length;
    } else if (message.data is Map) {
      final rawData = message.data as Map<String, dynamic>;
      items = (rawData['items'] ?? rawData['data'] ?? []) as List<dynamic>;
      totalCount = (rawData['totalCount'] as num?)?.toInt() ?? items.length;
    }

    if (items.isEmpty && totalCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header message
          Align(
            alignment: Alignment.centerLeft,
            child: ChatbotMessage(
              message: ChatMessage(
                text:
                    '${TTexts.chatbotLowStockFoundPrefix.tr} $totalCount ${TTexts.chatbotLowStockFoundSuffix.tr}',
                isUser: false,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Product list — dọc, không scroll ngang
          ...items.map((item) => ChatCardLowStockProduct(
                itemData: item as Map<String, dynamic>,
              )),

          const SizedBox(height: 4),

          // View full list link
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.lowStock),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.link,
                    size: 13,
                    color: AppColors.subText.withOpacity(0.55),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    TTexts.chatbotViewFullList.tr,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.subText.withOpacity(0.55),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
