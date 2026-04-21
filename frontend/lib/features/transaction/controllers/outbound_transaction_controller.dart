import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';

class OutboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InventoryProvider _inventoryProvider = InventoryProvider();

  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  final TextEditingController noteController = TextEditingController();

  final List<String> predefinedReasons = [
    TTexts.reasonRetailSale.tr,
    TTexts.reasonWholesale.tr,
    TTexts.reasonOther.tr,
  ];

  final RxString selectedReason = ''.obs;
  final RxInt otherFinancialEffect = 0.obs;

  @override
  void onInit() {
    super.onInit();
    selectedReason.value = predefinedReasons[0];
  }

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalFunds =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice}) {
    final String? pkgId = productData['productPackageId'];
    final int stock = productData['currentStock'] ?? 0;

    if (pkgId == null || pkgId.isEmpty) {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts
              .errorUnknownMessage.tr); // Thay errorNoPackageId bằng lỗi có sẵn
      return;
    }

    final index =
        cartItems.indexWhere((item) => item.productPackageId == pkgId);

    if (index != -1) {
      final currentItem = cartItems[index];
      final newQty = currentItem.quantity + quantity;

      if (newQty > stock) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: "Số lượng vượt quá tồn kho");
        return;
      }

      cartItems[index] = TransactionDetailModel(
        productPackageId: pkgId,
        quantity: newQty,
        unitPrice: customPrice ?? currentItem.unitPrice,
        packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
        currentStock: stock,
        reorderThreshold: currentItem.reorderThreshold,
      );
    } else {
      if (quantity > stock) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: "Số lượng vượt quá tồn kho");
        return;
      }
      cartItems.add(TransactionDetailModel(
        productPackageId: pkgId,
        quantity: quantity,
        unitPrice: customPrice ?? productData['sellingPrice'] ?? 0.0,
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
      if (newQuantity > item.currentStock) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: "Số lượng vượt quá tồn kho");
        return;
      }

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
    cartItems.removeAt(index);
  }

  Future<void> completeExport() async {
    if (cartItems.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: "Giỏ hàng đang trống");
      return;
    }

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingExportTicket.tr);

      final String finalNote = noteController.text.trim().isNotEmpty
          ? "${selectedReason.value} - ${noteController.text.trim()}"
          : selectedReason.value;

      final List<Map<String, dynamic>> itemsPayload = cartItems.map((item) {
        return {
          'productPackageId': item.productPackageId,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        };
      }).toList();

      final response = await _provider.createExportTransaction(
        note: finalNote,
        items: itemsPayload,
      );

      FullScreenLoaderUtils.stopLoading();

      final transaction = TransactionModel(
        transactionId: response['transactionId'] ?? 'NEW-TX',
        totalPrice: totalFunds,
        type: 'export',
        status: 'COMPLETED',
        note: finalNote,
        createdAt: DateTime.now(),
        items: cartItems.toList(),
      );

      cartItems.clear();
      noteController.clear();
      selectedReason.value = predefinedReasons[0];

      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().fetchTransactions();
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadAllHomeData();
      }

      Get.offNamed(AppRoutes.transactionSummary, arguments: transaction);

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.exportTicketCreated.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      if (e is DioException && e.response?.statusCode == 409) {
        final List<dynamic> conflicts = e.response?.data['conflicts'] ?? [];
        List<String> conflictedNames = [];

        for (var conflict in conflicts) {
          final String pkgId = conflict['productPackageId'];
          final int newStock = conflict['currentStock'] ?? 0;
          final index =
              cartItems.indexWhere((i) => i.productPackageId == pkgId);

          if (index != -1) {
            final item = cartItems[index];
            final productName =
                item.packageInfo?.displayName ?? TTexts.unknownProduct.tr;
            conflictedNames
                .add("$productName (Tồn: $newStock) ➔ Đã xóa khỏi giỏ");
            cartItems.removeAt(index);
          }
        }
        Get.dialog(TCustomDialogWidget(
          title: "Sản phẩm vượt tồn kho",
          description:
              "Một số sản phẩm vượt quá số lượng tồn kho hiện tại và đã được tự động loại bỏ.\n\nChi tiết:\n${conflictedNames.map((e) => "• $e").join("\n")}",
          icon: const Text('🛒', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          onPrimaryPressed: () => Get.back(),
        ));
      } else {
        handleError(e);
      }
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
      FullScreenLoaderUtils.openLoadingDialog('Đang tìm sản phẩm...');
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

        Get.toNamed(AppRoutes.outboundTransactionItemAdd,
            arguments: displayItem);
      } else if (resolutionType == 'candidate_match') {
        TSnackbarsWidget.warning(
            title: 'Chưa xác nhận mã',
            message:
                'Sản phẩm chưa được gán chính xác. Vui lòng xác nhận bên ngoài.');
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr, message: 'Mã vạch không tồn tại!');
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorServerTitle.tr, message: 'Lỗi xử lý mã vạch: $e');
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
