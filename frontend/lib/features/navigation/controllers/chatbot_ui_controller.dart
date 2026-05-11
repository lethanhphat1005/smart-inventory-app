import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
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
    // Nếu hành động là đóng chatbot, thực hiện ẩn bàn phím
    if (!isChatOpen.value) {
      _hideKeyboard();
    }
  }

  void closeChat() {
    if (isChatOpen.value) {
      isChatOpen.value = false;
      _hideKeyboard();
    }
  }

  void _hideKeyboard() {
    focusNode.unfocus(); // Bỏ focus khỏi ô nhập liệu
    // Cách tiếp cận an toàn hơn để đảm bảo bàn phím đóng hoàn toàn
    FocusManager.instance.primaryFocus?.unfocus();
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
          style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
        content: Text(
          TTexts.chatbotResetMessage.tr,
          style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 14,
              color: AppColors.primaryText),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TTexts.cancel.tr,
                style: TextStyle(
                    color: AppColors.subText,
                    fontFamily: AppFonts.mainFont,
                    fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _apiClient.delete('/api/chat-bot/history');
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
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontWeight: FontWeight.w600)),
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

      final response = await _apiClient.post(
        '/api/chat-bot/confirm',
        data: {'draftActionId': draftActionId, 'isConfirmed': true},
      );
      final serverMessage = response.data['data']?['message'] as String?;

      message.isResolved = true;
      messages.refresh();

      messages.add(ChatMessage(
        text: serverMessage ?? TTexts.chatbotTransactionSuccess.tr,
        isUser: false,
      ));
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

  Future<void> cancelTransaction(ChatMessage message) async {
    if (message.isResolved) return;

    try {
      isTyping.value = true;
      _scrollToBottom();

      final draftActionId = message.data['draftActionId'];

      // Gọi API báo Hủy cho Backend dọn dẹp Redis
      await _apiClient.post(
        '/api/chat-bot/confirm',
        data: {'draftActionId': draftActionId, 'isConfirmed': false},
      );

      message.isResolved = true;
      messages.refresh();

      // Thông báo cho user là đã hủy thành công
      messages.add(
          ChatMessage(text: "Đã hủy phiếu nháp thành công! ❌", isUser: false));
    } catch (e) {
      handleError(e);
      messages.add(ChatMessage(
          text: "Không thể hủy phiếu, vui lòng thử lại.", isUser: false));
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  Future<void> clearChatData() async {
    try {
      messages.clear();
      isChatOpen.value = false;

      await _apiClient.delete('/api/chat-bot/history');
    } catch (e) {
      debugPrint('Lỗi khi xóa lịch sử chat: $e');
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
