import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TBarcodePrefillBottomSheet extends StatelessWidget {
  final String barcode;
  final Map<String, dynamic> prefill;

  const TBarcodePrefillBottomSheet({
    super.key,
    required this.barcode,
    required this.prefill,
  });

  static void show(
      {required String barcode, required Map<String, dynamic> prefill}) {
    Get.bottomSheet(
      TBarcodePrefillBottomSheet(barcode: barcode, prefill: prefill),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      if (Get.isRegistered<BarcodeScannerController>()) {
        BarcodeScannerController.instance.resumeScan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = prefill['name'] ?? TTexts.barcodeUnknown.tr;
    final brand = prefill['brand'] ?? TTexts.barcodeUnknown.tr;

    return TBottomSheetWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon Header
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Iconsax.magic_star_copy,
                  color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // 2. Title
          Text(
            TTexts.barcodePrefillTitle.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: AppSizes.p8),

          // 3. Subtitle
          Text(
            TTexts.barcodePrefillDesc.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // 4. Barcode Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.barcode_copy,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      barcode,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primaryText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: barcode));
                    TSnackbarsWidget.success(
                        title: TTexts.successTitle.tr,
                        message: TTexts.barcodeCopied.tr);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.copy_rounded,
                        color: AppColors.primary, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // 5. Product Details Card
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.branding_watermark_outlined,
                              color: AppColors.subText, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${TTexts.brand.tr}: $brand',
                              style: const TextStyle(
                                color: AppColors.subText,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p32),

          // 6. Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.softGrey),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius12)),
                  ),
                  child: Text(
                    TTexts.cancel.tr,
                    style: const TextStyle(
                        color: AppColors.softGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              Expanded(
                flex: 2, // Cho nút chính to hơn
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.add_square_copy,
                          color: AppColors.whiteText, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        TTexts.barcodeAddToStoreBtn.tr,
                        style: const TextStyle(
                          color: AppColors.whiteText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
