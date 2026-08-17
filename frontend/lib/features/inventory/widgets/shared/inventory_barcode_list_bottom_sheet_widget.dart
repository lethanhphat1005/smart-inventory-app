import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class InventoryBarcodeListBottomSheetWidget extends StatelessWidget {
  final ProductPackageModel package;

  const InventoryBarcodeListBottomSheetWidget(
      {super.key, required this.package});

  // Chuyển đổi source thô thành text dịch (TTexts)
  String _getFriendlySource(String source) {
    switch (source.toLowerCase()) {
      case 'user_confirmed':
        return TTexts.sourceUserConfirmed.tr;
      case 'seed':
        return TTexts.sourceSeed.tr;
      case 'admin':
        return TTexts.sourceAdmin.tr;
      case 'barcode_flow_create':
        return TTexts.sourceBarcodeFlow.tr;
      case 'api_import':
        return TTexts.sourceApi.tr;
      default:
        return TTexts.sourceOther.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            child:
                Icon(Iconsax.barcode_copy, color: AppColors.primary, size: 32),
          ),
        ),
        const SizedBox(height: AppSizes.p16),

        // 2. Title
        Text(
          TTexts.barcodeListTitle.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
            fontFamily: AppFonts.mainFont,
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        // 3. Subtitle (Sản phẩm: Tên)
        Text(
          '${TTexts.productLabel.tr}: ${DisplayNameUtils.getFullPackageDisplayName(package)}',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.subText,
            height: 1.5,
            fontFamily: AppFonts.mainFont,
          ),
        ),
        const SizedBox(height: AppSizes.p24),

        // 4. Danh sách các mã vạch
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.45,
          ),
          child: package.barcodes.isEmpty
              ? Center(
                  child: Text(TTexts.errorNotFoundMessage.tr,
                      style: const TextStyle(color: AppColors.subText)))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: package.barcodes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSizes.p12),
                  itemBuilder: (context, index) {
                    final barcodeItem = package.barcodes[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p16, vertical: AppSizes.p12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: const Icon(Iconsax.scan_barcode_copy,
                                color: AppColors.primaryText, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        barcodeItem.barcode,
                                        style: TextStyle(
                                          fontFamily: AppFonts.mainFont,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryText,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    if (barcodeItem.isVerified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Iconsax.verify_copy,
                                                color: Colors.green, size: 12),
                                            const SizedBox(width: 4),
                                            Text(TTexts.verifiedLabel.tr,
                                                style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${TTexts.sourceLabel.tr}: ${_getFriendlySource(barcodeItem.source)}',
                                  style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 12,
                                    color: AppColors.softGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: AppSizes.p16),
      ],
    );
  }
}
