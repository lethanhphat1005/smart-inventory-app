import 'package:flutter/foundation.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class UserProfileProvider {
  final _apiClient = ApiClient();

  Future<void> createUserProfile({String fullName = ""}) async {
    try {
      await _apiClient.post(
        '/api/auth/me/profile',
        data: {
          "fullName": fullName != ""
              ? fullName
              : "user@${DateTime.now().millisecondsSinceEpoch}",
        },
      );

      debugPrint("Tạo profile thành công");
    } catch (e) {
      debugPrint("Lỗi tạo profile: $e");
    }
  }

  Future<UserProfileModel> fetchMyProfile() async {
    try {
      final response = await _apiClient.get('/api/auth/me');
      final Map<String, dynamic> data = response.data['data'];

      return UserProfileModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _apiClient.patch('/api/auth/$userId', data: data);
      debugPrint("Cập nhật profile thành công");
    } catch (e) {
      debugPrint("Lỗi cập nhật profile: $e");
      rethrow;
    }
  }
}
