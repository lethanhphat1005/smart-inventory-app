import 'package:flutter/material.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/routes/app_routes.dart';

class UserService extends GetxService {
  final UserProfileProvider _profileProvider = UserProfileProvider();

  // Biến observable lưu trữ thông tin user hiện tại.
  // Dùng Rxn (hoặc Rx<UserProfileModel?>) để cho phép giá trị null khi chưa đăng nhập.
  final Rx<UserProfileModel?> currentUser = Rx<UserProfileModel?>(null);

  // Biến loading để UI (ví dụ màn hình splash) có thể lắng nghe
  final RxBool isLoading = false.obs;

  Object? get stores => null;

  Future<UserService> init() async {
    return this;
  }

  // Hàm này gọi sau khi login thành công HOẶC khi app mở lên có remember me
  Future<bool> fetchAndSaveProfile() async {
    isLoading.value = true;
    try {
      // Gọi provider để lấy data từ backend
      final profile = await _profileProvider.fetchMyProfile();
      currentUser.value = profile; // Lưu vào RAM

      return true;
    } catch (e) {
      clearUser();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Xóa data trên RAM khi logout
  void clearUser() {
    currentUser.value = null;
  }

  // =========================================================================
  // BẪY LỖI KIỂM TRA QUYỀN CHỦ CỬA HÀNG (OWNER SECURITY TRAP)
  // =========================================================================
  void enforceOwnerSecurityTrap(String storeCreatorId, String currentRole) {
    final user = currentUser.value;
    if (user == null) return;

    // Nếu ID của user hiện tại TRÙNG KHỚP với ID của người tạo ra Store
    if (user.userId == storeCreatorId) {
      // Thì chắc chắn 100% quyền BẮT BUỘC phải là 'owner'
      if (currentRole.toLowerCase() != 'owner') {
        debugPrint(
            "🚨 BẪY BẢO MẬT KÍCH HOẠT: Phát hiện sai lệch quyền hạn! User tạo ra Store nhưng bị gán quyền '$currentRole'. Đang tiến hành đăng xuất khẩn cấp...");

        // 1. Xóa sạch dữ liệu đăng nhập trong ổ cứng
        Get.find<AuthService>().clearAuthData();

        // 2. Xóa sạch thông tin user trên RAM
        clearUser();

        // 3. Đá văng người dùng ra màn hình Đăng nhập ngay lập tức
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}
