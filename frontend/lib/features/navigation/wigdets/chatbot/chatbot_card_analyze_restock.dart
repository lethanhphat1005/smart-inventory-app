import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
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
        const SizedBox(height: 12),
        _buildAnalyzeContainer(
          title: isCrossSell ? "Phân tích mua kèm" : "Dự báo nhập hàng",
          icon: isCrossSell ? Icons.auto_graph : Icons.analytics_outlined,
          child: isCrossSell
              ? _buildCrossSellContent(data)
              : _buildRestockContent(data),
        ),
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
    return Column(
      children: suggestions.map((s) => _buildRestockRow(s)).toList(),
    );
  }

  Widget _buildCrossSellContent(Map<String, dynamic> data) {
    final items = data['crossSellItems'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Khách mua ${data['targetProduct']} thường mua kèm:",
          style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildCrossSellRow(item)),
      ],
    );
  }

  Widget _buildRestockRow(dynamic s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['productName'] ?? 'Sản phẩm',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text("Tồn hiện tại: ${s['currentStock']}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text("+${s['suggestedQuantity']}",
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCrossSellRow(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
              child: Text("${item['productName']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
          Text("${item['frequency']} lượt",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blue)),
        ],
      ),
    );
  }
}
