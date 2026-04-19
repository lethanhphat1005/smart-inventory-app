import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_barcode_candidate_bottom_sheet.dart';
import 'package:frontend/core/ui/widgets/t_barcode_exact_match_bottom_sheet.dart';
import 'package:frontend/core/ui/widgets/t_barcode_not_found_bottom_sheet.dart';
import 'package:frontend/core/ui/widgets/t_barcode_prefill_bottom_sheet.dart';
import 'package:frontend/core/ui/widgets/t_barcode_valid_for_form_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';

class BarcodeActionController extends GetxController {
  static BarcodeActionController get instance =>
      Get.find<BarcodeActionController>();
  final InventoryProvider _provider = InventoryProvider();

  /// Hàm xử lý chính cho mọi nơi trong App
  /// [isFromForm]: Nếu true, quét xong mã mới sẽ điền vào Form thay vì mở trang Create mới
  Future<void> handleScannedBarcode(String barcode,
      {bool isFromForm = false}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog('Đang kiểm tra mã vạch...');
      final result = await _provider.scanBarcode(barcode);
      FullScreenLoaderUtils.stopLoading();

      final resolutionType = result['resolutionType'];
      final Map<String, dynamic> prefill = result['prefill'] != null
          ? Map<String, dynamic>.from(result['prefill'])
          : <String, dynamic>{};

      if (resolutionType == 'exact_match') {
        // TRƯỜNG HỢP: ĐÃ CÓ TRONG HỆ THỐNG
        // Luôn hiện Bottom Sheet để cảnh báo/xem thông tin, không cho tạo trùng.
        TBarcodeExactMatchBottomSheet.show(
            barcode: barcode, packageData: result['productPackage']);
      } else if (resolutionType == 'candidate_match' &&
          result['candidates'] != null) {
        // TRƯỜNG HỢP: CÓ SẢN PHẨM GẦN GIỐNG
        TBarcodeCandidateBottomSheet.show(
            barcode: barcode,
            candidates: result['candidates'],
            prefill: prefill);
      } else {
        // TRƯỜNG HỢP: CHƯA CÓ TRONG HỆ THỐNG (not_found hoặc có prefill trên mạng)
        if (isFromForm) {
          // Nếu đang ở trong Form: Hiện Bottom Sheet báo "Mã hợp lệ",
          // User nhấn OK thì đóng camera và điền vào ô Text.
          TBarcodeValidForFormBottomSheet.show(
              barcode: barcode, prefill: prefill);
        } else {
          // Nếu ở ngoài (Search): Hiện Bottom Sheet hỏi có muốn tạo mới không.
          if (prefill.isNotEmpty) {
            TBarcodePrefillBottomSheet.show(barcode: barcode, prefill: prefill);
          } else {
            TBarcodeNotFoundBottomSheet.show(barcode: barcode);
          }
        }
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      // In lỗi ra màn hình Terminal (Console)
      debugPrint('====== LỖI SCAN BARCODE: $e ======');

      // Hiển thị tạm cái lỗi lên Snackbar để bạn thấy rõ
      TSnackbarsWidget.error(
        title: 'Lỗi Call API',
        message: e.toString(), // Thay vì ghi chung chung, ta in thẳng lỗi ra
      );
    }
  }
}
