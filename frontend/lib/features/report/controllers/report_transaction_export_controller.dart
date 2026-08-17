import 'dart:io';
import 'package:excel/excel.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportTransactionExportController extends GetxController {
  final RxBool isExporting = false.obs;
  final RxDouble exportProgress = 0.0.obs;
  final RxString exportStatus = ''.obs;

  Future<void> exportTransactionToExcel(TransactionModel tx) async {
    try {
      isExporting.value = true;
      exportProgress.value = 0.0;
      exportStatus.value = TTexts.exportPreparing.tr;

      exportProgress.value = 0.1;
      exportStatus.value = TTexts.exportPermissionChecking.tr;
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }
      await Future.delayed(const Duration(milliseconds: 300));

      exportProgress.value = 0.3;
      exportStatus.value = TTexts.exportCreatingDoc.tr;
      var excel = Excel.createExcel();

      String rawId = tx.transactionId ?? 'Tx';
      String shortId = rawId.length > 15 ? rawId.substring(0, 15) : rawId;
      String sheetName = 'Receipt_$shortId';
      if (sheetName.length > 31) {
        sheetName = sheetName.substring(0, 31);
      }

      Sheet sheetObject = excel[sheetName];
      excel.setDefaultSheet(sheetName);

      // ==========================================
      // LẤY DỮ LIỆU CỬA HÀNG VÀ NGƯỜI DÙNG
      // ==========================================
      final storeService = Get.find<StoreService>();
      final userService = Get.find<UserService>();

      final exporterName =
          userService.currentUser.value?.fullName ?? TTexts.unknownUser.tr;
      final storeName = storeService.currentStoreName.value.isNotEmpty
          ? storeService.currentStoreName.value
          : TTexts.mainHQStore.tr;
      final storeAddress = storeService.currentStoreAddress.value.isNotEmpty
          ? storeService.currentStoreAddress.value
          : TTexts.na.tr;

      final exportTime =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
      final dateFormatted =
          DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt ?? DateTime.now());

      // ==========================================
      // THIẾT LẬP STYLE (Đã sử dụng ExcelColor)
      // ==========================================
      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: ExcelColor.fromHexString('#FF8A00'), // Màu Cam
      );

      CellStyle headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString('#FF8A00'), // Nền Cam
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'), // Chữ Trắng
      );

      CellStyle boldStyle = CellStyle(bold: true);

      // 3. Đổ dữ liệu Header
      exportProgress.value = 0.5;
      exportStatus.value = TTexts.exportWritingTxInfo.tr;

      sheetObject.appendRow([TextCellValue('')]); // Dòng 0

      // Tiêu đề
      sheetObject.appendRow(
          [TextCellValue(TTexts.exportExcelSystemName.tr)]); // Dòng 1
      sheetObject.cell(CellIndex.indexByString("A2")).cellStyle = titleStyle;

      sheetObject
          .appendRow([TextCellValue(TTexts.exportReceiptTitle.tr)]); // Dòng 2
      sheetObject.cell(CellIndex.indexByString("A3")).cellStyle = boldStyle;

      sheetObject.appendRow([TextCellValue('')]); // Dòng 3

      // Thông tin Doanh nghiệp / Cửa hàng
      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelStoreName.tr),
        TextCellValue(storeName)
      ]);
      sheetObject.cell(CellIndex.indexByString("A5")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelAddress.tr),
        TextCellValue(storeAddress)
      ]);
      sheetObject.cell(CellIndex.indexByString("A6")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelExportedBy.tr),
        TextCellValue(exporterName)
      ]);
      sheetObject.cell(CellIndex.indexByString("A7")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelExportTime.tr),
        TextCellValue(exportTime)
      ]);
      sheetObject.cell(CellIndex.indexByString("A8")).cellStyle = boldStyle;

      sheetObject.appendRow([TextCellValue('')]); // Dòng 9

      // Thông tin chi tiết Phiếu
      sheetObject.appendRow([
        TextCellValue('${TTexts.exportExcelColId.tr}:'),
        TextCellValue(tx.transactionId ?? TTexts.na.tr)
      ]);
      sheetObject.cell(CellIndex.indexByString("A10")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue('${TTexts.exportExcelColType.tr}:'),
        TextCellValue(tx.type.toUpperCase())
      ]);
      sheetObject.cell(CellIndex.indexByString("A11")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue('${TTexts.exportExcelColStatus.tr}:'),
        TextCellValue(tx.status.toUpperCase())
      ]);
      sheetObject.cell(CellIndex.indexByString("A12")).cellStyle = boldStyle;

      sheetObject.appendRow(
          [TextCellValue(TTexts.dateAndTime.tr), TextCellValue(dateFormatted)]);
      sheetObject.cell(CellIndex.indexByString("A13")).cellStyle = boldStyle;

      sheetObject.appendRow([TextCellValue('')]); // Dòng 14

      // Header Bảng Items
      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelColNo.tr),
        TextCellValue(TTexts.exportColProductName.tr),
        TextCellValue(TTexts.exportColBarcode.tr),
        TextCellValue(TTexts.exportColUnitPrice.tr),
        TextCellValue(TTexts.exportColQuantity.tr),
        TextCellValue(TTexts.exportColTotal.tr),
      ]);

      // Phủ màu cam cho Header (Dòng 16 trong Excel = rowIndex 15)
      for (int i = 0; i < 6; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 15))
            .cellStyle = headerStyle;
      }

      await Future.delayed(const Duration(milliseconds: 400));

      // 4. Đổ dữ liệu Items
      exportProgress.value = 0.7;
      exportStatus.value = TTexts.exportProcessingItems.tr;

      int totalItemsCount = 0;
      int startingDataRow = 16;

      for (int i = 0; i < tx.items.length; i++) {
        final item = tx.items[i];
        // final productName =
        //     item.packageInfo?.displayName ?? TTexts.unknownProduct.tr;
        final productName =
            DisplayNameUtils.getFullPackageDisplayName(item.packageInfo);
        final barcode = item.packageInfo?.barcodeValue ?? TTexts.na.tr;

        final displayQty = item.quantity.abs().toInt();
        final itemTotal = item.unitPrice * displayQty;

        totalItemsCount += displayQty;

        sheetObject.appendRow([
          IntCellValue(i + 1),
          TextCellValue(productName),
          TextCellValue(barcode),
          DoubleCellValue(item.unitPrice),
          IntCellValue(displayQty),
          DoubleCellValue(itemTotal),
        ]);
      }

      // Dòng Grand Total
      sheetObject.appendRow([TextCellValue('')]);
      final grandTotalRowIndex = startingDataRow + tx.items.length + 1;

      sheetObject.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(TTexts.exportExcelGrandTotal.tr),
        IntCellValue(totalItemsCount),
        DoubleCellValue(tx.totalPrice),
      ]);

      // In đậm dòng tổng kết
      for (int i = 3; i < 6; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: i, rowIndex: grandTotalRowIndex))
            .cellStyle = boldStyle;
      }

      await Future.delayed(const Duration(milliseconds: 300));

      // 5. Lưu File
      exportProgress.value = 0.9;
      exportStatus.value = TTexts.exportSavingFile.tr;
      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception("Failed to generate Excel file");

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath = '${directory!.path}/$sheetName.xlsx';
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      exportProgress.value = 1.0;
      exportStatus.value = TTexts.exportComplete.tr;
      await Future.delayed(const Duration(milliseconds: 400));

      if (Get.isBottomSheetOpen == true) Get.back();

      TSnackbarsWidget.success(
        title: TTexts.exportSuccessTitle.tr,
        message: TTexts.exportFileSaved.tr,
        actionText: TTexts.exportOpenBtn.tr,
        onActionPressed: () async {
          final result = await OpenFile.open(filePath);

          if (result.type != ResultType.done) {
            TSnackbarsWidget.error(
              title: TTexts.exportCannotOpen.tr,
              message: TTexts.exportNoAppFoundDetail.tr,
            );
          }
        },
      );
    } catch (e) {
      if (Get.isBottomSheetOpen == true) Get.back();
      TSnackbarsWidget.error(
          title: TTexts.exportFailedTitle.tr, message: e.toString());
    } finally {
      isExporting.value = false;
    }
  }
}
