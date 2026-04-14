import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/features/navigation/wigdets/chatbot_bubble_standard.dart';
import 'package:frontend/features/navigation/wigdets/chatbot_card_action_confirm.dart';
import 'package:frontend/features/navigation/wigdets/chatbot_card_choose_product.dart';
import 'package:frontend/features/navigation/wigdets/chatbot_card_low_stock.dart';
import 'package:frontend/features/navigation/wigdets/chatbot_card_product_info.dart';
import 'package:frontend/features/navigation/wigdets/chatbot_typing_indicator.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
              _buildHeader(context, controller),
              Container(height: 1, color: AppColors.divider.withOpacity(0.5)),
              Flexible(
                child: Container(
                  color: AppColors.surface,
                  child: Obx(
                    () => ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      itemCount: controller.messages.length +
                          (controller.isTyping.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.messages.length) {
                          return const ChatTypingIndicator();
                        }
                        return _buildMessageRouter(controller.messages[index]);
                      },
                    ),
                  ),
                ),
              ),
              _buildInputArea(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatbotUiController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      color: AppColors.background,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(TImages.appLogos.appLogo, width: 24, height: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.chatbotName.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      TTexts.chatbotOnline.tr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.subText),
            onPressed: () {
              FocusScope.of(context).unfocus();
              controller.closeChat();
            },
          )
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatbotUiController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: AppColors.divider.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: controller.textController,
                    maxLines: 4,
                    minLines: 1,
                    cursorColor: AppColors.primary,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      hintText: TTexts.chatbotInputHint.tr,
                      hintStyle: const TextStyle(
                          color: AppColors.subText, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]),
                  child: const Icon(Iconsax.send_1_copy,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageRouter(ChatMessage msg) {
    if (msg.isUser) return ChatBubbleStandard(message: msg);

    switch (msg.intent) {
      case 'get_product_info':
      if (msg.data == null) return ChatBubbleStandard(message: msg);
        return ChatCardProductInfo(message: msg);
      case 'confirm_import':
      case 'confirm_export':
        return ChatCardActionConfirm(message: msg);
      case 'get_low_stock':
        return ChatCardLowStock(message: msg);
      case 'choose_product':
        return ChatCardChooseProduct(message: msg);
      default:
        return ChatBubbleStandard(message: msg);
    }
  }
}
