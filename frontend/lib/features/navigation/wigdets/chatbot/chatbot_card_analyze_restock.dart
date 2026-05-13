import 'package:flutter/material.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/components/cross_sell_item_row.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/components/restock_item_row.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_message_widget.dart';

class ChatCardAnalyzeRestock extends StatelessWidget {
  final ChatMessage message;

  const ChatCardAnalyzeRestock({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return ChatbotMessage(message: message);

    final type = data['type'] as String?;
    final isCrossSell = type == 'cross_sell';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatbotMessage(message: message),
        _buildAnalyzeContainer(
          // Sử dụng Localization cho Title
          title: isCrossSell
              ? TTexts.chatbotAnalyzeCrossSellTitle.tr
              : TTexts.chatbotAnalyzeRestockTitle.tr,
          icon: isCrossSell ? Icons.auto_graph : Icons.analytics_outlined,
          child: isCrossSell
              ? _buildCrossSellContent(data)
              : _buildRestockContent(data),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAnalyzeContainer(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary)),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildRestockContent(Map<String, dynamic> data) {
    final suggestions = data['suggestions'] as List<dynamic>? ?? [];

    // Nếu kho trống (không có gợi ý)
    if (suggestions.isEmpty) {
      return Text(TTexts.chatbotAnalyzeOptimalStock.tr,
          style: TextStyle(color: Colors.grey[700], fontSize: 13));
    }

    return Column(
      children: suggestions.map((s) => RestockItemRow(item: s)).toList(),
    );
  }

  Widget _buildCrossSellContent(Map<String, dynamic> data) {
    final items = data['crossSellItems'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // Dùng trParams để truyền tên sản phẩm vào chuỗi đa ngôn ngữ
          TTexts.chatbotAnalyzeBoughtTogether
              .trParams({'target': data['targetProduct']?.toString() ?? ''}),
          style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => CrossSellItemRow(item: item)),
      ],
    );
  }
}
