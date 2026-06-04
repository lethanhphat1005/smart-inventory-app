import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class InventoryProductFormShimmerWidget extends StatefulWidget {
  const InventoryProductFormShimmerWidget({super.key});

  @override
  State<InventoryProductFormShimmerWidget> createState() =>
      _InventoryProductFormShimmerWidgetState();
}

class _InventoryProductFormShimmerWidgetState extends State<InventoryProductFormShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p20, vertical: AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề và Subtitle giả
              _buildBone(width: 200, height: 22, radius: 8),
              const SizedBox(height: 8),
              _buildBone(width: 150, height: 14, radius: 6),
              const SizedBox(height: 32),

              // 2. Ô Input 1 (Ví dụ: Tên sản phẩm / Chọn đơn vị)
              _buildBone(width: 120, height: 16, radius: 6),
              const SizedBox(height: 8),
              _buildBone(width: double.infinity, height: 56, radius: 12),
              const SizedBox(height: 24),

              // 3. Ô Input 2
              _buildBone(width: 100, height: 16, radius: 6),
              const SizedBox(height: 8),
              _buildBone(width: double.infinity, height: 56, radius: 12),
              const SizedBox(height: 24),

              // 4. Khối 2 ô Input nằm ngang (Ví dụ: Giá nhập & Giá bán)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBone(width: 80, height: 16, radius: 6),
                        const SizedBox(height: 8),
                        _buildBone(
                            width: double.infinity, height: 56, radius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBone(width: 80, height: 16, radius: 6),
                        const SizedBox(height: 8),
                        _buildBone(
                            width: double.infinity, height: 56, radius: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 5. Nút bấm giả ở dưới cùng
              _buildBone(width: double.infinity, height: 56, radius: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBone(
      {required double width, required double height, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.softGrey.withOpacity(0.2), // Màu xám nhạt làm khung
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
