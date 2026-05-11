import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_item_add_controller.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_item_add_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionBarcodeWidget extends StatelessWidget {
  const TransactionBarcodeWidget({super.key});

  dynamic get _controller {
    if (Get.isRegistered<OutboundTransactionItemAddController>()) {
      return Get.find<OutboundTransactionItemAddController>();
    } else if (Get.isRegistered<InboundTransactionItemAddController>()) {
      return Get.find<InboundTransactionItemAddController>();
    }
    throw Exception("Không tìm thấy Controller (Inbound/Outbound)");
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller; // GỌI CONTROLLER RA

    return Obx(() {
      final barcodes = controller.fetchedBarcodesList;
      final hasMultipleBarcodes = barcodes.length > 1;
      final displayBarcode = controller.barcode;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            onTap: hasMultipleBarcodes
                ? () => controller.showBarcodeListBottomSheet()
                : null,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: hasMultipleBarcodes
                    ? AppColors.primary.withOpacity(0.02)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                border: Border.all(
                  color: hasMultipleBarcodes
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.divider.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: hasMultipleBarcodes
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.divider)),
                    child: _buildMockLinearBarcode(displayBarcode),
                  ),
                  const SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.barcode_copy,
                                size: 14, color: AppColors.subText),
                            const SizedBox(width: 4),
                            Text(
                              TTexts.barcodeLabel.tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.subText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayBarcode,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontFamily: AppFonts.mainFont,
                                  color: AppColors.primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasMultipleBarcodes) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color:
                                          AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Text(
                                  '+${barcodes.length - 1}',
                                  style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasMultipleBarcodes)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Iconsax.arrow_right_3_copy,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMockLinearBarcode(String value) {
    if (value.isEmpty || value == TTexts.na.tr) {
      return const SizedBox(
          height: 40, width: 60, child: Icon(Iconsax.barcode_copy));
    }
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: value.padRight(10, '0').split('').take(15).map((char) {
          int widthMultiplier = (char.codeUnitAt(0) % 3) + 1;
          return Container(
            width: widthMultiplier * 1.5,
            color: AppColors.primaryText.withOpacity(0.8),
            margin: const EdgeInsets.only(right: 1.5),
          );
        }).toList(),
      ),
    );
  }
}
