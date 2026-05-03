import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/navigation/providers/chatbot_provider.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class ChatbotUiController extends GetxController with TErrorHandler {
  static ChatbotUiController get instance => Get.find();

  final ChatbotProvider _chatbotProvider = ChatbotProvider();
  final ApiClient _apiClient = ApiClient();

  final RxBool isChatOpen = false.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final FocusNode focusNode = FocusNode();

  void toggleChat() {
    isChatOpen.value = !isChatOpen.value;
  }

  void closeChat() {
    if (isChatOpen.value) isChatOpen.value = false;
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();
    _scrollToBottom();

    isTyping.value = true;
    _scrollToBottom();

    try {
      final result = await _chatbotProvider.sendMessageToBot(text);

      final String botReply =
          result['botReply'] ?? TTexts.chatbotFallbackReply.tr;
      final String aiIntent = result['aiIntent'] ?? "unknown";
      final dynamic rawData = result['data'];

      messages.add(ChatMessage(
        text: botReply,
        isUser: false,
        intent: aiIntent,
        data: rawData,
      ));
    } catch (e) {
      handleError(e);
      messages.add(
          ChatMessage(text: TTexts.chatbotConnectionError.tr, isUser: false));
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  void resetChat() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          TTexts.chatbotResetTitle.tr,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Text(
          TTexts.chatbotResetMessage.tr,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.primaryText),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TTexts.cancel.tr,
                style: const TextStyle(
                    color: AppColors.subText,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              messages.clear();
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(TTexts.chatbotResetBtn.tr,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> confirmTransaction(ChatMessage message) async {
    if (message.isResolved) return;

    try {
      isTyping.value = true;
      _scrollToBottom();

      final draftActionId = message.data['draftActionId'];

      await _apiClient.post(
        '/api/chat-bot/confirm',
        data: {'draftActionId': draftActionId, 'isConfirmed': true},
      );

      message.isResolved = true;
      messages.refresh();

      messages.add(ChatMessage(
          text: TTexts.chatbotTransactionSuccess.tr, isUser: false));

      // 1. Cập nhật Dashboard
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadAllHomeData();
      }

      // 2. Cập nhật trang Inventory 
      if (Get.isRegistered<InventoryController>()) {
        Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
      }

      // 3. Cập nhật trang Báo cáo 
      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().fetchTransactions(isRefresh: true);
      }
    } catch (e) {
      handleError(e);

      messages.add(
          ChatMessage(text: TTexts.chatbotTransactionFailed.tr, isUser: false));
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
