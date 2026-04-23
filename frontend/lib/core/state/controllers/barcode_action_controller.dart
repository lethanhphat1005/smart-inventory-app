import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_barcode_candidate_bottom_sheet.dart';
import 'package:frontend/core/ui/widgets/t_barcode_not_found_bottom_sheet.dart';
import 'package:frontend/core/ui/widgets/t_barcode_prefill_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';

class BarcodeActionController extends GetxController {
  static BarcodeActionController get instance =>
      Get.find<BarcodeActionController>();
  final InventoryProvider _provider = InventoryProvider();

  Future<void> handleScannedBarcode(String barcode,
      {bool isFromForm = false}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.barcodeCheckingLoader.tr);
      final result = await _provider.scanBarcode(barcode);
      FullScreenLoaderUtils.stopLoading();

      final resolutionType = result['resolutionType'];
      final Map<String, dynamic> prefill = result['prefill'] != null
          ? Map<String, dynamic>.from(result['prefill'])
          : <String, dynamic>{};

      if (resolutionType == 'exact_match') {
        // ==============================================================
        // LUỒNG MỚI: ĐIỀU HƯỚNG THẲNG KHÔNG CẦN QUA BƯỚC PHỤ
        // ==============================================================
        if (isFromForm) {
          // (Sau này code xử lý điền form tại đây)
        } else {
          Get.back(); // Đóng camera/màn hình Scanner ngay lập tức

          // Nhảy vọt thẳng vào trang Chi tiết sản phẩm
          Get.toNamed(AppRoutes.inventoryDetail, arguments: {
            'packageId': result['productPackage']['productPackageId'],
            'package': result['productPackage'],
          });
        }
      } else if (resolutionType == 'candidate_match' &&
          result['candidates'] != null) {
        TBarcodeCandidateBottomSheet.show(
            barcode: barcode,
            candidates: result['candidates'],
            prefill: prefill);
      } else {
        if (isFromForm) {
          // (Sau này code xử lý cho Form)
        } else {
          if (prefill.isNotEmpty) {
            TBarcodePrefillBottomSheet.show(barcode: barcode, prefill: prefill);
          } else {
            TBarcodeNotFoundBottomSheet.show(barcode: barcode);
          }
        }
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      debugPrint('====== LỖI SCAN BARCODE: $e ======');

      TSnackbarsWidget.error(
        title: TTexts.barcodeScanErrorTitle.tr,
        message: e.toString(),
      );
    }
  }
}
