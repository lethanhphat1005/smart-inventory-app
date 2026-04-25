import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/unit_model.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/features/search/widgets/search_filter_bottom_sheet_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/features/search/models/search_product_model.dart';
import 'package:frontend/features/search/providers/search_provider.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/controllers/barcode_action_controller.dart';

enum SearchTarget { global, inventory, transactions, users }

class SearchFilterUserModel {
  final String id;
  final String name;
  final String avatarUrl;
  SearchFilterUserModel(
      {required this.id, required this.name, required this.avatarUrl});
}

class TSearchController extends GetxController with TErrorHandler {
  final SearchProvider _provider = SearchProvider();
  final InventoryProvider _inventoryProvider = InventoryProvider();
  final storage = GetStorage();

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final scrollController = ScrollController();

  final RxString currentSearchQuery = ''.obs;

  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString suggestion = ''.obs;
  String dynamicHint = TTexts.searchEverything.tr;

  late final SearchTarget target;

  String returnRouteContext = '';

  bool get isTransactionSearch => target == SearchTarget.transactions;

  bool get isAddingToCart =>
      returnRouteContext == AppRoutes.outboundTransaction ||
      returnRouteContext == AppRoutes.inboundTransaction;

  bool get isStockAdjustment => returnRouteContext == AppRoutes.stockAdjustment;

  final RxString filterType = TTexts.filterNone.obs;
  final Rx<DateTimeRange?> filterDateRange = Rx<DateTimeRange?>(null);

  final RxString filterUserId = ''.obs;
  final RxString filterUserName = ''.obs;
  final RxList<SearchFilterUserModel> availableUsers =
      <SearchFilterUserModel>[].obs;

  final RxList<InventoryInsightDisplayModel> searchResults =
      <InventoryInsightDisplayModel>[].obs;
  final RxList<TransactionModel> searchTransactionResults =
      <TransactionModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;

