import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:get/get.dart';

class StoreMemberProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<dynamic>> getStoreMembers() async {
    try {
      final response = await _apiClient.get('/api/store-members');

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRole(String userId, String role) async {
    try {
      await _apiClient.patch(
        '/api/store-members/$userId/role',
        data: {'role': role.toLowerCase()},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeStoreMember(String userId) async {
    try {
      await _apiClient.delete('/api/store-members/$userId');
    } catch (e) {
      rethrow;
    }
  }
}
