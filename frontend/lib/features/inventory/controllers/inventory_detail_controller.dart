import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/features/inventory/models/inventory_history_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/home/widgets/shared/home_adjustment_details_bottom_sheet.dart';

class _TempHistory {
  final DateTime date;
  final InventoryActionType type;
  final int qty; // Chênh lệch
  final int rawDiff;
  final String note;
  final int oldQty;
  final int newQty;

  _TempHistory({
    required this.date,
    required this.type,
    required this.qty,
    required this.rawDiff,
    required this.note,
    this.oldQty = 0,
    this.newQty = 0,
  });
}

class InventoryDetailController extends GetxController with TErrorHandler {
  final Rx<InventoryInsightDisplayModel?> currentDisplayItem =
      Rx<InventoryInsightDisplayModel?>(null);
  final RxBool isLoading = true.obs;
  late final bool canManageInventory;
  final RxBool isChartMode = false.obs;
  final List<InventoryInsightDisplayModel> historyStack = [];
  final RxString categoryNameObs = TTexts.uncategorized.tr.obs;
  final RxList<InventoryInsightDisplayModel> relatedPackagesList =
      <InventoryInsightDisplayModel>[].obs;

  final RxInt totalStockInObs = 0.obs;
  final RxInt totalStockOutObs = 0.obs;
  final RxList<Map<String, dynamic>> stockMovementDataObs =
      <Map<String, dynamic>>[].obs;

  final RxList<InventoryHistoryModel> inventoryHistoryList =
      <InventoryHistoryModel>[].obs;
  final rawHistoryStack = <_TempHistory>[];

  final InventoryProvider _provider = InventoryProvider();

