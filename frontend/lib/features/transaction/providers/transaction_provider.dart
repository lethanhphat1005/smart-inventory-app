import 'package:frontend/core/infrastructure/network/app_client.dart';

class TransactionProvider {
  final _apiClient = ApiClient();

  Future<Map<String, dynamic>> createImportTransaction({
    required String note,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/transactions/import',
        data: {
          if (note.isNotEmpty) 'note': note,
          'items': items,
        },
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createExportTransaction({
    required String note,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/transactions/export',
        data: {
          if (note.isNotEmpty) 'note': note,
          'items': items,
        },
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInventoryDetailByPackageId(
      String packageId) async {
    try {
      final response =
          await _apiClient.get('/api/inventories/product-packages/$packageId');
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Lỗi khi fetch chi tiết tồn kho: $e');
    }
  }

  Future<void> batchAdjustInventories({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await _apiClient.post(
        '/api/inventories/adjustments',
        data: {
          'items': items,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductPackage(
      String productPackageId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/product-packages/$productPackageId',
        data: data);
  }

  Future<List<dynamic>> getInventoriesForAdjustment() async {
    try {
      final response = await _apiClient.get('/api/inventories?limit=100');
      final data = response.data['data']?['items'] ??
          response.data['data'] ??
          response.data;
      if (data is List) return data;
      return [];
    } catch (e) {
      throw Exception('Lỗi khi fetch danh sách tồn kho: $e');
    }
  }

  Future<Map<String, dynamic>> getProductPackageById(String packageId) async {
    try {
      final response = await _apiClient.get('/api/product-packages/$packageId');
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Lỗi khi fetch chi tiết product package: $e');
    }
  }

  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await _apiClient.get('/api/products/$productId');
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Lỗi khi fetch chi tiết product: $e');
    }
  }

  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    final response = await _apiClient.post(
      '/api/barcodes/scan',
      data: {'barcode': barcode},
    );
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getInventoriesPaginated({
    int page = 1,
    int limit = 20,
    String? keyword,
  }) async {
    try {
      String url =
          '/api/inventories?page=$page&limit=$limit&sortBy=quantity&sortOrder=asc';
      if (keyword != null && keyword.isNotEmpty) {
        url += '&keyword=$keyword';
      }
      final response = await _apiClient.get(url);
      return response.data['data'] ?? {};
    } catch (e) {
      throw Exception('Lỗi khi fetch danh sách tồn kho phân trang: $e');
    }
  }
}
