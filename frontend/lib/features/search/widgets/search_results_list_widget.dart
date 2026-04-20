import 'package:flutter/material.dart';
import 'package:frontend/features/search/widgets/search_filter_chips_widget.dart';
import 'package:frontend/features/report/widgets/report/report_transaction_card_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/search/widgets/search_history_widget.dart';
import 'package:frontend/features/search/widgets/search_simple_item_widget.dart';

class SearchResultsListWidget extends GetView<TSearchController> {
  const SearchResultsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Nếu đang Loading (Gọi API)
      if (controller.isSearching.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      // 2. Nếu ô search trống (Và không phải màn hình Transaction) -> Hiện Lịch sử
      if (controller.currentSearchQuery.value.isEmpty &&
          !controller.isTransactionSearch) {
        return const SingleChildScrollView(child: SearchHistoryWidget());
      }

      // Xác định mảng hiển thị dựa trên Target
      final bool isListEmpty = controller.isTransactionSearch
          ? controller.searchTransactionResults.isEmpty
          : controller.searchResults.isEmpty;
      final int listLength = controller.isTransactionSearch
          ? controller.searchTransactionResults.length
          : controller.searchResults.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CHIPS LỌC ---
          if (controller.isTransactionSearch) const SearchFilterChipsWidget(),

          // --- THANH GỢI Ý (Did you mean) ---
          if (controller.suggestion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: InkWell(
                onTap: controller.applySuggestion,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.magic_star_copy,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: '${TTexts.didYouMean.tr} ',
                            style: const TextStyle(
                                color: AppColors.primaryText, fontSize: 14),
                            children: [
                              TextSpan(
                                text: '"${controller.suggestion.value}"',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                              const TextSpan(
                                  text: ' ?',
                                  style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.primary.withOpacity(0.7), size: 14),
                    ],
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '$listLength ${TTexts.resultsFound.tr}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.subText,
              ),
            ),
          ),

          // --- DANH SÁCH HOẶC EMPTY STATE ---
          Expanded(
            child: isListEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TEmptyStateWidget(
                      icon: controller.isTransactionSearch
                          ? Iconsax.receipt_search_copy
                          : Iconsax.box_search_copy,
                      title: controller.isTransactionSearch
                          ? TTexts.noTransactionsFound.tr
                          : TTexts.noResultsFound.tr,
                      subtitle: TTexts.errorNotFoundMessage.tr,
                    ),
                  )
                : ListView.separated(
                    controller: controller.scrollController,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    itemCount: listLength + 1,
                    separatorBuilder: (_, __) => controller.isTransactionSearch
                        ? const SizedBox(height: 12)
                        : const Divider(
                            height: 1,
                            indent: 72,
                            endIndent: 20,
                            color: AppColors.surface),
                    itemBuilder: (context, index) {
                      if (index == listLength) {
                        return controller.isLoadingMore.value
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : const SizedBox(height: 80);
                      }

                      // --- RENDER GIAO DỊCH ---
                      if (controller.isTransactionSearch) {
                        final tx = controller.searchTransactionResults[index];
                        final String typeLower = tx.type.toLowerCase();

                        Color themeColor = AppColors.primaryText;
                        String bottomLabel = 'Total Items / Transaction';

                        if (typeLower == 'import') {
                          themeColor = AppColors.stockIn;
                        } else if (typeLower == 'export') {
                          themeColor = AppColors.stockOut;
                        } else {
                          themeColor = const Color(0xFFFF9900);
                          bottomLabel = 'Check Items / Stock Stats';
                        }

                        final String displayType = tx.type.isNotEmpty
                            ? '${tx.type[0].toUpperCase()}${tx.type.substring(1).toLowerCase()}'
                            : 'Unknown';

                        final String itemCountDisplay = tx.itemCount > 0
                            ? tx.itemCount.toString()
                            : (tx.items.isNotEmpty
                                ? tx.items.length.toString()
                                : '0');

                        return GestureDetector(
                          onTap: () => controller.handleItemTap(tx),
                          child: ReportTransactionCardWidget(
                            transactionId: tx.transactionId ?? 'N/A',
                            dateStr: tx.createdAt != null
                                ? '${tx.createdAt!.day}/${tx.createdAt!.month}/${tx.createdAt!.year}'
                                : 'N/A',
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
                      }

                      // --- RENDER SẢN PHẨM ---
                      final displayItem = controller.searchResults[index];
                      return SearchSimpleItemWidget(
                        displayItem: displayItem,
                        onTap: () => controller.handleItemTap(displayItem),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
