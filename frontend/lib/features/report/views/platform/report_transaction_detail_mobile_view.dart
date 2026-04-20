import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/report/controllers/report_transaction_detail_controller.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_export_bottom_sheet_widget.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_info_card_widget.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_item_card_widget.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_shimmer_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class ReportTransactionDetailView
    extends GetView<ReportTransactionDetailController> {
  const ReportTransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double topOffset = topPadding + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.transactionDetails.tr,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download_copy,
                color: AppColors.primaryText),
            onPressed: () {
              if (controller.transaction.value != null) {
                TBottomSheetWidget.show(
                  child: ReportTransactionExportBottomSheetWidget(
                    transaction: controller.transaction.value!,
                  ),
                );
              }
            },
          )
        ],
      ),
      body: TRefreshIndicatorWidget(
        onRefresh: () => controller.fetchTransactionDetail(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return ReportTransactionDetailShimmerWidget(topOffset: topOffset);
          }

          final tx = controller.transaction.value;
          if (tx == null) {
            return Center(child: Text(TTexts.transactionDetailsNotFound.tr));
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topOffset + 24)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                sliver: SliverToBoxAdapter(
                    child: ReportTransactionDetailInfoCardWidget(tx: tx)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.p20, 32, AppSizes.p20, 16),
                  child: Text(TTexts.items.tr,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = tx.items[index];
                      return ReportTransactionDetailItemCardWidget(item: item);
                    },
                    childCount: tx.items.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        }),
      ),
      bottomSheet: Obx(() {
        if (controller.isLoading.value ||
            controller.transaction.value == null) {
          return const SizedBox.shrink();
        }
        final tx = controller.transaction.value!;

        final totalQty = tx.type.toLowerCase() == 'adjustment'
            ? tx.items.length
            : tx.items
                .fold(0, (sum, item) => sum + item.quantity.abs().toInt());

        final moneyFormatted =
            NumberFormat.currency(locale: 'en_US', symbol: '\$')
                .format(tx.totalPrice);

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(TTexts.totalItems.tr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('$totalQty',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(TTexts.totalAmount.tr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(moneyFormatted,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
