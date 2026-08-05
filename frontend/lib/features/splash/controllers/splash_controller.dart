import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/controllers/network_controller.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Đã thêm thư viện Supabase

class SplashController extends GetxController {
  // 1. State variables
  final RxDouble progress = 0.0.obs;
  // Khởi tạo text mặc định tránh rỗng
  final RxString loadingMessage = "Starting...".obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // 3. Private methods
  Future<void> _initializeApp() async {
    progress.value = 0.0;

    final List<Map<String, dynamic>> tasks = [
      {
        'message': TTexts.splashLoadingInternet.tr,
        'action': _checkInternetConnection,
      },
      {
        'message': TTexts.splashLoadingSettings.tr,
        'action': _loadSystemSettings,
      },
      {'message': TTexts.splashLoadingServices.tr, 'action': _initCoreServices},
      {
        'message': TTexts.splashLoadingUser.tr,
        'action': _checkUserAuthentication, // Tác vụ được điều chỉnh
      },
    ];

    try {
      for (int i = 0; i < tasks.length; i++) {
        loadingMessage.value = tasks[i]['message'];

        await tasks[i]['action']();

        progress.value = (i + 1) / tasks.length;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _navigateToNextScreen();
    } catch (e) {
      debugPrint('🚨 Tiến trình Splash bị chặn: $e');

      if (!NetworkController.instance.isConnected.value) {
        return;
      }

      // NẾU BẮT ĐƯỢC LỖI SERVER SẬP -> HIỆN DIALOG LIVE BẮT THỬ LẠI
      if (e.toString().contains('SERVER_CONNECTION_ERROR')) {
        _showServerDownDialog();
      }
      // CÁC LỖI NGHIÊM TRỌNG KHÁC (như Token chết) -> XOÁ DATA VÀ RA LOGIN
      else {
        // Chủ động gọi Supabase signOut để dọn rác
        await Supabase.instance.client.auth.signOut();
        await Get.find<AuthService>().clearAuthData();
        _navigateToNextScreen();
      }
    }
  }

  /// TÁC VỤ 1: KIỂM TRA INTERNET
  Future<void> _checkInternetConnection() async {
    final networkManager = NetworkController.instance;

    // Kiểm tra mạng lần đầu
    bool hasInternet = await networkManager.checkInternetDirectly();

    if (!hasInternet) {
      networkManager.isConnected.value = false;

      networkManager.showNoInternetDialog();

      // Lúc này vòng lặp mới thực sự "giam" app lại cho đến khi có mạng
      while (!networkManager.isConnected.value) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  /// TÁC VỤ 2: Load data ứng dụng
  Future<void> _loadSystemSettings() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // TÁC VỤ 3: Load các core Service của hệ thống
  Future<void> _initCoreServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// TÁC VỤ 4: Xác thực Token với Server (ĐÃ ĐƯỢC CHỈNH SỬA)
  Future<void> _checkUserAuthentication() async {
    final authService = Get.find<AuthService>();
    final storage = GetStorage();

    // Nếu chưa từng đăng nhập -> Bỏ qua
    if (!authService.isLoggedIn.value) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    try {
      final session = Supabase.instance.client.auth.currentSession;

      // 🌟 THỰC THI LUỒNG THỦ CÔNG: Kiểm tra Token hết hạn hoặc rỗng
      if (session == null || session.isExpired) {
        debugPrint(
            "⏳ Token hết hạn hoặc bị mất. Đang lôi Refresh Token từ Local ra...");

        // 1. Đọc Refresh Token từ Local
        final savedRefreshToken = storage.read('REFRESH_TOKEN');

        if (savedRefreshToken == null) {
          throw Exception(
              'Không tìm thấy Refresh Token trong Local. Yêu cầu Login lại.');
        }

        // 2. Gọi ép hàm phục hồi phiên (setSession / refreshSession) truyền thẳng Token vào
        final response =
            await Supabase.instance.client.auth.setSession(savedRefreshToken);

        if (response.session == null) {
          throw Exception('Refresh Token đã bị Server từ chối (Revoked).');
        }

        // 3. Cập nhật lại Refresh Token MỚI NHẤT vào Local để xài cho lần sau
        await storage.write('REFRESH_TOKEN', response.session!.refreshToken!);
        debugPrint(
            "✅ Đã lấy Access Token mới thành công từ Local Refresh Token!");
      }

      // Đã lưu Remember Me & Token đều hợp lệ
      final userService = Get.find<UserService>();
      final isProfileLoaded = await userService.fetchAndSaveProfile();

      if (!isProfileLoaded) {
        throw Exception('SERVER_CONNECTION_ERROR');
      } else {
        debugPrint('Xác thực và tải profile thành công!');
        await NotificationService.registerTokenWithBackend();
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showServerDownDialog() {
    Get.dialog(
      PopScope(
        canPop: false, // Chặn bấm nút Back để thoát
        child: TCustomDialogWidget(
          icon: const Text('☁️', style: TextStyle(fontSize: 40)),
          title: TTexts.errorServerTitle.tr,
          description: TTexts.errorServerMessage.tr,
          primaryButtonText: TTexts.tryAgain.tr,
          onPrimaryPressed: () {
            Get.back(); // Đóng Dialog
            _initializeApp(); // Chạy lại toàn bộ vòng kiểm tra từ đầu
          },
        ),
      ),
      barrierDismissible: false, // Bấm ra ngoài không tắt được
    );
  }

  void _navigateToNextScreen() {
    final storage = GetStorage();
    final authService = Get.find<AuthService>();
    final storeService = Get.find<StoreService>();

    // 1. Kiểm tra xem đã chọn ngôn ngữ lần đầu chưa
    final isLanguageSelected = storage.read('IS_LANGUAGE_SELECTED') ?? false;
    if (!isLanguageSelected) {
      Get.offAllNamed(AppRoutes.languageSelect);
      return;
    }

    // 2. Kiểm tra Onboarding (Logic cũ của bạn)
    final isFirstTime = storage.read('IS_FIRST_TIME') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authService.isLoggedIn.value) {
      // ... giữ nguyên logic kiểm tra store và notification của bạn
      if (storeService.currentStoreId.value.isNotEmpty) {
        if (NotificationService.pendingInitialMessage != null) {
          debugPrint(
              "🎯 Splash đã load xong! Bàn giao thông báo cho Router...");
          final msg = NotificationService.pendingInitialMessage!;
          NotificationService.pendingInitialMessage = null;
          NotificationService.handleNotificationTap(msg);
          return;
        }

        // Có rồi -> Vào thẳng Home bỏ qua màn chọn
        Get.offAllNamed(AppRoutes.main);
      } else {
        // Chưa có -> Bắt chọn cửa hàng
        Get.offAllNamed(AppRoutes.storeSelection);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