  @override
  void onInit() {
    super.onInit();
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageInventory =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageInventory = false;
    }
    Future.microtask(() => _initData());
  }

  void _initData() {
    final arg = Get.arguments;
    String? productId;

    if (arg is String) {
      productId = arg;
    } else if (arg is Map) {
      productId = arg['productId'];
    }

    final packageId = Get.parameters['packageId'];
    final barcode = Get.parameters['barcode'];

    _fetchDetailData(
        productId: productId, packageId: packageId, barcode: barcode);
  }

  Future<void> _fetchDetailData(
      {String? productId,
      String? packageId,
      String? barcode,
      bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      String? finalProductId = productId;

      if ((finalProductId == null || finalProductId.isEmpty) &&
          packageId != null &&
          packageId.isNotEmpty) {
        final pkgData = await _provider.getProductPackageDetail(packageId);
        finalProductId =
            pkgData['productId'] ?? pkgData['product']?['productId'];
      }

      if (finalProductId == null || finalProductId.isEmpty) {
        throw Exception(TTexts.errorProductOrPackageIdMissing.tr);
      }

      final baseResults = await Future.wait([
        _provider.getProductDetail(finalProductId),
        _provider.getPackagesByProductId(finalProductId),
      ]);

      final rawProduct = baseResults[0] as Map<String, dynamic>;
      final rawPackages = baseResults[1] as List<dynamic>;

      categoryNameObs.value =
          rawProduct['category']?['name'] ?? TTexts.uncategorized.tr;
      final parentProduct = ProductModel.fromJson(rawProduct);

      List<InventoryInsightDisplayModel> related = [];
      InventoryInsightDisplayModel? initialItem;

      for (var pkgJson in rawPackages) {
        final pkgModel = ProductPackageModel.fromJson(pkgJson);
        final invJsonMap =
            Map<String, dynamic>.from(pkgJson['inventory'] ?? {});
        invJsonMap['productPackage'] = pkgJson;
        invJsonMap['productPackageId'] = pkgModel.productPackageId;
        if (invJsonMap['inventoryId'] == null) {
          invJsonMap['inventoryId'] = 'INV_MOCK_${pkgModel.productPackageId}';
        }
        if (invJsonMap['quantity'] == null) invJsonMap['quantity'] = 0;

        final invModel = InventoryModel.fromJson(invJsonMap);
        final mappedItem = InventoryInsightDisplayModel(
            product: parentProduct, inventory: invModel);
        related.add(mappedItem);

        if (packageId != null && pkgModel.productPackageId == packageId) {
          initialItem = mappedItem;
        } else if (initialItem == null &&
            barcode != null &&
            pkgModel.barcodeValue == barcode) {
          initialItem = mappedItem;
        }
      }

      if (initialItem == null && related.isNotEmpty) {
        initialItem = related.first;
      }
      if (initialItem != null) {
        related.removeWhere((item) =>
            item.inventory.productPackageId ==
            initialItem!.inventory.productPackageId);
      }

      relatedPackagesList.assignAll(related);
      currentDisplayItem.value = initialItem;

      if (initialItem != null) {
        final statsResults = await Future.wait([
          _provider.getTransactions(queryParams: {'limit': 100}),
          _provider.getAuditLogs(
              queryParams: {'entityType': 'Inventory', 'limit': 100}),
        ]);
        _processStatsAndHistory(statsResults[0] as List<TransactionModel>,
            statsResults[1], initialItem);
      } else {
        _resetStats();
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _processStatsAndHistory(List<TransactionModel> txList,
      List<dynamic> auditList, InventoryInsightDisplayModel item) {
    int tIn = 0;
    int tOut = 0;
    List<_TempHistory> tempHistory = [];
    final targetPackageId = item.inventory.productPackageId;
    final targetInventoryId = item.inventory.inventoryId;

    // 1. Xử lý Transactions (Nhập/Xuất)
    for (var tx in txList) {
      final txType = tx.type;
      if (txType != 'import' && txType != 'export') continue;
      final targetDetail = tx.items
          .firstWhereOrNull((d) => d.productPackageId == targetPackageId);
      if (targetDetail == null) continue;

      int qty = targetDetail.quantity;
      if (qty <= 0) continue;

      final date = tx.createdAt ?? DateTime.now();
      final note = tx.note ?? '';

      if (txType == 'import') tIn += qty;
      if (txType == 'export') tOut += qty;

      tempHistory.add(_TempHistory(
        date: date,
        type: txType == 'import'
            ? InventoryActionType.stockIn
            : InventoryActionType.stockOut,
        qty: qty,
        rawDiff: txType == 'import' ? qty : -qty,
        note: note.isNotEmpty
            ? note
            : (txType == 'import'
                ? TTexts.importGoods.tr
                : TTexts.exportGoods.tr),
        // Đối với transaction, Backend không trả về old/new stock tại thời điểm đó nên tạm tính 0 hoặc N/A
        oldQty: 0,
        newQty: 0,
      ));
    }

    // 2. Xử lý Audit Logs (Kiểm kho) - ĐÃ CẬP NHẬT LẤY OLD/NEW QTY
    for (var log in auditList) {
      if (log['entityType'] != 'Inventory') continue;
      if (log['entityId'] != targetInventoryId &&
          log['entityId'] != targetPackageId) {
        continue;
      }

      Map<String, dynamic> oldVal = {};
      Map<String, dynamic> newVal = {};
      try {
        if (log['oldValue'] is Map) {
          oldVal = log['oldValue'] as Map<String, dynamic>;
        } else if (log['oldValue'] is String) {
          oldVal = jsonDecode(log['oldValue']);
        }
        if (log['newValue'] is Map) {
          newVal = log['newValue'] as Map<String, dynamic>;
        } else if (log['newValue'] is String) {
          newVal = jsonDecode(log['newValue']);
        }
      } catch (e) {
        continue;
      }

      final oldQtyVal = oldVal['quantity'];
      final newQtyVal = newVal['quantity'];

      if (oldQtyVal != null && newQtyVal != null && oldQtyVal != newQtyVal) {
        int oQ = (oldQtyVal as num).toInt();
        int nQ = (newQtyVal as num).toInt();
        int diff = nQ - oQ;

        final date = log['performedAt'] != null
            ? DateTime.parse(log['performedAt']).toLocal()
            : DateTime.now();
        final note = log['note'] ?? '';

        if (diff > 0) tIn += diff;
        if (diff < 0) tOut += diff.abs();

        tempHistory.add(_TempHistory(
          date: date,
          type: InventoryActionType.adjust,
          qty: diff,
          rawDiff: diff,
          note: note.isNotEmpty ? note : TTexts.stockAdjustmentOrCheck.tr,
          oldQty: oQ, // Gán giá trị thực tế từ Audit Log
          newQty: nQ, // Gán giá trị thực tế từ Audit Log
        ));
      }
    }

    tempHistory.sort((a, b) => b.date.compareTo(a.date));
    rawHistoryStack.assignAll(tempHistory);

    List<InventoryHistoryModel> finalHistory = tempHistory
        .map((e) => InventoryHistoryModel(
            date: DayFormatterUtils.formatDateTime(e.date),
            type: e.type,
            qty: e.qty,
            note: e.note))
        .toList();

    totalStockInObs.value = tIn;
    totalStockOutObs.value = tOut;
    inventoryHistoryList.assignAll(finalHistory);

    // Tính Chart 7 ngày (giữ nguyên logic cũ của bạn)
    DateTime now = DateTime.now();
    Map<String, Map<String, dynamic>> weeklyData = {};
    for (int i = 6; i >= 0; i--) {
      DateTime d = now.subtract(Duration(days: i));
      weeklyData[DateFormat('yyyy-MM-dd').format(d)] = {
        'in': 0,
        'out': 0,
        'day': DateFormat('EEE').format(d)
      };
    }
    for (var h in tempHistory) {
      String txDateStr = DateFormat('yyyy-MM-dd').format(h.date);
      if (weeklyData.containsKey(txDateStr)) {
        if (h.rawDiff > 0) {
          weeklyData[txDateStr]!['in'] =
              (weeklyData[txDateStr]!['in'] as int) + h.rawDiff;
        } else if (h.rawDiff < 0) {
          weeklyData[txDateStr]!['out'] =
              (weeklyData[txDateStr]!['out'] as int) + h.rawDiff.abs();
        }
      }
    }
    List<Map<String, dynamic>> finalChartData = [];
    weeklyData.forEach((key, val) => finalChartData.add(val));
    stockMovementDataObs.assignAll(finalChartData);
  }

  void _resetStats() {
    totalStockInObs.value = 0;
    totalStockOutObs.value = 0;
    stockMovementDataObs.clear();
    inventoryHistoryList.clear();
    rawHistoryStack.clear();
  }

  Future<void> refreshData() async {
    final currentProductId = currentDisplayItem.value?.product?.productId;
    final currentPkgId = currentDisplayItem.value?.inventory.productPackageId;
    if (currentProductId != null) {
      await _fetchDetailData(
          productId: currentProductId,
          packageId: currentPkgId,
          isRefresh: true);
    }
  }

  void pushRelatedItem(InventoryInsightDisplayModel newItem) {
    if (currentDisplayItem.value != null) {
      final targetPkgId = newItem.inventory.productPackageId;
      final existingIndex = historyStack.indexWhere(
          (element) => element.inventory.productPackageId == targetPkgId);
      if (existingIndex != -1) {
        historyStack.removeRange(existingIndex, historyStack.length);
      } else {
        historyStack.add(currentDisplayItem.value!);
      }
      currentDisplayItem.value = newItem;
      final productId = newItem.product?.productId;
      if (productId != null) {
        _fetchDetailData(
            productId: productId, packageId: targetPkgId, isRefresh: false);
      }
    }
  }

  void goBack() {
    if (historyStack.isNotEmpty) {
      final oldItem = historyStack.removeLast();
      currentDisplayItem.value = oldItem;
    } else {
      Get.back();
    }
  }

  void toggleStatsMode(bool isChart) {
    isChartMode.value = isChart;
  }

  void handleMenuAction(String actionKey) {
    if (actionKey == TTexts.viewProductInfo) {
      final product = currentDisplayItem.value?.product;
      if (product != null) {
        Get.toNamed(AppRoutes.productCatalogDetail, arguments: product)
            ?.then((_) {
          if (Get.isRegistered<InventoryController>()) {
            Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
          }
          if (Get.isRegistered<InventoryInsightController>()) {
            Get.find<InventoryInsightController>().refreshData();
          }
        });
      } else {
        TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.productDataMissing.tr,
        );
      }
    }
  }

  void viewAllHistory() {
    Get.toNamed(AppRoutes.adjustmentHistory, arguments: {'search': barcode});
  }

  // ==========================================
  // GỌI BOTTOM SHEET (TÁI SỬ DỤNG TỪ HOME)
  // ==========================================
  void openHistoryDetails(int index) {
    if (index < 0 || index >= rawHistoryStack.length) return;

    final rawItem = rawHistoryStack[index];

    // Icon đại diện đồng bộ
    final String iconChar = rawItem.type == InventoryActionType.adjust
        ? "📝"
        : (rawItem.type == InventoryActionType.stockOut ? "📤" : "📥");

    TBottomSheetWidget.show(
      child: HomeAdjustmentDetailsBottomSheet(
        icon: iconChar,
        productName: name,
        date: rawItem.date,
        oldQty: rawItem.oldQty,
        newQty: rawItem.newQty,
        difference: rawItem.rawDiff,
        note: rawItem.note.isNotEmpty ? rawItem.note : TTexts.na.tr,
      ),
    );
  }

  // ==========================================
  // GETTERS UI
  // ==========================================

  InventoryInsightDisplayModel? get _item => currentDisplayItem.value;
  String get name =>
      _item?.inventory.productPackage?.displayName ?? TTexts.unknownProduct.tr;
  String get barcode =>
      _item?.inventory.productPackage?.barcodeValue ?? TTexts.na.tr;
  String? get imageUrl => _item?.product?.imageUrl;
  String get brand => _item?.product?.brand ?? '';
  String get barcodeType =>
      _item?.inventory.productPackage?.barcodeType ?? 'EAN';
  String get activeStatus =>
      _item?.inventory.productPackage?.activeStatus ?? 'active';
  String get categoryName => categoryNameObs.value;
  List<InventoryInsightDisplayModel> get relatedPackages => relatedPackagesList;

  List<String> get tags {
    List<String> result = [categoryName, statusText];
    if (brand.isNotEmpty && brand != 'N/A') result.add(brand);
    if (activeStatus.toLowerCase() != 'active') result.add(TTexts.inactive.tr);
    return result;
  }

  double get price => _item?.inventory.productPackage?.sellingPrice ?? 0.0;
  double get importPrice => _item?.inventory.productPackage?.importPrice ?? 0.0;
  double get profitMargin {
    if (importPrice == 0) return 0.0;
    return ((price - importPrice) / importPrice) * 100;
  }

  int get quantity => _item?.inventory.quantity ?? 0;
  int get threshold => _item?.inventory.reorderThreshold ?? 0;

  double get stockHealthRatio {
    if (quantity <= 0) return 0.0;
    if (threshold <= 0) return 1.0;
    final ratio = quantity / (threshold * 2);
    return ratio > 1.0 ? 1.0 : ratio;
  }

  Color get stockHealthColor {
    if (quantity <= 0) return AppColors.alertText;
    if (quantity <= threshold) return AppColors.primary;
    return AppColors.stockIn;
  }

  String get statusText {
    if (quantity <= 0) return TTexts.tabOutStock.tr;
    if (quantity <= threshold) return TTexts.tabLowStock.tr;
    return TTexts.tabHealthy.tr;
  }

  int get totalStockIn => totalStockInObs.value;
  int get totalStockOut => totalStockOutObs.value;
  List<InventoryHistoryModel> get inventoryHistory => inventoryHistoryList;
  List<Map<String, dynamic>> get stockMovementData => stockMovementDataObs;
}
