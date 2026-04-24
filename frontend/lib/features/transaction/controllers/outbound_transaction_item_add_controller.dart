import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_barcode_model.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_barcode_list_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class OutboundTransactionItemAddController extends GetxController
    with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();

  late final InventoryInsightDisplayModel initialItem;
  final Rxn<InventoryModel> freshInventoryData = Rxn<InventoryModel>();
  final RxBool isLoadingFreshData = true.obs;

  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();

  final RxInt itemQuantity = 1.obs;
  final RxDouble totalPrice = 0.0.obs;

  final RxString fetchedCategoryName = ''.obs;
  final RxString fetchedImageUrl = ''.obs;
  final RxString fetchedBrandName = ''.obs;
  final RxString fetchedBarcode = ''.obs;

  final RxList<ProductPackageBarcodeModel> fetchedBarcodesList =
      <ProductPackageBarcodeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null &&
        Get.arguments is InventoryInsightDisplayModel) {
      initialItem = Get.arguments as InventoryInsightDisplayModel;

      fetchedCategoryName.value = TTexts.uncategorized.tr;
      fetchedBrandName.value = initialItem.product?.brand ?? TTexts.noBrand.tr;
      fetchedImageUrl.value = _validateUrl(initialItem.product?.imageUrl);

      _fetchFreshData();
    } else {
      Get.back();
    }

    quantityController.addListener(_updateTotalPriceAndQuantity);
    priceController.addListener(_updateTotalPriceAndQuantity);
  }

  String _validateUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final normalized = UrlHelperUtils.normalizeImageUrl(url) ?? '';
    if (!normalized.startsWith('http')) return '';
    return normalized;
  }

  void _updateTotalPriceAndQuantity() {
    int qty = int.tryParse(quantityController.text) ?? 1;

    // RÀNG BUỘC: Không cho phép nhập số lượng > Tồn kho
    if (qty > currentStock) {
      qty = currentStock;
      // Dùng postFrameCallback để tránh xung đột luồng khi đang gõ phím
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quantityController.text = qty.toString();
      });
    }

    itemQuantity.value = qty;
    final price = double.tryParse(priceController.text) ?? 0.0;
    totalPrice.value = qty * price;
  }

  Future<void> _fetchFreshData() async {
    try {
      isLoadingFreshData.value = true;
      final packageId = initialItem.inventory.productPackageId;

      String? targetProductId = initialItem.product?.productId;
      if (targetProductId == null || targetProductId.isEmpty) {
        targetProductId = initialItem.inventory.productPackage?.productId;
      }

      if (packageId.isNotEmpty) {
        final invData =
            await _provider.getInventoryDetailByPackageId(packageId);
        freshInventoryData.value = InventoryModel.fromJson(invData);
        priceController.text =
            (freshInventoryData.value!.productPackage?.sellingPrice ?? 0.0)
                .toStringAsFixed(2);

        if (targetProductId == null || targetProductId.isEmpty) {
          targetProductId = freshInventoryData.value?.productPackage?.productId;
        }

        try {
          final packageFullData =
              await _provider.getProductPackageById(packageId);
          if (targetProductId == null || targetProductId.isEmpty) {
            targetProductId = packageFullData['productId'];
          }
          if (packageFullData['productPackageBarcodes'] != null) {
            final barcodes = (packageFullData['productPackageBarcodes'] as List)
                .map((e) => ProductPackageBarcodeModel.fromJson(e))
                .toList();
            fetchedBarcodesList.assignAll(barcodes);
            if (barcodes.isNotEmpty) {
              fetchedBarcode.value = barcodes.first.barcode;
            } else {
              fetchedBarcode.value = packageFullData['barcodeValue'] ?? '';
            }
          } else {
            fetchedBarcode.value = packageFullData['barcodeValue'] ?? '';
          }
        } catch (e) {
          debugPrint('Lỗi fetch package: $e');
        }
      }

      if (targetProductId != null && targetProductId.isNotEmpty) {
        try {
          final productFullData =
              await _provider.getProductById(targetProductId);
          fetchedBrandName.value =
              productFullData['brand'] ?? TTexts.noBrand.tr;
          fetchedCategoryName.value =
              productFullData['category']?['name'] ?? TTexts.uncategorized.tr;
          fetchedImageUrl.value = _validateUrl(productFullData['imageUrl']);
        } catch (e) {
          debugPrint('Lỗi fetch product: $e');
        }
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingFreshData.value = false;
      _updateTotalPriceAndQuantity();
    }
  }

  void showBarcodeListBottomSheet() {
    final package =
        _activeInventory.productPackage ?? initialItem.inventory.productPackage;
    if (package != null && fetchedBarcodesList.isNotEmpty) {
      final updatedPackage = package.copyWith(barcodes: fetchedBarcodesList);
      TBottomSheetWidget.show(
        child: InventoryBarcodeListBottomSheetWidget(package: updatedPackage),
      );
    }
  }

  InventoryModel get _activeInventory =>
      freshInventoryData.value ?? initialItem.inventory;
  String get displayName =>
      _activeInventory.productPackage?.displayName ??
      initialItem.product?.name ??
      TTexts.productNameUnknown.tr;

  String get barcode {
    if (fetchedBarcode.value.isNotEmpty) return fetchedBarcode.value;
    final pkg =
        _activeInventory.productPackage ?? initialItem.inventory.productPackage;
    if (pkg?.barcodeValue != null && pkg!.barcodeValue!.isNotEmpty) {
      return pkg.barcodeValue!;
    }
    return TTexts.na.tr;
  }

  int get currentStock => _activeInventory.quantity;
  int get threshold => _activeInventory.reorderThreshold;

  String get productImageUrl => fetchedImageUrl.value;
  String get categoryName => fetchedCategoryName.value;
  String get brandName => fetchedBrandName.value;

  bool get isProductActive =>
      (initialItem.product?.activeStatus ?? 'active').toLowerCase() == 'active';

  String get healthStatusText {
    if (currentStock <= 0) return TTexts.tabOutStock.tr;
    if (currentStock <= threshold) return TTexts.tabLowStock.tr;
    return TTexts.tabHealthy.tr;
  }

  Color get healthStatusColor {
    if (currentStock <= 0) return AppColors.alertText;
    if (currentStock <= threshold) return AppColors.primary;
    return AppColors.stockIn;
  }

  void incrementQuantity() {
    final current = int.tryParse(quantityController.text) ?? 1;
    // RÀNG BUỘC: Không tăng quá số lượng tồn
    if (current < currentStock) {
      quantityController.text = (current + 1).toString();
    } else {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.batchExceedsStock.tr);
    }
  }

  void decrementQuantity() {
    final current = int.tryParse(quantityController.text) ?? 1;
    if (current > 1) {
      quantityController.text = (current - 1).toString();
    }
  }

  void confirmAndAddToCart() {
    try {
      final qty = int.tryParse(quantityController.text) ?? 0;
      if (qty <= 0) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.quantityGreaterThanZero.tr);
        return;
      }

      // RÀNG BUỘC TRƯỚC KHI SUBMIT
      if (qty > currentStock) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.batchExceedsStock.tr);
        return;
      }

      FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingAddingToCart.tr);

      final package = _activeInventory.productPackage ??
          initialItem.inventory.productPackage;

      String realPkgId = _activeInventory.productPackageId;
      if (realPkgId.isEmpty || realPkgId == 'null') {
        realPkgId =
            package?.productPackageId ?? initialItem.inventory.productPackageId;
      }

      if (realPkgId.isEmpty || realPkgId == 'null') {
        FullScreenLoaderUtils.stopLoading();
        TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr,
            message: 'Lỗi: Không tìm thấy ID của phân loại sản phẩm.');
        return;
      }

      ProductModel finalProduct;
      if (initialItem.product != null) {
        finalProduct =
            initialItem.product!.copyWith(imageUrl: fetchedImageUrl.value);
      } else {
        finalProduct = ProductModel.fromJson({
          'productId': package?.productId ?? '',
          'name': displayName,
          'imageUrl': fetchedImageUrl.value,
          'brand': fetchedBrandName.value,
        });
      }

      final Map<String, dynamic> cartData = {
        'productPackageId': realPkgId,
        'displayName': displayName,
        'packageInfo': package?.copyWith(
          product: finalProduct,
          barcodes: fetchedBarcodesList,
        ),
        'importPrice': package?.importPrice ?? 0.0,
        'sellingPrice': package?.sellingPrice ?? 0.0,
        'currentStock': currentStock,
        'reorderThreshold': threshold,
      };

      Get.find<OutboundTransactionController>().addToCart(
        cartData,
        quantity: qty,
        customPrice: double.tryParse(priceController.text),
      );

      FullScreenLoaderUtils.stopLoading();
      Get.until(
          (route) => route.settings.name == AppRoutes.outboundTransaction);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }
}
