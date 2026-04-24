import 'package:frontend/core/infrastructure/network/app_client.dart';

class StoreMemberProvider {
  final _apiClient = ApiClient();

  Future<List<dynamic>> getStoreMembers(String storeId) async {
    try {
      final response =
          await _apiClient.get('/api/store-members/$storeId/members');

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }

      return [];
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
