import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:get/get.dart';

class HiddenCategoryController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  final RxList<CategoryModel> hiddenCategories = <CategoryModel>[].obs;
  final RxList<String> selectedIds = <String>[].obs;

  final RxBool isSelectMode = false.obs; // Trạng thái chọn nhiều
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHiddenCategories();
  }

  Future<void> fetchHiddenCategories() async {
    try {
      isLoading.value = true;
      final data = await _provider.getHiddenCategories();
      hiddenCategories.assignAll(data);
      selectedIds.clear();
      isSelectMode.value = false;
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
    if (!isSelectMode.value) selectedIds.clear();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) isSelectMode.value = false;
    } else {
      selectedIds.add(id);
      isSelectMode.value = true;
    }
  }

  void handleLongPress(String id) {
    if (!isSelectMode.value) {
      isSelectMode.value = true;
      toggleSelection(id);
    }
  }

  void restoreSingle(CategoryModel category) {
    confirmRestoreCategory(category);
  }

  void confirmRestoreCategory(CategoryModel category) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmRestoreTitle.tr,
        description: "${TTexts.confirmRestoreDesc.tr}\n\n• ${category.name}",
        icon: const Text('🔄', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.restore.tr,
        onPrimaryPressed: () {
          Get.back(); // Đóng popup
          _executeRestore(category);
        },
        secondaryButtonText: TTexts.cancel.tr,
      ),
    );
  }

  Future<void> _executeRestore(CategoryModel category) async {
    try {
      // 1. Gỡ ngay khỏi UI để tạo cảm giác mượt mà
      hiddenCategories.removeWhere((c) => c.categoryId == category.categoryId);
      selectedIds.remove(category.categoryId);
      if (selectedIds.isEmpty) isSelectMode.value = false;

      // 2. Gọi API ngầm
      await _provider.unhideDefaultCategory(category.categoryId);

      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.restoreSuccess.tr,
      );

      // Refresh lại danh sách Catalog ở màn hình trước
      if (Get.isRegistered<ProductCatalogController>()) {
        Get.find<ProductCatalogController>().refreshCategories();
      }
    } catch (e) {
      // Nếu API lỗi, tải lại danh sách để khôi phục data
      fetchHiddenCategories();
      handleError(e);
    }
  }

  void confirmBatchRestore() {
    if (selectedIds.isEmpty) return;

    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmBatchRestoreTitle.tr,
        description:
            "${TTexts.confirmBatchRestoreDesc.tr} (${selectedIds.length} ${TTexts.categoriesUnit.tr})",
        icon: const Text('🔄', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.restore.tr,
        onPrimaryPressed: () {
          Get.back();
          _executeBatchRestore();
        },
        secondaryButtonText: TTexts.cancel.tr,
      ),
    );
  }

  Future<void> _executeBatchRestore() async {
    try {
      final List<String> idsToRestore = List.from(selectedIds);

      // Xóa hàng loạt trên UI ngay lập tức
      hiddenCategories.removeWhere((c) => idsToRestore.contains(c.categoryId));
      selectedIds.clear();
      isSelectMode.value = false;

      // Xử lý API ngầm
      for (String id in idsToRestore) {
        await _provider.unhideDefaultCategory(id);
      }

      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.restoreSuccess.tr,
      );

      if (Get.isRegistered<ProductCatalogController>()) {
        Get.find<ProductCatalogController>().refreshCategories();
      }
    } catch (e) {
      // Nếu lỗi thì hoàn tác
      fetchHiddenCategories();
      handleError(e);
    }
  }
}
