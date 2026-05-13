import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart'; // Giả định bạn dùng Dio cho ApiClient
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';

mixin TErrorHandler {
  /// Hàm xử lý lỗi chung, tự động phân tích exception và hiển thị Snackbar đa ngôn ngữ
  void handleError(dynamic error) {
    String title = TTexts.errorTitle.tr;
    String message = TTexts.errorUnknownMessage.tr;

    // 1. Xử lý lỗi Timeout
    if (error is TimeoutException) {
      title = TTexts.errorTimeoutTitle.tr;
      message = TTexts.errorTimeoutMessage.tr;
    }
    // 2. Xử lý lỗi Mạng / Socket
    else if (error is SocketException) {
      title = TTexts.netErrorTitle.tr;
      message = TTexts.netErrorDescription.tr;
    }
    // 3. Xử lý lỗi HTTP (Nếu dùng thư viện Dio)
    else if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        title = TTexts.errorTimeoutTitle.tr;
        message = TTexts.errorTimeoutMessage.tr;
      } else if (error.type == DioExceptionType.connectionError) {
        title = TTexts.netErrorTitle.tr;
        message = TTexts.netErrorDescription.tr;
      } else if (error.response != null) {
        // Ánh xạ lỗi theo HTTP Status Code
        final statusCode = error.response!.statusCode;
        switch (statusCode) {
          case 403:
            title = TTexts.errorAccessRestrictedTitle.tr;
            message = TTexts.errorAccessRestrictedSubtitle.tr;
            break;
          case 404:
            title = TTexts.errorNotFoundTitle.tr;
            message = TTexts.errorNotFoundMessage.tr;
            break;
          case 429:
            title = TTexts.errorTooManyRequestsTitle.tr;
            message = TTexts.errorTooManyRequestsMessage.tr;
            break;
          case 500:
          case 502:
          case 503:
            title = TTexts.errorServerTitle.tr;
            message = TTexts.errorServerMessage.tr;
            break;
          default:
            // Ưu tiên lấy message trực tiếp từ API backend trả về nếu có
            final backendMessage = error.response?.data?['message']?.toString();
            if (backendMessage != null && backendMessage.isNotEmpty) {
              message = backendMessage;
            } else {
              message = TTexts.errorUnknownMessage.tr;
            }
            break;
        }
      }
    }
    // 4. Fallback: Bắt các loại Exception dạng String chung chung
    else {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('timeout')) {
        title = TTexts.errorTimeoutTitle.tr;
        message = TTexts.errorTimeoutMessage.tr;
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        title = TTexts.netErrorTitle.tr;
        message = TTexts.netErrorDescription.tr;
      } else if (error is FormatException) {
        message = TTexts.errorUiMessage.tr;
      } else {
        // Nếu là lỗi lạ mà bạn tự throw (vd: Exception('Custom error'))
        message = error.toString().replaceAll('Exception: ', '');
      }
    }

    // Hiển thị thông báo Snackbar
    TSnackbarsWidget.error(title: title, message: message);
  }
}
