class ChatMessage {
  final String text;
  final bool isUser;
  final String? intent; // Loại thẻ cần vẽ (ví dụ: 'confirm_import', 'get_product_info')
  final dynamic data;   // Dữ liệu JSON gốc từ Backend
  bool isResolved;      // Đánh dấu xem thẻ xác nhận đã được bấm hay chưa (tránh bấm 2 lần)

  ChatMessage({
    required this.text,
    required this.isUser,
    this.intent,
    this.data,
    this.isResolved = false,
  });
}