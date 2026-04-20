import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:frontend/features/notification/utils/notification_router.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Khởi tạo ApiClient (Đã tự động lấy token Supabase gắn vào header)
  static final ApiClient _apiClient = ApiClient();

  static RemoteMessage? pendingInitialMessage;

  final supabase = Supabase.instance.client;

  static Future<void> initialize({SupabaseClient? supabase}) async {
    // 1. XIN QUYỀN (Bắt buộc cho iOS & Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. SETUP LOCAL NOTIFICATION (Dành cho Foreground)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            final String type = data['type'] ?? 'UNKNOWN';
            final String referenceId = data['referenceId'] ?? '';
            final String storeId = data['storeId'] ?? '';

            debugPrint(
                "🔔 [Local Noti] Click lúc app đang mở: type=$type, storeId=$storeId");

            // Xử lý báo đã đọc ngầm nếu có notificationId
            final String notiId = data['notificationId'] ?? '';

            if (notiId.isNotEmpty) {
              // Dùng hàm ẩn danh (IIFE) để không block luồng chính
              () async {
                try {
                  await _apiClient.patch('/api/notification/$notiId/read');
                  if (Get.isRegistered<NotificationController>()) {
                    Get.find<NotificationController>().markAsRead(notiId);
                  }
                } catch (e) {
                  debugPrint("Lỗi xử lý đã đọc thông báo: $e");
                }
              }();
            }

            // Giao cho Router điều hướng và Switch Store
            NotificationRouter.navigate(type, referenceId, storeId);
          } catch (e) {
            debugPrint("⚠️ Lỗi parse payload local notification: $e");
          }
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Khớp 100% với BE Node.js
      'High Importance Notifications',
      description: 'Dùng cho các thông báo quan trọng.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. LẮNG NGHE KHI APP ĐANG MỞ (Foreground) -> Hiển thị popup nổi
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      final type = message.data['type'];

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@drawable/ic_notification',
              color: const Color(0x00ff7a03),
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(message.data),
        );

        // Cập nhật lại danh sách thông báo nếu user đang mở màn hình Notification
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications();
        }

        if (type == 'ROLE_UPDATED') {
          TSnackbarsWidget.warning(
              title: 'Quyền hạn thay đổi',
              message: 'Vui lòng đăng nhập lại để cập nhật quyền hạn mới.');

          await supabase!.auth.signOut();
          // Đăng xuất Google để lần sau hiện lại popup chọn tài khoản
          await GoogleSignIn.instance.signOut();

          // 2. Xoá StoreID hoặc data local
          GetStorage().remove('STORE_ID');

          // 3. Điều hướng về màn Login
          Get.offAllNamed(AppRoutes.login);
          return;
        }
      }
    });

    // 4. XỬ LÝ CLICK VÀO THÔNG BÁO TỪ TRẠNG THÁI NGẦM (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message); // Nhớ bỏ dấu gạch dưới
    });

    // 5. XỬ LÝ CLICK VÀO THÔNG BÁO TỪ TRẠNG THÁI TẮT HOÀN TOÀN (Terminated)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      pendingInitialMessage = initialMessage; // Cất vào đây cho Splash xử lý
    }

    // 6. LẮNG NGHE ĐỔI TOKEN (Firebase tự đổi định kỳ)
    _messaging.onTokenRefresh.listen((newToken) {
      registerTokenWithBackend();
    });
  }

  static void handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    final String type = data['type'] ?? 'UNKNOWN';
    final String referenceId = data['referenceId'] ?? '';
    final String notificationId = data['notificationId'] ?? '';
    final String storeId = data['storeId'] ?? '';

    debugPrint(
        "🔔 [FCM] User click thông báo: type=$type, refId=$referenceId, storeId=$storeId");

    if (notificationId.isNotEmpty) {
      () async {
        try {
          await _apiClient.patch('/api/notification/$notificationId/read');
        } catch (e) {
          debugPrint("⚠️ [FCM] Lỗi update trạng thái read: $e");
        }
      }();
    }

    NotificationRouter.navigate(type, referenceId, storeId);
  }

  static Future<void> registerTokenWithBackend() async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        debugPrint("⚠️ [FCM] Không sinh được token từ thiết bị!");
        return;
      }

      // Đã sửa lại đường dẫn, bỏ /api
      await _apiClient.post(
        '/api/notification/register-token',
        data: {'token': fcmToken},
      );
      debugPrint("✅ [FCM] Đăng ký token lên server thành công");
    } on DioException catch (e) {
      // Bắt lỗi chi tiết để trị lỗi null-null
      debugPrint("❌ [FCM] Lỗi gọi API Dio đăng ký token:");
      debugPrint("   - Type: ${e.type}");
      debugPrint("   - Message: ${e.message}");
      debugPrint("   - Status: ${e.response?.statusCode}");
      debugPrint("   - Data: ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ [FCM] Lỗi hệ thống chưa xác định: $e");
    }
  }

  static Future<void> removeTokenFromBackend() async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      // Đã sửa lại đường dẫn, bỏ /api
      await _apiClient.post(
        '/api/notification/remove-token',
        data: {'token': fcmToken},
      );

      await _messaging.deleteToken();
      debugPrint("✅ [FCM] Đã xóa token thành công");
    } on DioException catch (e) {
      // Bắt lỗi chi tiết để trị lỗi null-null
      debugPrint("❌ [FCM] Lỗi gọi API Dio xóa token:");
      debugPrint("   - Type: ${e.type}");
      debugPrint("   - Message: ${e.message}");
      debugPrint("   - Status: ${e.response?.statusCode}");
      debugPrint("   - Data: ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ [FCM] Lỗi xóa token: $e");
    }
  }
}
