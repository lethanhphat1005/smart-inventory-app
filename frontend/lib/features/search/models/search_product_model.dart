import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';

class SearchProductModel {
  final String productId;
  final String productName;
  final String? imageUrl;
  final String? brand;
  final String categoryId;
  final String categoryName;
  final String? productPackageId;
  final String? displayName;
  final String? barcodeValue;
  final double? importPrice;
  final double? sellingPrice;
  final int quantity;
  final int reorderThreshold;
  final String? unitId;
  final String? unitCode;
  final String? unitName;

  SearchProductModel({
    required this.productId,
    required this.productName,
    this.imageUrl,
    this.brand,
    required this.categoryId,
    required this.categoryName,
    this.productPackageId,
    this.displayName,
    this.barcodeValue,
    this.importPrice,
    this.sellingPrice,
    required this.quantity,
    required this.reorderThreshold,
    this.unitId,
    this.unitCode,
    this.unitName,
  });

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    return SearchProductModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? 'Unknown',
      imageUrl: UrlHelperUtils.normalizeImageUrl(json['imageUrl']),
      brand: json['brand'],
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      productPackageId: json['productPackageId'] ?? json['id'] ?? '',
      displayName: json['displayName'],
      barcodeValue: json['barcodeValue'],
      importPrice: json['importPrice']?.toDouble(),
      sellingPrice: json['sellingPrice']?.toDouble(),
      quantity: json['quantity'] ?? 0,
      reorderThreshold: json['reorderThreshold'] ?? 0,
      unitId: json['unitId'],
      unitCode: json['unitCode'],
      unitName: json['unitName'],
    );
  }
}
