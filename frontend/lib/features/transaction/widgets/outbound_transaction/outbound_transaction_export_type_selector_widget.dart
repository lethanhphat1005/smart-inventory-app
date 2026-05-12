import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OutboundTransactionExportTypeSelectorWidget extends StatelessWidget {
  final List<String> reasons;
  final String selectedReason;
  final Function(String) onReasonSelected;
  final int otherFinancialEffect; // 1: Income, 0: Neutral, -1: Loss
  final Function(int) onOtherFinancialEffectChanged;

  const OutboundTransactionExportTypeSelectorWidget({
    super.key,
    required this.reasons,
    required this.selectedReason,
    required this.onReasonSelected,
    required this.otherFinancialEffect,
    required this.onOtherFinancialEffectChanged,
  });

  IconData _getIconForReason(String reason) {
    if (reason == TTexts.reasonRetailSale) return Iconsax.shopping_cart_copy;
    if (reason == TTexts.reasonReturn) return Iconsax.box_time_copy;
    if (reason == TTexts.reasonDamaged) return Iconsax.trash_copy;
    return Iconsax.document_copy; // Other
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.selectExportType.tr,
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: reasons.map((reasonKey) {
            final isSelected = selectedReason == reasonKey;

            return Column(
              children: [
                GestureDetector(
                  onTap: () => onReasonSelected(reasonKey),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Radio<String>(
                            value: reasonKey,
                            groupValue: selectedReason,
                            onChanged: (val) => onReasonSelected(val!),
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _getIconForReason(reasonKey),
                          size: 20,
                          color: isSelected
                              ? AppColors.primaryText
                              : AppColors.subText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reasonKey.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryText
                                  : AppColors.subText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // HIỂN THỊ 3 TÙY CHỌN TÀI CHÍNH NẾU CHỌN "OTHER"
                if (reasonKey == TTexts.reasonOther && isSelected)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 32, right: 0, bottom: 16), // Xóa right padding
                    child: Column(
                      children: [
                        _buildFinancialRadio(
                            1, TTexts.reasonIncome.tr, AppColors.stockIn),
                        _buildFinancialRadio(
                            0, TTexts.reasonNeutral.tr, AppColors.softGrey),
                        _buildFinancialRadio(
                            -1, TTexts.reasonExpense.tr, AppColors.stockOut),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFinancialRadio(int value, String title, Color activeColor) {
    return RadioListTile<int>(
      title: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      value: value,
      groupValue: otherFinancialEffect,
      onChanged: (val) => onOtherFinancialEffectChanged(val!),
      activeColor: activeColor,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );
  }
}
