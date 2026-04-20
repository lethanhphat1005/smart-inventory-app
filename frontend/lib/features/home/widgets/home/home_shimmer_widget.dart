import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class HomeShimmerWidget extends StatelessWidget {
  const HomeShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. KHUNG CHỜ CHO HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeleton(
                      height: 28, width: 220, radius: AppSizes.radius8),
                  const SizedBox(height: 8),
                  _buildSkeleton(
                      height: 16, width: 140, radius: AppSizes.radius8),
                ],
              ),
              _buildSkeleton(height: 48, width: 48, radius: 16),
            ],
          ),
        ),

        // 2. KHUNG CHỜ CHO BODY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.p8),
              // Khung chờ cho Biểu đồ doanh thu
              _buildSkeleton(
                  height: 220,
                  width: double.infinity,
                  radius: AppSizes.radius24),
              const SizedBox(height: AppSizes.p32),

              // Khung chờ cho Quick Actions
              _buildSkeleton(
                  height: 185,
                  width: double.infinity,
                  radius: AppSizes.radius24),
              const SizedBox(height: AppSizes.p32),

              // Khung chờ cho Daily Summary
              _buildSkeleton(
                  height: 200,
                  width: double.infinity,
                  radius: AppSizes.radius24),
              const SizedBox(height: AppSizes.p32),

              // Khung chờ cho List
              _buildSkeleton(
                  height: 150,
                  width: double.infinity,
                  radius: AppSizes.radius24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(
      {required double height, required double width, required double radius}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.softGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
