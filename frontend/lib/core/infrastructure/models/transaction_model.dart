// lib/core/infrastructure/models/transaction_model.dart
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';

class TransactionModel {
  final String? transactionId;
  final DateTime? createdAt;
  final String? note;
  final double totalPrice;
  final String? userId;
  final String type;
  final String status;
  final int itemCount;
  final List<TransactionDetailModel> items;

  TransactionModel({
    this.transactionId,
    this.createdAt,
    this.note,
    required this.totalPrice,
    this.userId,
    required this.type,
    this.status = 'COMPLETED',
    this.itemCount = 0,
    required this.items,
  });
  
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] ?? json['transaction_id'],
      createdAt: (json['createdAt'] != null || json['created_at'] != null)
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,
      note: json['note'],
      totalPrice: double.tryParse(json['totalPrice']?.toString() ??
              json['total_price']?.toString() ??
              '0') ??
          0.0,
      userId: json['userId'] ?? json['user_id'],
      type: json['type']?.toString() ?? 'unknown',
      status: json['status']?.toString().toUpperCase() ?? 'COMPLETED',
      itemCount: int.tryParse(json['itemCount']?.toString() ??
              json['item_count']?.toString() ??
              '0') ??
          0,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) =>
                  TransactionDetailModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (note != null) 'note': note,
        'total_price': totalPrice,
        'type': type,
        'status': status,
        'item_count': itemCount,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
