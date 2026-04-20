import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/widgets/report/report_export_bottom_sheet_widget.dart';
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
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  TTexts.reportTransactionsOverview.tr,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
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
