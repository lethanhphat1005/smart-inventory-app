import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';

class ReportFilterTabsWidget extends GetView<ReportController> {
  const ReportFilterTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTab(
                  logicKey: 'Today',
                  displayText: TTexts.reportTabToday.tr,
                  isActive: controller.activeTab.value == 'Today',
                ),
                const SizedBox(width: 12),
                _buildTab(
                  logicKey: 'Calendar',
                  displayText: TTexts.reportTabCalendar.tr,
                  isActive: controller.activeTab.value == 'Calendar',
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildTab({
    required String logicKey,
    required String displayText,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(logicKey),
      child: Container(
        // Trả lại padding nguyên bản đẹp đẽ của bạn
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gradientBlackStart,
                    AppColors.gradientBlackEnd
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.softGrey.withOpacity(0.3)),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            color: isActive ? Colors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
