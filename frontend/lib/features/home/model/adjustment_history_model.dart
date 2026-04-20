import 'dart:convert';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class AdjustmentHistoryModel {
  final String id;
  final String productName;
  final int oldQuantity;
  final int newQuantity;
  final int difference;
  final DateTime performedAt;
  final String note;

  bool get isPositive => difference > 0;

  AdjustmentHistoryModel({
    required this.id,
    required this.productName,
    required this.oldQuantity,
    required this.newQuantity,
    required this.difference,
    required this.performedAt,
    required this.note,
  });

  // ĐÃ SỬA: Thêm từ khóa "factory" vào đây
  factory AdjustmentHistoryModel.fromJson(Map<String, dynamic> json) {
    dynamic oldRaw = json['oldValue'] ?? json['old_value'];
    dynamic newRaw = json['newValue'] ?? json['new_value'];

    Map<String, dynamic> oldVal = {};
    Map<String, dynamic> newVal = {};

    if (oldRaw is String) {
      try {
        oldVal = jsonDecode(oldRaw);
      } catch (_) {}
    } else if (oldRaw is Map) {
      oldVal = Map<String, dynamic>.from(oldRaw);
    }

    if (newRaw is String) {
      try {
        newVal = jsonDecode(newRaw);
      } catch (_) {}
    } else if (newRaw is Map) {
      newVal = Map<String, dynamic>.from(newRaw);
    }

    int oldQty = int.tryParse(oldVal['quantity']?.toString() ?? '0') ?? 0;
    int newQty = int.tryParse(newVal['quantity']?.toString() ?? '0') ?? 0;

    // Ưu tiên lấy Note, nếu không có thì fallback
    String pName = json['note']?.toString() ?? '';
    if (pName.isEmpty || pName == 'null') {
      pName = TTexts.systemAdjustment.tr;
    }

    final dateStr = json['performedAt'] ??
        json['performed_at'] ??
        DateTime.now().toIso8601String();

    return AdjustmentHistoryModel(
      id: json['id']?.toString() ??
          json['event_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      productName:
          pName, // Ta dùng note làm tên SP dựa trên logic tối ưu trước đó
      oldQuantity: oldQty,
      newQuantity: newQty,
      difference: newQty - oldQty,
      performedAt: DateTime.parse(dateStr).toLocal(),
      note: json['note']?.toString() ?? '',
    );
  }
}
