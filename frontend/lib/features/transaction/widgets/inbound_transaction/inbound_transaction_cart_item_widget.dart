import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InboundTransactionCartItemWidget extends StatelessWidget {
  final TransactionDetailModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const InboundTransactionCartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    // final name = item.packageInfo?.displayName ??
    //     '${TTexts.product.tr} #${item.productPackageId?.substring(0, 5) ?? TTexts.labelNoBarcode.tr}';
    final name = item.packageInfo != null
        ? DisplayNameUtils.getFullPackageDisplayName(item.packageInfo)
        : '${TTexts.product.tr} #'
            '${item.productPackageId?.substring(0, 5) ?? TTexts.labelNoBarcode.tr}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.softGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.box_1_copy, color: AppColors.subText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      CurrencyFormatterUtils.formatFull(item.unitPrice),
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontSize: 13,
                        color: AppColors.subText,
                      ),
                    )),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onDecrease,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softGrey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.minus_copy,
                      size: 16, color: AppColors.primaryText),
                ),
              ),
              Container(
                width: 36,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onIncrease,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.add_copy,
                      size: 16, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
