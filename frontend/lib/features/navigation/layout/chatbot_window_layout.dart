import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_action_confirm.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_analyze_restock.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_audit_log.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_choose_product.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_low_stock.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_card_product_info.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_header_widget.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_input_area_widget.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_message_widget.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_suggested_prompts.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_typing_indicator.dart';

import 'package:get/get.dart';

class ChatbotWindowLayout extends StatelessWidget {
  ChatbotWindowLayout({super.key});
  final controller = Get.find<ChatbotUiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Column(
            children: [
              // 1. HEADER
              const ChatbotHeaderWidget(),
              Container(height: 1, color: AppColors.divider.withOpacity(0.5)),

              // 2. CHAT AREA (CÓ HÌNH NỀN)
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    image: DecorationImage(
                      image:
                          AssetImage(TImages.chatbotImages.chatbotBackground),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Colors.white70,
                        BlendMode.lighten,
                      ),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.messages.isEmpty &&
                        !controller.isTyping.value) {
                      return ChatbotSuggestedPrompts(
                        onAction: (text, autoSend) {
                          // 🛑 CHỐNG SPAM: Ngăn double-tap siêu tốc vào nút gợi ý
                          if (controller.isTyping.value) return;

                          if (autoSend) {
                            controller.textController.text = text;
                            controller.sendMessage();
                          } else {
                            controller.textController.text = text;
                            controller.textController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset:
                                        controller.textController.text.length));
                            controller.focusNode.requestFocus();
                          }
                        },
                      );
                    }

                    // 🛑 CẢI THIỆN UX: Chạm vào vùng chat trống để ẩn bàn phím ngay lập tức
                    return GestureDetector(
                      onTap: () {
                        controller.focusNode.unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: ListView.builder(
                        controller: controller.scrollController,
                        // Thêm physics này để vùng trống cũng bắt được sự kiện vuốt/chạm
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        itemCount: controller.messages.length +
                            (controller.isTyping.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.messages.length) {
                            return const ChatTypingIndicator();
                          }
                          return _buildMessageRouter(
                              controller.messages[index]);
                        },
                      ),
                    );
                  }),
                ),
              ),

              // 3. INPUT AREA & ACTION MENU
              const ChatbotInputAreaWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageRouter(ChatMessage msg) {
    if (msg.isUser) return ChatbotMessage(message: msg);

    switch (msg.intent) {
      case 'get_product_info':
        if (msg.data == null) return ChatbotMessage(message: msg);
        return ChatCardProductInfo(message: msg);
      case 'confirm_import':
      case 'confirm_export':
        return ChatCardActionConfirm(message: msg);
      case 'get_low_stock':
        return ChatCardLowStock(message: msg);
      case 'choose_product':
        return ChatCardChooseProduct(message: msg);
      case 'query_audit_logs':
        return ChatCardAuditLog(message: msg);
      case 'analyze_restock':
        return ChatCardAnalyzeRestock(message: msg);
      default:
        return ChatbotMessage(message: msg);
    }
  }
}
