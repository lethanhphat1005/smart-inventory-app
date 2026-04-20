import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:shimmer/shimmer.dart';

class LowStockShimmerWidget extends StatelessWidget {
  const LowStockShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          child: Shimmer.fromColors(
            baseColor: AppColors.softGrey.withOpacity(0.15),
            highlightColor: AppColors.white.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.p16),

                // 1. Giả lập Overview Widget
                Row(
                  children: [
                    Expanded(child: _buildBox(height: 100)),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(child: _buildBox(height: 100)),
                  ],
                ),
                const SizedBox(height: AppSizes.p24),

                // 2. Giả lập Section Header
                Row(
                  children: [
                    _buildBox(width: 4, height: 16, borderRadius: 2),
                    const SizedBox(width: 8),
                    _buildBox(width: 140, height: 20),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // 3. Giả lập danh sách Low Stock Items
                ...List.generate(
                    6,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.p12),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.p12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radius16),
                              border: Border.all(
                                  color: AppColors.softGrey.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                // Giả lập Image
                                _buildBox(
                                    width: 50,
                                    height: 50,
                                    borderRadius: AppSizes.radius8),
                                const SizedBox(width: AppSizes.p16),
                                // Giả lập Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildBox(
                                          width: double.infinity, height: 14),
                                      const SizedBox(height: 8),
                                      _buildBox(width: 100, height: 12),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Giả lập số lượng
                                _buildBox(width: 30, height: 20),
                              ],
                            ),
                          ),
                        ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(
      {required double height, double? width, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
