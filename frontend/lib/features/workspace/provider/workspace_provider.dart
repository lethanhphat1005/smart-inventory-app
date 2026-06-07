// lib/features/workspace/providers/workspace_provider.dart
import 'package:frontend/core/infrastructure/models/currency_model.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class WorkspaceProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<StoreModel>> getMyStores() async {
    try {
      final response = await _apiClient.get('/api/stores');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // --- BỔ SUNG HÀM CREATE STORE ---
  Future<StoreModel> createStore(Map<String, dynamic> storeData) async {
    try {
      // Gọi POST endpoint '/' như định nghĩa trong store.route.ts của bạn
      final response = await _apiClient.post('/api/stores', data: storeData);

      // Lấy data trả về từ Backend
      final dynamic data = response.data['data'] ?? response.data;
      return StoreModel.fromJson(data);
    } catch (e) {
      rethrow; // Ném lỗi ra để Controller dùng TExceptions xử lý
    }
  }

  Future<StoreModel> joinStore(String inviteCode) async {
    try {
      final response = await _apiClient.post(
        '/api/stores/join',
        data: {'inviteCode': inviteCode},
      );
      final dynamic data = response.data['data'] ?? response.data;
      return StoreModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
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

  Future<StoreModel> getStoreById(String storeId) async {
    try {
      final response = await _apiClient.get('/api/stores/$storeId');
      final dynamic data = response.data['data'] ?? response.data;
      return StoreModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> refreshInviteCode(String storeId) async {
    try {
      final response = await _apiClient.post(
        '/api/stores/refresh-invite-code',
      );

      final dynamic data = response.data['data'] ?? response.data;
      return data['inviteCode'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMemberRole(String userId, String newRole) async {
    try {
      await _apiClient.patch(
        '/api/store-members/$userId/role',
        data: {
          'role': newRole,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response = await _apiClient.get('/api/currencies');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => CurrencyModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
