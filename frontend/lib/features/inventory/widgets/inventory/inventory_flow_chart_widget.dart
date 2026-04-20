import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryFlowChartWidget extends GetView<InventoryController> {
  InventoryFlowChartWidget({super.key}) {
    Future.delayed(const Duration(milliseconds: 150), () {
      _isAnimated.value = true;
    });
  }

  final RxBool _isAnimated = false.obs;
  final List<double> _zeros = List.filled(7, 0.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.stockFlow.tr,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              // Nút Detail được tạm ẩn theo yêu cầu
            ],
          ),
          const SizedBox(height: 4),
          Text(TTexts.inboundOutbound7Days.tr,
              style: const TextStyle(color: AppColors.subText, fontSize: 12)),
          const SizedBox(height: AppSizes.p24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: _buildBarChart(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => _buildBottomStat(
                  TTexts.totalItemsTransaction.tr,
                  "${controller.totalActiveProducts.value}",
                  AppColors.primaryText)),
              Obx(() => _buildBottomStat(TTexts.flowIn.tr,
                  "+${controller.weeklyInbound.value}", AppColors.stockIn)),
              Obx(() => _buildBottomStat(TTexts.flowOut.tr,
                  "-${controller.weeklyOutbound.value}", AppColors.stockOut)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.subText,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  Widget _buildBarChart() {
    return Obx(() {
      final currentInbound =
          _isAnimated.value ? controller.inboundFlow : _zeros;
      final currentOutbound =
          _isAnimated.value ? controller.outboundFlow : _zeros;

      final maxIn = currentInbound.isEmpty
          ? 0.0
          : currentInbound.reduce((a, b) => a > b ? a : b);
      final maxOut = currentOutbound.isEmpty
          ? 0.0
          : currentOutbound.reduce((a, b) => a > b ? a : b);
      final chartMaxY = (maxIn > maxOut ? maxIn : maxOut) * 1.2;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: chartMaxY < 10 ? 10 : chartMaxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipColor: (group) =>
                  AppColors.primaryText.withOpacity(0.85),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final inVal = currentInbound[groupIndex].toInt();
                final outVal = currentOutbound[groupIndex].toInt();
                
                return BarTooltipItem(
                  '${TTexts.chartTooltipIn.tr}: $inVal\n${TTexts.chartTooltipOut.tr}: $outVal',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final now = DateTime.now();
                  final days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  final labels = <String>[];
                  for (int i = 6; i >= 0; i--) {
                    final date = now.subtract(Duration(days: i));
                    labels.add(days[date.weekday - 1]);
                  }

                  int index = value.toInt();
                  if (index < 0 || index > 6) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(labels[index],
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.softGrey,
                            fontWeight: FontWeight.w600)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: chartMaxY > 50 ? (chartMaxY / 4).roundToDouble() : 10,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text("${value.toInt()}",
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.softGrey));
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                chartMaxY > 50 ? (chartMaxY / 4).roundToDouble() : 10,
            getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.softGrey.withOpacity(0.1), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: currentInbound.asMap().entries.map((e) {
            int index = e.key;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                    toY: currentInbound[index],
                    color: AppColors.stockIn,
                    width: 6,
                    borderRadius: BorderRadius.circular(2)),
                BarChartRodData(
                    toY: currentOutbound[index],
                    color: AppColors.stockOut,
                    width: 6,
                    borderRadius: BorderRadius.circular(2)),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 1200),
        swapAnimationCurve: Curves.easeOutCubic,
      );
    });
  }
}
