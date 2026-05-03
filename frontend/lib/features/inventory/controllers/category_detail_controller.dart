import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class CategoryDetailController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  final Rx<CategoryModel> rxCategory = CategoryModel(
    categoryId: '',
    name: 'Loading...',
    storeId: '',
    isDefault: false,
  ).obs;

  final RxBool isLoading = true.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  bool canManageProduct = false;

  @override
  void onInit() {
    super.onInit();

    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageProduct =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageProduct = false;
    }

    // 2. NHẬN DATA CHUẨN
    if (Get.arguments != null && Get.arguments is CategoryModel) {
      // Gán data thật đè lên cái data mặc định ở trên
      rxCategory.value = Get.arguments as CategoryModel;

      // 3. DIỆT LỖI OVERLAY: Bắt buộc đợi giao diện vẽ xong mới gọi API (vì API có kèm Loading Dialog)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchProducts();
      });
    } else {
      // Nếu không có data truyền sang -> Đẩy người dùng về trang trước
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        handleError("Dữ liệu danh mục không hợp lệ!");
      });
    }
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    try {
      isLoading.value = true;

      final fetchedData =
          await _provider.getProductsByCategory(rxCategory.value.categoryId);
      products.assignAll(fetchedData);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- ACTIONS CHO SẢN PHẨM ---
  void addNewProduct() {
    try {
      Get.toNamed(
        AppRoutes.productForm,
        arguments: rxCategory.value,
      );
    } catch (e) {
      handleError(e);
    }
  }

  // ==========================================
  // ẨN DEFAULT CATEGORY
  // ==========================================
  Future<void> hideCategory() async {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.hideCategoryTitle.tr,
        description: TTexts.hideCategoryConfirm.tr,
        icon: const Text('👁️‍🗨️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.hide.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () async {
          Get.back();
          try {
            FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);

            // Gọi API ẩn category từ provider
            await _provider.hideDefaultCategory(rxCategory.value.categoryId);

            FullScreenLoaderUtils.stopLoading();

            // Refresh lại danh sách Catalog
            if (Get.isRegistered<ProductCatalogController>()) {
              Get.find<ProductCatalogController>().fetchCategories();
            }

            if (Get.isRegistered<InventoryController>()) {
              Get.find<InventoryController>().fetchDashboardData();
            }

            // Văng người dùng về trang Product Catalog
            Get.back();

            TSnackbarsWidget.success(
                title: TTexts.successTitle.tr,
                message: TTexts.hideCategorySuccessMessage.tr);
          } catch (e) {
            FullScreenLoaderUtils.stopLoading();
            handleError(e);
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  void goToProductDetail(ProductModel product) {
    try {
      Get.toNamed(AppRoutes.productCatalogDetail, arguments: product)
          ?.then((_) {
        // Hàm này sẽ tự động chạy ngầm NGAY KHI màn hình Catalog đóng lại, cap nhat data ngay lap tuc o 2 trang duoi
        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
        }
        if (Get.isRegistered<InventoryInsightController>()) {
          Get.find<InventoryInsightController>().refreshData();
        }
      });
    } catch (e) {
      handleError(e);
    }
  }

  // ==========================================
  // ACTIONS CHO CATEGORY
  // ==========================================
  void editCategory() {
    try {
      // Chuyển sang form dùng chung và truyền category sang để bật Edit Mode
      Get.toNamed(AppRoutes.categoryForm, arguments: rxCategory.value)
          ?.then((_) {
        // Khi đóng form Edit quay lại, tự chọc gọi lại API để load lại Tên và Mô tả mới!
        // Lưu ý: Vì API ko trả thẳng 1 category mà trả về danh sách, ta cần chọc vào Catalog để lấy danh sách mới rồi tìm lại thằng hiện tại
        if (Get.isRegistered<ProductCatalogController>()) {
          final catalogCtrl = Get.find<ProductCatalogController>();
          catalogCtrl.fetchCategories().then((_) {
            // Sau khi load xong danh sách tổng, bốc lấy cục data mới đắp vào rxCategory hiện tại
            final updatedCat = catalogCtrl.categories.firstWhereOrNull(
                (c) => c.categoryId == rxCategory.value.categoryId);
            if (updatedCat != null) {
              rxCategory.value = updatedCat;
            }
          });
        }
      });
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteCategory() async {
    // SỬ DỤNG TCustomDialogWidget ĐỂ HIỆN XÁC NHẬN
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.deleteCategory.tr,
        description: TTexts.deleteCategoryConfirm.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () async {
          Get.back();
          try {
            FullScreenLoaderUtils.openLoadingDialog('Deleting...');

            await _provider.deleteCategory(rxCategory.value.categoryId);

            FullScreenLoaderUtils.stopLoading();

            // Refresh lại danh sách Catalog
            if (Get.isRegistered<ProductCatalogController>()) {
              Get.find<ProductCatalogController>().fetchCategories();
            }

            // Xóa xong thì đá văng người dùng về trang Product Catalog
            Get.back();

            TSnackbarsWidget.success(
              title: TTexts.successTitle.tr,
              message: TTexts.deleteCategorySuccessMessage.tr,
            );
          } on DioException catch (e) {
            FullScreenLoaderUtils.stopLoading();
            final statusCode = e.response?.statusCode;

            if (statusCode == 409) {
              // HIỆN POPUP XÁC NHẬN LẦN 2
              Get.dialog(
                TCustomDialogWidget(
                  title: TTexts.deleteCategoryTitle.tr,
                  description: TTexts.deleteCategoryWarning.tr,
                  icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
                  primaryButtonText: TTexts.deleteCategoryConfirmBtn.tr,
                  secondaryButtonText: TTexts.cancel.tr,
                  onSecondaryPressed: () => Get.back(),
                  onPrimaryPressed: () async {
                    Get.back(); // Đóng dialog warning
                    try {
                      FullScreenLoaderUtils.openLoadingDialog(
                          TTexts.loading.tr);

                      // Gọi API xóa với cờ canReassignToUncategorized = true
                      await _provider.deleteCategory(
                          rxCategory.value.categoryId,
                          canReassignToUncategorized: true);

                      FullScreenLoaderUtils.stopLoading();

                      // Refresh danh sách ở trang ngoài
                      if (Get.isRegistered<ProductCatalogController>()) {
                        Get.find<ProductCatalogController>().fetchCategories();
                      }

                      Get.back(); // Thoát trang chi tiết về Catalog
                      TSnackbarsWidget.success(
                        title: TTexts.successTitle.tr,
                        message: TTexts.deleteCategorySuccess.tr,
                      );
                    } catch (err) {
                      FullScreenLoaderUtils.stopLoading();
                      handleError(err);
                    }
                  },
                ),
              );
            } else {
              handleError(e);
            }
          } catch (e) {
            FullScreenLoaderUtils.stopLoading();
            handleError(e);
          }
        },
      ),
      barrierDismissible: true, // Cho phép bấm ra ngoài để đóng
    );
  }
}
