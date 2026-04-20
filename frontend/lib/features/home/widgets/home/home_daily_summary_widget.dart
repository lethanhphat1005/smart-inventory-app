import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeDailySummaryWidget extends GetView<HomeController> {
  const HomeDailySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TTexts.homeInventoryOverview.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              InkWell(
                onTap: controller.openOverviewInfo,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Iconsax.info_circle_copy,
                      size: 20, color: AppColors.softGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // TẦNG 1: HOẠT ĐỘNG ĐẾM PHIẾU
          Row(
            children: [
              _buildActivityBox(
                  TTexts.homeStockIn.tr,
                  '${controller.inboundTransactionsCount}',
                  Iconsax.box_add_copy, // ICON HỘP NHẬP
                  Colors.blue),
              const SizedBox(width: 12),
              _buildActivityBox(
                  TTexts.homeStockOut.tr,
                  '${controller.outboundTransactionsCount}',
                  Iconsax.box_remove_copy, // ICON HỘP XUẤT
                  Colors.purple),
              const SizedBox(width: 12),
              _buildActivityBox(
                  TTexts.adjust.tr,
                  '${controller.adjustedItemsCount}',
                  Iconsax.box_tick_copy, // ICON HỘP KIỂM TRA
                  Colors.orange),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppColors.divider, height: 1),
          ),

          // TẦNG 2: BIỂU ĐỒ ĐỐI KHÁNG TỔNG SỐ LƯỢNG (QUANTITY)
          _buildOpposingBarChart(
            inQty: controller.totalItemsInToday,
            outQty: controller.totalItemsOutToday,
          ),
        ],
      ),
    );
  }

  // Widget hộp đếm hoạt động
  Widget _buildActivityBox(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color), // Tăng nhẹ size icon
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // GIẢM ĐỘ ĐẬM
                    color: AppColors.primaryText)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // Widget biểu đồ ngang tinh tế
  Widget _buildOpposingBarChart({required int inQty, required int outQty}) {
    final int total = inQty + outQty;
    final int inFlex = total == 0 ? 1 : inQty;
    final int outFlex = total == 0 ? 1 : outQty;

    return Column(
      children: [
        // Nhãn ở trên
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(TTexts.totalIn.tr.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.stockIn)),
              ],
            ),
            Row(
              children: [
                Text(TTexts.totalOut.tr.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.stockOut)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Expanded(
                flex: inFlex,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: total == 0
                        ? AppColors.softGrey.withOpacity(0.2)
                        : AppColors.stockIn,
                  ),
                ),
              ),
              // Vạch ngăn cách ở giữa
              if (inQty > 0 && outQty > 0)
                Container(width: 2, height: 8, color: AppColors.surface),
              Expanded(
                flex: outFlex,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: total == 0
                        ? AppColors.softGrey.withOpacity(0.2)
                        : AppColors.stockOut,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Giá trị ở dưới
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              inQty.toString(),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.stockIn),
            ),
            Text(
              outQty.toString(),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.stockOut),
            ),
          ],
        ),
      ],
    );
  }
}
