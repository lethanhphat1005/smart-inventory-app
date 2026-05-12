import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InboundProductSelectionShimmerWidget extends StatelessWidget {
  const InboundProductSelectionShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.softGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.softGrey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          height: 16,
                          color: AppColors.softGrey.withOpacity(0.1)),
                      const SizedBox(height: 8),
                      Container(
                          width: 100,
                          height: 14,
                          color: AppColors.softGrey.withOpacity(0.1)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 60,
                              height: 18,
                              color: AppColors.softGrey.withOpacity(0.1)),
                          Container(
                              width: 80,
                              height: 36,
                              decoration: BoxDecoration(
                                  color: AppColors.softGrey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20))),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
