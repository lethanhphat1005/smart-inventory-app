import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';

import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';

class ProductCatalogDetailController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  late final ProductModel product;

  // CÁC BIẾN OBSERVE ĐỂ CẬP NHẬT UI TỨC THÌ
  final RxString rxName = ''.obs;
  final RxString rxBrand = ''.obs;
  final RxString rxImageUrl = ''.obs;

  final RxBool isLoadingPackages = true.obs;
  final RxList<ProductPackageModel> packages = <ProductPackageModel>[].obs;

  bool _isDeleteDialogShowing = false;
  bool canManageProduct = false;

  @override
  void onInit() {
    super.onInit();
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      // ĐÃ FIX PHÂN QUYỀN: Cấp quyền cho cả owner, admin và manager
      canManageProduct =
          (role == 'owner' || role == 'admin' || role == 'manager');
    } catch (e) {
      canManageProduct = false;
    }

    if (Get.arguments is ProductModel) {
      product = Get.arguments as ProductModel;
      rxName.value = product.name;
      rxBrand.value = product.brand ?? '';
      rxImageUrl.value = product.imageUrl ?? '';
      fetchPackages();
    } else {
      handleError(TTexts.productDataMissing.tr);
      Get.back();
    }
  }

  Future<void> fetchPackages({bool isRefresh = false}) async {
    try {
      isLoadingPackages.value = true;

      if (isRefresh) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final results = await Future.wait([
        _provider.getPackagesByProduct(product.productId),
        _provider.getInventories(),
      ]);

      final fetchedPackages = results[0] as List<ProductPackageModel>;
      final allInventories = results[1] as List<InventoryModel>;

      final deadInventoryPackageIds = allInventories
          .where((inv) => (inv.activeStatus).toLowerCase() == 'inactive')
          .map((inv) => inv.productPackageId)
          .toSet();

      final validPackages = fetchedPackages.where((p) {
        final isPackageActive = (p.activeStatus).toLowerCase() == 'active';
        final isInventoryDead =
            deadInventoryPackageIds.contains(p.productPackageId);

        return isPackageActive && !isInventoryDead;
      }).toList();

      packages.assignAll(validPackages);
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingPackages.value = false;
    }
  }

  Future<void> refreshProductData() async {
    try {
      final data = await _provider.getProductDetail(product.productId);
      final updatedProduct = ProductModel.fromJson(data);

      rxName.value = updatedProduct.name;
      rxBrand.value = updatedProduct.brand ?? '';

      if (updatedProduct.imageUrl != null &&
          updatedProduct.imageUrl!.isNotEmpty) {
        final thoiGian = DateTime.now().millisecondsSinceEpoch;
        final linkGoc = updatedProduct.imageUrl!;

        if (linkGoc.contains('?')) {
          rxImageUrl.value = "$linkGoc&v=$thoiGian";
        } else {
          rxImageUrl.value = "$linkGoc?v=$thoiGian";
        }
      } else {
        rxImageUrl.value = '';
      }

      if (Get.isRegistered<ProductCatalogController>()) {
        Get.find<ProductCatalogController>().fetchCategories();
      }
    } catch (e) {
      debugPrint("Lỗi khi làm mới: $e");
    }
  }

  void updateLocalInfo({String? name, String? brand, String? imageUrl}) {
    if (name != null) rxName.value = name;
    if (brand != null) rxBrand.value = brand;
    if (imageUrl != null) rxImageUrl.value = imageUrl;
  }

  void updateLocalPackage(ProductPackageModel updatedPkg) {
    final index = packages
        .indexWhere((p) => p.productPackageId == updatedPkg.productPackageId);
    if (index != -1) {
      packages[index] = updatedPkg;
      packages.refresh();
    } else {
      packages.insert(0, updatedPkg);
      packages.refresh();
    }
  }

  // ==========================================
  // ACTIONS CHO PRODUCT GỐC
  // ==========================================
  void editProductImage() {
    Get.toNamed(AppRoutes.productForm, arguments: {
      'mode': 'image',
      'product': product,
      'freshImageUrl': rxImageUrl.value,
    })?.then((_) {
      refreshProductData();
    });
  }

  void editProductInfo() {
    Get.toNamed(AppRoutes.productForm, arguments: {
      'mode': 'info',
      'product': product,
      'freshName': rxName.value,
      'freshBrand': rxBrand.value,
    })?.then((_) {
      refreshProductData();
    });
  }

  void deleteProduct() async {
    if (packages.isNotEmpty) {
      // Kiểm tra tồn kho của packages bên trong
      try {
        FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);
        final allInvs = await _provider.getInventories();
        final packageIds = packages.map((p) => p.productPackageId).toSet();

        final remainingStockInvs = allInvs
            .where((inv) =>
                packageIds.contains(inv.productPackageId) && inv.quantity > 0)
            .toList();

        FullScreenLoaderUtils.stopLoading();

        if (remainingStockInvs.isNotEmpty) {
          // Nếu còn tồn kho thì chuyển sang outbound
          Get.dialog(TCustomDialogWidget(
              title: TTexts.inventoryNotEmptyTitle.tr,
              description: TTexts.productHasRemainingStock.tr,
              icon: const Text('📦', style: TextStyle(fontSize: 40)),
              primaryButtonText: TTexts.clearAllStock.tr,
              secondaryButtonText: TTexts.cancel.tr,
              onSecondaryPressed: () => Get.back(),
              onPrimaryPressed: () {
                Get.back();
                // Gom toàn bộ Data
                final itemsToAdd = remainingStockInvs.map((inv) {
                  final pkg = packages.firstWhere(
                      (p) => p.productPackageId == inv.productPackageId);
                  return {
                    'package': pkg,
                    'inventory': inv,
                    'quantity': inv.quantity,
                  };
                }).toList();

                // Đẩy sang Outbound
                Get.toNamed(AppRoutes.outboundTransaction,
                    arguments: {'autoAddItems': itemsToAdd});
              }));
          return;
        } else {
          // Nếu packages trống thì xóa package trước rồi mới đi xóa product
          TSnackbarsWidget.error(
              title: TTexts.errorTitle.tr,
              message: TTexts.productNotEmptyError.tr);
          return;
        }
      } catch (e) {
        FullScreenLoaderUtils.stopLoading();
        handleError(e);
        return;
      }
    }

    // Logic xóa Product bình thường (như cũ)
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.deleteProduct.tr,
        description: TTexts.confirmMoveProductToTrash.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () async {
          Get.back();
          try {
            FullScreenLoaderUtils.openLoadingDialog(TTexts.deletingProduct.tr);
            await _provider.deleteProduct(product.productId);
            FullScreenLoaderUtils.stopLoading();

            if (Get.isRegistered<CategoryDetailController>()) {
              Get.find<CategoryDetailController>()
                  .fetchProducts(isRefresh: true);
            }
            if (Get.isRegistered<InventoryController>()) {
              Get.find<InventoryController>()
                  .fetchDashboardData(isRefresh: true);
            }
            if (Get.isRegistered<InventoryInsightController>()) {
              Get.find<InventoryInsightController>().refreshData();
            }

            Get.back();
            Future.delayed(const Duration(milliseconds: 300), () {
              TSnackbarsWidget.success(
                  title: TTexts.successTitle.tr,
                  message: TTexts.productDeletedSuccess.tr);
            });
          } on DioException catch (e) {
            FullScreenLoaderUtils.stopLoading();
            TSnackbarsWidget.error(
                title: TTexts.errorTitle.tr,
                message: e.response?.data?['message'] ??
                    TTexts.errorUnknownMessage.tr);
          } catch (e) {
            FullScreenLoaderUtils.stopLoading();
            handleError(e);
          }
        },
      ),
    );
  }

  // ==========================================
  // ACTIONS CHO PACKAGES
  // ==========================================
  void addNewPackage() {
    Get.toNamed(AppRoutes.productForm,
        arguments: {'product': product, 'mode': 'add_package'});
  }

  void editPackage(ProductPackageModel package) {
    Get.toNamed(AppRoutes.productForm, arguments: {
      'product': product,
      'package': package,
      'mode': 'edit_package'
    });
  }

  // ==========================================
  // XÓA 1 PACKAGE CỤ THỂ
  // ==========================================
  void deletePackage(ProductPackageModel package) async {
    if (_isDeleteDialogShowing) return;

    if (!packages.any((p) => p.productPackageId == package.productPackageId)) {
      return;
    }

    _isDeleteDialogShowing = true;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final inv = await _provider.getInventoryDetail(package.productPackageId);
      final int currentQuantity = inv.quantity;

      FullScreenLoaderUtils.stopLoading();

      if (currentQuantity > 0) {
        await Get.dialog(
          TCustomDialogWidget(
            title: TTexts.inventoryNotEmptyTitle.tr,
            description:
                '${TTexts.inventoryNotEmptyMessage.tr}\n\n(${TTexts.currentStockWithCount.trParams({
                  'count': currentQuantity.toString()
                })})',
            icon: const Text('📦', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.clearStock.tr, // Text mới
            secondaryButtonText: TTexts.cancel.tr,
            onSecondaryPressed: () => Get.back(),
            onPrimaryPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.outboundTransaction, arguments: {
                'autoAddItems': [
                  {
                    'package': package,
                    'inventory': inv,
                    'quantity': currentQuantity,
                  }
                ]
              });
            },
          ),
          barrierDismissible: false,
        );
        return;
      }

      // Logic xóa Package bình thường
      final bool? shouldDelete = await Get.dialog<bool>(
        TCustomDialogWidget(
          title: TTexts.deletePackage.tr,
          description:
              '${TTexts.confirmDeletePackageMessage.tr}\n(${package.displayName})',
          icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.delete.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onSecondaryPressed: () => Get.back(result: false),
          onPrimaryPressed: () => Get.back(result: true),
        ),
        barrierDismissible: false,
      );

      if (shouldDelete == true) {
        await _performDeletePackage(package.productPackageId);
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isDeleteDialogShowing = false;
    }
  }

  Future<void> _performDeletePackage(String packageId) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.deletingPackage.tr);
      await _provider.deleteProductPackage(packageId);
      FullScreenLoaderUtils.stopLoading();

      packages.removeWhere((p) => p.productPackageId == packageId);
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.packageDeletedSuccess.tr);

      if (Get.isRegistered<InventoryController>()) {
        Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
      }
      if (Get.isRegistered<InventoryInsightController>()) {
        Get.find<InventoryInsightController>().refreshData();
      }
    } on DioException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message:
              e.response?.data?['message'] ?? TTexts.errorUnknownMessage.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }
}
