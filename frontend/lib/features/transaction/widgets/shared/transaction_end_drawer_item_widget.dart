import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';

class TransactionEndDrawerItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final bool showDivider;

  const TransactionEndDrawerItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: color ?? AppColors.primaryText),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color ?? AppColors.primaryText,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.softGrey.withOpacity(0.5)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 54, right: 16),
            child:
                Divider(color: AppColors.divider.withOpacity(0.5), height: 1),
          ),
      ],
    );
  }
}
