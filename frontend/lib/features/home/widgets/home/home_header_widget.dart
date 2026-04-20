import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // ĐẢM BẢO CÓ IMPORT NÀYtext_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final user = homeController.userProfile.value;
                  final displayName = user?.fullName ?? 'Guest';

                  return Text(
                    '${homeController.greetingText}, $displayName',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
                const SizedBox(height: 2),
                Text(
                  TTexts.homeDailyOverview.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.p12),

          // NÚT CHUÔNG THÔNG BÁO (THAY THẾ CHO ROLE BADGE)
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.notification,
                  arguments: homeController.userProfile.value);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softGrey.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(
                () => Badge(
                  backgroundColor: homeController.unreadCount.value > 0
                      ? AppColors.stockOut
                      : Colors.transparent,
                  smallSize: 10,
                  child: const Icon(Iconsax.notification_bing_copy,
                      color: AppColors.primaryText, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
