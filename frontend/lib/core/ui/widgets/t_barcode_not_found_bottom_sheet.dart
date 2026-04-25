import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/routes/app_routes.dart';

class TBarcodeNotFoundBottomSheet {
  static void show({required String barcode}) {
    TBottomSheetWidget.show(
      title: TTexts.barcodeNoDataTitle.tr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TTexts.barcodeNoDataDesc.tr,
              style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: AppSizes.p14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: AppSizes.p16),

            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.p12, horizontal: AppSizes.p16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),

                  // Mã vạch ở giữa
                  Expanded(
                    child: Text(
                      barcode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 2.0,
                          color: AppColors.primaryText),
                    ),
                  ),

                  // Nút copy
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: barcode));
                      TSnackbarsWidget.success(
                        title: TTexts.successTitle.tr,
                        message: TTexts.barcodeCopied.tr,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // --------------------------------------------------------

            const SizedBox(height: AppSizes.p24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12)),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                ),
                onPressed: () {
                  Get.back();
                  Get.back();
                  Get.toNamed(AppRoutes.productForm, arguments: {
                    'mode': 'create',
                    'barcode': barcode,
                  });
                },
                child: Text(TTexts.barcodeAddNewBtn.tr,
                    style: const TextStyle(
                        color: AppColors.whiteText,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    ).whenComplete(() {
      if (Get.isRegistered<BarcodeScannerController>()) {
        BarcodeScannerController.instance.resumeScan();
      }
    });
  }
}
