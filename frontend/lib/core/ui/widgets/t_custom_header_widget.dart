// lib/core/widgets/t_custom_header_widget.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';

class TCustomHeaderWidget extends StatelessWidget {
  final String title;
  final bool isDark; // Bật tắt chế độ tối
  final Widget? trailingWidget;

  const TCustomHeaderWidget({
    super.key,
    required this.title,
    this.isDark = false,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Cài đặt màu sắc theo chế độ Sáng/Tối
    final textColor = isDark ? Colors.white : Colors.black87;
    final backBtnBg =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

    return SizedBox(
      height: 56, // Chiều cao AppBar chuẩn
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Nút Back (Bên trái)
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backBtnBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ),
          ),

          // 2. Tiêu đề (Chính giữa)
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.mainFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          // 3. Nút bên phải (Tuỳ chọn - Tạm thời bỏ trống)
          if (trailingWidget != null)
            Positioned(
              right: 0,
              child: trailingWidget!,
            ),
        ],
      ),
    );
  }
}
