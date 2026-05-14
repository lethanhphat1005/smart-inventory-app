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
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_scanner_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/inbound_transaction/inbound_transaction_scan_cart_bottom_sheet_widget.dart';

class InboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InventoryProvider _inventoryProvider = InventoryProvider();
  final _storage = GetStorage(); // KHỞI TẠO STORAGE CHO RECENT

  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;
  final TextEditingController noteController = TextEditingController();

  final RxList<InventoryModel> drawerRecentItems = <InventoryModel>[].obs;
  final RxList<InventoryModel> drawerPriorityItems = <InventoryModel>[].obs;

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalFunds =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  @override
  void onInit() {
    super.onInit();
    _loadRecentFromStorage();
  }

  @override
  void onReady() {
    super.onReady();
    fetchDrawerSuggestions();
  }

  // =========================================================================
  // LOGIC STORAGE RECENT ACTIVITIES
  // =========================================================================

  // Tạo key recent
  String get _recentStorageKey {
    final storeId = _storage.read('STORE_ID') ?? 'default_store';

    final userEmail = _storage.read('USER_EMAIL') ?? 'default_user';

    return 'recent_inbound_${storeId}_$userEmail';
  }

  void _loadRecentFromStorage() {
    final List<dynamic>? storedData = _storage.read(_recentStorageKey);
    if (storedData != null) {
      // Parse an toàn từ Map
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
                      'brand': inv.productPackage!.product!.brand,
                      'categoryName': inv.productPackage!.product!.categoryName,
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
        quantity: item.currentStock + item.quantity,
        reorderThreshold: item.reorderThreshold,
        lastCount: 0,
        updatedAt: DateTime.now(),
        activeStatus: 'active',
        productPackage: item.packageInfo,
      );

      // Tránh trùng lặp, đẩy lên đầu
      currentRecent
          .removeWhere((e) => e.productPackageId == inv.productPackageId);
      currentRecent.insert(0, inv);
    }

    // Giới hạn 5 món
    final finalRecent = currentRecent.take(5).toList();
    drawerRecentItems.assignAll(finalRecent);

    // Ghi xuống Storage sử dụng Key động và Hàm Map thủ công
    _storage.write(
        _recentStorageKey, finalRecent.map((e) => _inventoryToMap(e)).toList());
  }

  // =========================================================================
  // PHÍM TẮT & GỢI Ý (ĐƯỢC GỌI TỪ DRAWER)
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

      // Lấy danh sách ưu tiên (dưới ngưỡng an toàn)
      var priority = parsed
          .where((e) => e.quantity <= e.reorderThreshold)
          .toList()
        ..sort((a, b) => a.quantity.compareTo(b.quantity));
      drawerPriorityItems.assignAll(priority.take(5).toList());
    } catch (_) {}
  }

  // Hộp thoại xác nhận thêm tất cả ưu tiên
  void confirmAddAllPriority() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmAddPriorityTitle.tr,
        description: TTexts.confirmAddPriorityDesc.tr,
        icon: const Text('️🎯', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirm.tr,
        onPrimaryPressed: () {
          Get.back();
          addAllPriorityItems();
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> addAllPriorityItems() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.checkingInventory.tr);

      final Map<String, dynamic> data =
          await _provider.getInventoriesPaginated(page: 1, limit: 50);
      final List itemsRaw = data['items'] ?? data['data'] ?? [];
      final List<InventoryModel> parsed =
          itemsRaw.map((e) => InventoryModel.fromJson(e)).toList();

      // Lọc các món CHƯA CÓ trong giỏ và ĐANG THIẾU
      final priorities = parsed.where((item) {
        final pkgId = item.productPackageId.isNotEmpty
            ? item.productPackageId
            : item.productPackage?.productPackageId ?? '';
        final isBelowThreshold = item.quantity <= item.reorderThreshold;
        final notInCart = !cartItems.any((c) => c.productPackageId == pkgId);
        return isBelowThreshold && notInCart && pkgId.isNotEmpty;
      }).toList();

      FullScreenLoaderUtils.stopLoading();

      if (priorities.isEmpty) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.allPrioritySatisfied.tr);
        return;
      }

      for (var item in priorities) {
        final pkgId = item.productPackageId.isNotEmpty
            ? item.productPackageId
            : item.productPackage?.productPackageId ?? '';

        // Tự động tính toán số lượng bù
        int addQty = item.reorderThreshold > item.quantity
            ? (item.reorderThreshold - item.quantity)
            : 10;
        if (addQty <= 0) addQty = 1;

        addToCart({
          'productPackageId': pkgId,
          'displayName': item.productPackage?.displayName ?? TTexts.product.tr,
          'packageInfo': item.productPackage,
          'importPrice': item.productPackage?.importPrice ?? 0.0,
          'sellingPrice': item.productPackage?.sellingPrice ?? 0.0,
          'currentStock': item.quantity,
          'reorderThreshold': item.reorderThreshold,
        }, quantity: addQty);
      }

      Get.back(); // Tự động đóng Drawer nếu đang mở
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.addedPrioritySuccessMsg.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  // =========================================================================
  // LOGIC GIỎ HÀNG CHÍNH
  // =========================================================================

  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice, bool isReplace = false}) {
    final String? pkgId = productData['productPackageId'];
    final int stock = productData['currentStock'] ?? 0;

    if (pkgId == null || pkgId.isEmpty) {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.errorInvalidPackageId.tr);
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
    if (index >= 0 && index < cartItems.length) {
      if (newQuantity <= 0) {
        removeItem(index);
      } else {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
        cartItems.refresh();
      }
    }
  }

  void updateItemQuantity(String productPackageId, int newQuantity) {
    final index = cartItems
        .indexWhere((item) => item.productPackageId == productPackageId);
    if (index != -1) {
      if (newQuantity <= 0) {
        removeItem(index);
      } else {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
        cartItems.refresh();
      }
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
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

  // =========================================================================
  // XỬ LÝ NHẬP KHO VÀ LƯU RECENT
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
      // Danh sách chi tiết giá
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

      // SAU KHI TẠO ĐƠN THÀNH CÔNG -> LƯU VÀO RECENT DỰA THEO KEY SHOP/USER
      final List<TransactionDetailModel> savedItems = List.from(cartItems);
      _saveRecentToStorage(savedItems);

      FullScreenLoaderUtils.stopLoading();

      final transaction = TransactionModel(
        transactionId: response['transactionId'] ?? 'NEW-TX',
        totalPrice: totalFunds,
        type: 'import',
        status: 'COMPLETED',
        note: noteController.text.trim(),
        createdAt: DateTime.now(),
        items: savedItems,
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

  // =========================================================================
  // SCANNER VÀ CÁC THAO TÁC KHÁC
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
                const InboundTransactionScanCartBottomSheetWidget(),
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
            product: productModel, inventory: inventoryModel);

        Get.toNamed(AppRoutes.inboundTransactionItemAdd, arguments: {
          'displayItem': displayItem,
          'fromScanner': true,
        })?.then((_) {
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
