import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_barcode_list_bottom_sheet_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final InventoryProvider _inventoryProvider = InventoryProvider();

  final RxList<AdjustmentItemRx> allItems = <AdjustmentItemRx>[].obs;
  final RxList<AdjustmentItemRx> filteredItems = <AdjustmentItemRx>[].obs;

  final RxMap<String, String> fetchedImages = <String, String>{}.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController additionalNoteController =
      TextEditingController();

  @override
  void onReady() {
    super.onReady();
    _fetchInventoryToAdjust();
  }

  Future<void> _fetchInventoryToAdjust() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);
      final data = await _provider.getInventoriesForAdjustment();

      final parsedItems = data.map((e) {
        final packageJson = e['productPackage'];
        final packageInfo = packageJson != null
            ? ProductPackageModel.fromJson(packageJson)
            : null;

        final String realPackageId =
            packageJson?['productPackageId'] ?? e['productPackageId'] ?? '';

        return AdjustmentItemRx(
          id: e['inventoryId'] ?? e['id'] ?? '',
          packageId: realPackageId,
          name: packageInfo?.displayName ?? TTexts.unknownProduct.tr,
          initialSystemQty: e['quantity'] ?? 0,
          packageInfo: packageInfo,
        );
      }).toList();

      allItems.assignAll(parsedItems);
      filteredItems.assignAll(parsedItems);
      FullScreenLoaderUtils.stopLoading();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  void filterItems(String query) {
    if (query.trim().isEmpty) {
      filteredItems.assignAll(allItems);
    } else {
      final keyword = query.trim().toLowerCase();
      filteredItems.assignAll(
        allItems.where((item) {
          final matchName = item.name.toLowerCase().contains(keyword);
          final matchBarcode =
              item.packageInfo?.barcodeValue?.toLowerCase().contains(keyword) ??
                  false;
          return matchName || matchBarcode;
        }).toList(),
      );
    }
  }

  int get totalItems => allItems.length;
  int get checkedItemsCount =>
      allItems.where((item) => item.isChecked.value).length;
  bool get canSave => checkedItemsCount > 0;

  String get combinedItemNotes {
    List<String> notes = [];
    for (var item in allItems) {
      if (item.isChecked.value && item.note.value.trim().isNotEmpty) {
        notes.add("• ${item.note.value.trim()}");
      }
    }
    return notes.join("\n");
  }

  void goToItemAdjustmentPage(AdjustmentItemRx item) {
    Get.toNamed(AppRoutes.stockAdjustmentItem, arguments: item);
  }

  void showBarcodeListBottomSheet(ProductPackageModel package) {
    TBottomSheetWidget.show(
      child: InventoryBarcodeListBottomSheetWidget(package: package),
    );
  }

  // DIALOG 1: XÁC NHẬN CHỌN TẤT CẢ
  void checkAllUncheckedItems() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmCheckAllTitle.tr,
        description: TTexts.confirmCheckAllDesc.tr,
        icon: const Text('✅', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirm.tr,
        onPrimaryPressed: () {
          Get.back();
          for (var item in allItems) {
            if (!item.isChecked.value) {
              item.isChecked.value = true;
              item.actualQty.value = item.systemQty.value;
              item.selectedReason.value = '';
              item.note.value = '';
            }
          }
          filteredItems.refresh();
        },
        secondaryButtonText: TTexts.cancel.tr,
      ),
    );
  }

  // DIALOG 2: XÁC NHẬN BỎ CHỌN TẤT CẢ
  void uncheckAllItems() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmUncheckAllTitle.tr,
        description: TTexts.confirmUncheckAllDesc.tr,
        icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirm.tr,
        onPrimaryPressed: () {
          Get.back();
          for (var item in allItems) {
            item.isChecked.value = false;
            item.actualQty.value = item.systemQty.value;
            item.selectedReason.value = '';
            item.note.value = '';
          }
          filteredItems.refresh();
        },
        secondaryButtonText: TTexts.cancel.tr,
      ),
    );
  }

  // DIALOG 3: XÁC NHẬN THOÁT
  void handleExit() {
    if (checkedItemsCount > 0) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.unsavedChangesTitle.tr,
          description: TTexts.unsavedChangesDesc.tr,
          icon: const Text('🚨', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.exitAnyway.tr,
          onPrimaryPressed: () {
            Get.back();
            Get.back();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    } else {
      Get.back();
    }
  }

  // DIALOG 4: XÁC NHẬN LƯU VÀ KIỂM TRA LỆCH
  void handleSaveAdjustment() {
    if (!canSave) return;

    final hasDifferences = allItems.any(
        (i) => i.isChecked.value && i.actualQty.value != i.systemQty.value);

    if (!hasDifferences) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.noDifferencesFound.tr,
      );
      return;
    }

    // 1. TÌM CÁC SẢN PHẨM BIẾN ĐỘNG LỚN (>= 10)
    final significantChanges = allItems.where((i) {
      return i.isChecked.value &&
          (i.actualQty.value - i.systemQty.value).abs() >= 10;
    }).toList();

    if (significantChanges.isNotEmpty) {
      // Xây dựng danh sách text tối đa 3 món
      String itemDetails = "${TTexts.highQtyFluctuationDesc.tr}\n";
      for (var i = 0; i < significantChanges.length; i++) {
        if (i >= 3) {
          itemDetails += "\n... ${TTexts.andMore.tr}";
          break;
        }
        final item = significantChanges[i];
        itemDetails +=
            "\n• ${item.name}: ${item.systemQty.value} ➔ ${item.actualQty.value}";
      }

      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.significantChangeDetected.tr,
          description: itemDetails,
          icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onPrimaryPressed: () {
            Get.back();
            executeSave();
          },
        ),
      );
      return;
    }

    // Nếu không có biến động lớn, hiện Dialog xác nhận
    if (checkedItemsCount < totalItems) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.incompleteSaveTitle.tr,
          description: TTexts.incompleteSaveDesc.tr,
          icon: const Text('👀', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.proceedAdjustment.tr,
          onPrimaryPressed: () {
            Get.back();
            executeSave();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    } else {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.confirmSaveTitle.tr,
          description: TTexts.confirmSaveDesc.tr,
          icon: const Text('💾', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          onPrimaryPressed: () {
            Get.back();
            executeSave();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    }
  }

  Future<void> executeSave() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final itemsToUpdate = allItems.where((i) {
        return i.isChecked.value && (i.actualQty.value != i.systemQty.value);
      }).toList();

      final addNote = additionalNoteController.text.trim();

      final batchItems = itemsToUpdate.map((item) {
        String finalNote = item.note.value;
        if (addNote.isNotEmpty) {
          finalNote = finalNote.isNotEmpty ? "$finalNote - $addNote" : addNote;
        }

        return {
          "productPackageId": item.packageId,
          "type": "set",
          "quantity": item.actualQty.value,
          "reason": item.selectedReason.value.isNotEmpty
              ? item.selectedReason.value
              : 'Stock Take',
          "note": finalNote.isNotEmpty ? finalNote : null,
        };
      }).toList();

      await _provider.batchAdjustInventories(items: batchItems);

      FullScreenLoaderUtils.stopLoading();

      double totalAdjustmentValue = 0.0;
      List<TransactionDetailModel> summaryDetails = [];

      for (var item in itemsToUpdate) {
        double unitPrice = item.packageInfo?.importPrice ?? 0.0;
        int spread = item.actualQty.value - item.systemQty.value;
        totalAdjustmentValue += (spread * unitPrice);

        summaryDetails.add(TransactionDetailModel(
          productPackageId: item.packageId,
          quantity: spread,
          unitPrice: unitPrice,
          packageInfo: item.packageInfo,
        ));
      }

      final summaryTransaction = TransactionModel(
          transactionId:
              "ADJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
          createdAt: DateTime.now(),
          type: 'adjustment',
          status: 'COMPLETED',
          totalPrice: totalAdjustmentValue,
          note: addNote.isNotEmpty ? addNote : 'Stock Take',
          items: summaryDetails,
          userId: 'system');

      Get.offNamed(AppRoutes.transactionSummary, arguments: summaryTransaction);

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.inventoryUpdatedSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  void openScanner() {
    Get.to(
      () => TBarcodeScannerLayout(
        title: TTexts.scanProductBarcode.tr,
        onScanned: (code) {
          Get.back();
          _processScannedBarcode(code);
        },
      ),
      transition: Transition.downToUp,
    );
  }

  Future<void> _processScannedBarcode(String barcode) async {
    final localMatch = allItems.firstWhereOrNull((item) {
      final pkg = item.packageInfo;
      if (pkg?.barcodeValue == barcode) return true;
      if (pkg?.barcodes.any((b) => b.barcode == barcode) ?? false) return true;
      return false;
    });

    if (localMatch != null) {
      goToItemAdjustmentPage(localMatch);
      return;
    }

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.searchingProduct.tr);
      final result = await _inventoryProvider.scanBarcode(barcode);
      FullScreenLoaderUtils.stopLoading();

      if (result['resolutionType'] == 'exact_match') {
        final pkgJson = result['productPackage'];
        final packageInfo = ProductPackageModel.fromJson(pkgJson);

        final invJsonMap =
            Map<String, dynamic>.from(pkgJson['inventory'] ?? {});
        final String realPackageId = pkgJson['productPackageId'] ?? '';

        final newItem = AdjustmentItemRx(
          id: invJsonMap['inventoryId'] ?? '',
          packageId: realPackageId,
          name: packageInfo.displayName,
          initialSystemQty: invJsonMap['quantity'] ?? 0,
          packageInfo: packageInfo,
        );

        allItems.insert(0, newItem);
        filterItems(searchController.text);
        goToItemAdjustmentPage(newItem);
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.barcodeNotFoundMessage.tr);
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorServerTitle.tr,
          message: '${TTexts.errorProcessingBarcode.tr}: $e');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    additionalNoteController.dispose();
    super.onClose();
  }
}
