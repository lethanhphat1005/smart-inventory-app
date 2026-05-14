import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/features/transaction/widgets/inbound_product_selection/inbound_product_selection_overflow_dialog_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';

class InboundProductSelectionController extends GetxController
    with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InboundTransactionController _inboundCtrl =
      Get.find<InboundTransactionController>();

  final List<InventoryModel> _loadedItems = [];
  final RxList<InventoryModel> allItems = <InventoryModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isFetchingMore = false.obs;

  final RxList<String> categoryList = <String>[].obs;
  final RxString activeCategory = "".obs;

  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 20;
  int _fetchId = 0;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxMap<String, int> draftCart = <String, int>{}.obs;
  final Map<String, InventoryModel> draftCartModels = {};

  final RxMap<String, double> draftCustomPrices = <String, double>{}.obs;
  final RxMap<String, double> cachedOriginalPrices = <String, double>{}.obs;
  int get totalDraftItems => draftCart.values.fold(0, (sum, qty) => sum + qty);

  double get totalDraftPrice {
    double total = 0.0;
    draftCart.forEach((id, qty) {
      final price = draftCustomPrices[id] ??
          cachedOriginalPrices[id] ??
          draftCartModels[id]?.productPackage?.importPrice ??
          0.0;
      total += price * qty;
    });
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    activeCategory.value = TTexts.allItems.tr;
    categoryList.assign(TTexts.allItems.tr);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 500) {
        fetchProducts();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    fetchProducts(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  String _getPkgId(InventoryModel item) {
    if (item.productPackage != null &&
        item.productPackage!.productPackageId.isNotEmpty) {
      return item.productPackage!.productPackageId;
    }
    if (item.productPackageId.isNotEmpty) return item.productPackageId;
    if (item.inventoryId.isNotEmpty) return item.inventoryId;
    return item.hashCode.toString();
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      isLoading.value = true;
      _loadedItems.clear();
    }

    if (!_hasNextPage || (isFetchingMore.value && !isRefresh)) return;

    _fetchId++;
    final int currentFetchId = _fetchId;

    try {
      if (!isRefresh) isFetchingMore.value = true;

      final data = await _provider.getInventoriesPaginated(
        page: _currentPage,
        limit: _limit,
        keyword: searchController.text.trim(),
      );

      if (_fetchId != currentFetchId) return;

      List itemsRaw = data['items'] ?? data['data'] ?? [];
      int totalItems = data['totalItems'] ?? data['total'] ?? 0;

      final List<InventoryModel> parsed =
          itemsRaw.map((e) => InventoryModel.fromJson(e)).toList();

      for (var newItem in parsed) {
        final newPkgId = _getPkgId(newItem);
        if (!_loadedItems.any((existing) => _getPkgId(existing) == newPkgId)) {
          _loadedItems.add(newItem);
        }
      }

      _updateCategories();
      _currentPage++;

      if (totalItems > 0) {
        _hasNextPage = _loadedItems.length < totalItems;
      } else {
        _hasNextPage = parsed.length >= _limit;
      }

      _applyFilters();
    } catch (e) {
      handleError(e);
    } finally {
      if (_fetchId == currentFetchId) {
        isLoading.value = false;
        isFetchingMore.value = false;
        isInitialLoading.value = false;
      }
    }
  }

  Future<void> navigateToDetail(InventoryModel item) async {
    final pkgId = _getPkgId(item);
    if (pkgId.isEmpty || pkgId == item.hashCode.toString()) return;

    final qty = getQtyInDraft(pkgId);
    final displayItem = InventoryInsightDisplayModel(
        product: item.productPackage?.product, inventory: item);

    final result = await Get.toNamed(
      AppRoutes.inboundTransactionItemAdd,
      arguments: {
        'displayItem': displayItem,
        'quantity': qty > 0 ? qty : 1,
        'isEditing': qty > 0,
        'fromSelectionScreen': true,
        'customPrice': draftCustomPrices[pkgId],
      },
    );

    // Hứng lại giá Import Price gốc để cập nhật nháp
    if (result != null && result is Map && result.containsKey('quantity')) {
      if (result['importPrice'] != null) {
        cachedOriginalPrices[pkgId] = result['importPrice'];
      }
      updateQuantity(item, result['quantity'],
          customPrice: result['customPrice']);
    }
  }

  void _updateCategories() {
    final Set<String> categories = {TTexts.allItems.tr};
    for (var item in _loadedItems) {
      final cat = item.productPackage?.product?.categoryName;
      if (cat != null && cat.isNotEmpty) categories.add(cat);
    }
    final newList = categories.toList();
    if (categoryList.length != newList.length) categoryList.assignAll(newList);
  }

  void searchProduct(String query) => fetchProducts(isRefresh: true);

  void setCategory(String category) {
    activeCategory.value = category;
    _applyFilters();
  }

  void _applyFilters() {
    if (activeCategory.value == TTexts.allItems.tr) {
      allItems.assignAll(_loadedItems);
    } else {
      allItems.assignAll(_loadedItems
          .where((item) =>
              (item.productPackage?.product?.categoryName ??
                  TTexts.uncategorized.tr) ==
              activeCategory.value)
          .toList());
    }
  }

  int getQtyInDraft(String pkgId) => draftCart[pkgId] ?? 0;

  void increaseItem(InventoryModel inventory) {
    final pkgId = _getPkgId(inventory);
    if (pkgId.isEmpty || pkgId == inventory.hashCode.toString()) return;
    int current = getQtyInDraft(pkgId);
    if (current < 999999) {
      draftCart[pkgId] = current + 1;
      draftCartModels[pkgId] = inventory;
    }
  }

  void decreaseItem(InventoryModel inventory) {
    final pkgId = _getPkgId(inventory);
    if (pkgId.isEmpty || pkgId == inventory.hashCode.toString()) return;
    int current = getQtyInDraft(pkgId);
    if (current > 1) {
      draftCart[pkgId] = current - 1;
    } else {
      draftCart.remove(pkgId);
      draftCartModels.remove(pkgId);
      draftCustomPrices.remove(pkgId);
      cachedOriginalPrices.remove(pkgId);
    }
  }

  void updateQuantity(InventoryModel inventory, int newQty,
      {double? customPrice}) {
    final pkgId = _getPkgId(inventory);
    if (pkgId.isEmpty || pkgId == inventory.hashCode.toString()) return;
    if (newQty <= 0) {
      draftCart.remove(pkgId);
      draftCartModels.remove(pkgId);
      draftCustomPrices.remove(pkgId);
      cachedOriginalPrices.remove(pkgId);
    } else {
      draftCart[pkgId] = newQty > 999999 ? 999999 : newQty;
      draftCartModels[pkgId] = inventory;
      if (customPrice != null) draftCustomPrices[pkgId] = customPrice;
    }
  }

  void clearDraft() {
    draftCart.clear();
    draftCartModels.clear();
    draftCustomPrices.clear();
    cachedOriginalPrices.clear();
  }

  // ==========================================
  // LOGIC XÁC NHẬN (SỬ DỤNG TCUSTOMDIALOGWIDGET)
  // ==========================================
  void confirmAndAddToMainCart() {
    if (draftCart.isEmpty) return;

    final List<String> overflowingKeys = [];
    final List<String> normalKeys = [];

    for (var pkgId in draftCart.keys) {
      final draftQty = draftCart[pkgId]!;
      final existingItemIndex = _inboundCtrl.cartItems
          .indexWhere((item) => item.productPackageId == pkgId);
      int existingQty = existingItemIndex != -1
          ? _inboundCtrl.cartItems[existingItemIndex].quantity
          : 0;
      if (draftQty + existingQty > 999999) {
        overflowingKeys.add(pkgId);
      } else {
        normalKeys.add(pkgId);
      }
    }

    if (overflowingKeys.isNotEmpty) {
      _showOverflowDialog(normalKeys, overflowingKeys);
    } else {
      _executeAddToCart(draftCart.keys.toList(), capAtMax: false);
    }
  }

  void _showOverflowDialog(
      List<String> normalKeys, List<String> overflowingKeys) {
    Get.dialog(InboundProductSelectionOverflowDialogWidget(
      onCapAtMax: () {
        Get.back();
        _executeAddToCart(draftCart.keys.toList(), capAtMax: true);
      },
      onAddValidOnly: normalKeys.isNotEmpty
          ? () {
              Get.back();
              _executeAddToCart(normalKeys, capAtMax: false);
            }
          : null,
      onReviewAgain: () => Get.back(),
    ));
  }

  // Lấy dữ liệu API Full Package lần cuối trước khi thêm vào giỏ
  Future<void> _executeAddToCart(List<String> keysToAdd,
      {required bool capAtMax}) async {
    bool hasAdded = false;
    FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingAddingToCart.tr);

    try {
      for (var pkgId in keysToAdd) {
        final inv = draftCartModels[pkgId]!;
        int qtyToAdd = draftCart[pkgId]!;

        if (capAtMax) {
          final existingItemIndex = _inboundCtrl.cartItems
              .indexWhere((item) => item.productPackageId == pkgId);
          int existingQty = existingItemIndex != -1
              ? _inboundCtrl.cartItems[existingItemIndex].quantity
              : 0;
          if (existingQty + qtyToAdd > 999999) {
            qtyToAdd = 999999 - existingQty;
          }
        }

        if (qtyToAdd > 0) {
          hasAdded = true;
          final packageFullData = await _provider.getProductPackageById(pkgId);
          final pkg = ProductPackageModel.fromJson(packageFullData);

          final Map<String, dynamic> data = {
            'productPackageId': pkgId,
            'displayName': pkg.displayName,
            'packageInfo': pkg,
            'importPrice': pkg.importPrice,
            'sellingPrice': pkg.sellingPrice,
            'currentStock': inv.quantity,
            'reorderThreshold': inv.reorderThreshold,
          };

          _inboundCtrl.addToCart(data,
              quantity: qtyToAdd,
              customPrice: draftCustomPrices[pkgId],
              isReplace: false);
        }
      }

      if (hasAdded) _inboundCtrl.cartItems.refresh();
      Get.until((route) => route.settings.name == AppRoutes.inboundTransaction);
    } catch (e) {
      handleError(e);
    } finally {
      FullScreenLoaderUtils.stopLoading();
    }
  }

  void handleBack() {
    if (draftCart.isNotEmpty) {
      Get.dialog(TCustomDialogWidget(
        title: TTexts.discardSelectionTitle.tr,
        description: TTexts.discardSelectionDesc.tr,
        icon: const Text('️⚠️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.exitAnyway.tr,
        onPrimaryPressed: () {
          Get.back();
          Get.back();
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ));
    } else {
      Get.back();
    }
  }
}
