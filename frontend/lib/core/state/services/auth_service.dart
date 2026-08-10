import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final storage = GetStorage();

  // Biến quản lý trạng thái đăng nhập
  final RxBool isLoggedIn = false.obs;
  final RxString currentUserEmail = ''.obs;

  Future<AuthService> init() async {
    // Đọc ổ cứng xem trước đó đã đăng nhập chưa
    isLoggedIn.value = storage.read('IS_LOGGED_IN') ?? false;
    currentUserEmail.value = storage.read('USER_EMAIL') ?? '';

    // Nếu trước đó đăng nhập KHÔNG tick Remember Me -> Ép đăng xuất khi mở lại App
    if (!isLoggedIn.value) {
      await Supabase.instance.client.auth.signOut();
    }

    return this;
  }

  // Lưu trạng thái khi đăng nhập thành công
  Future<void> saveUserLogin(
      String email, String password, bool rememberMe) async {
    if (rememberMe) {
      await storage.write('IS_LOGGED_IN', true);
      await storage.write('USER_EMAIL', email);

      // Bóc và lưu trực tiếp Refresh Token vào GetStorage
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.refreshToken != null) {
        await storage.write('REFRESH_TOKEN', session.refreshToken);
      }
    } else {
      await storage.remove('IS_LOGGED_IN');
      await storage.remove('REFRESH_TOKEN'); // Xóa khi không Remember Me
    }

    // Cập nhật lên RAM để UI phản hồi ngay lập tức
    isLoggedIn.value = true;
    currentUserEmail.value = email;
  }

  // Xóa sạch dữ liệu khi Đăng xuất
  Future<void> clearAuthData() async {
    await storage.remove('IS_LOGGED_IN');
    await storage.remove('USER_EMAIL');
    await storage.remove('REFRESH_TOKEN'); 
    isLoggedIn.value = false;
    currentUserEmail.value = '';
  }
}
