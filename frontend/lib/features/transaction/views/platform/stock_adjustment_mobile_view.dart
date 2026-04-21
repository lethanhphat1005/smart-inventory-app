import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_editable_search_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment/stock_adjustment_fab_widget.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment/stock_adjustment_item_card_widget.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment/stock_adjustment_additional_note_widget.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment/stock_adjustment_bottom_bar_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StockAdjustmentMobileView extends GetView<StockAdjustmentController> {
  const StockAdjustmentMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          controller.handleExit();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: TAppBarWidget(
            title: TTexts.stockAdjustment.tr,
            showBackArrow: true,
            onBackPress: controller.handleExit,
            centerTitle: true,
          ),
          floatingActionButton: StockAdjustmentFabWidget(
            onCheckAll: controller.checkAllUncheckedItems,
            onUncheckAll: controller.uncheckAllItems,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: TEditableSearchBarWidget(
                    hintText: TTexts.searchHint.tr,
                    controller: controller.searchController,
                    onChanged: controller.filterItems,
                    onScanTap: controller.openScanner,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p20, vertical: 8),
                  child: Text(TTexts.listItems.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryText)),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.filteredItems.isEmpty) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: TEmptyStateWidget(
                          icon: Iconsax.search_normal_1_copy,
                          title: TTexts.noItemsFound.tr,
                          subtitle: TTexts.noItemsFoundDesc.tr,
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.p20, 0, AppSizes.p20, 80),
                      itemCount: controller.filteredItems.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == controller.filteredItems.length) {
                          return const StockAdjustmentAdditionalNoteWidget();
                        }
                        final item = controller.filteredItems[index];
                        final originalIndex =
                            controller.allItems.indexOf(item) + 1;
                        return StockAdjustmentItemCardWidget(
                            item: item, index: originalIndex);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const StockAdjustmentBottomBarWidget(),
        ));
  }
}
