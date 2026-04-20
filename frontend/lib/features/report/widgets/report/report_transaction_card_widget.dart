import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart'; // ĐÃ THÊM
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart'; // ĐÃ THÊM
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReportTransactionCardWidget extends StatelessWidget {
  final String transactionId;
  final String dateStr;
  final String typeDisplay;
  final Color typeColor;
  final String itemsDisplay;
  final Color itemsColor;
  final String moneyDisplay;
  final Color moneyColor;
  final bool isInbound;
  final bool isOutbound;
  final String leftBottomLabel;

  const ReportTransactionCardWidget({
    super.key,
    required this.transactionId,
    required this.dateStr,
    required this.typeDisplay,
    required this.typeColor,
    required this.itemsDisplay,
    required this.itemsColor,
    required this.moneyDisplay,
    required this.moneyColor,
    this.isInbound = false,
    this.isOutbound = false,
    required this.leftBottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildRow(
            TTexts.transactionId.tr,
            transactionId,
            rightWidget: _buildFakeBarcode(),
          ),
          const SizedBox(height: 20),
          _buildRow(
            TTexts.transactionDate.tr,
            dateStr,
            rightWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(TTexts.transactionType.tr,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subText)),
                const SizedBox(height: 4),
                Text(
                  typeDisplay,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: typeColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildRow(
            leftBottomLabel,
            '',
            customLeftWidget: Row(
              children: [
                Text(itemsDisplay,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: itemsColor)),
                const Text(" / ",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subText)),
                Text(moneyDisplay,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: moneyColor)),
              ],
            ),
            rightWidget: _buildCustomLayerIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String leftTitle, String leftValue,
      {Widget? customLeftWidget, Widget? rightWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftTitle,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subText,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              customLeftWidget ??
                  Text(leftValue,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryText,
                          fontFamily: 'Poppins'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
            ],
          ),
        ),
        if (rightWidget != null) ...[
          const SizedBox(width: 24),
          rightWidget,
        ]
      ],
    );
  }

  Widget _buildFakeBarcode() {
    final List<double> widths = [2, 4, 1.5, 3, 1, 5, 2, 1.5, 4, 2, 1, 3];
    final List<double> heights = [
      36,
      40,
      32,
      38,
      40,
      34,
      38,
      32,
      40,
      36,
      38,
      40
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
          widths.length,
          (index) => Container(
                width: widths[index],
                height: heights[index],
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                    color: AppColors.primaryText,
                    borderRadius: BorderRadius.circular(1)),
              )),
    );
  }

  Widget _buildCustomLayerIcon() {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: Icon(Iconsax.layer_copy, color: typeColor, size: 28)),
          if (isInbound)
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: AppColors.stockIn, shape: BoxShape.circle),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 12, weight: 800))),
          if (isOutbound)
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: AppColors.stockOut, shape: BoxShape.circle),
                    child: const Icon(Icons.remove,
                        color: Colors.white, size: 12, weight: 800))),
        ],
      ),
    );
  }
}
