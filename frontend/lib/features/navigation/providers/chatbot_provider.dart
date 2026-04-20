import 'package:frontend/core/infrastructure/network/app_client.dart';

class ChatbotProvider {
  // Khởi tạo ApiClient đã được cấu hình sẵn base URL, timeout và interceptors (gắn token, storeId)
  final ApiClient _apiClient = ApiClient();

  /// Gửi tin nhắn lên AI Chatbot Backend
  /// Phương thức POST đến endpoint: /chatbot
  Future<Map<String, dynamic>> sendMessageToBot(String message) async {
    try {
      final response = await _apiClient.post(
        '/api/chat-bot', // Đảm bảo AppConstants.baseUrl đã có đuôi '/api'
        data: {
          'message': message,
        },
      );

      // Backend trả về chuẩn ApiResponse: { success: true, data: { aiIntent, botReply, data: ... } }
      // Trả về thẳng block 'data' bên trong cho Controller xử lý
      return response.data['data'] ?? {};
    } catch (e) {
      // Quăng lỗi ra cho Controller hứng và đưa vào handleError()
      rethrow; 
    }
  }
}