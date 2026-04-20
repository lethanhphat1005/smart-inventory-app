import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/controllers/network_controller.dart';
import 'package:frontend/core/infrastructure/utils/token_utils.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/store_service.dart';

class SplashController extends GetxController {
  // 1. State variables
  final RxDouble progress = 0.0.obs;
  final RxString loadingMessage = TTexts.splashLoadingStart.tr.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // 3. Private methods
  Future<void> _initializeApp() async {
    // 2. Cập nhật danh sách Tasks dùng Locale
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
        'action': _checkUserAuthentication,
      },
    ];

    for (int i = 0; i < tasks.length; i++) {
      loadingMessage.value = tasks[i]['message'];

      await tasks[i]['action']();

      progress.value = (i + 1) / tasks.length;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _navigateToNextScreen();
  }

  /// TÁC VỤ 1: KIỂM TRA INTERNET
  Future<void> _checkInternetConnection() async {
    final networkManager = NetworkController.instance;

    // Kiểm tra mạng lần đầu
    bool hasInternet = await networkManager.checkInternetDirectly();

    if (!hasInternet) {
      // Ép hiện Dialog bắt ép người dùng kết nối mạng
      networkManager.showNoInternetDialog();

      // Vòng lặp này sẽ "đóng băng" Splash Screen, không cho chạy Tác vụ 2, 3, 4
      // cho đến khi NetworkManager báo là đã có mạng (isConnected = true)
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

  /// TÁC VỤ 4: Xác thực Token với Server
  Future<void> _checkUserAuthentication() async {
    final authService = Get.find<AuthService>();

    // 1. Nếu chưa từng đăng nhập -> Bỏ qua
    if (!authService.isLoggedIn.value) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    // 2. Đã lưu Remember Me
    try {
      final userService = Get.find<UserService>();
      final isProfileLoaded = await userService.fetchAndSaveProfile();

      if (!isProfileLoaded) {
        // LỖI Ở ĐÂY: Lấy profile thất bại (Thường do mạng vừa bật chưa ổn định)

        // KIỂM TRA BẰNG TOKEN UTILS
        if (TokenUtils.isSessionExpired) {
          // Chỉ khi nào Token thực sự đã chết hoặc hết hạn thì mới ném lỗi để Đăng xuất
          throw Exception('Session expired or Invalid');
        } else {
          // Token vẫn còn sống nhăn, chỉ là API Profile bị nghẽn mạng lúc vừa bật Wifi.
          // Ta tha cho nó, cho phép vào App bình thường!
          debugPrint(
              'Profile API failed, but Session is still active. Proceeding to Main...');
          // Có mạng trở lại, token còn sống, tranh thủ cập nhật Notification Token
          await NotificationService.registerTokenWithBackend();
        }
      } else {
        debugPrint('Xác thực và tải profile thành công!');
        // Load profile thành công, mọi thứ hoàn hảo, cập nhật Notification Token
        await NotificationService.registerTokenWithBackend();
      }
    } catch (e) {
      debugPrint('Phiên đăng nhập đã chết hoặc có lỗi nghiêm trọng: $e');

      // 3. CHỈ XÓA SẠCH DỮ LIỆU KHI CHẮC CHẮN TOKEN ĐÃ HỎNG
      await authService.clearAuthData();
    }
  }

  void _navigateToNextScreen() {
    final storage = GetStorage();
    final authService = Get.find<AuthService>();
    final storeService = Get.find<StoreService>();

    final isFirstTime = storage.read('IS_FIRST_TIME') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authService.isLoggedIn.value) {
      // KIỂM TRA XEM ĐÃ CÓ CỬA HÀNG CHƯA BẰNG STORE SERVICE
      if (storeService.currentStoreId.value.isNotEmpty) {
        if (NotificationService.pendingInitialMessage != null) {
          debugPrint(
              "🎯 Splash đã load xong! Bàn giao thông báo cho Router...");
          final msg = NotificationService.pendingInitialMessage!;
          NotificationService.pendingInitialMessage =
              null; // Xóa cờ sau khi lấy
          NotificationService.handleNotificationTap(msg);
          return; // KẾT THÚC SPLASH TẠI ĐÂY, KHÔNG GỌI Get.offAllNamed() NỮA ĐỂ TRÁNH XUNG ĐỘT
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
