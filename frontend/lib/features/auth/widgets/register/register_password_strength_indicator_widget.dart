import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class RegisterPasswordStrengthIndicatorWidget extends StatelessWidget {
  final int strength;

  const RegisterPasswordStrengthIndicatorWidget(
      {super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: AppSizes.p8),
        Row(
          children: [
            _buildBar(1, strength >= 1 ? Colors.red : Colors.grey.shade300),
            const SizedBox(width: AppSizes.p4),
            _buildBar(2, strength >= 2 ? Colors.orange : Colors.grey.shade300),
            const SizedBox(width: AppSizes.p4),
            _buildBar(3, strength >= 3 ? Colors.blue : Colors.grey.shade300),
            const SizedBox(width: AppSizes.p4),
            _buildBar(4, strength >= 4 ? Colors.green : Colors.grey.shade300),
          ],
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          _getStrengthText(strength),
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _getStrengthColor(strength),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(int index, Color color) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 1:
        return TTexts.weak.tr;
      case 2:
        return TTexts.fair.tr;
      case 3:
        return TTexts.good.tr;
      case 4:
        return TTexts.strong.tr;
      default:
        return '';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }
}
