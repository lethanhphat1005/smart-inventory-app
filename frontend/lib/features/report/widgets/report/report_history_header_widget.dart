import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/widgets/report/report_export_bottom_sheet_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class ReportHistoryHeaderWidget extends StatelessWidget {
  const ReportHistoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final reportCtrl = Get.find<ReportController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.p16, AppSizes.p24, AppSizes.p16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.reportHistory.tr,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final count = reportCtrl.filteredTransactions.length;

                  final now = DateTime.now();
                  final selectedDate = reportCtrl.selectedDay.value;

                  // Đưa cả 2 về cùng thời điểm 00:00:00 để so sánh chuẩn số ngày
                  final today = DateTime(now.year, now.month, now.day);
                  final selected = DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day);

                  final difference = selected.difference(today).inDays;

                  String timeLabel;
                  if (difference == 0) {
                    timeLabel = TTexts.today.tr.toLowerCase();
                  } else if (difference == 1) {
                    timeLabel = TTexts.tomorrow.tr.toLowerCase();
                  } else if (difference == -1) {
                    timeLabel = TTexts.yesterday.tr.toLowerCase();
                  } else {
                    // Mặc định hiển thị dạng 25 Apr 2026
                    timeLabel = DateFormat('dd MMM yyyy').format(selectedDate);
                  }

                  return Text(
                    "$count ${TTexts.reportTransactionsOverview.tr} $timeLabel",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subText),
                  );
                }),
              ],
            ),
          ),

          // --- NÚT SEARCH TRANSACTION ---
          InkWell(
            onTap: () =>
                Get.toNamed(AppRoutes.search, arguments: 'transaction'),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.softGrey.withOpacity(0.2),
                ),
              ),
              child: const Icon(Iconsax.search_normal_copy,
                  color: AppColors.primaryText, size: 22),
            ),
          ),

          const SizedBox(width: AppSizes.p12),

          // --- NÚT EXPORT ---
          InkWell(
            onTap: () {
              final currentList = reportCtrl.filteredTransactions;
              if (currentList.isEmpty) {
                TSnackbarsWidget.error(
                  title: TTexts.exportFailedTitle.tr,
                  message: TTexts.exportFailedMessage.tr,
                );
                return;
              }

              final String dateStr = reportCtrl.activeTab.value == 'Today'
                  ? 'Today'
                  : DateFormat('dd/MM/yyyy')
                      .format(reportCtrl.selectedDay.value);

              TBottomSheetWidget.show(
                child: ReportExportBottomSheetWidget(
                  transactions: currentList,
                  dateStr: dateStr,
                ),
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondPrimary],
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Iconsax.document_download_copy,
                  color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
