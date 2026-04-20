import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/widgets/report/report_calendar_widget.dart';
import 'package:frontend/features/report/widgets/report/report_date_header_widget.dart';
import 'package:frontend/features/report/widgets/report/report_filter_tabs_widget.dart';
import 'package:frontend/features/report/widgets/report/report_history_header_widget.dart';
import 'package:frontend/features/report/widgets/report/report_shimmer_widget.dart';
import 'package:frontend/features/report/widgets/report/report_transaction_card_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReportMobileView extends GetView<ReportController> {
  const ReportMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: TRefreshIndicatorWidget(
          onRefresh: () => controller.fetchTransactions(isRefresh: true),
          child: Obx(() {
            if (controller.isLoading.value) return const ReportShimmerWidget();

            final displayList = controller.filteredTransactions;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReportHistoryHeaderWidget(),
                  const SizedBox(height: 20),
                  const ReportFilterTabsWidget(),
                  const SizedBox(height: 24),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      layoutBuilder: (Widget? currentChild,
                          List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: controller.activeTab.value == 'Today'
                          ? const ReportDateHeaderWidget(
                              key: ValueKey('date_header'))
                          : const ReportCalendarWidget(
                              key: ValueKey('calendar_widget')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (displayList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TEmptyStateWidget(
                        icon: Iconsax.document_text_1_copy,
                        title: TTexts.reportEmptyTitle.tr,
                        subtitle: TTexts.reportEmptySubtitle.tr,
                      ),
                    )
                  else
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                      child: Column(
                        children: displayList.map((tx) {
                          Color themeColor = AppColors.primaryText;
                          String bottomLabel = TTexts.totalItemsTransaction.tr;

                          // Lấy type nguyên bản để check
                          final String typeLower = tx.type.toLowerCase();

                          if (typeLower == 'import') {
                            themeColor = AppColors.stockIn; // XANH LÁ TOÀN TẬP
                          } else if (typeLower == 'export') {
                            themeColor = AppColors.stockOut; // ĐỎ TOÀN TẬP
                          }

                          // Viết hoa chữ cái đầu cho đẹp UI (import -> Import)
                          final String displayType = tx.type.isNotEmpty
                              ? '${tx.type[0].toUpperCase()}${tx.type.substring(1).toLowerCase()}'
                              : TTexts.unknownProduct.tr;

                          final String itemCountDisplay = tx.itemCount > 0
                              ? tx.itemCount.toString()
                              : (tx.items.isNotEmpty
                                  ? tx.items.length.toString()
                                  : '0');

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.transactionDetail,
                                arguments: {'id': tx.transactionId},
                              );
                            },
                            child: ReportTransactionCardWidget(
                              transactionId: tx.transactionId ?? TTexts.na.tr,
                              dateStr:
                                  DayFormatterUtils.formatDate(tx.createdAt),
                              typeDisplay: displayType,
                              typeColor: themeColor,
                              leftBottomLabel: bottomLabel,
                              itemsDisplay: itemCountDisplay,
                              itemsColor: themeColor,
                              moneyDisplay:
                                  '\$${tx.totalPrice.toStringAsFixed(2)}',
                              moneyColor: themeColor,
                              isInbound: typeLower == 'import',
                              isOutbound: typeLower == 'export',
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: AppSizes.bottomNavSpacer),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
