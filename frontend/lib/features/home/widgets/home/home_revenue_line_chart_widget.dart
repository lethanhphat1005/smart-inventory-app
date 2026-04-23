import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeRevenueLineChartWidget extends StatefulWidget {
  const HomeRevenueLineChartWidget({super.key});

  @override
  State<HomeRevenueLineChartWidget> createState() =>
      _HomeRevenueLineChartWidgetState();
}

class _HomeRevenueLineChartWidgetState extends State<HomeRevenueLineChartWidget>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<HomeController>();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final limits = controller.lineLimits;
      final spots = controller.lineChartSpots;

      if (spots.length < 2) return const SizedBox();

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          final progress = _animationController.value;

          final animatedSpots = _buildSegmentSpots(spots, progress);

          return LineChart(
            LineChartData(
              // ĐÃ FIX: Khóa cứng trục X là 24 tiếng để biểu đồ không bị dãn ngang
              minX: 0.0,
              maxX: 24.0,
              minY: limits['min'],
              maxY: limits['max'],

              // TOOLTIP
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primary,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                    return LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}k\$',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // GRID
              gridData: FlGridData(
                show: true,
                horizontalInterval: limits['interval'],
                drawVerticalLine: false,
              ),

              // TITLES
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: limits[
                        'interval'], // Sử dụng interval động từ Controller
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      // Logic định dạng nhãn thông minh
                      String label;
                      double absVal = value.abs();

                      if (absVal >= 1000000) {
                        label = '${(value / 1000000).toStringAsFixed(1)}M\$';
                      } else if (absVal >= 1000) {
                        label = '${(value / 1000).toStringAsFixed(1)}k\$';
                      } else {
                        label = '${value.toInt()}\$';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.subText,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 6, // Hiển thị các mốc cách nhau 6 tiếng
                    reservedSize: 25,
                    getTitlesWidget: _bottomTitles,
                  ),
                ),
              ),

              borderData: FlBorderData(show: false),

              // Line
              lineBarsData: [
                LineChartBarData(
                  spots: animatedSpots,
                  isCurved: false,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
            duration: Duration.zero,
          );
        },
      );
    });
  }

  // Core Logic Animation
  List<FlSpot> _buildSegmentSpots(List<FlSpot> spots, double progress) {
    final totalSegments = spots.length - 1;
    final segmentProgress = progress * totalSegments;

    List<FlSpot> result = [];

    for (int i = 0; i < totalSegments; i++) {
      final start = spots[i];
      final end = spots[i + 1];

      if (segmentProgress >= i + 1) {
        result.add(start);
      } else if (segmentProgress >= i) {
        final t = segmentProgress - i;

        final easedT = Curves.easeInOut.transform(t);

        final x = start.x + (end.x - start.x) * easedT;
        final y = start.y + (end.y - start.y) * easedT;

        result.add(start);
        result.add(FlSpot(x, y));
        break;
      } else {
        break;
      }
    }

    if (progress == 1) {
      return List.from(spots);
    }

    return result;
  }

  //  Tự động vẽ các mốc 00:00, 06:00, 12:00, 18:00
  Widget _bottomTitles(double val, TitleMeta meta) {
    if (val % 6 == 0 && val <= 24) {
      // Đổi 24h thành 00h cho chuẩn định dạng đồng hồ
      final hourStr =
          val.toInt() == 24 ? '00' : val.toInt().toString().padLeft(2, '0');
      return SideTitleWidget(
        meta: meta,
        space: 10,
        child: Text(
          '$hourStr:00',
          style: const TextStyle(fontSize: 10, color: AppColors.softGrey),
        ),
      );
    }
    return const SizedBox();
  }
}
