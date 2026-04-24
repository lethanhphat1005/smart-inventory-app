import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
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
                    "${TTexts.chatbotLowStockFoundPrefix.tr} $totalCount ${TTexts.chatbotLowStockFoundSuffix.tr}",
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.lowStock),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  TTexts.chatbotViewFullList.tr,
                  style: const TextStyle(
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
