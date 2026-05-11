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
}
