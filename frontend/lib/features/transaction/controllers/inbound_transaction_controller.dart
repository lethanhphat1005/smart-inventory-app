import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
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

class InboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InventoryProvider _inventoryProvider = InventoryProvider();

  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  final TextEditingController noteController = TextEditingController();

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalFunds =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice, bool isReplace = false}) {
    // ĐÃ THÊM isReplace = false
    final String? pkgId = productData['productPackageId'];
    final int stock = productData['currentStock'] ?? 0;

    if (pkgId == null || pkgId.isEmpty) {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.errorNoPackageId.tr);
      return;
    }

    final index =
        cartItems.indexWhere((item) => item.productPackageId == pkgId);

    if (index != -1) {
      final currentItem = cartItems[index];

      final int newQuantity =
          isReplace ? quantity : currentItem.quantity + quantity;

      cartItems[index] = TransactionDetailModel(
        productPackageId: pkgId,
        quantity: newQuantity,
        unitPrice: customPrice ?? currentItem.unitPrice,
        packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
        currentStock: stock,
        reorderThreshold: currentItem.reorderThreshold,
      );
    } else {
      cartItems.add(TransactionDetailModel(
        productPackageId: pkgId,
        quantity: quantity,
        unitPrice: customPrice ?? productData['importPrice'] ?? 0.0,
        packageInfo: productData['packageInfo'],
        currentStock: stock,
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

  void updateItemQuantity(String packageId, int newQuantity) {
    final index =
        cartItems.indexWhere((item) => item.productPackageId == packageId);
    if (index != -1 && newQuantity > 0) {
      cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }

  // =========================================================================
  // LOGIC KIỂM TRA GIÁ VÀ CÁC DIALOG XÁC NHẬN CỦA INBOUND
  // =========================================================================
  void handleImportWithPriceCheck() {
    if (cartItems.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.emptyCartWarning.tr);
      return;
    }

    final priceChangedItems = cartItems.where((item) {
      final originalPrice = item.packageInfo?.importPrice ?? 0.0;
      return item.unitPrice != originalPrice;
    }).toList();

    if (priceChangedItems.isNotEmpty) {
      // 2. DANH SÁCH CHI TIẾT GIÁ
      String priceDetails = "${TTexts.priceFluctuationDesc.tr}\n";
      for (var i = 0; i < priceChangedItems.length; i++) {
        if (i >= 3) {
          priceDetails += "\n... ${TTexts.andMore.tr}";
          break;
        }
        final item = priceChangedItems[i];
        final oldPrice = item.packageInfo?.importPrice ?? 0.0;
        priceDetails +=
            "\n• ${item.packageInfo?.displayName ?? TTexts.unknownProduct.tr}: \$${oldPrice.toStringAsFixed(2)} ➔ \$${item.unitPrice.toStringAsFixed(2)}";
      }

      priceDetails += "\n\n${TTexts.priceChangeDetectedDesc.tr}";

      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.priceChangeDetectedTitle.tr,
          description: priceDetails,
          icon: const Text('💰', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.updatePriceAndImport.tr,
          secondaryButtonText: TTexts.importOnly.tr,
          onPrimaryPressed: () {
            Get.back();
            _executeImport(
                updatePrices: true, priceChangedItems: priceChangedItems);
          },
          onSecondaryPressed: () {
            Get.back();
            _executeImport(updatePrices: false);
          },
        ),
      );
    } else {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.confirmImportTitle.tr,
          description: TTexts.confirmImportDesc.tr,
          icon: const Text('📦', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onPrimaryPressed: () {
            Get.back();
            _executeImport(updatePrices: false);
          },
        ),
      );
    }
  }

  Future<void> _executeImport(
      {bool updatePrices = false,
      List<TransactionDetailModel>? priceChangedItems}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingImportTicket.tr);

      if (updatePrices && priceChangedItems != null) {
        for (var item in priceChangedItems) {
          if (item.productPackageId != null &&
              item.productPackageId!.isNotEmpty) {
            await _provider.updateProductPackage(
              item.productPackageId!,
              {
                'importPrice': item.unitPrice,
                'unitId': item.packageInfo?.unitId ?? 'u-default',
              },
            );
          }
        }
      }

      final List<Map<String, dynamic>> itemsPayload = cartItems.map((item) {
        return {
          'productPackageId': item.productPackageId,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        };
      }).toList();

      final response = await _provider.createImportTransaction(
        note: noteController.text.trim(),
        items: itemsPayload,
      );

      FullScreenLoaderUtils.stopLoading();

      final transaction = TransactionModel(
        transactionId: response['transactionId'] ?? 'NEW-TX',
        totalPrice: totalFunds,
        type: 'import',
        status: 'COMPLETED',
        note: noteController.text.trim(),
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

  void openScanner() {
    Get.to(
      () => TBarcodeScannerLayout(
        title: TTexts.scanProductBarcode.tr,
        onScanned: (code) {
          Get.back();
          _processScannedBarcode(code);
        },
      ),
      transition: Transition.downToUp,
    );
  }

  Future<void> _processScannedBarcode(String barcode) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.searchingProduct.tr);
      final result = await _inventoryProvider.scanBarcode(barcode);
      FullScreenLoaderUtils.stopLoading();

      final resolutionType = result['resolutionType'];

      if (resolutionType == 'exact_match') {
        final pkgJson = result['productPackage'];

        final packageModel = ProductPackageModel.fromJson(pkgJson);
        final productModel = pkgJson['product'] != null
            ? ProductModel.fromJson(pkgJson['product'])
            : null;

        final invJsonMap =
            Map<String, dynamic>.from(pkgJson['inventory'] ?? {});
        invJsonMap['productPackageId'] = packageModel.productPackageId;
        invJsonMap['productPackage'] = pkgJson;
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

        Get.toNamed(AppRoutes.inboundTransactionItemAdd,
            arguments: displayItem);
      } else if (resolutionType == 'candidate_match') {
        TSnackbarsWidget.warning(
            title: TTexts.unconfirmedBarcodeTitle.tr,
            message: TTexts.unconfirmedBarcodeMessage.tr);
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.barcodeNotFoundMessage.tr);
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorServerTitle.tr,
          message: '${TTexts.errorProcessingBarcode.tr}: $e');
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

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
