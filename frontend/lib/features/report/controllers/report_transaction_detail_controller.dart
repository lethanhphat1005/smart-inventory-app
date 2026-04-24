import 'package:frontend/core/infrastructure/models/product_package_model.dart'; // ĐÃ THÊM IMPORT NÀY
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
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

      // ==============================================================
      // THUẬT TOÁN ĐẮP BARCODE SIÊU TỐI ƯU (ĐÃ FIX WARNING NULL CHECK)
      // ==============================================================
      final uniquePackageIds = data.items
          .map((item) => item.productPackageId)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      if (uniquePackageIds.isNotEmpty) {
        final futures = uniquePackageIds
            .map<Future<MapEntry<String, ProductPackageModel?>>>((id) async {
          final pkgData = await _provider.getPackageDetailSummary(id);
          if (pkgData != null) {
            try {
              return MapEntry(id, ProductPackageModel.fromJson(pkgData));
            } catch (_) {
              return MapEntry(id, null);
            }
          }
          return MapEntry(id, null);
        });

        final results = await Future.wait(futures);
        final packageMap = Map.fromEntries(results);

        for (int i = 0; i < data.items.length; i++) {
          final item = data.items[i];
          final pkgId = item.productPackageId;

          if (pkgId != null && packageMap.containsKey(pkgId)) {
            final enrichedPackage = packageMap[pkgId];

            if (enrichedPackage != null) {
              final updatedPackageInfo = item.packageInfo?.copyWith(
                    barcodeValue: enrichedPackage.barcodeValue,
                    barcodes: enrichedPackage.barcodes,
                  ) ??
                  enrichedPackage;

              data.items[i] = TransactionDetailModel(
                productPackageId: item.productPackageId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                packageInfo: updatedPackageInfo,
                currentStock: item.currentStock,
                reorderThreshold: item.reorderThreshold,
              );
            }
          }
        }
      }

      transaction.value = data;
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
