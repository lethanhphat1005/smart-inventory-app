import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart'; 
import 'package:frontend/routes/app_routes.dart';

class TBarcodePrefillBottomSheet {
  static void show(
      {required String barcode, required Map<String, dynamic> prefill}) {
    final name = prefill['name'] ?? TTexts.barcodeUnknown.tr;
    final brand = prefill['brand'] ?? TTexts.barcodeUnknown.tr;

    TBottomSheetWidget.show(
      title: TTexts.barcodePrefillTitle.tr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TTexts.barcodePrefillDesc.tr,
              style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: AppSizes.p14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THÊM NÚT COPY VÀO ĐÂY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${TTexts.barcodeLabel.tr}: $barcode',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText)),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: barcode));
                          TSnackbarsWidget.success(
                              title: TTexts.successTitle.tr,
                              message: TTexts.barcodeCopied.tr);
                        },
                        child: const Icon(Icons.copy_rounded,
                            color: AppColors.primary, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text('${TTexts.productName.tr}: $name',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16)),
                  const SizedBox(height: AppSizes.p8),
                  Text('${TTexts.brand.tr}: $brand',
                      style: const TextStyle(
                          color: AppColors.subText,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
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
                    'freshName': name,
                    'freshBrand': brand,
                    'barcode': barcode,
                  });
                },
                child: Text(TTexts.barcodeAddToStoreBtn.tr,
                    style: const TextStyle(
                        color: AppColors.whiteText,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
