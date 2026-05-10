import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:get/get.dart';

class ReportDateHeaderWidget extends GetView<ReportController> {
  const ReportDateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.currentDateStr,
            style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 34,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 2),
          Text(
            controller.currentDayStr,
            style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 18,
                color: AppColors.subText.withOpacity(0.8),
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
