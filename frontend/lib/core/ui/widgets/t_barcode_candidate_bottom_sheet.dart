import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';

class TBarcodeCandidateBottomSheet {
  static void show(
      {required String barcode,
      required List<dynamic> candidates,
      required Map<String, dynamic> prefill}) {
    final InventoryProvider provider = InventoryProvider();

    TBottomSheetWidget.show(
      title: TTexts.barcodeSimilarTitle.tr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TTexts.barcodeSimilarDesc.tr,
              style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: AppSizes.p14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: AppSizes.p12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
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
            ),
            const SizedBox(height: AppSizes.p16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.35),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: candidates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final candidate = candidates[index]['productPackage'];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: Text(
                          candidate['displayName'] ?? TTexts.unknownProduct.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: AppColors.primaryText,
                              fontSize: 15)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            '${TTexts.sellingPrice.tr}: ${candidate['sellingPrice']} \$',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500)),
                      ),
                      trailing: const Icon(Icons.link_rounded,
                          color: AppColors.primary),
                      onTap: () async {
                        Get.back(); // Đóng Bottom Sheet
                        FullScreenLoaderUtils.openLoadingDialog(
                            TTexts.barcodeLinkingLoader.tr);
                        try {
                          await provider.confirmBarcodeMapping(
                            barcode: barcode,
                            productPackageId: candidate['productPackageId'],
                          );
                          FullScreenLoaderUtils.stopLoading();
                          Get.back(); // Đóng màn Scanner

                          Get.toNamed(AppRoutes.inventoryDetail, arguments: {
                            'packageId': candidate['productPackageId'],
                            'package': candidate,
                          });
                          TSnackbarsWidget.success(
                              title: TTexts.successTitle.tr,
                              message: TTexts.barcodeLinkSuccessMsg.tr);
                        } catch (e) {
                          FullScreenLoaderUtils.stopLoading();
                          TSnackbarsWidget.error(
                              title: TTexts.errorTitle.tr,
                              message: TTexts.barcodeLinkConflictError.tr);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12)),
                ),
                onPressed: () {
                  Get.back();
                  Get.back();
                  Get.toNamed(AppRoutes.productForm, arguments: {
                    'mode': 'create',
                    'barcode': barcode,
                    'freshName': prefill['name'],
                    'freshBrand': prefill['brand'],
                  });
                },
                child: Text(TTexts.barcodeCreateNewBtn.tr,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
