// lib/features/report/controllers/report_transaction_detail_controller.dart
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/report/providers/report_provider.dart';
import 'package:get/get.dart';

class ReportTransactionDetailController extends GetxController
    with TErrorHandler {
  final _provider = ReportProvider();

  final RxBool isLoading = true.obs;
  final Rx<TransactionModel?> transaction = Rx<TransactionModel?>(null);

  late final String transactionId;

  @override
  void onInit() {
    super.onInit();
    transactionId = Get.arguments?['id'] ?? '';

    if (transactionId.isNotEmpty) {
      fetchTransactionDetail();
    } else {
      Get.back(); 
    }
  }

  Future<void> fetchTransactionDetail() async {
    try {
      isLoading.value = true;
      final data = await _provider.getTransactionById(transactionId);
      transaction.value = data;
    } catch (e) {
      handleError(e); 
    } finally {
      isLoading.value = false;
    }
  }
}
