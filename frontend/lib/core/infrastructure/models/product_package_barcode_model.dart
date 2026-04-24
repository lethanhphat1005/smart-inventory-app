class ProductPackageBarcodeModel {
  final String productPackageBarcodeId;
  final String barcode;
  final String? type;
  final bool isVerified;
  final String source;

  ProductPackageBarcodeModel({
    required this.productPackageBarcodeId,
    required this.barcode,
    this.type,
    required this.isVerified,
    required this.source,
  });

  factory ProductPackageBarcodeModel.fromJson(Map<String, dynamic> json) {
    return ProductPackageBarcodeModel(
      productPackageBarcodeId:
          json['productPackageBarcodeId'] ?? json['id'] ?? '',
      barcode: json['barcode'] ?? '',
      type: json['type'] ?? json['barcodeType'],
      isVerified: json['isVerified'] ?? true,
      source: json['source'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productPackageBarcodeId': productPackageBarcodeId,
      'barcode': barcode,
      'type': type,
      'isVerified': isVerified,
      'source': source,
    };
  }
}
