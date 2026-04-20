class ReorderSuggestionModel {
  final String productId;
  final String productName;
  final int currentStock;
  final int suggestedQuantity;
  final int suggestedThreshold;
  final String reason;

  ReorderSuggestionModel({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.suggestedQuantity,
    required this.suggestedThreshold,
    required this.reason,
  });

  factory ReorderSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ReorderSuggestionModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? 'Sản phẩm',
      currentStock: int.tryParse(json['currentStock']?.toString() ?? '0') ?? 0,
      suggestedQuantity:
          int.tryParse(json['suggestedQuantity']?.toString() ?? '0') ?? 0,
      suggestedThreshold:
          int.tryParse(json['suggestedThreshold']?.toString() ?? '0') ?? 0,
      reason: json['reason'] ?? '',
    );
  }
}
