import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class HomeAdjustmentStatsWidget extends GetView<HomeController> {
  const HomeAdjustmentStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logs = controller.todayAdjustments;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.p20,
                top: AppSizes.p20,
                right: AppSizes.p20,
                bottom: logs.length > 5 ? 60 : AppSizes.p20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TTexts.recentAdjustments.tr,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 16),
                  if (logs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          TTexts.noRecentAdjustments.tr,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.softGrey,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ...logs.take(5).map((item) {
                      final timeStr = DayFormatterUtils.formatTime(item.time);
                      final diffStr = item.difference == 0
                          ? '0'
                          : (item.isPositive
                              ? '+${item.difference}'
                              : '${item.difference}');

                      return GestureDetector(
                        onTap: () => controller.openDetails(item),
                        child: Container(
                          width: double.infinity, // Đảm bảo full chiều ngang
                          margin: const EdgeInsets.only(bottom: AppSizes.p12),
                          padding: const EdgeInsets.all(AppSizes.p16),
                          decoration: BoxDecoration(
                            color: AppColors.white, // Nền trắng y chang bản gốc
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius16),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.03)),
                          ),
                          child: Row(
                            children: [
                              // Icon clipboard_tick_copy màu Primary y chang bản gốc
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.sync_alt_rounded,
                                    size: 22, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryText),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 14,
                                            color: AppColors.softGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeStr,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13,
                                              color: AppColors.softGrey),
                                        ),
                                        const SizedBox(width: 12),
                                        // Hiển thị Qty: 23 -> 21
                                        Text(
                                            "${TTexts.qty.tr}: ${item.oldQuantity} → ${item.newQuantity}",
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.subText)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Số tận cùng đổi màu Xanh/Đỏ theo giá trị chênh lệch
                              Text(
                                diffStr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: item.isPositive
                                      ? AppColors.stockIn
                                      : AppColors.stockOut,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            if (logs.length > 5)
              TCustomFadeOverlayWidget(
                text: TTexts.homeTapToViewMoreHistory.tr,
                onTap: controller.goToAdjustmentHistory,
              ),
          ],
        ),
      );
    });
  }
}
