import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class TEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionButton; // Thêm action button (không bắt buộc)

  const TEmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI Ở ĐÂY: Dùng Center + SingleChildScrollView để chống tràn khi mở bàn phím
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize
              .min, // QUAN TRỌNG: Ép Column chiếm chiều cao nhỏ nhất có thể
          children: [
            // 1. Icon với nền mờ bo tròn (Soft Blob Background)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.softGrey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.softGrey,
              ),
            ),
            const SizedBox(height: 24),

            // 2. Title đậm và rõ ràng hơn
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Subtitle được tăng khoảng cách dòng (height) để dễ đọc
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.5, // Giúp văn bản đa dòng thoáng hơn
                color: AppColors.subText,
              ),
            ),

            // 4. Nếu có truyền vào nút Action thì hiển thị
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton!,
            ]
          ],
        ),
      ),
    );
  }
}
