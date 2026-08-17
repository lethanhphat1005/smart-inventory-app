import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_barcode_model.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
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

  bool isEditing = false;
  bool fromSelectionScreen = false;
  bool fromScanner = false;

  double? passedCustomPrice;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      int passedQty = 1;

      if (Get.arguments is Map) {
        initialItem = Get.arguments['displayItem'];
        isEditing = Get.arguments['isEditing'] ?? false;
        passedQty = Get.arguments['quantity'] ?? 1;

        if (Get.arguments['fromSelectionScreen'] != null) {
          fromSelectionScreen = Get.arguments['fromSelectionScreen'];
        }
        // Bắt cờ Scanner
        if (Get.arguments['fromScanner'] != null) {
          fromScanner = Get.arguments['fromScanner'];
        }
        if (Get.arguments['customPrice'] != null) {
          passedCustomPrice = Get.arguments['customPrice'];
        }
      } else {
        initialItem = Get.arguments as InventoryInsightDisplayModel;
      }

      if (!fromSelectionScreen) {
        try {
          final outboundCtrl = Get.find<OutboundTransactionController>();
          String pkgId = initialItem.inventory.productPackageId;
          if (pkgId.isEmpty) {
            pkgId =
                initialItem.inventory.productPackage?.productPackageId ?? '';
          }

          if (pkgId.isNotEmpty) {
            final existingIndex = outboundCtrl.cartItems
                .indexWhere((item) => item.productPackageId == pkgId);
            if (existingIndex != -1) {
              final existingItem = outboundCtrl.cartItems[existingIndex];
              passedQty = existingItem.quantity;
              isEditing = true;
            }
          }
        } catch (e) {
          debugPrint('OutboundTransactionController not found: $e');
        }
      }

      quantityController.text = passedQty.toString();
      itemQuantity.value = passedQty;
      double initPrice =
          initialItem.inventory.productPackage?.sellingPrice ?? 0.0;

      if (fromSelectionScreen && passedCustomPrice != null) {
        initPrice = passedCustomPrice!;
      } else if (isEditing && !fromSelectionScreen) {
        try {
          final outboundCtrl = Get.find<OutboundTransactionController>();
          String pkgId = initialItem.inventory.productPackageId;
          if (pkgId.isEmpty) {
            pkgId =
                initialItem.inventory.productPackage?.productPackageId ?? '';
          }
          final existingIndex = outboundCtrl.cartItems
              .indexWhere((item) => item.productPackageId == pkgId);
          if (existingIndex != -1) {
            initPrice = outboundCtrl.cartItems[existingIndex].unitPrice;
          }
        } catch (_) {}
      }

      // Gắn lên UI tức thì để không bị rỗng
      priceController.text = initPrice.toStringAsFixed(2);
      _updateTotalPriceAndQuantity();

      fetchedCategoryName.value = initialItem.product?.categoryName ??
          initialItem.inventory.productPackage?.product?.categoryName ??
          TTexts.uncategorized.tr;

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

    // Outbound: Ràng buộc không cho nhập lố kho
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

      // ==========================================
      // ĐÃ SỬA: KHẮC PHỤC LỖI TRỐNG PACKAGE ID
      // ==========================================
      String packageId = initialItem.inventory.productPackageId;
      if (packageId.isEmpty || packageId == 'null') {
        packageId =
            initialItem.inventory.productPackage?.productPackageId ?? '';
      }

      String? targetProductId = initialItem.product?.productId;
      if (targetProductId == null || targetProductId.isEmpty) {
        targetProductId = initialItem.inventory.productPackage?.productId;
      }

      if (packageId.isNotEmpty) {
        final results = await Future.wait([
          _provider.getInventoryDetailByPackageId(packageId),
          _provider.getProductPackageById(packageId),
        ]);

        final invDataRaw = results[0];
        final packageFullData = results[1];

        final Map<String, dynamic> mutableInvData =
            Map<String, dynamic>.from(invDataRaw);
        mutableInvData['productPackage'] = packageFullData;

        freshInventoryData.value = InventoryModel.fromJson(mutableInvData);

        double displayPrice =
            initialItem.inventory.productPackage?.sellingPrice ?? 0.0;
        if (packageFullData['sellingPrice'] != null) {
          displayPrice = (packageFullData['sellingPrice'] as num).toDouble();
        }

        if (fromSelectionScreen) {
          if (passedCustomPrice != null) displayPrice = passedCustomPrice!;
        } else if (isEditing) {
          try {
            final outboundCtrl = Get.find<OutboundTransactionController>();
            final existingIndex = outboundCtrl.cartItems
                .indexWhere((item) => item.productPackageId == packageId);
            if (existingIndex != -1) {
              displayPrice = outboundCtrl.cartItems[existingIndex].unitPrice;
            }
          } catch (_) {}
        }

        priceController.text = displayPrice.toStringAsFixed(2);

        if (targetProductId == null || targetProductId.isEmpty) {
          targetProductId = freshInventoryData.value?.productPackage?.productId;
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
      }

      if (targetProductId != null && targetProductId.isNotEmpty) {
        try {
          final productFullData =
              await _provider.getProductById(targetProductId);
          fetchedBrandName.value =
              productFullData['brand'] ?? TTexts.noBrand.tr;

          fetchedCategoryName.value = productFullData['categoryName'] ??
              productFullData['category']?['name'] ??
              TTexts.uncategorized.tr;

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
          child:
              InventoryBarcodeListBottomSheetWidget(package: updatedPackage));
    }
  }

  InventoryModel get _activeInventory =>
      freshInventoryData.value ?? initialItem.inventory;
  // String get displayName =>
  //     _activeInventory.productPackage?.displayName ??
  //     initialItem.product?.name ??
  //     TTexts.productNameUnknown.tr;
  String get displayName {
    final package = _activeInventory.productPackage;

    if (package != null) {
      return DisplayNameUtils.getFullPackageDisplayName(package);
    }

    return initialItem.product?.name ?? TTexts.productNameUnknown.tr;
  }

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
    // Ràng buộc: Không tăng quá số lượng tồn
    if (current < currentStock) {
      quantityController.text = (current + 1).toString();
    } else {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.batchExceedsStock.tr);
    }
  }

  void decrementQuantity() {
    final current = int.tryParse(quantityController.text) ?? 0;
    if (current > 0) {
      quantityController.text = (current - 1).toString();
    }
  }

  void confirmAndAddToCart() {
    try {
      final qty = int.tryParse(quantityController.text) ?? 0;
      final price = double.tryParse(priceController.text);

      if (fromSelectionScreen) {
        Get.back(result: {
          'quantity': qty,
          'customPrice': price,
          'sellingPrice': _activeInventory.productPackage?.sellingPrice ?? 0.0,
        });
        return;
      }

      if (qty <= 0) {
        if (isEditing) {
          final index = Get.find<OutboundTransactionController>()
              .cartItems
              .indexWhere((item) =>
                  item.productPackageId == _activeInventory.productPackageId);
          if (index != -1) {
            Get.find<OutboundTransactionController>().removeItem(index);
          }

          // Lùi về Camera nếu đang Quét
          if (fromScanner) {
            Get.back();
          } else {
            Get.until((route) =>
                route.settings.name == AppRoutes.outboundTransaction);
          }
          return;
        } else {
          TSnackbarsWidget.warning(
              title: TTexts.warningTitle.tr,
              message: TTexts.quantityGreaterThanZero.tr);
          return;
        }
      }

      // Ràng buộc trước khi submit
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
            message: TTexts.errorInvalidPackageId.tr);
        return;
      }

      ProductModel finalProduct;
      if (initialItem.product != null) {
        finalProduct = initialItem.product!.copyWith(
            imageUrl: fetchedImageUrl.value,
            categoryName: fetchedCategoryName.value);
      } else {
        finalProduct = ProductModel.fromJson({
          'productId': package?.productId ?? '',
          'name': displayName,
          'imageUrl': fetchedImageUrl.value,
          'brand': fetchedBrandName.value,
          'categoryName': fetchedCategoryName.value,
        });
      }

      final Map<String, dynamic> cartData = {
        'productPackageId': realPkgId,
        'displayName': displayName,
        'packageInfo': package?.copyWith(
            product: finalProduct, barcodes: fetchedBarcodesList),
        'importPrice': package?.importPrice ?? 0.0,
        'sellingPrice': package?.sellingPrice ?? 0.0,
        'currentStock': currentStock,
        'reorderThreshold': threshold,
      };

      Get.find<OutboundTransactionController>().addToCart(
        cartData,
        quantity: qty,
        customPrice: double.tryParse(priceController.text),
        isReplace: isEditing,
      );

      FullScreenLoaderUtils.stopLoading();

      // Lùi về Camera nếu đang Quét
      if (fromScanner) {
        Get.back();
      } else {
        Get.until(
            (route) => route.settings.name == AppRoutes.outboundTransaction);
      }
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
