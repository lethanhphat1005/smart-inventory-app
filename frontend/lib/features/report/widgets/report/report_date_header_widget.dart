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
    // Kiểm tra nếu là Tiếng Việt
    final isVi = Get.locale?.languageCode == 'vi';

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
              // LOGIC MỚI: Tiếng Việt dài nên giảm còn 24, Tiếng Anh giữ 34
              fontSize: isVi ? 24 : 34,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            controller.currentDayStr,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 16,
              color: AppColors.subText.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
