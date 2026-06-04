import 'package:frontend/core/infrastructure/network/app_client.dart';

class ChatbotProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> sendMessageToBot(String message) async {
    try {
      final response = await _apiClient.post(
        '/api/chat-bot',
        data: {
          'message': message,
        },
      );

      return response.data['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearChatHistory() async {
    try {
      await _apiClient.delete('/api/chat-bot/history');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmAction(
      String draftActionId, bool isConfirmed) async {
    try {
      final response = await _apiClient.post(
        '/api/chat-bot/confirm',
        data: {
          'draftActionId': draftActionId,
          'isConfirmed': isConfirmed,
        },
      );

      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
