import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InventoryDetailHealthWidget extends GetView<InventoryDetailController> {
  const InventoryDetailHealthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final healthColor = controller.stockHealthColor;
    final healthRatio = controller.stockHealthRatio;
    final healthPercent = (healthRatio * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: healthColor.withOpacity(0.1),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.surface)),
              CircularProgressIndicator(
                  value: healthRatio,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  strokeCap: StrokeCap.round),
              Center(
                child: Text("$healthPercent%",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.mainFont,
                        color: AppColors.primaryText)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Text(controller.statusText.toUpperCase(),
              style: TextStyle(
                  color: healthColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.5)),
        ),
      ],
    );
  }
}
