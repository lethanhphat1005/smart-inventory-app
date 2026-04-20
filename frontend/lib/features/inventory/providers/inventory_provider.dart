import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/unit_model.dart'; // IMPORT THÊM UNIT MODEL

class InventoryProvider {
  final _apiClient = ApiClient();

  // ==========================================
  // UNITS
  // ==========================================
  Future<List<UnitModel>> getUnits() async {
    final listData = await _apiClient.getList('/api/units');
    return listData.map((json) => UnitModel.fromJson(json)).toList();
  }

  // ==========================================
  // CATEGORIES
  // ==========================================
  Future<List<CategoryModel>> getCategories() async {
    final listData = await _apiClient
        .getList('/api/categories', queryParameters: {'limit': 100});
    return listData.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/categories', data: data);
    return CategoryModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> updateCategory(
      String categoryId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/categories/$categoryId', data: data);
  }

  Future<void> deleteCategory(String categoryId,
      {bool canReassignToUncategorized = false}) async {
    await _apiClient.delete('/api/categories/$categoryId',
        data: {'canReassignToUncategorized': canReassignToUncategorized});
  }

  Future<void> hideDefaultCategory(String categoryId) async {
    await _apiClient.patch('/api/categories/$categoryId/hide');
  }

  // ==========================================
  // PRODUCTS
  // ==========================================
  Future<List<ProductModel>> getProducts() async {
    final listData = await _apiClient
        .getList('/api/products', queryParameters: {'limit': 100});
    return listData.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getProductDetail(String productId) async {
    final response = await _apiClient.get('/api/products/$productId');
    return response.data['data'] ?? response.data;
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final listData = await _apiClient.getList('/api/products',
        queryParameters: {'categoryId': categoryId, 'limit': 100});
    return listData.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/products', data: data);
    return ProductModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/products/$productId', data: data);
  }

  Future<void> deleteProduct(String productId) async {
    await _apiClient.delete('/api/products/$productId');
  }

  // ==========================================
  // PRODUCT PACKAGES
  // ==========================================
  Future<List<ProductPackageModel>> getPackagesByProduct(
      String productId) async {
    final listData = await _apiClient.getList(
        '/api/products/$productId/packages',
        queryParameters: {'limit': 100});
    return listData.map((json) => ProductPackageModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getProductPackageDetail(String packageId) async {
    final response = await _apiClient.get('/api/product-packages/$packageId');
    return response.data['data'] ?? response.data;
  }

Future<Map<String, dynamic>> createProductPackage(
      String productId, Map<String, dynamic> packageData, Map<String, dynamic> inventoryData) async {
    final response = await _apiClient.post(
      '/api/products/$productId/packages', 
      data: {
        'package': packageData,
        'inventory': inventoryData,
      }
    );
    return response.data['data'] ?? response.data;
  }

  Future<void> updateProductPackage(
      String productPackageId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/product-packages/$productPackageId',
        data: data);
  }

  Future<void> deleteProductPackage(String packageId) async {
    await _apiClient.delete('/api/product-packages/$packageId');
  }

  Future<List<dynamic>> getPackagesByProductId(String productId) async {
    try {
      final response = await _apiClient.get('/api/products/$productId/packages',
          queryParameters: {'limit': 100});

      final responseData = response.data['data'] ?? response.data;
      if (responseData is Map && responseData.containsKey('items')) {
        return responseData['items'] as List<dynamic>;
      } else if (responseData is List) {
        return responseData;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // INVENTORIES & TRANSACTIONS
  // ==========================================
  Future<List<InventoryModel>> getInventories(
      {Map<String, dynamic>? queryParams}) async {
    final listData = await _apiClient.getList('/api/inventories',
        queryParameters: queryParams ?? {'limit': 100});
    return listData.map((json) => InventoryModel.fromJson(json)).toList();
  }

  Future<List<InventoryModel>> getLowStockInventories(
      {Map<String, dynamic>? queryParams}) async {
    final listData = await _apiClient.getList('/api/inventories/low-stock',
        queryParameters: queryParams ?? {'limit': 100});
    return listData.map((json) => InventoryModel.fromJson(json)).toList();
  }

  Future<void> createInventory(String packageId,
      {int quantity = 0, int? reorderThreshold}) async {
    await _apiClient.post('/api/inventories', data: {
      'productPackageId': packageId,
      'quantity': quantity,
      if (reorderThreshold != null) 'reorderThreshold': reorderThreshold,
    });
  }

  Future<InventoryModel> getInventoryDetail(String packageId) async {
    final response =
        await _apiClient.get('/api/inventories/product-packages/$packageId');
    return InventoryModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> updateInventorySettings(String packageId,
      {int? reorderThreshold, int? lastCount}) async {
    await _apiClient
        .patch('/api/inventories/product-packages/$packageId', data: {
      if (reorderThreshold != null) 'reorderThreshold': reorderThreshold,
      if (lastCount != null) 'lastCount': lastCount,
    });
  }

  Future<void> adjustInventory(String packageId,
      {required String type,
      required int quantity,
      String? reason,
      String? note}) async {
    await _apiClient.post(
        '/api/inventories/product-packages/$packageId/adjustments',
        data: {
          'type': type,
          'quantity': quantity,
          if (reason != null) 'reason': reason,
          if (note != null) 'note': note,
        });
  }

  Future<void> deleteInventory(String packageId) async {
    await _apiClient.delete('/api/inventories/product-packages/$packageId');
  }

  // ==========================================
  // TRANSACTIONS FLOW CHARTS
  // ==========================================
  Future<List<TransactionModel>> getTransactions(
      {Map<String, dynamic>? queryParams}) async {
    final listData = await _apiClient.getList('/api/transactions',
        queryParameters: queryParams ?? {'limit': 100});
    return listData.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<List<dynamic>> getAuditLogs(
      {Map<String, dynamic>? queryParams}) async {
    final listData = await _apiClient.getList('/api/audit-logs',
        queryParameters: queryParams ?? {'limit': 100});
    return listData;
  }
}