  int _currentPage = 1; // Dùng cho Product
  int _txPage = 1; // Dùng cho Transaction
  final int _txPageSize = 20;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      target = args['target'] as SearchTarget? ?? SearchTarget.inventory;
      dynamicHint = args['hint'] ??
          (isTransactionSearch
              ? TTexts.searchTransactionHint.tr
              : TTexts.searchEverything.tr);
    } else if (args is String) {
      if (args == 'transaction') {
        target = SearchTarget.transactions;
        dynamicHint = TTexts.searchTransactionHint.tr;
      } else {
        returnRouteContext = args;
        target = SearchTarget.inventory;
        if (isAddingToCart || isStockAdjustment) {
          dynamicHint = TTexts.searchProductToAdd.tr;
        } else {
          dynamicHint = TTexts.searchEverything.tr;
        }
      }
    } else {
      target = SearchTarget.inventory;
      dynamicHint = TTexts.searchEverything.tr;
    }

    if (isTransactionSearch) {
      _loadFilterUsers();
    } else {
      _loadRecentSearches();
    }

    try {
      final storeService = Get.find<StoreService>();
      final userService = Get.find<UserService>();
      if (!isTransactionSearch) {
        ever(storeService.currentStoreId, (_) => _loadRecentSearches());
        ever(userService.currentUser, (_) => _loadRecentSearches());
      }
    } catch (e) {
      debugPrint("Services not initialized yet.");
    }

    scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => focusNode.requestFocus());
  }

  Future<void> _loadFilterUsers() async {
    try {
      final storeId = Get.find<StoreService>().currentStoreId.value;
      final currentUser = Get.find<UserService>().currentUser.value;
      final currentUserId = currentUser?.userId ?? '';

      if (storeId.isEmpty) return;

      final members = await _provider.getStoreMembers(storeId, currentUserId);

      if (members.isNotEmpty) {
        final mappedUsers = members.map((m) {
          final id = m.userId;
          final name = m.name;
          const String avatar = '';
          return SearchFilterUserModel(id: id, name: name, avatarUrl: avatar);
        }).toList();

        availableUsers.assignAll(mappedUsers);
      } else {
        final myName = currentUser?.fullName ?? 'Admin';
        availableUsers.assignAll([
          SearchFilterUserModel(id: currentUserId, name: myName, avatarUrl: '')
        ]);
      }
    } catch (e) {
      debugPrint("Lỗi fetch users: $e");
    }
  }

  void openTransactionFilterSheet() {
    focusNode.unfocus();
    TBottomSheetWidget.show(
      title: TTexts.filterTransactions.tr,
      child: const SearchFilterBottomSheetWidget(),
    );
  }

  void applyFilters(
      String type, DateTimeRange? dateRange, String userId, String userName) {
    filterType.value = type;
    filterDateRange.value = dateRange;
    filterUserId.value = userId;
    filterUserName.value = userName;
    Get.back();
    _executeTransactionSearch(); // Không cần truyền text nữa
  }

  void removeFilter(String filterCategory) {
    if (filterCategory == 'type') filterType.value = TTexts.filterNone;
    if (filterCategory == 'date') filterDateRange.value = null;
    if (filterCategory == 'user') {
      filterUserId.value = '';
      filterUserName.value = '';
    }
    _executeTransactionSearch(); // Không cần truyền text nữa
  }

  void onSearchChanged(String query) {
    currentSearchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (isTransactionSearch) {
      // Transaction không còn search bằng text nữa do Backend không hỗ trợ FTS
    } else {
      if (query.trim().length >= 2) {
        _debounce = Timer(const Duration(milliseconds: 500),
            () => _executeProductSearch(query.trim()));
      } else {
        searchResults.clear();
        suggestion.value = '';
      }
    }
  }

  void confirmRemoveRecentSearch(String query) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.deleteSearchTitle.tr,
        description: '${TTexts.deleteSearchMessage.tr}\n\n"$query"',
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onPrimaryPressed: () {
          Get.back();
          _removeRecentSearch(query);
        },
      ),
    );
  }

  void _removeRecentSearch(String query) {
    recentSearches.remove(query);
    storage.write(_currentStorageKey, recentSearches.toList());
  }

  // ====================================================================
  // ĐÃ CẬP NHẬT: TÌM KIẾM TRANSACTION CÓ PHÂN TRANG API (REAL PAGINATION)
  // ====================================================================
  Future<void> _executeTransactionSearch() async {
    final bool hasNoFilters = filterType.value == TTexts.filterNone &&
        filterDateRange.value == null &&
        filterUserId.value.isEmpty;

    if (hasNoFilters) {
      searchTransactionResults.clear(); 
      hasMore.value = false; 
      return; 
    }

    isSearching.value = true;
    hasMore.value = true;
    _txPage = 1;

    try {
      Map<String, dynamic> queryParams = {
        'limit': _txPageSize,
        'page': _txPage,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      };

      if (filterType.value != TTexts.filterNone) {
        if (filterType.value == TTexts.filterInbound) {
          queryParams['type'] = 'import';
        }
        if (filterType.value == TTexts.filterOutbound) {
          queryParams['type'] = 'export';
        }
      }
      if (filterDateRange.value != null) {
        queryParams['startDate'] =
            DayFormatterUtils.formatApiDate(filterDateRange.value!.start);
        queryParams['endDate'] =
            DayFormatterUtils.formatApiDate(filterDateRange.value!.end);
      }
      if (filterUserId.value.isNotEmpty) {
        queryParams['userId'] = filterUserId.value;
      }

      List<TransactionModel> results =
          await _provider.searchTransactions(queryParams: queryParams);

      searchTransactionResults.assignAll(results);

      if (results.length < _txPageSize) {
        hasMore.value = false;
      }
    } catch (e) {
      handleError(e);
    } finally {
      isSearching.value = false;
    }
  }

  // ====================================================================
  // ĐÃ THÊM: HÀM LOAD MORE RIÊNG CHO TRANSACTION
  // ====================================================================
  Future<void> _loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _txPage++;

    try {
      Map<String, dynamic> queryParams = {
        'limit': _txPageSize,
        'page': _txPage,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      };

      if (filterType.value != TTexts.filterNone) {
        if (filterType.value == TTexts.filterInbound) {
          queryParams['type'] = 'import';
        }
        if (filterType.value == TTexts.filterOutbound) {
          queryParams['type'] = 'export';
        }
      }
      if (filterDateRange.value != null) {
        queryParams['startDate'] =
            DayFormatterUtils.formatApiDate(filterDateRange.value!.start);
        queryParams['endDate'] =
            DayFormatterUtils.formatApiDate(filterDateRange.value!.end);
      }
      if (filterUserId.value.isNotEmpty) {
        queryParams['userId'] = filterUserId.value;
      }

      List<TransactionModel> results =
          await _provider.searchTransactions(queryParams: queryParams);

      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        searchTransactionResults.addAll(results);
        if (results.length < _txPageSize) hasMore.value = false;
      }
    } catch (e) {
      _txPage--;
      handleError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _executeProductSearch(String query) async {
    isSearching.value = true;
    _currentPage = 1;
    hasMore.value = true;
    suggestion.value = '';
    try {
      final response =
          await _provider.searchProductsByKeyword(query, page: _currentPage);
      final List<SearchProductModel> rawItems = response['items'];

      final mappedItems = rawItems
          .where((i) {
            if (isAddingToCart || isStockAdjustment) {
              return i.productPackageId != null &&
                  i.productPackageId!.isNotEmpty;
            }
            return true;
          })
          .map((i) => _mapToDisplayModel(i))
          .toList();

      searchResults.assignAll(mappedItems);

      if (mappedItems.isEmpty && query.trim().isNotEmpty) {
        String fallbackPrefix =
            query.length > 1 ? query.substring(0, query.length - 1) : query;
        final prefixResults =
            await _provider.searchProductsByPrefix(fallbackPrefix);
        if (prefixResults.isNotEmpty) {
          final String firstSuggestion = prefixResults.first['name'] ?? '';
          if (firstSuggestion.isNotEmpty &&
              firstSuggestion.toLowerCase() != query.toLowerCase()) {
            suggestion.value = firstSuggestion;
          }
        }
      }
      if (_currentPage >= (response['totalPages'] as int)) {
        hasMore.value = false;
      }
    } catch (e) {
      handleError(e);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore.value ||
        !hasMore.value ||
        currentSearchQuery.value.trim().isEmpty ||
        isTransactionSearch) {
      return;
    }
    isLoadingMore.value = true;
    _currentPage++;
    try {
      final response = await _provider.searchProductsByKeyword(
          currentSearchQuery.value.trim(),
          page: _currentPage);
      final List<SearchProductModel> rawItems = response['items'];
      final mappedNewItems = rawItems
          .where((i) {
            if (isAddingToCart || isStockAdjustment) {
              return i.productPackageId != null &&
                  i.productPackageId!.isNotEmpty;
            }
            return true;
          })
          .map((i) => _mapToDisplayModel(i))
          .toList();

      if (mappedNewItems.isEmpty &&
          _currentPage >= (response['totalPages'] as int)) {
        hasMore.value = false;
      } else {
        searchResults.addAll(mappedNewItems);
      }
    } catch (e) {
      _currentPage--;
      handleError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void handleItemTap(dynamic item) {
    if (!isTransactionSearch) saveRecentSearch(currentSearchQuery.value);

    if (isTransactionSearch && item is TransactionModel) {
      Get.toNamed(AppRoutes.transactionDetail,
          arguments: {'id': item.transactionId});
      return;
    }

    if (!isTransactionSearch && item is InventoryInsightDisplayModel) {
      final pkg = item.inventory.productPackage;
      final prod = item.product;

      if (returnRouteContext == AppRoutes.outboundTransaction) {
        Get.offNamed(AppRoutes.outboundTransactionItemAdd, arguments: item);
        return;
      } else if (returnRouteContext == AppRoutes.inboundTransaction) {
        Get.offNamed(AppRoutes.inboundTransactionItemAdd, arguments: item);
        return;
      } else if (returnRouteContext == AppRoutes.stockAdjustment) {
        if (pkg != null) {
          final newItem = AdjustmentItemRx(
            id: item.inventory.inventoryId,
            packageId: pkg.productPackageId,
            name: pkg.displayName,
            initialSystemQty: item.inventory.quantity,
            packageInfo: pkg,
          );

          if (Get.isRegistered<StockAdjustmentController>()) {
            final saController = Get.find<StockAdjustmentController>();
            final localMatch = saController.allItems
                .firstWhereOrNull((i) => i.packageId == newItem.packageId);
            if (localMatch != null) {
              Get.offNamed(AppRoutes.stockAdjustmentItem,
                  arguments: localMatch);
            } else {
              saController.allItems.insert(0, newItem);
              saController.filterItems(saController.searchController.text);
              Get.offNamed(AppRoutes.stockAdjustmentItem, arguments: newItem);
            }
          } else {
            Get.offNamed(AppRoutes.stockAdjustmentItem, arguments: newItem);
          }
        }
        return;
      }

      if (pkg != null) {
        Get.toNamed(AppRoutes.inventoryDetail,
            arguments: prod?.productId ?? pkg.productId,
            parameters: {'packageId': pkg.productPackageId});
      } else if (prod != null && prod.productId.isNotEmpty) {
        Get.toNamed(AppRoutes.productCatalogDetail, arguments: prod);
      } else if (prod != null && prod.categoryId.isNotEmpty) {
        final catModel = CategoryModel(
            categoryId: prod.categoryId,
            name: prod.name,
            storeId: '',
            isDefault: false);
        Get.toNamed(AppRoutes.categoryDetail, arguments: catModel);
      }
    }
  }

  void openBarcodeScanner() {
    Get.to(() => TBarcodeScannerLayout(
          onScanned: (code) {
            // Đóng scanner trước khi hiện kết quả
            // Get.back();

            // FIX: Gọi logic xử lý tập trung
            BarcodeActionController.instance.handleScannedBarcode(code);
          },
        ));
  }

  void openScanner() {
    Get.to(
      () => TBarcodeScannerLayout(
        title: TTexts.barCodeScan.tr,
        onScanned: (code) {
          if (isAddingToCart || isStockAdjustment) {
            _processScannedBarcodeForTransaction(code);
          } else {
            BarcodeActionController.instance.handleScannedBarcode(code);
          }
        },
      ),
      transition: Transition.downToUp,
    );
  }

  Future<void> _processScannedBarcodeForTransaction(String barcode) async {
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

        if (isAddingToCart) {
          final displayItem = InventoryInsightDisplayModel(
            product: productModel,
            inventory: inventoryModel,
          );

          if (returnRouteContext == AppRoutes.outboundTransaction) {
            Get.offNamed(AppRoutes.outboundTransactionItemAdd,
                arguments: displayItem);
          } else {
            Get.offNamed(AppRoutes.inboundTransactionItemAdd,
                arguments: displayItem);
          }
        } else if (isStockAdjustment) {
          final newItem = AdjustmentItemRx(
            id: invJsonMap['inventoryId'] ?? '',
            packageId: packageModel.productPackageId,
            name: packageModel.displayName,
            initialSystemQty: invJsonMap['quantity'] ?? 0,
            packageInfo: packageModel,
          );

          if (Get.isRegistered<StockAdjustmentController>()) {
            final saController = Get.find<StockAdjustmentController>();
            final localMatch = saController.allItems.firstWhereOrNull(
                (item) => item.packageId == newItem.packageId);

            if (localMatch != null) {
              Get.offNamed(AppRoutes.stockAdjustmentItem,
                  arguments: localMatch);
            } else {
              saController.allItems.insert(0, newItem);
              saController.filterItems(saController.searchController.text);
              Get.offNamed(AppRoutes.stockAdjustmentItem, arguments: newItem);
            }
          } else {
            Get.offNamed(AppRoutes.stockAdjustmentItem, arguments: newItem);
          }
        }
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

  InventoryInsightDisplayModel _mapToDisplayModel(SearchProductModel s) {
    bool isCategoryOnly = s.productId.isEmpty && s.categoryId.isNotEmpty;
    bool hasPackage =
        s.productPackageId != null && s.productPackageId!.isNotEmpty;

    return InventoryInsightDisplayModel(
      inventory: InventoryModel(
          inventoryId: '',
          quantity: s.quantity,
          reorderThreshold: s.reorderThreshold,
          lastCount: 0,
          updatedAt: DateTime.now(),
          productPackageId: s.productPackageId ?? '',
          activeStatus: 'active',
          productPackage: hasPackage
              ? ProductPackageModel(
                  productPackageId: s.productPackageId!,
                  displayName: s.displayName ?? s.productName,
                  importPrice: s.importPrice ?? 0,
                  sellingPrice: s.sellingPrice ?? 0,
                  unitId: s.unitId ?? 'u-default',
                  productId: s.productId,
                  activeStatus: 'active',
                  barcodeValue: s.barcodeValue,
                  unit: UnitModel(
                      unitId: s.unitId ?? 'u-default',
                      code: s.unitCode ?? '---',
                      name: s.unitName ?? 'Unknown Unit'))
              : null),
      product: ProductModel(
          productId: s.productId,
          name: isCategoryOnly ? s.categoryName : s.productName,
          imageUrl: UrlHelperUtils.normalizeImageUrl(s.imageUrl),
          brand: s.brand,
          categoryId: s.categoryId,
          storeId: '',
          activeStatus: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
    );
  }

  void applySuggestion() {
    if (suggestion.isNotEmpty) {
      final newQuery = suggestion.value;
      textController.text = newQuery;
      textController.selection =
          TextSelection.collapsed(offset: newQuery.length);
      onSearchChanged(newQuery);
    }
  }

  // ====================================================================
  // ĐÃ CẬP NHẬT: PHÂN NHÁNH RÕ RÀNG GIỮA SCROLL CỦA TX VÀ PRODUCT
  // ====================================================================
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (isTransactionSearch) {
        _loadMoreTransactions(); // Nạp thêm Transaction
      } else {
        _loadMore(); // Nạp thêm Product
      }
    }
  }

  String get _currentStorageKey {
    try {
      final storeId = Get.find<StoreService>().currentStoreId.value;
      final userId =
          Get.find<UserService>().currentUser.value?.userId ?? 'guest';
      return storeId.isEmpty
          ? 'RECENT_SEARCHES_USER_${userId}_DEFAULT'
          : 'RECENT_SEARCHES_USER_${userId}_STORE_$storeId';
    } catch (e) {
      return 'RECENT_SEARCHES_DEFAULT';
    }
  }

  void _loadRecentSearches() {
    final List<dynamic>? savedList = storage.read(_currentStorageKey);
    if (savedList != null) {
      recentSearches.assignAll(savedList.cast<String>());
    } else {
      recentSearches.clear();
    }
  }

  void saveRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    final q = query.trim();
    recentSearches.remove(q);
    recentSearches.insert(0, q);
    if (recentSearches.length > 10) recentSearches.removeLast();
    storage.write(_currentStorageKey, recentSearches.toList());
  }

  void clearRecentSearches() {
    recentSearches.clear();
    storage.remove(_currentStorageKey);
  }

  void clearSearch() {
    textController.clear();
    currentSearchQuery.value = '';
    searchResults.clear();
    searchTransactionResults.clear();
    suggestion.value = '';
    if (isTransactionSearch) _executeTransactionSearch();
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
