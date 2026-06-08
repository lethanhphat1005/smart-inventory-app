import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/transaction/widgets/transaction_summary/transaction_summary_details_bottom_sheet_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class TransactionSummaryController extends GetxController {
  late final TransactionModel transaction;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is TransactionModel) {
      transaction = Get.arguments;
    } else {
      Get.back();
    }
  }

  // Check đúng loại giao dịch
  bool get isInbound => transaction.type.toLowerCase() == 'import';
  bool get isOutbound => transaction.type.toLowerCase() == 'export';
  bool get isAdjustment => transaction.type.toLowerCase() == 'adjustment';

  Color get themeColor {
    if (isInbound) return AppColors.stockIn;
    if (isOutbound) return AppColors.stockOut;
    return AppColors.primary;
  }

  // Lấy số lượng dòng hàng (items) thay vì cộng dồn quantity
  int get totalItems => transaction.items.length;

  String get itemsDisplay => "$totalItems ${TTexts.items.tr}";
  Color get itemsColor => themeColor;

  // Tiền
  double get rawTotal => transaction.totalPrice;
  String get moneyDisplay =>
      CurrencyFormatterUtils  .formatFull(transaction.totalPrice);
  Color get moneyColor => themeColor;

  // Loại giao dịch
  Color get typeColor => themeColor;
  String get typeDisplay {
    if (isInbound) return TTexts.inbound.tr;
    if (isOutbound) return TTexts.outbound.tr;
    if (isAdjustment) return TTexts.stockAdjustment.tr;

    if (transaction.type.isNotEmpty) {
      return '${transaction.type[0].toUpperCase()}${transaction.type.substring(1).toLowerCase()}';
    }
    return transaction.type;
  }

  // Label góc trái dưới cùng
  String get bottomLabel {
    if (isAdjustment) return TTexts.checkItemsStats.tr;
    return TTexts.totalItemsTransaction.tr;
  }

  // Format ngày
  String get dateStr => DayFormatterUtils.formatDate(transaction.createdAt,
      format: 'dd MMMM yyyy');

  String get createAnotherText {
    if (isInbound) return TTexts.createAnotherInbound.tr;
    if (isOutbound) return TTexts.createAnotherOutbound.tr;
    if (isAdjustment) return TTexts.createAnotherAdjustment.tr;
    return TTexts.createNewTransaction.tr;
  }

  void createAnotherTransaction() {
    Get.until((route) => route.isFirst);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadAllHomeData();
    }
    if (Get.isRegistered<InventoryController>()) {
      // ĐÃ FIX: Đổi thành fetchDashboardData
      Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
    }

    if (isInbound) {
      Get.toNamed(AppRoutes.inboundTransaction);
    } else if (isOutbound) {
      Get.toNamed(AppRoutes.outboundTransaction);
    } else if (isAdjustment) {
      Get.toNamed(AppRoutes.stockAdjustment);
    }
  }

  void goToHome() {
    Get.until((route) => route.isFirst);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadAllHomeData();
    }
    if (Get.isRegistered<InventoryController>()) {
      // ĐÃ FIX: Đổi thành fetchDashboardData
      Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
    }
  }

  void openDetailsBottomSheet() {
    TBottomSheetWidget.show(
      title: TTexts.transactionDetails.tr,
      child: const TransactionSummaryDetailsBottomSheetWidget(),
    );
  }
}
