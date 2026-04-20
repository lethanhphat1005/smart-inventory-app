import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailStockStatsWidget extends StatefulWidget {
  const InventoryDetailStockStatsWidget({super.key});

  @override
  State<InventoryDetailStockStatsWidget> createState() =>
      _InventoryDetailStockStatsWidgetState();
}

class _InventoryDetailStockStatsWidgetState
    extends State<InventoryDetailStockStatsWidget> {
  final controller = Get.find<InventoryDetailController>();
  int? selectedChartIndex; // Lưu vị trí điểm đang được chạm/vuốt

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. HEADER & NÚT TOGGLE ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(TTexts.stockMovement.tr,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText)),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider)),
              child: Obx(() => Row(
                    children: [
                      _buildToggleBtn(
                          TTexts.data.tr,
                          Iconsax.data_copy,
                          !controller.isChartMode.value,
                          () => controller.toggleStatsMode(false)),
                      _buildToggleBtn(
                          TTexts.chart.tr,
                          Iconsax.chart_2_copy,
                          controller.isChartMode.value,
                          () => controller.toggleStatsMode(true)),
                    ],
                  )),
            )
          ],
        ),
        const SizedBox(height: AppSizes.p16),

        // --- 2. KHU VỰC HIỂN THỊ (DATA HOẶC CHART) ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Obx(() => controller.isChartMode.value
              ? _buildChartView()
              : _buildDataView()),
        ),
      ],
    );
  }

  // --- NÚT BẤM TOGGLE ---
  Widget _buildToggleBtn(
      String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: isActive ? AppColors.primaryText : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon,
                size: 14, color: isActive ? Colors.white : AppColors.subText),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.subText)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CHẾ ĐỘ 1: VIEW SỐ LIỆU (DATA)
  // ==========================================
  Widget _buildDataView() {
    return Obx(() => Row(
          children: [
            Expanded(
                child: _buildDataCard(TTexts.totalStockInTitle.tr,
                    "${controller.totalStockIn}", true)),
            const SizedBox(width: AppSizes.p12),
            Expanded(
                child: _buildDataCard(TTexts.totalStockOutTitle.tr,
                    "${controller.totalStockOut}", false)),
          ],
        ));
  }

  Widget _buildDataCard(String title, String value, bool isStockIn) {
    final color = isStockIn ? AppColors.stockIn : AppColors.alertText;
    final bgColor = isStockIn ? AppColors.toastSuccessBg : AppColors.alertBg;
    final icon = isStockIn ? Iconsax.arrow_down_copy : Iconsax.arrow_up_3_copy;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  // ==========================================
  // CHẾ ĐỘ 2: VIEW BIỂU ĐỒ ĐƯỜNG (LINE CHART)
  // ==========================================
  Widget _buildChartView() {
    if (controller.stockMovementData.isEmpty) return const SizedBox();
    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(
        children: [
          // Chú thích (Legend)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(TTexts.stockIn.tr, AppColors.stockIn),
              const SizedBox(width: 16),
              _buildLegendItem(TTexts.stockOut.tr, AppColors.alertText),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              // XỬ LÝ VUỐT/CHẠM VỚI VÙNG CHẠM CỰC RỘNG
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _updateSelectedIndex(
                    details.localPosition.dx, constraints.maxWidth),
                onHorizontalDragUpdate: (details) => _updateSelectedIndex(
                    details.localPosition.dx, constraints.maxWidth),
                onTapUp: (_) => setState(() => selectedChartIndex = null),
                onHorizontalDragEnd: (_) =>
                    setState(() => selectedChartIndex = null),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _LineChartPainter(
                        data: controller.stockMovementData,
                        colorIn: AppColors.stockIn,
                        colorOut: AppColors.alertText,
                        animationValue: value,
                        selectedIndex: selectedChartIndex,
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Trục X (Các ngày trong tuần)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: controller.stockMovementData.map((d) {
              return Text(d['day'],
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w600));
            }).toList(),
          ),
        ],
      ),
    );
  }

  // HÀM TÍNH TOÁN VỊ TRÍ CHẠM
  void _updateSelectedIndex(double dx, double width) {
    if (controller.stockMovementData.isEmpty) return;
    final stepX = width / (controller.stockMovementData.length - 1);
    int index = (dx / stepX).round();

    // Đảm bảo không bị out index
    if (index < 0) index = 0;
    if (index >= controller.stockMovementData.length) {
      index = controller.stockMovementData.length - 1;
    }

    if (selectedChartIndex != index) {
      setState(() => selectedChartIndex = index);
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.subText,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ==========================================
// PAINTER: GIỮ NGUYÊN GIAO DIỆN CŨ, THÊM HIGHLIGHT & TOOLTIP
// ==========================================
class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color colorIn;
  final Color colorOut;
  final double animationValue;
  final int? selectedIndex;

  _LineChartPainter({
    required this.data,
    required this.colorIn,
    required this.colorOut,
    required this.animationValue,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    int maxVal = data.fold<int>(
        0, (m, e) => math.max(m, math.max(e['in'] as int, e['out'] as int)));

    // XỬ LÝ KHÔNG CÓ DATA: CHO BIỂU ĐỒ NẰM SÁT ĐÁY
    if (maxVal == 0) maxVal = 1;

    final gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.4)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final stepX = size.width / (data.length - 1);

    final paintIn = Paint()
      ..color = colorIn
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintOut = Paint()
      ..color = colorOut
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathIn = Path();
    final pathOut = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final yIn =
          size.height - (data[i]['in'] / maxVal * size.height * animationValue);
      final yOut = size.height -
          (data[i]['out'] / maxVal * size.height * animationValue);

      if (i == 0) {
        pathIn.moveTo(x, yIn);
        pathOut.moveTo(x, yOut);
      } else {
        final prevX = (i - 1) * stepX;
        final prevYIn = size.height -
            (data[i - 1]['in'] / maxVal * size.height * animationValue);
        final prevYOut = size.height -
            (data[i - 1]['out'] / maxVal * size.height * animationValue);

        final controlX = prevX + (x - prevX) / 2;

        pathIn.cubicTo(controlX, prevYIn, controlX, yIn, x, yIn);
        pathOut.cubicTo(controlX, prevYOut, controlX, yOut, x, yOut);
      }
    }

    canvas.drawPath(pathIn, paintIn);
    canvas.drawPath(pathOut, paintOut);

    final dotPaintIn = Paint()
      ..color = colorIn
      ..style = PaintingStyle.fill;
    final dotPaintOut = Paint()
      ..color = colorOut
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // VẼ CÁC CHẤM TRÊN BIỂU ĐỒ VÀ TOOLTIP
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final yIn =
          size.height - (data[i]['in'] / maxVal * size.height * animationValue);
      final yOut = size.height -
          (data[i]['out'] / maxVal * size.height * animationValue);

      // Chấm mặc định
      canvas.drawCircle(Offset(x, yIn), 5, whitePaint);
      canvas.drawCircle(Offset(x, yIn), 3, dotPaintIn);
      canvas.drawCircle(Offset(x, yOut), 5, whitePaint);
      canvas.drawCircle(Offset(x, yOut), 3, dotPaintOut);

      if (selectedIndex == i) {
        // Highlight chấm (phóng to nhẹ khi chạm vào)
        canvas.drawCircle(Offset(x, yIn), 7, dotPaintIn);
        canvas.drawCircle(Offset(x, yOut), 7, dotPaintOut);
        canvas.drawCircle(Offset(x, yIn), 3, whitePaint);
        canvas.drawCircle(Offset(x, yOut), 3, whitePaint);

        // Vẽ nội dung Tooltip
        final textSpan = TextSpan(
          text:
              "${TTexts.chartTooltipIn.tr}: ${data[i]['in']}  |  ${TTexts.chartTooltipOut.tr}: ${data[i]['out']}",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        );
        final tpTooltip =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tpTooltip.layout();

        // Tính toán tọa độ để Tooltip luôn nằm gọn trong màn hình
        double tipX = x - tpTooltip.width / 2;
        if (tipX < 0) tipX = 0;
        if (tipX + tpTooltip.width > size.width) {
          tipX = size.width - tpTooltip.width;
        }

        double topY = math.min(yIn, yOut);
        double tipY = topY - tpTooltip.height - 14;
        if (tipY < 0) {
          tipY =
              math.max(yIn, yOut) + 14; // Nếu tràn mép trên thì nhét xuống dưới
        }

        // Vẽ khung nền Tooltip
        final bgRect = Rect.fromLTWH(
            tipX - 8, tipY - 6, tpTooltip.width + 16, tpTooltip.height + 12);
        canvas.drawRRect(
            RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
            Paint()..color = AppColors.primaryText.withOpacity(0.9));
        tpTooltip.paint(canvas, Offset(tipX, tipY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
