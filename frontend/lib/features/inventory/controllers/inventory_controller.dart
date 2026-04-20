import 'dart:convert'; // 🔥 Đã thêm import để parse JSON từ Audit Log
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/dashboard_stat_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/inventory_provider.dart';

class InventoryController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();
  final _box = GetStorage();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;
  final RxList<CategoryStatModel> categoryStats = <CategoryStatModel>[].obs;
  final RxList<DistributionModel> topDistribution = <DistributionModel>[].obs;

  final RxList<String> customCategoryOrder = <String>[].obs;
  final RxBool isLoading = true.obs;

  final RxInt totalActiveProducts = 0.obs;
  final RxDouble totalStockValue = 0.0.obs;

  final RxDouble stockHealthPercent = 0.0.obs;
  final RxInt healthyCount = 0.obs;
  final RxInt lowCount = 0.obs;
  final RxInt outCount = 0.obs;

  final RxList<double> inboundFlow = <double>[].obs;
  final RxList<double> outboundFlow = <double>[].obs;
  final RxInt weeklyInbound = 0.obs;
  final RxInt weeklyOutbound = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomOrder();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      if (isRefresh) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final now = DateTime.now();
      final startDateStr = DayFormatterUtils.formatApiDate(
          now.subtract(const Duration(days: 6)));
      final endDateStr =
          DayFormatterUtils.formatApiDate(now.add(const Duration(days: 1)));

      final results = await Future.wait([
        _provider.getCategories(),
        _provider.getProducts(),
        _provider.getInventories(),
        // 🔥 Lấy Audit Logs của đúng bảng Inventory để soi sự thay đổi vật lý
        _provider.getAuditLogs(queryParams: {
          'limit': 100,
          'entityType': 'Inventory',
          'startDate': startDateStr,
          'endDate': endDateStr,
        }),
      ]);

      final fetchedCategories = results[0] as List<CategoryModel>;
      final fetchedProducts = results[1] as List<ProductModel>;
      final fetchedInventories = results[2] as List<InventoryModel>;
      final fetchedAuditLogs = results[3];

      final validCategoryIds =
          fetchedCategories.map((c) => c.categoryId).toSet();
      final validProducts = fetchedProducts
          .where((p) => validCategoryIds.contains(p.categoryId))
          .toList();
      final validProductIds = validProducts.map((p) => p.productId).toSet();

      final activeInventories = fetchedInventories.where((inv) {
        final pkg = inv.productPackage;
        if (pkg == null) return false;
        if ((pkg.activeStatus).toLowerCase() != 'active') return false;
        if ((inv.activeStatus).toLowerCase() == 'inactive') return false;
        if (!validProductIds.contains(pkg.productId)) return false;
        return true;
      }).toList();

      categories.assignAll(fetchedCategories);
      products.assignAll(validProducts);
      inventories.assignAll(activeInventories);

      _calculateDashboardInsights();

      // 🔥 Truyền thẳng AuditLogs vào để tính toán In/Out
      _calculateFlowChart(fetchedAuditLogs);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateFlowChart(List<dynamic> auditLogs) {
    List<double> inFlow = List.filled(7, 0.0);
    List<double> outFlow = List.filled(7, 0.0);

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    int totalIn = 0;
    int totalOut = 0;

    // Quét qua Audit Logs hệt như cách của Home Controller
    for (var log in auditLogs) {
      final entityType = log['entityType']?.toString().toLowerCase() ??
          log['entity_type']?.toString().toLowerCase();

      // Chỉ phân tích log của kho
      if (entityType != 'inventory') continue;

      final dateStr =
          log['performedAt'] ?? log['performed_at'] ?? log['createdAt'];
      if (dateStr == null) continue;

      final logDate = DateTime.parse(dateStr).toLocal();
      final logStartOfDay = DateTime(logDate.year, logDate.month, logDate.day);
      final differenceDays = startOfToday.difference(logStartOfDay).inDays;

      if (differenceDays >= 0 && differenceDays < 7) {
        final index = 6 - differenceDays;

        dynamic oldRaw = log['oldValue'] ?? log['old_value'];
        dynamic newRaw = log['newValue'] ?? log['new_value'];

        Map<String, dynamic> oldVal = {};
        Map<String, dynamic> newVal = {};

        if (oldRaw is String) {
          try {
            oldVal = jsonDecode(oldRaw);
          } catch (_) {}
        } else if (oldRaw is Map) {
          oldVal = Map<String, dynamic>.from(oldRaw);
        }

        if (newRaw is String) {
          try {
            newVal = jsonDecode(newRaw);
          } catch (_) {}
        } else if (newRaw is Map) {
          newVal = Map<String, dynamic>.from(newRaw);
        }

        // Lấy số cũ và mới để tính lượng hàng In/Out tuyệt đối
        int oldQty = int.tryParse(oldVal['quantity']?.toString() ?? '0') ?? 0;
        int newQty = int.tryParse(newVal['quantity']?.toString() ?? '0') ?? 0;
        int diff = newQty - oldQty;

        if (diff > 0) {
          inFlow[index] += diff.toDouble();
          totalIn += diff;
        } else if (diff < 0) {
          outFlow[index] += diff.abs().toDouble();
          totalOut += diff.abs();
        }
      }
    }

    inboundFlow.value = inFlow;
    outboundFlow.value = outFlow;
    weeklyInbound.value = totalIn;
    weeklyOutbound.value = totalOut;
  }

  void _loadCustomOrder() {
    List<dynamic>? saved = _box.read<List<dynamic>>(_customOrderKey);
    if (saved != null) {
      customCategoryOrder.assignAll(saved.cast<String>());
    } else {
      customCategoryOrder.clear();
    }
  }

  void saveCustomOrder(List<String> newOrder) {
    customCategoryOrder.assignAll(newOrder);
    _box.write(_customOrderKey, newOrder);
    _calculateDashboardInsights();
  }

  String get _customOrderKey {
    try {
      final storeService = Get.find<StoreService>();
      final userService = Get.find<UserService>();
      final storeId = storeService.currentStoreId.value;
      final userId = userService.currentUser.value?.userId ?? 'unknown_user';
      if (storeId.isEmpty) return 'custom_category_order_default';
      return 'custom_category_order_${storeId}_$userId';
    } catch (e) {
      return 'custom_category_order_default';
    }
  }

  void _calculateDashboardInsights() {
    double tempValue = 0.0;
    int totalQtyInStock = 0;
    int hCount = 0;
    int lCount = 0;
    int oCount = 0;

    for (var inv in inventories) {
      totalQtyInStock += inv.quantity;

      if (inv.productPackage != null) {
        tempValue += (inv.quantity * inv.productPackage!.importPrice);
      }

      if (inv.quantity == 0) {
        oCount++;
      } else if (inv.quantity <= inv.reorderThreshold) {
        lCount++;
      } else {
        hCount++;
      }
    }

    totalActiveProducts.value = totalQtyInStock;
    totalStockValue.value = tempValue;
    healthyCount.value = hCount;
    lowCount.value = lCount;
    outCount.value = oCount;

    final totalInventories = hCount + lCount + oCount;
    if (totalInventories > 0) {
      stockHealthPercent.value = (hCount / totalInventories) * 100;
    } else {
      stockHealthPercent.value = 0.0;
    }

    List<CategoryStatModel> tempCatStats = [];
    List<DistributionModel> tempDist = [];
    int maxDistValue = 0;

    for (var cat in categories) {
      int pCount = products.where((p) => p.categoryId == cat.categoryId).length;
      tempCatStats.add(CategoryStatModel(name: cat.name, count: pCount));

      int totalQty = 0;
      final catProductIds = products
          .where((p) => p.categoryId == cat.categoryId)
          .map((p) => p.productId)
          .toList();

      for (var inv in inventories) {
        if (inv.productPackage != null &&
            catProductIds.contains(inv.productPackage!.productId)) {
          totalQty += inv.quantity;
        }
      }

      if (totalQty > maxDistValue) maxDistValue = totalQty;
      tempDist.add(DistributionModel(name: cat.name, value: totalQty, max: 1));
    }

    tempCatStats.sort((a, b) {
      final catA = categories.firstWhereOrNull((c) => c.name == a.name);
      final catB = categories.firstWhereOrNull((c) => c.name == b.name);

      final isDefaultA = catA?.isDefault ?? false;
      final isDefaultB = catB?.isDefault ?? false;

      if (isDefaultA && !isDefaultB) return -1;
      if (!isDefaultA && isDefaultB) return 1;

      int indexA = customCategoryOrder.indexOf(a.name);
      int indexB = customCategoryOrder.indexOf(b.name);

      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;

      return a.name.compareTo(b.name);
    });

    categoryStats.value = tempCatStats;

    tempDist.sort((a, b) => b.value.compareTo(a.value));
    topDistribution.value = tempDist.take(5).map((e) {
      return DistributionModel(
          name: e.name,
          value: e.value,
          max: maxDistValue == 0 ? 1 : maxDistValue);
    }).toList();
  }

  void onCategorySelected(String categoryName) {
    final match = categories.where((c) => c.name == categoryName);
    if (match.isNotEmpty) {
      Get.toNamed(AppRoutes.categoryDetail, arguments: match.first);
    } else {
      TSnackbarsWidget.error(
          title: TTexts.errorUnknownTitle.tr,
          message: TTexts.errorUnknownMessage.tr);
    }
  }

  void goToAddCategory() {
    Get.toNamed(AppRoutes.categoryForm)?.then((_) {
      fetchDashboardData(isRefresh: true);
    });
  }
}
