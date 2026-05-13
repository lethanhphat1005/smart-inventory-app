import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeRevenueBarChartWidget extends StatefulWidget {
  const HomeRevenueBarChartWidget({super.key});

  @override
  State<HomeRevenueBarChartWidget> createState() =>
      _HomeRevenueBarChartWidgetState();
}

class _HomeRevenueBarChartWidgetState extends State<HomeRevenueBarChartWidget> {
  final controller = Get.find<HomeController>();

  List<double> _displayData = [];

  @override
  void initState() {
    super.initState();

    // init toàn bộ = 0
    final data = controller.weeklyBarData;
    _displayData = List.filled(data.length, 0);

    // delay 1 frame rồi animate lên
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _displayData = List.from(controller.weeklyBarData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final limits = controller.barLimits;

      return BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, x, rod, y) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}k\$',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          alignment: BarChartAlignment.spaceAround,
          minY: limits['min'],
          maxY: limits['max'],

          gridData: FlGridData(
            show: true,
            horizontalInterval: limits['interval'],
            drawVerticalLine: false,
          ),

          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: limits['interval'],
                getTitlesWidget: (value, meta) {
                  double realValue = value * 1000;
                  double absVal = realValue.abs();
                  String sign = realValue < 0 ? '-' : '';

                  String label;
                  if (absVal >= 1000000) {
                    label =
                        '$sign\$${(absVal / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
                  } else if (absVal >= 1000) {
                    label =
                        '$sign\$${(absVal / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
                  } else {
                    label = '$sign\$${absVal.toInt()}';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: AppColors.subText,
                        fontSize: 10,
                        fontFamily: AppFonts.mainFont,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: _bottomTitles,
              ),
            ),
          ),

          borderData: FlBorderData(show: false),

          // Data animation
          barGroups: _displayData.asMap().entries.map((e) {
            final isNeg = e.value < 0;

            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 14,
                  color: isNeg ? AppColors.stockOut : AppColors.stockIn,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),

        // Key animation
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    // ĐÃ THÊM: Kiểm tra xem app đang dùng tiếng Việt hay tiếng Anh
    final isVi = Get.locale?.languageCode == 'vi';

    // ĐÃ THÊM: Gán mảng ngày tương ứng
    final days = isVi
        ? ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    if (value < 0 || value >= 7) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        days[value.toInt()],
        style: TextStyle(
          color: AppColors.subText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.mainFont,
        ),
      ),
    );
  }
}
