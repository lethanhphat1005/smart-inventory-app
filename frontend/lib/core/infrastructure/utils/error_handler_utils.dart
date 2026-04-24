import 'package:dio/dio.dart';
import 'package:frontend/core/infrastructure/exceptions/t_exceptions.dart';
import 'package:frontend/core/state/controllers/global_error_controller.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

mixin TErrorHandler {
  void handleError(dynamic e) {
    // =========================================================
    // TẦNG 1: BẪY LỖI KẾT NỐI SERVER (BUNG DIALOG LIVE)
    // =========================================================
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout || // Bổ sung sendTimeout
          e.type == DioExceptionType.connectionError) {
        // Gọi thẳng lệnh bung Dialog
        GlobalErrorController.instance.showServerConnectionErrorDialog();

        // Return ngay lập tức để không chạy xuống Tầng 2 hiển thị Snackbar
        return;
      }
    }

    // =========================================================
    // TẦNG 2: CÁC LỖI API KHÁC (BUNG SNACKBAR BÌNH THƯỜNG)
    // =========================================================
    // Các lỗi 400 (Sai data), 404 (Not found), 500 (Lỗi logic server)
    // sẽ được TExceptions bóc tách message và hiển thị qua Snackbar.
    final error = TExceptions.getErrorMessage(e);

    Future.delayed(Duration.zero, () {
      TSnackbarsWidget.error(
        title: error['title']!,
        message: error['message']!,
      );
    });
  }
}
