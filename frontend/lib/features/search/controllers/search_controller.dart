import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/unit_model.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/features/search/widgets/search_filter_bottom_sheet_widget.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/features/search/models/search_product_model.dart';
import 'package:frontend/features/search/providers/search_provider.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

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
  bool get isTransactionSearch => target == SearchTarget.transactions;

  bool get isAddingToCart =>
      Get.isRegistered<OutboundTransactionController>() ||
      Get.isRegistered<InboundTransactionController>();

  final RxString filterType = TTexts.filterAll.obs;

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

  int _currentPage = 1;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    target = args['target'] as SearchTarget? ?? SearchTarget.inventory;
    dynamicHint = args['hint'] ??
        (isTransactionSearch
            ? TTexts.searchTransactionHint.tr
            : TTexts.searchEverything.tr);

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

      // Gọi API thật, trả về List<StoreMemberModel>
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
        // Fallback nếu cửa hàng chưa có ai, tự hiện chính mình
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
    _executeTransactionSearch(currentSearchQuery.value);
  }

  void removeFilter(String filterCategory) {
    if (filterCategory == 'type') filterType.value = TTexts.filterAll;
    if (filterCategory == 'date') filterDateRange.value = null;
    if (filterCategory == 'user') {
      filterUserId.value = '';
      filterUserName.value = '';
    }
    _executeTransactionSearch(currentSearchQuery.value);
  }

  void onSearchChanged(String query) {
    currentSearchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (isTransactionSearch) {
      if (query.trim().isNotEmpty) {
        _debounce = Timer(const Duration(milliseconds: 500),
            () => _executeTransactionSearch(query.trim()));
      } else {
        _executeTransactionSearch('');
      }
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

  Future<void> _executeTransactionSearch(String query) async {
    final q = query.trim();

    // ===============================================
    // ĐÃ FIX: CHỐT CHẶN TRÁNH TRÀN DATA
    // Kiểm tra xem có đang ở trạng thái "Trắng bóc" không
    // ===============================================
    final bool hasNoFilters = filterType.value == TTexts.filterAll &&
        filterDateRange.value == null &&
        filterUserId.value.isEmpty;

    // Nếu không gõ gì và cũng không có bộ lọc nào -> Xóa list và thoát luôn
    if (q.isEmpty && hasNoFilters) {
      searchTransactionResults.clear();
      return;
    }

    isSearching.value = true;
    hasMore.value = false;

    try {
      // 1. CHUẨN BỊ THAM SỐ LỌC CHO API BACKEND
      Map<String, dynamic> queryParams = {
        'limit': 100,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      };

      // Map Type Filter
      if (filterType.value != TTexts.filterAll) {
        if (filterType.value == TTexts.filterInbound) {
          queryParams['type'] = 'import';
        }
        if (filterType.value == TTexts.filterOutbound) {
          queryParams['type'] = 'export';
        }
      }

      // Map Date Range Filter
      if (filterDateRange.value != null) {
        queryParams['startDate'] =
            DayFormatterUtils.formatApiDate(filterDateRange.value!.start);
        queryParams['endDate'] =
            DayFormatterUtils.formatApiDate(filterDateRange.value!.end);
      }

      // 2. GỌI API TỪ SEARCH PROVIDER
      List<TransactionModel> results =
          await _provider.searchTransactions(queryParams: queryParams);

      // 3. LỌC Ở LOCAL (User ID & Text)
      if (filterUserId.value.isNotEmpty) {
        results =
            results.where((tx) => tx.userId == filterUserId.value).toList();
      }

      if (q.isNotEmpty) {
        results = results.where((tx) {
          final matchId =
              (tx.transactionId ?? '').toLowerCase().contains(q.toLowerCase());
          final matchNote =
              (tx.note ?? '').toLowerCase().contains(q.toLowerCase());
          return matchId || matchNote;
        }).toList();
      }

      searchTransactionResults.assignAll(results);
    } catch (e) {
      handleError(e);
    } finally {
      isSearching.value = false;
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

      // Nếu đang thêm vào giỏ hàng: CHỈ TRẢ VỀ PACKAGES.
      // Nếu đang search global: TRẢ VỀ TẤT CẢ (Categories, Products, Packages).
      final mappedItems = rawItems
          .where((i) {
            if (isAddingToCart) {
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
            if (isAddingToCart) {
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

  // Điều hướng:
  // Transaction: Chỉ cho search Product-package
  // Report: Chỉ cho search Transaction
  // Inventory: Cho search Category, Product-package và Product
  void handleItemTap(dynamic item) {
    if (!isTransactionSearch) saveRecentSearch(currentSearchQuery.value);

    // 1. Dành cho kết quả Giao dịch
    if (isTransactionSearch && item is TransactionModel) {
      Get.toNamed(AppRoutes.transactionDetail,
          arguments: {'id': item.transactionId});
      return;
    }

    // 2. Dành cho kết quả Hàng hóa
    if (!isTransactionSearch && item is InventoryInsightDisplayModel) {
      final pkg = item.inventory.productPackage;
      final prod = item.product;

      // TRƯỜNG HỢP A: ĐANG TẠO GIAO DỊCH (Chỉ click được vào Package)
      if (isAddingToCart) {
        if (pkg != null) {
          if (Get.isRegistered<OutboundTransactionController>()) {
            Get.toNamed(AppRoutes.outboundTransactionItemAdd, arguments: item);
          } else {
            Get.toNamed(AppRoutes.inboundTransactionItemAdd, arguments: item);
          }
        }
        return;
      }

      // TRƯỜNG HỢP B: SEARCH CHUNG BÌNH THƯỜNG
      if (pkg != null) {
        // Có Package -> Tới trang Inventory Detail
        Get.toNamed(AppRoutes.inventoryDetail,
            arguments: prod?.productId ?? pkg.productId,
            parameters: {'packageId': pkg.productPackageId});
      } else if (prod != null && prod.productId.isNotEmpty) {
        // Có Product nhưng chưa có Package -> Tới Product Catalog
        Get.toNamed(AppRoutes.productCatalogDetail, arguments: prod);
      } else if (prod != null && prod.categoryId.isNotEmpty) {
        // Chỉ có Category ID -> Tới Category Detail
        final catModel = CategoryModel(
            categoryId: prod.categoryId,
            name: prod.name, // Tên danh mục đã gán tạm vào prod.name ở hàm map
            storeId: '',
            isDefault: false);
        Get.toNamed(AppRoutes.categoryDetail, arguments: catModel);
      }
    }
  }

  // 🟢 SMART MAPPING: Map linh hoạt dữ liệu null
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

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      _loadMore();
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
    if (isTransactionSearch) _executeTransactionSearch('');
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
