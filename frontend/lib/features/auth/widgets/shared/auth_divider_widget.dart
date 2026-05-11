import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

/// Thanh phân cách có chữ "Hoặc" ở giữa dùng cho toàn bộ module Auth
class AuthDividerWidget extends StatelessWidget {
  const AuthDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300, // Đường kẻ xám siêu nhạt
            thickness: 1,
            endIndent: AppSizes.p8, // Cách chữ một chút
          ),
        ),
        Text(
          TTexts.authOrDivider.tr,
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 12,
            color: AppColors.subText,
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: AppSizes.p8, // Cách chữ một chút
          ),
        ),
      ],
    );
  }
}
