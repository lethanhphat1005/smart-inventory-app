import 'package:flutter/material.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_message_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_low_stock_product.dart';
import 'package:get/get.dart';

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
      totalCount = rawData['totalCount'] ?? items.length;
    }

    if (items.isEmpty && totalCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ChatbotMessage(
              message: ChatMessage(
                text:
                    "I found $totalCount items that are running low on stock. Please swipe to check the cards below:",
                isUser: false,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return ChatCardLowStockProduct(itemData: items[index]);
              },
            ),
          ),

          // TEXT "XEM TẤT CẢ" ĐÃ CHỈNH NHƯ TEXT BÌNH THƯỜNG THEO Ý BẠN
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.lowStock),
              child: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  "View full list ->",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subText,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
