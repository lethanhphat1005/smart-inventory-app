import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';

// ĐÃ THÊM: Import trực tiếp Provider để tự gọi API
import 'package:frontend/features/inventory/providers/inventory_provider.dart';

class ProductCatalogController extends GetxController with TErrorHandler {
  // 1. TỰ QUẢN LÝ PROVIDER VÀ STATE NỘI BỘ
  final InventoryProvider _provider = InventoryProvider();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool _isLoading = true.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  bool canManageCategory = false;

  @override
  void onInit() {
    super.onInit();

    // Khởi tạo quyền quản lý
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      // Chỉ Manager, Owner, Admin mới được thêm/sửa danh mục
      canManageCategory =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageCategory = false;
    }

    debounce(searchQuery, (_) => update(),
        time: const Duration(milliseconds: 300));

    // 2. GỌI API LẤY DỮ LIỆU NGAY KHI VÀO TRANG
    fetchCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ==========================================
  // LOGIC LẤY DỮ LIỆU TỪ BACKEND
  // ==========================================
  Future<void> fetchCategories({bool isRefresh = false}) async {
    try {
      // Chỉ hiện Shimmer toàn trang nếu không phải là hành động vuốt refresh
      if (!isRefresh) {
        _isLoading.value = true;
      }

      // Gọi API thực tế
      final fetchedData = await _provider.getCategories();

      // Gán data mới vào biến cục bộ
      categories.assignAll(fetchedData);
    } catch (e) {
      handleError(e);
    } finally {
      if (!isRefresh) {
        _isLoading.value = false;
      }
    }
  }

  // Hàm dành cho Refresh Indicator ở màn hình View
  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  // ==========================================
  // GETTERS & LOGIC NHÓM A-Z
  // ==========================================

  // Trả về loading state cho View
  bool get isLoading => _isLoading.value;

  // Lấy tổng số danh mục thực tế từ list cục bộ
  int get totalCategories => categories.length;

  Map<String, List<CategoryModel>> get groupedCategories {
    final query = searchQuery.value.trim().toLowerCase();

    // Tạo bản sao từ danh sách cục bộ để tránh lỗi mutate
    List<CategoryModel> list = categories.toList();

    // 1. Lọc theo search query (nếu có)
    if (query.isNotEmpty) {
      list = list.where((cat) {
        final name = cat.name.toLowerCase();
        final desc = cat.description?.toLowerCase() ?? '';
        return name.contains(query) || desc.contains(query);
      }).toList();
    }

    // 2. Sắp xếp toàn bộ từ A-Z không phân biệt default
    list.sort(
        (a, b) => (a.name).toLowerCase().compareTo((b.name).toLowerCase()));

    Map<String, List<CategoryModel>> grouped = {};

    // 3. Nhóm theo chữ cái đầu
    for (var cat in list) {
      final String firstLetter =
          (cat.name.isNotEmpty) ? cat.name[0].toUpperCase() : '#';

      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(cat);
    }

    return grouped;
  }

  // ==========================================
  // ACTIONS
  // ==========================================
  void addNewCategory() {
    try {
      Get.toNamed(AppRoutes.categoryForm)?.then((_) {
        fetchCategories();
      });
    } catch (e) {
      handleError(e);
    }
  }

  void goToCategoryDetail(CategoryModel category) {
    try {
      Get.toNamed(
        AppRoutes.categoryDetail,
        arguments: category,
      )?.then((_) {
        fetchCategories();
      });
    } catch (e) {
      handleError(e);
    }
  }

  void goToAllProducts() {
    try {
      Get.toNamed(AppRoutes.allProducts);
    } catch (e) {
      handleError(e);
    }
  }
}
