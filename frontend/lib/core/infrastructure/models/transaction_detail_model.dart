import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';

class TransactionDetailModel {
  final String? productPackageId;
  final int quantity;
  final double unitPrice;
  final ProductPackageModel? packageInfo;
  final int currentStock;
  final int reorderThreshold;

  TransactionDetailModel({
    this.productPackageId,
    required this.quantity,
    required this.unitPrice,
    this.packageInfo,
    this.currentStock = 0,
    this.reorderThreshold = 0,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    ProductPackageModel? parsedPackageInfo;

    // Trường hợp 1: Có nested object productPackage (Từ API tạo giỏ hàng)
    if (json['productPackage'] != null) {
      parsedPackageInfo = ProductPackageModel.fromJson(json['productPackage']);
    }
    // Trường hợp 2: JSON bị làm phẳng (Từ API lấy Chi tiết Hóa đơn)
    else if (json['displayName'] != null) {
      parsedPackageInfo = ProductPackageModel(
        productPackageId: json['productPackageId'] ?? '',
        displayName: json['displayName'],
        barcodeValue: json['barcodeValue'],
        importPrice: 0.0,
        sellingPrice: 0.0,
        unitId: '',
        productId: '',
        activeStatus: 'active',
        product: json['imageUrl'] != null
            ? ProductModel(
                productId: '',
                name: json['displayName'] ?? '',
                activeStatus: 'active',
                imageUrl: json['imageUrl'],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                storeId: '',
                categoryId: '',
              )
            : null,
      );
    }

    return TransactionDetailModel(
      productPackageId: json['productPackageId'] ?? json['product_package_id'],
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ??
              json['unit_price']?.toString() ??
              '0') ??
          0.0,
      packageInfo: parsedPackageInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_package_id': productPackageId,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}
