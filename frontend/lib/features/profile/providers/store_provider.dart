import 'package:frontend/core/infrastructure/network/app_client.dart';

class StoreProvider {
  final _apiClient = ApiClient();

  Future<List<dynamic>> getMyStores() async {
    try {
      final response = await _apiClient.get('/api/stores');

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStoreDetail(String storeId) async {
    try {
      final response = await _apiClient.get('/api/stores/$storeId');

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Không tìm thấy dữ liệu cửa hàng');
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật thông tin cửa hàng hiện tại
  Future<void> updateStore(Map<String, dynamic> data) async {
    try {
      await _apiClient.patch('/api/stores/', data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Xóa mềm cửa hàng theo storeId
  Future<void> deleteStore(String storeId) async {
    try {
      await _apiClient.delete('/api/stores/$storeId');
    } catch (e) {
      rethrow;
    }
  }

  // Refresh mã mời
  Future<Map<String, dynamic>> refreshInviteCode() async {
    try {
      final response = await _apiClient.post('/api/stores/refresh-invite-code');

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Không thể tạo mới mã mời');
    } catch (e) {
      rethrow;
    }
  }

  // Join store bằng invite code
  Future<Map<String, dynamic>> joinStore(String inviteCode) async {
    try {
      final response = await _apiClient.post(
        '/api/stores/join',
        data: {
          'inviteCode': inviteCode,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Không thể tham gia cửa hàng');
    } catch (e) {
      rethrow;
    }
  }
}
