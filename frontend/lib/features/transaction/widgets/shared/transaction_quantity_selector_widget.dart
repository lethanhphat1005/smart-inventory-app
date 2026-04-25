import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TransactionQuantitySelectorWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final int? maxQuantity;

  const TransactionQuantitySelectorWidget({
    super.key,
    required this.controller,
    required this.onIncrease,
    required this.onDecrease,
    this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.labelQuantity.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRawButton(
                icon: Iconsax.minus_copy,
                onTap: onDecrease,
                color: AppColors.softGrey,
              ),
              const SizedBox(width: 20),
              IntrinsicWidth(
                stepWidth: 48,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.softGrey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                    color: Colors.white,
                  ),
                  child: TextSelectionTheme(
                    data: TextSelectionThemeData(
                      cursorColor: AppColors.primary,
                      selectionColor: AppColors.primary.withOpacity(0.3),
                      selectionHandleColor: AppColors.primary,
                    ),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isEmpty) return;

                        final qty = int.tryParse(value);
                        if (qty == null || qty < 1) {
                          controller.text = '1';
                          controller.selection = TextSelection.fromPosition(
                              const TextPosition(offset: 1));
                          return;
                        }

                        if (maxQuantity != null && qty > maxQuantity!) {
                          controller.text = maxQuantity.toString();
                          controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.text.length));
                        }
                      },
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildRawButton(
                icon: Iconsax.add_copy,
                onTap: () {
                  final current = int.tryParse(controller.text) ?? 1;
                  if (maxQuantity != null && current >= maxQuantity!) return;
                  onIncrease();
                },
                // Đổi màu dấu cộng thành xám nếu đã max
                color: (maxQuantity != null &&
                        (int.tryParse(controller.text) ?? 1) >= maxQuantity!)
                    ? AppColors.softGrey
                    : AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRawButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}
