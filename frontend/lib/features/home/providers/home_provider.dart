import 'package:flutter/foundation.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';

class HomeProvider {
  final _apiClient = ApiClient();

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final now = DateTime.now();
      final startDateStr =
          DayFormatterUtils.formatApiDate(DateTime(now.year, now.month - 1, 1));
      final endDateStr =
          DayFormatterUtils.formatApiDate(DateTime(now.year, now.month + 1, 0));

      final response =
          await _apiClient.get('/api/transactions', queryParameters: {
        'limit': 100,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        'startDate': startDateStr,
        'endDate': endDateStr,
      });

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
      } else if (response.data is Map && response.data.containsKey('items')) {
        listData = response.data['items'];
      }

      return listData.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Lỗi getTransactions (Home): $e");
      return [];
    }
  }

  Future<List<InventoryModel>> getLowStockInventories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response =
          await _apiClient.get('/api/inventories/low-stock', queryParameters: {
        'page': page,
        'limit': limit,
        'sortBy': 'quantity',
        'sortOrder': 'asc',
      });

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
      } else if (response.data is Map && response.data.containsKey('items')) {
        listData = response.data['items'];
      }

      return listData.map((json) => InventoryModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Lỗi getLowStockInventories (Home): $e");
      return [];
    }
  }

  Future<List<InventoryModel>> getAllInventories() async {
    try {
      int currentPage = 1;
      int totalPages = 1;
      List<InventoryModel> allItems = [];

      do {
        final response =
            await _apiClient.get('/api/inventories', queryParameters: {
          'limit': 100,
          'page': currentPage,
        });

        final responseData = response.data['data'];
        List<dynamic> listData = [];

        if (responseData != null) {
          if (responseData is Map) {
            if (responseData.containsKey('items')) {
              listData = responseData['items'];
            }
            totalPages = responseData['totalPages'] ?? 1;
          } else if (responseData is List) {
            listData = responseData;
          }
        }

        final inventories =
            listData.map((json) => InventoryModel.fromJson(json)).toList();
        allItems.addAll(inventories);

        currentPage++;
      } while (currentPage <= totalPages);

      return allItems;
    } catch (e) {
      debugPrint("Lỗi getAllInventories (Home): $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTodayAuditLogs() async {
    try {
      final now = DateTime.now();

      // Lấy chính xác điểm bắt đầu và kết thúc của "Ngày hôm nay" ở Local
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      // Chuyển sang chuẩn ISO 8601 (UTC) để Backend Prisma đọc
      final startDateStr = startOfDay.toUtc().toIso8601String();
      final endDateStr = endOfDay.toUtc().toIso8601String();

      final response =
          await _apiClient.get('/api/audit-logs', queryParameters: {
        'limit': 100,
        'entityType': 'Inventory',
        'startDate': startDateStr,
        'endDate': endDateStr,
        'sortBy': 'performedAt',
        'sortOrder': 'desc',
      });

      final responseData = response.data['data'];
      List<dynamic> listData = [];

      if (responseData != null) {
        if (responseData is Map && responseData.containsKey('items')) {
          listData = responseData['items'];
        } else if (responseData is List) {
          listData = responseData;
        }
      }
      return listData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Lỗi getTodayAuditLogs: $e");
      return [];
    }
  }

  Future<List<InventoryModel>> getAllInventoriesForDictionary() async {
    try {
      int currentPage = 1;
      int totalPages = 1;
      List<InventoryModel> allItems = [];

      do {
        final response =
            await _apiClient.get('/api/inventories', queryParameters: {
          'limit': 100,
          'page': currentPage,
        });
        final responseData = response.data['data'];
        List<dynamic> listData = [];

        if (responseData != null) {
          if (responseData is Map && responseData.containsKey('items')) {
            listData = responseData['items'];
            totalPages = responseData['totalPages'] ?? 1;
          } else if (responseData is List) {
            listData = responseData;
          }
        }
        allItems.addAll(
            listData.map((json) => InventoryModel.fromJson(json)).toList());
        currentPage++;
      } while (currentPage <= totalPages);

      return allItems;
    } catch (e) {
      debugPrint("Lỗi getAllInventoriesForDictionary: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({
    int page = 1,
    int limit = 20,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        'entityType': 'Inventory',
        'sortBy': 'performedAt',
        'sortOrder': 'desc',
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response =
          await _apiClient.get('/api/audit-logs', queryParameters: queryParams);
      final responseData = response.data['data'];
      List<dynamic> listData = [];

      if (responseData != null) {
        if (responseData is Map && responseData.containsKey('items')) {
          listData = responseData['items'];
        } else if (responseData is List) {
          listData = responseData;
        }
      }
      return listData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Lỗi getAuditLogs (Provider): $e");
      return [];
    }
  }
}
