import 'package:frontend/core/infrastructure/exceptions/t_exceptions.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

mixin TErrorHandler {
  void handleError(dynamic e) {
    // Gọi class xử lý lỗi tập trung
    final error = TExceptions.getErrorMessage(e);
    Future.delayed(Duration.zero, () {
      // Gọi Snackbar
      TSnackbarsWidget.error(
        title: error['title']!,
        message: error['message']!,
      );
    });
  }
}
