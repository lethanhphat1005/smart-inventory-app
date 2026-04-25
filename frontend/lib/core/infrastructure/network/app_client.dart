import 'package:dio/dio.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token từ Supabase
          final session = Supabase.instance.client.auth.currentSession;
          final token = session?.accessToken;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Đọc StoreID từ Storage (Sử dụng StoreService/GetStorage như bạn đã thiết lập)
          final storeId = GetStorage().read('STORE_ID');
          if (storeId != null && storeId.toString().isNotEmpty) {
            options.headers['x-store-id'] = storeId;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) async {
          final statusCode = e.response?.statusCode;

          // Xử lý lỗi xác thực (401) hoặc quyền truy cập (403)
          if (statusCode == 401 || statusCode == 403) {
            // 1. Thực hiện dọn dẹp session ngầm
            await supabase.auth.signOut();

            // Đăng xuất Google để lần sau hiện lại popup chọn tài khoản
            await GoogleSignIn.instance.signOut();
            GetStorage().remove('STORE_ID');

            // 2. Kiểm tra xem user có đang ở màn hình "Công khai" hay không
            // Chúng ta không muốn hiện thông báo lỗi login khi họ còn chưa kịp login (như lúc đang xem Onboarding)
            final currentRoute = Get.currentRoute;
            final isPublicRoute = currentRoute == AppRoutes.login ||
                currentRoute == AppRoutes.onboarding ||
                currentRoute == AppRoutes.splash;

            if (!isPublicRoute) {
              // Chỉ chuyển hướng và hiện thông báo nếu họ đang ở TRONG app mà bị mất quyền
              Get.offAllNamed(AppRoutes.login);

              TSnackbarsWidget.warning(
                  title:
                      TTexts.systemSnackbarTitle.tr, // Kết quả: "System Notice"
                  message: TTexts.systemSnackbar403Error
                      .tr // Kết quả: "Your session has expired..."
                  );
            }
          }

          // Trả lỗi về để các controller khác có thể bắt nếu cần
          return handler.next(e);
        },
      ),
    );
  }

  // --- Các hàm gọi API cơ bản ---
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  // HÀM SAU KHI MERGE: Giữ phiên bản mới từ main (có thêm queryParameters)
  Future<Response> patch(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }

  // HÀM TIỆN ÍCH TỪ NHÁNH HEAD: Giữ lại để hỗ trợ parse List nhanh
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
