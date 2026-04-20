import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/features/search/models/search_product_model.dart';

class SearchProvider {
  final _apiClient = ApiClient();

  // Hàm tìm kiếm chính (Giữ nguyên của bạn)
  Future<Map<String, dynamic>> searchProductsByKeyword(String keyword,
      {int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      '/api/search/product-packages',
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data['data'];
    final items = (data['items'] as List)
        .map((json) => SearchProductModel.fromJson(json))
        .toList();

    return {
      'items': items,
      'totalItems': data['totalItems'] ?? 0,
      'totalPages': data['totalPages'] ?? 1,
    };
  }

  // Hàm gọi API Suggestion (Did you mean)
  Future<List<Map<String, dynamic>>> searchProductsByPrefix(String prefix,
      {int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/api/search/products/prefix',
        queryParameters: {
          'prefix': prefix,
          'limit': limit,
        },
      );
      final data = response.data['data'] ?? response.data;

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<TransactionModel>> searchTransactions(
      {Map<String, dynamic>? queryParams}) async {
    final response = await _apiClient.get(
      '/api/transactions',
      queryParameters: queryParams ??
          {'limit': 100, 'sortBy': 'createdAt', 'sortOrder': 'desc'},
    );

    final responseData = response.data['data'];
    List<dynamic> listData = [];

    if (responseData != null) {
      if (responseData is Map && responseData.containsKey('items')) {
        listData = responseData['items'];
      } else if (responseData is List) {
        listData = responseData;
      }
    } else if (response.data is List) {
      listData = response.data;
    }

    return listData.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<List<StoreMemberModel>> getStoreMembers(
      String storeId, String currentUserId) async {
    try {
      final response =
          await _apiClient.get('/api/store-members/$storeId/members');

      final List<dynamic> data = response.data['data'] ?? response.data;

      return data
          .map((json) =>
              StoreMemberModel.fromJson(json, currentUserId: currentUserId))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
