import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/providers/chatbot_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart'; // Import AppClient

class ChatbotUiController extends GetxController with TErrorHandler {
  static ChatbotUiController get instance => Get.find();

  final ChatbotProvider _chatbotProvider = ChatbotProvider();
  final ApiClient _apiClient = ApiClient(); // Thêm ApiClient để gọi transaction

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
          result['botReply'] ?? "Xin lỗi, tôi không hiểu yêu cầu này.";
      final String aiIntent = result['aiIntent'] ?? "unknown";
      final dynamic rawData = result['data'];

      // Thêm tin nhắn AI kèm theo intent và data để UI tự quyết định cách vẽ
      messages.add(ChatMessage(
        text: botReply,
        isUser: false,
        intent: aiIntent,
        data: rawData,
      ));
    } catch (e) {
      handleError(e);
      messages
          .add(ChatMessage(text: "Oops! Mất kết nối đến AI 😢", isUser: false));
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
        title: const Text(
          "Reset Conversation",
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: const Text(
          "Are you sure you want to clear all messages? This action cannot be undone.",
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.primaryText),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          // Nút Cancel
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel",
                style: TextStyle(
                    color: AppColors.subText,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500)),
          ),
          // Nút Reset (Màu cam Primary)
          ElevatedButton(
            onPressed: () {
              messages.clear(); // Xóa sạch tin nhắn
              Get.back(); // Đóng Dialog
              Get.back(); // Out ra khỏi Chatbot Window (như bạn yêu cầu)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Reset",
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Mới (Khớp với Backend 2 pha):
  Future<void> confirmTransaction(ChatMessage message) async {
    if (message.isResolved) return;

    try {
      isTyping.value = true;
      _scrollToBottom();

      // Lấy draftActionId do Backend trả về ở Pha 1
      final draftActionId = message.data['draftActionId'];

      // Bắn lên endpoint confirm mới
      await _apiClient.post(
        '/api/chat-bot/confirm', // Khớp với router: chatbotRouter.post('/confirm', ...)
        data: {
          'draftActionId': draftActionId,
          'isConfirmed': true // Khớp với biến req.body trong Controller
        },
      );

      message.isResolved = true;
      messages.refresh();

      messages.add(ChatMessage(
          text: "✅ Giao dịch thành công! Dữ liệu kho đã được cập nhật.",
          isUser: false));
    } catch (e) {
      handleError(e);
      messages.add(ChatMessage(
          text: "Giao dịch thất bại. Yêu cầu có thể đã hết hạn.",
          isUser: false));
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
