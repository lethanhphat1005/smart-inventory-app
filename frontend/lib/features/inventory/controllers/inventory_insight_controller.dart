import 'package:flutter/material.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/routes/app_routes.dart';

class InventoryInsightController extends GetxController with TErrorHandler {
  final InventoryController _parentCtrl = Get.find<InventoryController>();

  final RxString activeFilter = TTexts.tabAll.obs;
  final RxString activeCategory = TTexts.allItems.obs;

  final ScrollController scrollController = ScrollController();

  List<InventoryInsightDisplayModel> _allFilteredList = [];

  final RxList<InventoryInsightDisplayModel> displayList =
      <InventoryInsightDisplayModel>[].obs;

  int _currentPage = 1;
  final int _itemsPerPage = 15;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  bool canManageProduct = false;

  RxBool get isLoading => _parentCtrl.isLoading;
  List<CategoryModel> get categories => _parentCtrl.categories;

  @override
  void onInit() {
    super.onInit();
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageProduct = (role == 'manager' || role == 'owner');
    } catch (e) {
      canManageProduct = false;
    }

    scrollController.addListener(_onScroll);
    ever(_parentCtrl.inventories,
        (_) => _applyFiltersAndPaginate(isRefresh: true));
    _applyFiltersAndPaginate(isRefresh: true);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> refreshData() async {
    try {
      await _parentCtrl.fetchDashboardData();
    } catch (e) {
      handleError(e);
    }
  }

  void _applyFiltersAndPaginate({bool isRefresh = false}) {
    if (isRefresh) {
      _currentPage = 1;
      hasMore.value = true;
      displayList.clear();
    }

    final inventories = List<InventoryModel>.from(_parentCtrl.inventories);
    final products = _parentCtrl.products;

    List<InventoryModel> filteredInventories = inventories;
    if (activeFilter.value == TTexts.tabHealthy) {
      filteredInventories =
          inventories.where((i) => i.quantity > (i.reorderThreshold)).toList();
    } else if (activeFilter.value == TTexts.tabLowStock) {
      filteredInventories = inventories
          .where((i) => i.quantity > 0 && i.quantity <= (i.reorderThreshold))
          .toList();
    } else if (activeFilter.value == TTexts.tabOutStock) {
      filteredInventories = inventories.where((i) => i.quantity == 0).toList();
    }

    List<InventoryInsightDisplayModel> mappedList =
        filteredInventories.map((inv) {
      final product = products.firstWhereOrNull(
          (p) => p.productId == inv.productPackage?.productId);
      return InventoryInsightDisplayModel(inventory: inv, product: product);
    }).toList();

    if (activeCategory.value != TTexts.allItems) {
      mappedList = mappedList.where((item) {
        final category = categories
            .firstWhereOrNull((c) => c.categoryId == item.product?.categoryId);
        return category?.name == activeCategory.value;
      }).toList();
    }

    mappedList.sort((a, b) {
      if (a.inventory.quantity == 0 && b.inventory.quantity > 0) return -1;
      if (b.inventory.quantity == 0 && a.inventory.quantity > 0) return 1;
      return a.inventory.quantity.compareTo(b.inventory.quantity);
    });

    _allFilteredList = mappedList;
    _loadNextPage();
  }

  void _loadNextPage() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= _allFilteredList.length) {
      hasMore.value = false;
      return;
    }

    final nextItems = _allFilteredList.sublist(
      startIndex,
      endIndex > _allFilteredList.length ? _allFilteredList.length : endIndex,
    );

    displayList.addAll(nextItems);

    if (displayList.length >= _allFilteredList.length) {
      hasMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _currentPage++;
    _loadNextPage();
    isLoadingMore.value = false;
  }

  int getCount(String tabKey) {
    if (tabKey == TTexts.tabHealthy) return _parentCtrl.healthyCount.value;
    if (tabKey == TTexts.tabLowStock) return _parentCtrl.lowCount.value;
    if (tabKey == TTexts.tabOutStock) return _parentCtrl.outCount.value;
    return _parentCtrl.inventories.length;
  }

  void toggleFilter(String filterKey) {
    activeFilter.value =
        (activeFilter.value == filterKey) ? TTexts.tabAll : filterKey;
    _applyFiltersAndPaginate(isRefresh: true);
  }

  void setCategory(String categoryName) {
    activeCategory.value = categoryName;
    _applyFiltersAndPaginate(isRefresh: true);
  }

  void goToDetail(InventoryInsightDisplayModel item) {
    // Lấy object package lồng bên trong (nơi chứa data thật giống như Widget)
    final package = item.inventory.productPackage;

    if (package == null) {
      Get.snackbar("Lỗi", "Dữ liệu lô hàng bị thiếu từ Server.");
      return;
    }

    // Lấy ID và Barcode TRỰC TIẾP từ object package lồng
    final packageId = package.productPackageId;
    final productId =
        package.productId; // Lấy luôn productId từ đây cho an toàn
    final barcode = package.barcodeValue ?? '';

    // Log ra sẽ thấy ID khớp 100% với Backend
    debugPrint(
        "===> DATA CHUẨN BỊ GỬI: ProductID: $productId | PackageID: $packageId");

    if (packageId.isEmpty || productId.isEmpty) {
      Get.snackbar("Lỗi dữ liệu", "Sản phẩm hoặc Lô hàng không có ID hợp lệ.");
      return;
    }

    // Truyền đi đúng chuẩn như các trang khác
    Get.toNamed(
      AppRoutes.inventoryDetail,
      arguments: productId,
      parameters: {
        'packageId': packageId,
        if (barcode.isNotEmpty) 'barcode': barcode,
      },
    );
  }
}
