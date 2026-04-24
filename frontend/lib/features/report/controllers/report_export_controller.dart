import 'dart:io';
import 'package:excel/excel.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportExportController extends GetxController {
  final RxBool isExporting = false.obs;
  final RxDouble exportProgress = 0.0.obs;
  final RxString exportStatus = ''.obs;

  Future<void> exportDailyTransactions(
      List<TransactionModel> transactions, String dateStr) async {
    if (transactions.isEmpty) {
      if (Get.isBottomSheetOpen == true) Get.back();
      TSnackbarsWidget.error(
          title: TTexts.exportFailedTitle.tr,
          message: TTexts.exportFailedMessage.tr);
      return;
    }

    try {
      isExporting.value = true;
      exportProgress.value = 0.1;
      exportStatus.value = TTexts.exportPermissionChecking.tr;

      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) await Permission.storage.request();
      }
      await Future.delayed(const Duration(milliseconds: 300));

      exportProgress.value = 0.3;
      exportStatus.value = TTexts.exportCreatingDoc.tr;
      var excel = Excel.createExcel();

      String safeDate = dateStr.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String sheetName = 'Report_$safeDate';
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

      // ==========================================
      // THIẾT LẬP STYLE (MÀU SẮC THEO THEME APP)
      // ==========================================
      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: ExcelColor.fromHexString('#FF8A00'), 
      );

      CellStyle headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString('#FF8A00'), 
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'), 
      );

      CellStyle boldStyle = CellStyle(bold: true);

      exportProgress.value = 0.5;
      exportStatus.value = TTexts.exportWritingSummary.tr;

      // ==========================================
      // ĐỔ DỮ LIỆU METADATA LÊN EXCEL
      // ==========================================
      sheetObject.appendRow([TextCellValue('')]); // Dòng 0

      // Tiêu đề hệ thống (Màu cam, to)
      sheetObject.appendRow(
          [TextCellValue(TTexts.exportExcelSystemName.tr)]); // Dòng 1
      sheetObject.cell(CellIndex.indexByString("A2")).cellStyle = titleStyle;

      sheetObject
          .appendRow([TextCellValue(TTexts.exportExcelTitle.tr)]); // Dòng 2
      sheetObject.cell(CellIndex.indexByString("A3")).cellStyle = boldStyle;

      sheetObject.appendRow([TextCellValue('')]); // Dòng 3

      // Các thông tin chi tiết
      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelStoreName.tr),
        TextCellValue(storeName)
      ]); // Dòng 4
      sheetObject.cell(CellIndex.indexByString("A5")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelAddress.tr),
        TextCellValue(storeAddress)
      ]); // Dòng 5
      sheetObject.cell(CellIndex.indexByString("A6")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelExportedBy.tr),
        TextCellValue(exporterName)
      ]); // Dòng 6
      sheetObject.cell(CellIndex.indexByString("A7")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelExportTime.tr),
        TextCellValue(exportTime)
      ]); // Dòng 7
      sheetObject.cell(CellIndex.indexByString("A8")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelDate.tr),
        TextCellValue(dateStr)
      ]); // Dòng 8
      sheetObject.cell(CellIndex.indexByString("A9")).cellStyle = boldStyle;

      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelTotalTx.tr),
        IntCellValue(transactions.length)
      ]); // Dòng 9
      sheetObject.cell(CellIndex.indexByString("A10")).cellStyle = boldStyle;

      sheetObject.appendRow([TextCellValue('')]); // Dòng 10

      // ==========================================
      // HEADER BẢNG GIAO DỊCH (Có màu nền)
      // ==========================================
      sheetObject.appendRow([
        TextCellValue(TTexts.exportExcelColNo.tr),
        TextCellValue(TTexts.exportExcelColId.tr),
        TextCellValue(TTexts.exportExcelColTime.tr),
        TextCellValue(TTexts.exportExcelColType.tr),
        TextCellValue(TTexts.exportExcelColStatus.tr),
        TextCellValue(TTexts.exportExcelColItems.tr),
        TextCellValue(TTexts.exportExcelColAmount.tr),
      ]);

      // Format Header Bảng (Dòng số 12 trong Excel = rowIndex: 11)
      for (int i = 0; i < 7; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 11))
            .cellStyle = headerStyle;
      }

      exportProgress.value = 0.7;
      exportStatus.value = TTexts.exportProcessingTx.tr;

      double grandTotalAmount = 0.0;
      int grandTotalItems = 0;
      int startingDataRow = 12; // Bắt đầu in dữ liệu từ dòng 12

      for (int i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        final timeStr =
            DateFormat('HH:mm').format(tx.createdAt ?? DateTime.now());

        // ĐÃ FIX LỖI TỔNG ITEMS = 0
        int totalItems = tx.itemCount;
        if (totalItems == 0 && tx.items.isNotEmpty) {
          totalItems = tx.items
              .fold(0, (sum, item) => sum + item.quantity.abs().toInt());
        }

        // Chỉ tính tiền cho giao dịch hợp lệ
        if (tx.status.toUpperCase() != 'CANCELLED') {
          if (tx.type.toLowerCase() == 'export') {
            grandTotalAmount += tx.totalPrice;
          } else if (tx.type.toLowerCase() == 'import') {
            grandTotalAmount -= tx.totalPrice;
          }
        }

        grandTotalItems += totalItems;

        sheetObject.appendRow([
          IntCellValue(i + 1),
          TextCellValue(tx.transactionId ?? TTexts.na.tr),
          TextCellValue(timeStr),
          TextCellValue(tx.type.toUpperCase()),
          TextCellValue(tx.status.toUpperCase()),
          IntCellValue(totalItems),
          DoubleCellValue(tx.totalPrice),
        ]);
      }

      // Dòng Tổng Cộng Cuối Bảng
      sheetObject.appendRow([TextCellValue('')]);

      final grandTotalRowIndex = startingDataRow + transactions.length + 1;

      sheetObject.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(TTexts.exportExcelGrandTotal.tr),
        IntCellValue(grandTotalItems),
        DoubleCellValue(grandTotalAmount),
      ]);

      // In đậm dòng tổng kết
      for (int i = 4; i < 7; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: i, rowIndex: grandTotalRowIndex))
            .cellStyle = boldStyle;
      }

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
        title: TTexts.exportSuccessTitle.tr, // Giả sử có "Export Successful"
        message: TTexts.exportFileSaved.tr,
        actionText: TTexts.exportOpenBtn.tr,
        onActionPressed: () async {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            TSnackbarsWidget.error(
              title: TTexts.exportCannotOpen.tr,
              message: TTexts.exportNoAppFound.tr,
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
