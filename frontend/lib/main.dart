import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:frontend/core/infrastructure/localization/app_translations.dart';
import 'package:frontend/core/state/bindings/initial_binding.dart';
import 'package:frontend/core/state/services/auth_service.dart'
    show AuthService;
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/ui/theme/app_theme.dart';

// Hàm xử lý thông báo khi app chạy ngầm (Top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cho phép bỏ qua kiểm tra chứng chỉ SSL (Hữu ích khi dev với backend local)
  HttpOverrides.global = MyHttpOverrides();

  // 1. Khởi tạo Storage và Supabase
  await GetStorage.init();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 2. Khởi tạo Firebase và Notification Service
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();

  // 3. Khởi tạo các Dịch vụ toàn cục (Global Services)
  // App sẽ đợi các dịch vụ này nạp xong dữ liệu cũ trước khi render UI
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => UserService().init());
  await Get.putAsync(() => StoreService().init());

  runApp(
    DevicePreview(
      // enabled: !kReleaseMode,
      enabled: false,
      builder: (context) => const App(),
    ),
  );
}

// Lớp hỗ trợ xử lý lỗi chứng chỉ HTTP
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Storix',
      debugShowCheckedModeBanner: false,

      // Cấu hình Device Preview kết hợp tự động tắt bàn phím khi chạm ngoài màn hình
      // builder: (context, child) {
      //   final devicePreviewChild = DevicePreview.appBuilder(
      //     context,
      //     child,
      //   );
      //   return GestureDetector(
      //     onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      //     behavior: HitTestBehavior.opaque,
      //     child: devicePreviewChild,
      //   );
      // },

      // Cấu hình Release kết hợp tự động tắt bàn phím khi chạm ngoài màn hình
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: child!,
        );
      },

      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      smartManagement: SmartManagement.keepFactory,
    );
  }
}
