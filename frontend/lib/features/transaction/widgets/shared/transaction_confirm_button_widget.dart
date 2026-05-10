import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TransactionConfirmButtonWidget extends StatelessWidget {
  final int quantity;
  final double totalPrice;
  final VoidCallback onPressed;

  const TransactionConfirmButtonWidget({
    super.key,
    required this.quantity,
    required this.totalPrice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final itemText = quantity > 1 ? TTexts.items.tr : TTexts.item.tr;
    final qtyStr = '$quantity $itemText';
    final priceStr = '\$${totalPrice.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Add to Transaction • 1 Item"
              Text(
                '${TTexts.addToTransaction.tr} • $qtyStr',
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Text(
                priceStr,
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
