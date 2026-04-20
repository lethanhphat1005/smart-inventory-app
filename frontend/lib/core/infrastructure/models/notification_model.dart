class NotificationModel {
  final String notificationId;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final String? storeId;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.storeId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] ?? json['notificationId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      referenceId: json['reference_id'] ?? json['referenceId'],
      storeId: json['store_id'] ?? json['storeId'], // Lấy từ Backend trả về
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt']).toLocal()
          : DateTime.now(),
    );
  }
}
