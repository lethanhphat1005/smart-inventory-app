import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';

class ProductModel {
  final String productId;
  final String name;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? brand;
  final String storeId;
  final String categoryId;
  final String activeStatus;

  ProductModel({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    required this.storeId,
    required this.categoryId,
    required this.activeStatus,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      imageUrl: UrlHelperUtils.normalizeImageUrl(json['imageUrl']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      brand: json['brand'],
      storeId: json['storeId'] ?? json['store']?['storeId'] ?? '',
      categoryId: json['categoryId'] ?? json['category']?['categoryId'] ?? '',
      activeStatus: json['activeStatus'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'brand': brand,
      'storeId': storeId,
      'categoryId': categoryId,
      'activeStatus': activeStatus,
    };
  }
}
