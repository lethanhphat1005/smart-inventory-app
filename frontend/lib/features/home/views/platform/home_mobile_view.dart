import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/home/widgets/home/home_adjustment_stats_widget.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/home/widgets/home/home_header_widget.dart';
import 'package:frontend/features/home/widgets/home/home_quick_actions_widget.dart';
import 'package:frontend/features/home/widgets/home/home_revenue_chart_widget.dart';
import 'package:frontend/features/home/widgets/home/home_daily_summary_widget.dart';
import 'package:frontend/features/home/widgets/home/home_low_stock_alerts_widget.dart';
import 'package:frontend/features/home/widgets/home/home_transaction_list_widget.dart';
import 'package:frontend/features/home/widgets/home/home_shimmer_widget.dart';

class HomeMobileScreen extends GetView<HomeController> {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: TRefreshIndicatorWidget(
          onRefresh: () async {
            await controller.loadAllHomeData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.p32),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const HomeShimmerWidget();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeaderWidget(),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSizes.p8),
                          const HomeRevenueChartWidget(),
                          const SizedBox(height: AppSizes.p32),
                          const HomeQuickActionsWidget(),
                          const SizedBox(height: AppSizes.p32),
                          Text(
                            TTexts.homeDailyOverview.tr,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText),
                          ),
                          const SizedBox(height: AppSizes.p12),
                          const HomeDailySummaryWidget(),
                          const SizedBox(height: AppSizes.p24),
                          if (controller.todayAdjustments.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: AppSizes.p24),
                              child: HomeAdjustmentStatsWidget(),
                            ),
                          if (controller.lowStockItems.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: AppSizes.p24),
                              child: HomeLowStockAlertsWidget(),
                            ),
                          if (controller.recentTransactions.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radius24),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: AppSizes.p20,
                                      top: AppSizes.p20,
                                      right: AppSizes.p20,
                                      bottom:
                                          controller.recentTransactions.length >
                                                  3
                                              ? 60
                                              : AppSizes.p20,
                                    ),
                                    child: const HomeTransactionListWidget(),
                                  ),
                                  if (controller.recentTransactions.length > 3)
                                    TCustomFadeOverlayWidget(
                                      text: TTexts.homeTapToViewMoreHistory.tr,
                                      onTap: () {
                                        Get.find<NavigationController>()
                                            .changeIndex(3);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          const TBottomNavSpacerWidget(),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
