import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/routes/app_routes.dart';

import 'inventory_health_widget.dart';
import 'inventory_distribution_widget.dart';

// THÊM 2 DÒNG NÀY ĐỂ DÙNG ĐA NGÔN NGỮ
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryInsightsWidget extends StatelessWidget {
  const InventoryInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        border: Border.all(color: AppColors.stockIn.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.inventoryInsights.tr,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.inventorySight),
                child: Row(
                  children: [
                    Text(TTexts.details.tr,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary, size: 14),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: AppSizes.p16),

          // GỌI COMPONENT 1: HEALTH
          const InventoryHealthWidget(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.black12, height: 1),
          ),

          // GỌI COMPONENT 2: DISTRIBUTION
          const InventoryDistributionWidget(),
        ],
      ),
    );
  }
}
