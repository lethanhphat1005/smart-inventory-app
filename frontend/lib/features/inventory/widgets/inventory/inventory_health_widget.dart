import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryHealthWidget extends GetView<InventoryController> {
  const InventoryHealthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.stockHealth.tr,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.subText,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final healthPercent = controller.stockHealthPercent.value;
          final hCount = controller.healthyCount.value;
          final lCount = controller.lowCount.value;
          final oCount = controller.outCount.value;
          final total = hCount + lCount + oCount;

          final hFlex = total == 0 ? 0 : (hCount / total * 100).toInt();
          final lFlex = total == 0 ? 0 : (lCount / total * 100).toInt();
          final oFlex = total == 0 ? 0 : (oCount / total * 100).toInt();

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: healthPercent),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutExpo,
                    builder: (context, value, child) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppFonts.mainFont,
                            height: 1),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 2),
                    child: Text("%",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.softGrey)),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(AppColors.stockIn,
                          "${TTexts.statusHealthy.tr} ($hCount)"),
                      const SizedBox(height: 4),
                      _buildLegend(AppColors.primary,
                          "${TTexts.statusLow.tr} ($lCount)"),
                      const SizedBox(height: 4),
                      _buildLegend(AppColors.alertText,
                          "${TTexts.statusOut.tr} ($oCount)"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    if (hFlex > 0)
                      Expanded(
                          flex: hFlex,
                          child:
                              Container(height: 6, color: AppColors.stockIn)),
                    if (lFlex > 0)
                      Expanded(
                          flex: lFlex,
                          child:
                              Container(height: 6, color: AppColors.primary)),
                    if (oFlex > 0)
                      Expanded(
                          flex: oFlex,
                          child:
                              Container(height: 6, color: AppColors.alertText)),
                    if (total == 0)
                      Expanded(
                          child: Container(
                              height: 6,
                              color: AppColors.softGrey.withOpacity(0.2))),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.subText)),
      ],
    );
  }
}
