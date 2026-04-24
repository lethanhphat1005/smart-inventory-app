import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/localization/app_translations.dart';
import 'package:frontend/core/state/bindings/initial_binding.dart';
import 'package:frontend/core/state/controllers/global_error_controller.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/ui/theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // 1. Khởi tạo GetStorage TRƯỚC KHI init các Service phụ thuộc
  await GetStorage.init();

  // 2. Khởi tạo Firebase và Notification Service (Cập nhật theo code của bạn)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();

  // 3. Khởi tạo Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 4. Khởi tạo các Services khác
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => StoreService().init());
  await Get.putAsync(() => UserService().init());

  Get.put(GlobalErrorController());

  PlatformDispatcher.instance.onError = (error, stack) {
    GlobalErrorController.instance.handleGlobalError(error, stack);
    return true;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    GlobalErrorController.instance.handleGlobalError(
        details.exception, details.stack ?? StackTrace.empty);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              Text(
                TTexts.errorUiTitle.tr,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                TTexts.errorUiMessage.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(
    DevicePreview(
      // enabled: !kReleaseMode,
      enabled: false,
      builder: (context) => const App(),
    ),
  );
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

      // Khai báo Localization ở đây là chuẩn nhất
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),

      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      smartManagement: SmartManagement.keepFactory,
    );
  }
}
