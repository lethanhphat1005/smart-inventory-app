import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_barcode_list_bottom_sheet_widget.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/core/infrastructure/models/product_package_barcode_model.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:get/get.dart';

class StockAdjustmentItemController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();

  late final AdjustmentItemRx item;

  late RxInt tempActualQty;
  late RxString tempSelectedReason;
  late TextEditingController tempNoteController;
  late TextEditingController actualQtyController;

  final RxString fetchedBarcode = ''.obs;
  final RxString fetchedImageUrl = ''.obs;
  final RxList<ProductPackageBarcodeModel> fetchedBarcodesList =
      <ProductPackageBarcodeModel>[].obs;

  final List<String> reasonOptions = [
    TTexts.damage,
    TTexts.expired,
    TTexts.loss,
    TTexts.itemFound,
    TTexts.inputError,
    TTexts.otherReason,
  ];

  @override
  void onInit() {
    super.onInit();
    try {
      if (Get.arguments is AdjustmentItemRx) {
        item = Get.arguments;
        _initializeFormData();
        _fetchFullPackageDetails();
      } else {
        Get.back();
        TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr, message: TTexts.errorLoadingData.tr);
      }
    } catch (e) {
      handleError(e);
    }
  }

  // HÀM CHUẨN HÓA URL
  String _validateUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final normalized = UrlHelperUtils.normalizeImageUrl(url) ?? '';
    if (!normalized.startsWith('http')) return '';
    return normalized;
  }

  void _initializeFormData() {
    tempActualQty = item.actualQty.value.obs;
    tempSelectedReason = item.selectedReason.value.obs;
    tempNoteController = TextEditingController(text: item.note.value);
    actualQtyController =
        TextEditingController(text: tempActualQty.value.toString());

    actualQtyController.addListener(() {
      final val = int.tryParse(actualQtyController.text) ?? 0;
      if (tempActualQty.value != val) {
        tempActualQty.value = val;
        _updateAutomatedNote();
      }
    });

    if (Get.isRegistered<StockAdjustmentController>()) {
      final cacheMap = Get.find<StockAdjustmentController>().fetchedImages;
      fetchedImageUrl.value = _validateUrl(
          cacheMap[item.packageId] ?? item.packageInfo?.product?.imageUrl);
    } else {
      fetchedImageUrl.value = _validateUrl(item.packageInfo?.product?.imageUrl);
    }
  }

  Future<void> _fetchFullPackageDetails() async {
    try {
      final packageId = item.packageId;
      String targetProductId = item.packageInfo?.productId ?? '';

      // 1. LẤY MÃ VẠCH TỪ PACKAGE
      if (packageId.isNotEmpty) {
        final packageFullData =
            await _provider.getProductPackageById(packageId);
        if (targetProductId.isEmpty) {
          targetProductId = packageFullData['productId'] ?? '';
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

      // 2. KÉO LUỒNG PHỤ LẤY ẢNH VÀ LƯU VÀO CACHE BÊN NGOÀI
      if (targetProductId.isNotEmpty) {
        try {
          final productFullData =
              await _provider.getProductById(targetProductId);

          final String fetchedImg = _validateUrl(productFullData['imageUrl']);
          if (fetchedImg.isNotEmpty) {
            fetchedImageUrl.value = fetchedImg;

            // GHI ẢNH ĐÃ CHUẨN HÓA VÀO CACHE ĐỂ BÊN NGOÀI DÙNG CHUNG
            if (Get.isRegistered<StockAdjustmentController>()) {
              Get.find<StockAdjustmentController>()
                  .fetchedImages[item.packageId] = fetchedImg;
            }
          }
        } catch (e) {
          debugPrint('Lỗi fetch product image: $e');
        }
      }
    } catch (e) {
      debugPrint('Lỗi fetch chi tiết: $e');
    }
  }

  String get imageUrl => fetchedImageUrl.value;

  String get displayBarcode {
    if (fetchedBarcode.value.isNotEmpty) return fetchedBarcode.value;
    final barcodes = item.packageInfo?.barcodes ?? [];
    if (barcodes.isNotEmpty) return barcodes.first.barcode;
    return item.packageInfo?.barcodeValue ?? '';
  }

  bool get hasMultipleBarcodes =>
      fetchedBarcodesList.length > 1 ||
      (item.packageInfo?.barcodes.length ?? 0) > 1;
  int get barcodeCount => fetchedBarcodesList.isNotEmpty
      ? fetchedBarcodesList.length
      : (item.packageInfo?.barcodes.length ?? 0);

  void showBarcodeListBottomSheet() {
    if (item.packageInfo != null && hasMultipleBarcodes) {
      final updatedPackage = item.packageInfo!.copyWith(
          barcodes: fetchedBarcodesList.isNotEmpty
              ? fetchedBarcodesList
              : item.packageInfo!.barcodes);
      TBottomSheetWidget.show(
        child: InventoryBarcodeListBottomSheetWidget(package: updatedPackage),
      );
    }
  }

  void incrementActualQty() {
    final current = int.tryParse(actualQtyController.text) ?? 0;
    actualQtyController.text = (current + 1).toString();
  }

  void decrementActualQty() {
    final current = int.tryParse(actualQtyController.text) ?? 0;
    if (current > 0) {
      actualQtyController.text = (current - 1).toString();
    } else {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr,
          message: TTexts.notEnoughStockWarning.tr);
    }
  }

  void selectReason(String reasonKey) {
    if (tempActualQty.value == item.systemQty.value) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr,
          message: TTexts.noReasonNeededWarning.tr);
      return;
    }

    if (tempSelectedReason.value == reasonKey) {
      tempSelectedReason.value = '';
    } else {
      tempSelectedReason.value = reasonKey;
    }
    _updateAutomatedNote();
  }

  void _updateAutomatedNote() {
    if (tempActualQty.value == item.systemQty.value) {
      tempSelectedReason.value = '';
      tempNoteController.text = '';
      return;
    }

    if (tempSelectedReason.value.isNotEmpty) {
      final spread = tempActualQty.value - item.systemQty.value;
      final spreadStr = spread.abs().toString();

      final unitStr = item.packageInfo?.unit?.name ?? TTexts.defaultUnit.tr;
      final foundText = TTexts.itemFoundText.tr;

      String automatedText = "${tempSelectedReason.value.tr}: ";
      automatedText += spread > 0 ? "$foundText $spreadStr" : "-$spreadStr";
      automatedText +=
          " ${item.packageInfo?.displayName ?? item.name} $unitStr";

      tempNoteController.text = automatedText;
    } else {
      tempNoteController.text = '';
    }
  }

  int get spread => tempActualQty.value - item.systemQty.value;

  void confirmItemAdjustment() {
    item.actualQty.value = tempActualQty.value;
    item.selectedReason.value = tempSelectedReason.value;
    item.note.value = tempNoteController.text.trim();
    item.isChecked.value = true;

    if (Get.isRegistered<StockAdjustmentController>()) {
      Get.find<StockAdjustmentController>().filteredItems.refresh();
    }
    Get.back();
  }

  @override
  void onClose() {
    tempNoteController.dispose();
    actualQtyController.dispose();
    super.onClose();
  }
}
