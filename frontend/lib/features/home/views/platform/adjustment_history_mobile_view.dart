import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/home/controllers/adjustment_history_controller.dart';
import 'package:frontend/features/home/widgets/adjustment_history/adjustment_history_filter_chips_widget.dart';
import 'package:frontend/features/home/widgets/adjustment_history/adjustment_history_item_widget.dart';
import 'package:frontend/features/home/widgets/adjustment_history/adjustment_history_search_bar_widget.dart';
import 'package:frontend/features/home/widgets/adjustment_history/adjustment_history_skeleton_widget.dart'; // ĐÃ THÊM SKELETON
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AdjustmentHistoryMobileView extends GetView<AdjustmentHistoryController> {
  const AdjustmentHistoryMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: TTexts.adjustmentHistoryTitle.tr,
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p20, vertical: 12),
            color: AppColors.white,
            child: Obx(() => AdjustmentHistorySearchBarWidget(
                  hintText: TTexts.searchAdjustmentHint.tr,
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  onCalendarTap: () => controller.pickDate(context),
                  hasDateFilter: controller.selectedDate.value != null,
                )),
          ),

          // 2. CHIP BỘ LỌC
          const AdjustmentHistoryFilterChipsWidget(),

          // 3. DANH SÁCH (BỌC REFRESH INDICATOR)
          Expanded(
            child: Obx(() {
              // 1. Trạng thái Loading (Hiện Shimmer)
              if (controller.isLoading.value) {
                return TRefreshIndicatorWidget(
                  onRefresh: () => controller.fetchLogs(isRefresh: true),
                  child:
                      const AdjustmentHistorySkeletonWidget(), // Dùng Skeleton của bạn
                );
              }

              if (controller.logs.isEmpty) {
                return TRefreshIndicatorWidget(
                  onRefresh: () => controller.fetchLogs(isRefresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: TEmptyStateWidget(
                        icon: Iconsax.document_filter_copy,
                        title: TTexts.noAdjustmentsFound.tr,
                        subtitle: TTexts.noAdjustmentsFoundDesc.tr,
                      ),
                    ),
                  ),
                );
              }
              final groupedData = controller.groupedLogs;
              final dates = groupedData.keys.toList();

              return TRefreshIndicatorWidget(
                onRefresh: () async =>
                    await controller.fetchLogs(isRefresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 50) {
                      controller.onLoadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        dates.length + (controller.isLoadMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == dates.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: TAnimationLoaderWidget(
                              text: TTexts.loading.tr,
                              showBackground: false,
                            ),
                          ),
                        );
                      }

                      final dateKey = dates[index];
                      final dailyLogs = groupedData[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: Text(
                              controller.formatDateHeader(dateKey),
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText),
                            ),
                          ),
                          ...dailyLogs.map((log) => AdjustmentHistoryItemWidget(
                                model: log,
                                onTap: () =>
                                    controller.openDetails(log),
                              )),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
