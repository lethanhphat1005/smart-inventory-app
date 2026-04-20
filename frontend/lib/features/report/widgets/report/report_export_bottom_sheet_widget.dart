import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/features/report/controllers/report_export_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart'; 
import 'package:get/get.dart';

class ReportExportBottomSheetWidget extends GetView<ReportExportController> {
  final List<TransactionModel> transactions;
  final String dateStr;

  const ReportExportBottomSheetWidget(
      {super.key, required this.transactions, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isExporting.value) {
        final percent = (controller.exportProgress.value * 100).toInt();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: AppColors.softGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radius16)),
              child: const Center(
                  child: Text("🖨", style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 24),
            Text(
                TTexts.exportingProgress.trParams(
                    {'percent': percent.toString()}), 
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText)),
            const SizedBox(height: 8),
            Text(controller.exportStatus.value,
                style: const TextStyle(fontSize: 13, color: AppColors.subText)),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: controller.exportProgress.value,
                minHeight: 8,
                backgroundColor: AppColors.softGrey.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.softGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius16)),
            child:
                const Center(child: Text("🖨", style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          Text(TTexts.exportDailyReport.tr, 
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              TTexts.exportDailyReportDesc.trParams({
                'count': transactions.length.toString(),
                'date': dateStr,
              }), 
              style: const TextStyle(
                  fontSize: 13, color: AppColors.subText, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side:
                        BorderSide(color: AppColors.softGrey.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(TTexts.cancel.tr,
                      style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      controller.exportDailyTransactions(transactions, dateStr),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(TTexts.export.tr, // 🔥 Đã đổi TTexts
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          )
        ],
      );
    });
  }
}
