import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/home/providers/home_provider.dart';
import 'package:get/get.dart';

class LowStockController extends GetxController with TErrorHandler {
  final HomeProvider _provider = HomeProvider();

  final RxBool isLoading = true.obs;
  final RxBool isLoadMore = false.obs;
  final RxList<InventoryModel> lowStockItems = <InventoryModel>[].obs;

  final RxString activeFilter = ''.obs;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    fetchLowStock(isRefresh: true);
  }

  Future<void> fetchLowStock({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      lowStockItems.clear();
      isLoading.value = true;
    } else if (_currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadMore.value = true;
    }

    try {
      final items = await _provider.getLowStockInventories(
        page: _currentPage,
        limit: _limit,
      );

      if (items.isEmpty || items.length < _limit) {
        _hasMoreData = false;
      }

      if (isRefresh || _currentPage == 1) {
        lowStockItems.assignAll(items);
      } else {
        lowStockItems.addAll(items);
      }
      _currentPage++;
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  void toggleFilter(String filter) {
    if (activeFilter.value == filter) {
      activeFilter.value = ''; // Nếu bấm lại cái đang chọn thì bỏ lọc
    } else {
      activeFilter.value = filter; // Chọn bộ lọc mới
    }
  }

  void onLoadMore() {
    if (_hasMoreData && !isLoadMore.value && !isLoading.value) {
      fetchLowStock();
    }
  }
}
