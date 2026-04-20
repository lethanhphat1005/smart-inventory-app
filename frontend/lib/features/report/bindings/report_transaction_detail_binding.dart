import 'package:frontend/features/report/controllers/report_transaction_detail_controller.dart';
import 'package:frontend/features/report/controllers/report_transaction_export_controller.dart';
import 'package:get/get.dart';

class ReportTransactionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportTransactionDetailController>(
        () => ReportTransactionDetailController());
    Get.put<ReportTransactionExportController>(
        ReportTransactionExportController());
  }
}
