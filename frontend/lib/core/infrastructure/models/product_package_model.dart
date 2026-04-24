import 'package:frontend/core/infrastructure/models/unit_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_barcode_model.dart';

class ProductPackageModel {
  final String productPackageId;
  final String displayName;
  final double importPrice;
  final double sellingPrice;
  final String unitId;
  final String productId;
  final String activeStatus;
  final String? variant;

  final List<ProductPackageBarcodeModel> barcodes;
  final String? barcodeValue;
  final String? barcodeType;

  final UnitModel? unit;
  final ProductModel? product;

  ProductPackageModel({
    required this.productPackageId,
    required this.displayName,
    required this.importPrice,
    required this.sellingPrice,
    required this.unitId,
    required this.productId,
    required this.activeStatus,
    this.variant,
    this.barcodes = const [],
    this.barcodeValue,
    this.barcodeType,
    this.unit,
    this.product,
  });

  factory ProductPackageModel.fromJson(Map<String, dynamic> json) {
    List<ProductPackageBarcodeModel> parsedBarcodes = [];
    if (json['productPackageBarcodes'] != null) {
      parsedBarcodes = (json['productPackageBarcodes'] as List)
          .map((e) => ProductPackageBarcodeModel.fromJson(e))
          .toList();
    }

    String? mainBarcodeValue = json['barcodeValue']?.toString();
    String? mainBarcodeType = json['barcodeType']?.toString();

    if (parsedBarcodes.isNotEmpty) {
      mainBarcodeValue ??= parsedBarcodes.first.barcode;
      mainBarcodeType ??= parsedBarcodes.first.type;
    }

    return ProductPackageModel(
      productPackageId: json['productPackageId'] ?? '',
      displayName: json['displayName'] ?? 'Unknown Package',
      importPrice:
          double.tryParse(json['importPrice']?.toString() ?? '0') ?? 0.0,
      sellingPrice:
          double.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0.0,
      unitId: json['unitId'] ?? json['unit']?['unitId'] ?? '',
      productId: json['productId'] ?? json['product']?['productId'] ?? '',
      activeStatus: json['activeStatus'] ?? 'active',
      variant: json['variant'],
      barcodes: parsedBarcodes,
      barcodeValue: mainBarcodeValue,
      barcodeType: mainBarcodeType,
      unit: json['unit'] != null ? UnitModel.fromJson(json['unit']) : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productPackageId': productPackageId,
      'displayName': displayName,
      'importPrice': importPrice,
      'sellingPrice': sellingPrice,
      'unitId': unitId,
      'productId': productId,
      'activeStatus': activeStatus,
      'variant': variant,
      'barcodeValue': barcodeValue,
      'barcodeType': barcodeType,
      'unit': unit?.toJson(),
      'product': product?.toJson(),
    };
  }

  ProductPackageModel copyWith({
    String? productPackageId,
    String? displayName,
    double? importPrice,
    double? sellingPrice,
    String? unitId,
    String? productId,
    String? activeStatus,
    String? variant,
    List<ProductPackageBarcodeModel>? barcodes,
    String? barcodeValue,
    String? barcodeType,
    UnitModel? unit,
    ProductModel? product,
  }) {
    return ProductPackageModel(
      productPackageId: productPackageId ?? this.productPackageId,
      displayName: displayName ?? this.displayName,
      importPrice: importPrice ?? this.importPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unitId: unitId ?? this.unitId,
      productId: productId ?? this.productId,
      activeStatus: activeStatus ?? this.activeStatus,
      variant: variant ?? this.variant,
      barcodes: barcodes ?? this.barcodes,
      barcodeValue: barcodeValue ?? this.barcodeValue,
      barcodeType: barcodeType ?? this.barcodeType,
      unit: unit ?? this.unit,
      product: product ?? this.product,
    );
  }
}
