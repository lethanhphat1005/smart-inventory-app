import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'home_revenue_line_chart_widget.dart';
import 'home_revenue_bar_chart_widget.dart';

class HomeRevenueChartWidget extends StatefulWidget {
  const HomeRevenueChartWidget({super.key});

  @override
  State<HomeRevenueChartWidget> createState() => _HomeRevenueChartWidgetState();
}

class _HomeRevenueChartWidgetState extends State<HomeRevenueChartWidget> {
  bool isLineChart = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final amount =
            isLineChart ? controller.todayRevenue : controller.thisWeekRevenue;
        final change = isLineChart
            ? controller.todayChangePercent
            : controller.weekChangePercent;
        final compareText =
            isLineChart ? TTexts.homeVsYesterday.tr : TTexts.homeThisWeek.tr;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.p12),
            Text("\$${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p8),
            _buildChangeIndicator(change, compareText),
            const SizedBox(height: AppSizes.p32),
            SizedBox(
                height: 220,
                child: isLineChart
                    ? const HomeRevenueLineChartWidget()
                    : const HomeRevenueBarChartWidget()),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            isLineChart
                ? TTexts.homeTodaysRevenue.tr
                : TTexts.homeProfitLossWeek.tr,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 15, color: AppColors.subText)),
        _buildToggleButtons(),
      ],
    );
  }

  Widget _buildChangeIndicator(double percent, String label) {
    final isUp = percent >= 0;
    final color = isUp ? AppColors.stockIn : AppColors.stockOut;
    return Row(
      children: [
        Icon(isUp ? Icons.trending_up : Icons.trending_down,
            color: color, size: 16),
        const SizedBox(width: 4),
        Text("${isUp ? '+' : ''}${percent.toStringAsFixed(1)}%",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.softGrey,
                fontSize: 13)),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _toggleBtn(Icons.show_chart, isLineChart,
              () => setState(() => isLineChart = true)),
          _toggleBtn(Icons.bar_chart, !isLineChart,
              () => setState(() => isLineChart = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool active, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6)),
        child: Icon(icon,
            size: 20,
            color: active ? AppColors.primaryText : AppColors.softGrey),
      ),
    );
  }
}
