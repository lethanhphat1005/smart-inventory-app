import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class AdjustmentHistorySearchBarWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onCalendarTap;
  final bool hasDateFilter;

  const AdjustmentHistorySearchBarWidget({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    required this.onCalendarTap,
    this.hasDateFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        boxShadow: [
          BoxShadow(
            color: AppColors.softGrey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          // 1. LỚP NỀN: Nút Lịch (Áp dụng Gradient y hệt nút Scan gốc)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradientBlackStart,
                  AppColors.gradientBlackEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onCalendarTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 15.0),
                  child: Icon(Iconsax.calendar_copy,
                      color: hasDateFilter ? Colors.orange : Colors.white,
                      size: 24),
                ),
              ),
            ),
          ),

          // 2. LỚP TRÊN: Phần nhập Text
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 60, 
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSizes.p16),
                  const Icon(Iconsax.search_normal_copy,
                      color: AppColors.softGrey, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      cursorColor: AppColors.primary,
                      controller: controller,
                      onChanged: onChanged,
                      style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                            color: AppColors.softGrey, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
