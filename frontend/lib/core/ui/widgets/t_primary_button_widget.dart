import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TPrimaryButtonWidget extends StatelessWidget {
  const TPrimaryButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.customIcon,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.white,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = AppSizes.radius12,
    this.fontSize = 12.0,
    this.isOutlined = false,
    this.borderColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? customIcon;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final double fontSize;

  // Thuộc tính mới
  final bool isOutlined;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    // 1. NẾU LÀ NÚT OUTLINE (Viền)
    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(
              color: borderColor ?? Colors.grey.shade300,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          ),
          child: _buildButtonContent(),
        ),
      );
    }

    // 2. NẾU LÀ NÚT BÌNH THƯỜNG (Nền đặc)
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  // Render nội dung bên trong nút (chữ + icon)
  Widget _buildButtonContent() {
    // KHIỂM TRA XEM NÚT CÓ ICON KHÔNG
    final bool hasIcon = customIcon != null || icon != null;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Icon ép sát mép trái (Nếu có)
        if (customIcon != null)
          Align(
            alignment: Alignment.centerLeft,
            child: customIcon!,
          )
        else if (icon != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, size: AppSizes.iconMd, color: textColor),
          ),

        // 2. Chữ ở giữa
        Padding(
          // CHỈ LÙI LỀ NẾU CÓ ICON.
          // Nếu không có Icon, padding = 0 để chữ có đủ không gian hiển thị trong nút nhỏ!
          padding: EdgeInsets.symmetric(horizontal: hasIcon ? 36.0 : 0.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Tránh rớt dòng
          ),
        ),
      ],
    );
  }
}
