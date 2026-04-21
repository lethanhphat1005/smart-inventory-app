import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
// IMPORT THÊM CÁC FILE ĐỂ HỖ TRỢ ĐIỀU HƯỚNG BARCODE
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';

import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InventoryProvider _inventoryProvider =
      InventoryProvider(); // Thêm provider để gọi API quét mã

  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  final TextEditingController noteController = TextEditingController();

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalFunds =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice}) {
    final String? pkgId = productData['productPackageId'];

    if (pkgId == null || pkgId.isEmpty || pkgId == "null") {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.errorNoPackageId.tr);
      return;
    }

    final index =
        cartItems.indexWhere((item) => item.productPackageId == pkgId);

    if (index != -1) {
      final currentItem = cartItems[index];
      cartItems[index] = TransactionDetailModel(
        productPackageId: pkgId,
        quantity: currentItem.quantity + quantity,
        unitPrice: customPrice ?? currentItem.unitPrice,
        packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
        currentStock: currentItem.currentStock,
        reorderThreshold: currentItem.reorderThreshold,
      );
    } else {
      cartItems.add(TransactionDetailModel(
        productPackageId: pkgId,
        quantity: quantity,
        unitPrice: customPrice ?? productData['importPrice'] ?? 0.0,
        packageInfo: productData['packageInfo'],
        currentStock: productData['currentStock'] ?? 0,
        reorderThreshold: productData['reorderThreshold'] ?? 0,
      ));
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
    } else {
      final item = cartItems[index];
      cartItems[index] = TransactionDetailModel(
        productPackageId: item.productPackageId,
        quantity: newQuantity,
        unitPrice: item.unitPrice,
        packageInfo: item.packageInfo,
        currentStock: item.currentStock,
        reorderThreshold: item.reorderThreshold,
      );
    }
  }

  void removeItem(int index) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.removeItem.tr,
        description: TTexts.confirmRemoveItemTransaction.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.remove.tr,
        onPrimaryPressed: () {
          cartItems.removeAt(index);
          Get.back();
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }

  void handleImportWithPriceCheck() {
    if (cartItems.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.emptyCartWarning.tr);
      return;
    }

    final changedPriceItems = cartItems.where((item) {
      final originalPrice = item.packageInfo?.importPrice ?? 0.0;
      return (item.unitPrice - originalPrice).abs() > 0.01;
    }).toList();

    if (changedPriceItems.isNotEmpty) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.priceChangeDetected.tr,
          description: TTexts.priceChangeMessage.tr,
          icon: const Text('💰', style: TextStyle(fontSize: 40)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: changedPriceItems.map((item) {
              final original = item.packageInfo?.importPrice ?? 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${item.packageInfo?.displayName}: \$${original.toStringAsFixed(2)} ➔ \$${item.unitPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.primaryText),
                ),
              );
            }).toList(),
          ),
          primaryButtonText: TTexts.updatePricesAndCreate.tr,
          onPrimaryPressed: () {
            Get.back();
            _showConfirmImportDialog(updatePrice: true);
          },
          secondaryButtonText: TTexts.justCreateTransaction.tr,
          onSecondaryPressed: () {
            Get.back();
            _showConfirmImportDialog(updatePrice: false);
          },
        ),
      );
    } else {
      _showConfirmImportDialog(updatePrice: false);
    }
  }

  void _showConfirmImportDialog({required bool updatePrice}) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmImportTitle.tr,
        description: TTexts.confirmImportDescription.tr,
        icon: const Text('📦', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.proceedImport.tr,
        onPrimaryPressed: () {
          Get.back();
          completeImport(updatePrice: updatePrice);
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> completeImport({required bool updatePrice}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingImportTicket.tr);

      final finalNote = noteController.text.trim().isNotEmpty
          ? noteController.text.trim()
          : TTexts.manualImport.tr;

      final List<Map<String, dynamic>> itemsPayload = cartItems.map((item) {
        return {
          'productPackageId': item.productPackageId,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        };
      }).toList();

      final response = await _provider.createImportTransaction(
        note: finalNote,
        items: itemsPayload,
      );

      if (updatePrice) {
        final validItems = cartItems.where((item) =>
            item.productPackageId != null && item.productPackageId!.isNotEmpty);

        List<Future<void>> updateTasks = [];
        for (var item in validItems) {
          updateTasks.add(_provider.updateProductPackage(
              item.productPackageId!, {'importPrice': item.unitPrice}));
        }
        await Future.wait(updateTasks);
      }

      FullScreenLoaderUtils.stopLoading();

      final transaction = TransactionModel(
        transactionId: response['transactionId'] ?? 'NEW-TX',
        totalPrice: totalFunds,
        type: 'import',
        status: 'COMPLETED',
        note: finalNote,
        createdAt: DateTime.now(),
        items: cartItems.toList(),
      );

      cartItems.clear();
      noteController.clear();

      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().fetchTransactions();
      }

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadAllHomeData();
      }

      Get.offNamed(AppRoutes.transactionSummary, arguments: transaction);

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.importTicketCreated.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  void handleExit() {
    if (cartItems.isNotEmpty) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.discardTransactionTitle.tr,
          description: TTexts.discardTransactionDesc.tr,
          icon: const Text('🚨', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.exitAnyway.tr,
          onPrimaryPressed: () {
            Get.back();
            Get.back();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    } else {
      Get.back();
    }
  }

  // =======================================================
  // ĐÃ SỬA: MỞ CAMERA VÀ XỬ LÝ NHẢY TRANG NGAY LẬP TỨC
  // =======================================================
  void openScanner() {
    Get.to(
      () => TBarcodeScannerLayout(
        title: TTexts.scanProductBarcode.tr,
        onScanned: (code) {
          Get.back(); // Đóng camera ngay lập tức
          _processScannedBarcode(code); // Gọi hàm xử lý logic
        },
      ),
      transition: Transition.downToUp,
    );
  }

  Future<void> _processScannedBarcode(String barcode) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog('Đang tìm sản phẩm...');
      final result = await _inventoryProvider.scanBarcode(barcode);
      FullScreenLoaderUtils.stopLoading();

      final resolutionType = result['resolutionType'];

      if (resolutionType == 'exact_match') {
        // TÌM THẤY MÃ CHUẨN -> TẠO MODEL VÀ NHẢY TRANG LUÔN
        final pkgJson = result['productPackage'];

        final packageModel = ProductPackageModel.fromJson(pkgJson);
        final productModel = pkgJson['product'] != null
            ? ProductModel.fromJson(pkgJson['product'])
            : null;

        // Chế tạo Inventory Model tương thích với UI Add Item
        final invJsonMap =
            Map<String, dynamic>.from(pkgJson['inventory'] ?? {});
        invJsonMap['productPackageId'] = packageModel.productPackageId;
        invJsonMap['productPackage'] =
            pkgJson; // Bắt buộc phải gắn lại để parse
        if (invJsonMap['inventoryId'] == null) invJsonMap['inventoryId'] = '';
        if (invJsonMap['quantity'] == null) invJsonMap['quantity'] = 0;
        if (invJsonMap['reorderThreshold'] == null) {
          invJsonMap['reorderThreshold'] = 0;
        }

        final inventoryModel = InventoryModel.fromJson(invJsonMap);

        final displayItem = InventoryInsightDisplayModel(
          product: productModel,
          inventory: inventoryModel,
        );

        // ĐIỀU HƯỚNG THẲNG SANG TRANG THÊM VÀO INBOUND KÈM THAM SỐ
        Get.toNamed(AppRoutes.inboundTransactionItemAdd,
            arguments: displayItem);
      } else if (resolutionType == 'candidate_match') {
        // CÓ NHIỀU MÃ GẦN GIỐNG -> CHƯA CHỐT ĐƯỢC
        TSnackbarsWidget.warning(
            title: 'Chưa xác nhận mã',
            message:
                'Hệ thống tìm thấy sản phẩm nhưng chưa được map chuẩn. Vui lòng xác nhận bên ngoài.');
      } else {
        // KHÔNG TÌM THẤY
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: 'Mã vạch không tồn tại trong hệ thống!');
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorServerTitle.tr,
          message: 'Không thể xử lý mã vạch: $e');
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
