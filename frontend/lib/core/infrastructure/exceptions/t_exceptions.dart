import 'package:dio/dio.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TExceptions {
  static Map<String, String> getErrorMessage(dynamic e) {
    String title = TTexts.errorUnknownTitle.tr;
    String message = TTexts.errorUnknownMessage.tr;

    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          title = TTexts.errorTimeoutTitle.tr;
          message = TTexts.errorTimeoutMessage.tr;
          break;
        case DioExceptionType.connectionError:
          title = TTexts.netErrorTitle.tr;
          message = TTexts.netErrorDescription.tr;
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;

          if (responseData != null) {
            // 1. Kiểm tra xem data có phải là JSON Object (Map) không
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('message') &&
                  responseData['message'] != null) {
                title = TTexts.errorServerTitle.tr;
                message = responseData['message']
                    .toString(); // Ép về chuỗi cho an toàn
                break;
              }
            }
            // 2. Nếu server trả về một mảng báo lỗi (List)
            else if (responseData is List && responseData.isNotEmpty) {
              title = TTexts.errorServerTitle.tr;
              message = responseData.first.toString();
              break;
            }
            // 3. Nếu server trả về Text trơn (String)
            else if (responseData is String && responseData.isNotEmpty) {
              // Cắt bớt nếu chuỗi HTML quá dài
              title = TTexts.errorServerTitle.tr;
              message = responseData.length > 100
                  ? "Lỗi máy chủ không xác định"
                  : responseData;
              break;
            }
          }

          // Fallback nếu không bóc tách được message
          if (statusCode == 404) {
            title = TTexts.errorNotFoundTitle.tr;
            message = TTexts.errorNotFoundMessage.tr;
          } else if (statusCode != null && statusCode >= 500) {
            title = TTexts.errorServerTitle.tr;
            message = TTexts.errorServerMessage.tr;
          }
          break;
        default:
          break;
      }
    }
    return {'title': title, 'message': message};
  }
}
