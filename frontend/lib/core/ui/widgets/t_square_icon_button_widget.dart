import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class TSquareIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const TSquareIconButtonWidget({
    super.key,
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Mình thu nhỏ kích thước từ 44x44 xuống 40x40 một chút
        // để nhét vừa 4 nút trên thanh ngang mà không bị đè vào Tiêu đề
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
