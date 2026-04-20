import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/transaction/widgets/transaction_summary/transaction_summary_details_bottom_sheet_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
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
    if (isAdjustment) return const Color(0xFFFF9900);
    return AppColors.primaryText;
  }

  // Số lượng Items
  int get totalItems {
    if (isAdjustment) {
      return transaction.items.length;
    }
    return transaction.items.fold(0, (sum, item) => sum + item.quantity.abs());
  }

  // Giao diện y hệt Report: Bỏ dấu +/-
  String get itemsDisplay => totalItems.toString();
  Color get itemsColor => themeColor;

  // Tiền: Bỏ dấu +/- lằng nhằng, dùng chung màu chủ đạo
  double get rawTotal => transaction.totalPrice;
  String get moneyDisplay => '\$${rawTotal.abs().toStringAsFixed(2)}';
  Color get moneyColor => themeColor;

  // Loại giao dịch
  Color get typeColor => themeColor;
  String get typeDisplay {
    if (isInbound) return TTexts.inbound.tr;
    if (isOutbound) return TTexts.outbound.tr;
    if (isAdjustment) return TTexts.stockAdjustment.tr;

    // Viết hoa chữ cái đầu cho đẹp
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

  void goToHome() {
    Get.until((route) => route.isFirst);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadAllHomeData();
    }
  }

  void openDetailsBottomSheet() {
    TBottomSheetWidget.show(
      title: TTexts.transactionDetails.tr,
      child: const TransactionSummaryDetailsBottomSheetWidget(),
    );
  }
}
