import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  late Dio dio;
  final supabase = Supabase.instance.client;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        responseType: ResponseType.json,
      ),
    );

    // 🔥 SỬ DỤNG QUEUED INTERCEPTOR ĐỂ XỬ LÝ ĐỒNG BỘ KHI CÓ NHIỀU REQUEST CÙNG LÚC
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token hiện tại
          final session = supabase.auth.currentSession;
          final token = session?.accessToken;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final storeId = GetStorage().read('STORE_ID');
          if (storeId != null && storeId.toString().isNotEmpty) {
            options.headers['x-store-id'] = storeId;
          }

          final currentLocale = Get.locale?.languageCode ??
              Get.deviceLocale?.languageCode ??
              'vi';
          options.headers['x-locale'] = currentLocale;

          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),

        // LOGIC XỬ LÝ LỖI (REFRESH TOKEN HOẶC LOGOUT)
        onError: (DioException e, handler) async {
          final statusCode = e.response?.statusCode;

          if (statusCode == 401) {
            // 1. CHẶN LỖI LÚC MỚI MỞ APP (Nếu request không có token thì bỏ qua)
            final hasAuthHeader =
                e.requestOptions.headers.containsKey('Authorization');
            if (!hasAuthHeader) {
              return handler.next(e);
            }

            try {
              final tokenSent = e.requestOptions.headers['Authorization']
                  ?.toString()
                  .replaceAll('Bearer ', '');
              final currentSession = supabase.auth.currentSession;
              final currentToken = currentSession?.accessToken;

              // 2. CHỐNG XUNG ĐỘT (CONCURRENT REFRESH):
              // Nếu API khác đã xin Token thành công rồi thì xài ké luôn, không gọi refresh nữa!
              if (currentToken != null && currentToken != tokenSent) {
                debugPrint(
                    "🔄 Token đã được làm mới bởi request trước đó. Hưởng sái xài luôn!");
                e.requestOptions.headers['Authorization'] =
                    'Bearer $currentToken';
                final cloneReq = await dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              }

              // 3. NẾU CHƯA AI XIN -> ĐẠI DIỆN ĐI XIN TOKEN MỚI
              final AuthResponse res = await supabase.auth.refreshSession();
              final newToken = res.session?.accessToken;

              if (newToken != null) {
                debugPrint("🔄 Tự động Refresh Token thành công!");
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                final cloneReq = await dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                throw Exception("Refresh trả về Token null");
              }
            } catch (refreshError) {
              // 4. REFRESH THẤT BẠI (Do token bị revoke, user bị disable, v.v.)
              debugPrint(
                  "❌ Refresh Token thất bại: $refreshError. Tiến hành Logout.");
              await _forceLogout(isSessionExpired: true);
              return handler.next(e);
            }
          }

          // NẾU BỊ 403 (Cấm truy cập)
          if (statusCode == 403) {
            await _forceLogout(isSessionExpired: false);
          }

          return handler.next(e);
        },
      ),
    );
  }

  // --- HÀM ÉP ĐĂNG XUẤT TẬP TRUNG ---
  Future<void> _forceLogout({required bool isSessionExpired}) async {
    await supabase.auth.signOut();
    await GoogleSignIn.instance.signOut();

    try {
      if (Get.isRegistered<AuthService>()) {
        await Get.find<AuthService>().clearAuthData();
      }
      if (Get.isRegistered<StoreService>()) {
        await Get.find<StoreService>().clearWorkspaceData();
      }
      if (Get.isRegistered<UserService>()) {
        Get.find<UserService>().clearUser();
      }
      if (Get.isRegistered<ChatbotUiController>()) {
        Get.find<ChatbotUiController>().messages.clear();
        Get.find<ChatbotUiController>().isChatOpen.value = false;
      }
    } catch (cleanupError) {
      debugPrint('Lỗi dọn dẹp data: $cleanupError');
    }

    final currentRoute = Get.currentRoute;
    final isPublicRoute = currentRoute == AppRoutes.login ||
        currentRoute == AppRoutes.onboarding ||
        currentRoute == AppRoutes.splash;

    if (!isPublicRoute) {
      Get.offAllNamed(AppRoutes.login);

      // Báo lỗi cho người dùng biết vì sao bị đá văng
      if (isSessionExpired) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message:
                TTexts.sessionExpiredMessage.tr); // "Phiên đăng nhập hết hạn"
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.systemSnackbarTitle.tr,
            message: TTexts.systemSnackbar403Error.tr);
      }
    }
  }

  // --- Các hàm gọi API cơ bản (Giữ nguyên) ---
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }

  Future<List<dynamic>> getList(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await get(path, queryParameters: queryParameters);
    final dataField = response.data['data'];

    if (dataField == null) return [];
    if (dataField is List) return dataField;
    if (dataField is Map) return dataField['items'] ?? dataField['data'] ?? [];
    return [];
  }
}
