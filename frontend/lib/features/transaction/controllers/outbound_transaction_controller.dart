import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/features/transaction/widgets/outbound_transaction/outbound_transaction_scan_cart_bottom_sheet_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart'; // ĐÃ THÊM: Import GetStorage
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_scanner_bottom_bar_widget.dart';

class OutboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InventoryProvider _inventoryProvider = InventoryProvider();
  final _storage = GetStorage();
  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  final TextEditingController noteController = TextEditingController();

  final RxList<InventoryModel> drawerRecentItems = <InventoryModel>[].obs;
  final RxList<InventoryModel> drawerPriorityItems = <InventoryModel>[].obs;

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
    _loadRecentFromStorage();
  }

  @override
  void onReady() {
    super.onReady();
    fetchDrawerSuggestions();
  }

  // =========================================================================
  // LOGIC STORAGE CHO RECENT (TÁCH BIỆT SHOP/USER)
  // =========================================================================
  String get _recentStorageKey {
    final storeId = _storage.read('STORE_ID') ?? 'default_store';
    final userEmail = _storage.read('USER_EMAIL') ?? 'default_user';
    return 'recent_outbound_${storeId}_$userEmail';
  }

  void _loadRecentFromStorage() {
    final List<dynamic>? storedData = _storage.read(_recentStorageKey);
    if (storedData != null) {
      drawerRecentItems.assignAll(storedData
          .map((e) => InventoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList());
    }
  }

  Map<String, dynamic> _inventoryToMap(InventoryModel inv) {
    return {
      'inventoryId': inv.inventoryId,
      'productPackageId': inv.productPackageId,
      'quantity': inv.quantity,
      'reorderThreshold': inv.reorderThreshold,
      'lastCount': inv.lastCount,
      'updatedAt': inv.updatedAt.toIso8601String(),
      'activeStatus': inv.activeStatus,
      'productPackage': inv.productPackage != null
          ? {
              'productPackageId': inv.productPackage!.productPackageId,
              'displayName': inv.productPackage!.displayName,
              'importPrice': inv.productPackage!.importPrice,
              'sellingPrice': inv.productPackage!.sellingPrice,
              'barcodeValue': inv.productPackage!.barcodeValue,
              'product': inv.productPackage!.product != null
                  ? {
                      'productId': inv.productPackage!.product!.productId,
                      'name': inv.productPackage!.product!.name,
                      'imageUrl': inv.productPackage!.product!.imageUrl,
                    }
                  : null,
            }
          : null,
    };
  }

  void _saveRecentToStorage(List<TransactionDetailModel> items) {
    List<InventoryModel> currentRecent =
        List<InventoryModel>.from(drawerRecentItems);
    for (var item in items) {
      if (item.packageInfo == null) continue;
      final inv = InventoryModel(
        inventoryId: '',
        productPackageId: item.productPackageId ?? '',
        quantity:
            item.currentStock - item.quantity, // Tồn kho còn lại sau khi xuất
        reorderThreshold: item.reorderThreshold,
        lastCount: 0,
        updatedAt: DateTime.now(),
        activeStatus: 'active',
        productPackage: item.packageInfo,
      );
      currentRecent
          .removeWhere((e) => e.productPackageId == inv.productPackageId);
      currentRecent.insert(0, inv);
    }
    final finalRecent = currentRecent.take(5).toList();
    drawerRecentItems.assignAll(finalRecent);
    _storage.write(
        _recentStorageKey, finalRecent.map((e) => _inventoryToMap(e)).toList());
  }

  // =========================================================================
  // GỢI Ý VÀ PHỤ TRỢ CHO DRAWER
  // =========================================================================
  int getItemQuantity(String packageId) {
    final index = cartItems.indexWhere((e) => e.productPackageId == packageId);
    return index != -1 ? cartItems[index].quantity : 0;
  }

  Future<void> fetchDrawerSuggestions() async {
    try {
      final Map<String, dynamic> data =
          await _provider.getInventoriesPaginated(page: 1, limit: 30);
      final List itemsRaw = data['items'] ?? data['data'] ?? [];
      final List<InventoryModel> parsed =
          itemsRaw.map((e) => InventoryModel.fromJson(e)).toList();

      // Ưu tiên các món hết hàng/sắp hết hàng để nhắc nhở người dùng
      var priority = parsed
          .where((e) => e.quantity <= e.reorderThreshold)
          .toList()
        ..sort((a, b) => a.quantity.compareTo(b.quantity));
      drawerPriorityItems.assignAll(priority.take(5).toList());
    } catch (_) {}
  }

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalFunds =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice, bool isReplace = false}) {
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

      int newQuantity = isReplace ? quantity : currentItem.quantity + quantity;

      // ĐÃ SỬA: Chặn nếu số lượng cộng dồn lớn hơn tồn kho thực tế
      if (newQuantity > stock) {
        newQuantity = stock;
        if (!isReplace) {
          TSnackbarsWidget.warning(
              title: TTexts.warningTitle.tr,
              message: TTexts.batchExceedsStock.tr);
        }
      }

      cartItems[index] = TransactionDetailModel(
        productPackageId: pkgId,
        quantity: newQuantity,
        unitPrice: customPrice ?? currentItem.unitPrice,
        packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
        currentStock: stock,
        reorderThreshold: currentItem.reorderThreshold,
      );
    } else {
      if (quantity > stock) {
        quantity = stock;
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.batchExceedsStock.tr);
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
            message: TTexts.batchExceedsStock.tr);
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

  void updateItemQuantity(String packageId, int newQuantity) {
    final index =
        cartItems.indexWhere((item) => item.productPackageId == packageId);
    if (index != -1) {
      // ĐÃ SỬA: Nếu giảm về <= 0 thì tự xóa khỏi giỏ
      if (newQuantity <= 0) {
        removeItem(index);
      } else {
        final item = cartItems[index];
        // ĐÃ SỬA: Chặn nếu người dùng nhập số lố tồn kho trong ô Text
        if (newQuantity > item.currentStock) {
          cartItems[index] = item.copyWith(quantity: item.currentStock);
          cartItems.refresh();
          TSnackbarsWidget.warning(
              title: TTexts.warningTitle.tr,
              message: TTexts.batchExceedsStock.tr);
        } else {
          cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
          cartItems.refresh();
        }
      }
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }

  void handleExportWithPriceCheck() {
    if (cartItems.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.emptyCartWarning.tr);
      return;
    }

    final priceChangedItems = cartItems.where((item) {
      final originalPrice = item.packageInfo?.sellingPrice ?? 0.0;
      return item.unitPrice != originalPrice;
    }).toList();

    if (priceChangedItems.isNotEmpty) {
      // 3. XÂY DỰNG DANH SÁCH CHI TIẾT GIÁ BÁN
      String priceDetails = "${TTexts.priceFluctuationDesc.tr}\n";
      for (var i = 0; i < priceChangedItems.length; i++) {
        if (i >= 3) {
          priceDetails += "\n... ${TTexts.andMore.tr}";
          break;
        }
        final item = priceChangedItems[i];
        final oldPrice = item.packageInfo?.sellingPrice ?? 0.0;

        final oldPriceStr = CurrencyFormatterUtils.formatFull(oldPrice);
        final newPriceStr = CurrencyFormatterUtils.formatFull(item.unitPrice);

        priceDetails +=
            "\n• ${item.packageInfo?.displayName ?? TTexts.unknownProduct.tr}: $oldPriceStr ➔ $newPriceStr";
      }
      priceDetails += "\n\n${TTexts.sellingPriceChangeDetectedDesc.tr}";

      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.priceChangeDetectedTitle.tr,
          description: priceDetails,
          icon: const Text('💰', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.updatePriceAndExport.tr,
          secondaryButtonText: TTexts.exportOnly.tr,
          onPrimaryPressed: () {
            Get.back();
            _executeExport(
                updatePrices: true, priceChangedItems: priceChangedItems);
          },
          onSecondaryPressed: () {
            Get.back();
            _executeExport(updatePrices: false);
          },
        ),
      );
    } else {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.confirmExportTitle.tr,
          description: TTexts.confirmExportDesc.tr,
          icon: const Text('📦', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onPrimaryPressed: () {
            Get.back();
            _executeExport(updatePrices: false);
          },
        ),
      );
    }
  }

  Future<void> _executeExport(
      {bool updatePrices = false,
      List<TransactionDetailModel>? priceChangedItems}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingExportTicket.tr);

      // Cập nhật giá bán niêm yết lên DB nếu user đồng ý
      if (updatePrices && priceChangedItems != null) {
        for (var item in priceChangedItems) {
          if (item.productPackageId != null &&
              item.productPackageId!.isNotEmpty) {
            await _provider.updateProductPackage(
              item.productPackageId!,
              {
                'sellingPrice': item.unitPrice,
                'unitId': item.packageInfo?.unitId ??
                    'u-default', // Kẹp unitId để tránh lỗi 400
              },
            );
          }
        }
      }

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

      // ĐÃ THÊM: SAU KHI TẠO ĐƠN THÀNH CÔNG -> LƯU VÀO RECENT DỰA THEO KEY SHOP/USER
      final List<TransactionDetailModel> savedItems = List.from(cartItems);
      _saveRecentToStorage(savedItems);

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
            conflictedNames.add(
                "$productName (${TTexts.actualStock.tr}: $newStock) ➔ ${TTexts.autoRemovedFromCart.tr}");
            cartItems.removeAt(index);
          }
        }
        Get.dialog(TCustomDialogWidget(
          title: TTexts.outOfStockTitle.tr,
          description:
              "${TTexts.outOfStockDesc.tr}\n\n${TTexts.updatedListLabel.tr}\n${conflictedNames.map((e) => "• $e").join("\n")}",
          icon: const Text('🛒', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          onPrimaryPressed: () => Get.back(),
        ));
      } else {
        handleError(e);
      }
    }
  }

  // =========================================================================
  // MÁY QUÉT LIÊN TỤC VÀ ĐIỀU HƯỚNG
  // =========================================================================

  void openScanner() {
    Get.to(
      () => TBarcodeScannerLayout(
        // title: TTexts.scanProductBarcode.tr,
        onScanned: (code) {
          Get.find<BarcodeScannerController>().pauseScan();
          _processContinuousScannedBarcode(code);
        },
        bottomBar: Obx(() {
          if (cartItems.isEmpty) return const SizedBox.shrink();
          return TransactionScannerBottomBarWidget(
            totalItems: totalItems,
            totalPrice: totalFunds,
            onCartTap: () => Get.bottomSheet(
                const OutboundScanCartBottomSheetWidget(),
                isScrollControlled: true),
            onConfirm: () => Get.back(),
          );
        }),
      ),
      transition: Transition.downToUp,
    );
  }

  Future<void> _processContinuousScannedBarcode(String barcode) async {
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

        // Chuyển sang trang chi tiết và báo cờ fromScanner
        Get.toNamed(AppRoutes.outboundTransactionItemAdd, arguments: {
          'displayItem': displayItem,
          'fromScanner': true,
        })?.then((_) {
          // Khi quay lại từ trang Add Item, tiếp tục quét
          Get.find<BarcodeScannerController>().resumeScan();
        });
      } else if (resolutionType == 'candidate_match') {
        TSnackbarsWidget.warning(
            title: TTexts.unconfirmedBarcodeTitle.tr,
            message: TTexts.unconfirmedBarcodeMessage.tr);
        Get.find<BarcodeScannerController>().resumeScan();
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.barcodeNotFoundMessage.tr);
        Get.find<BarcodeScannerController>().resumeScan();
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorServerTitle.tr,
          message: '${TTexts.errorProcessingBarcode.tr}: $e');
      Get.find<BarcodeScannerController>().resumeScan();
    }
  }

  // ĐÃ THÊM: Phục vụ cho nút "Xóa tất cả" trong Scanner Bottom Sheet
  void confirmClearCart() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.clearAll.tr,
        description: TTexts.clearCartConfirmDesc.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        onPrimaryPressed: () {
          cartItems.clear();
          Get.back();
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  void confirmRemoveItem(int index) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.removeProductTitle.tr,
        description: TTexts.removeProductDesc.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        onPrimaryPressed: () {
          removeItem(index);
          Get.back();
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
    );
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
