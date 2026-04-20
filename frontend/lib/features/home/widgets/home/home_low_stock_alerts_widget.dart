import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/routes/app_routes.dart'; // ĐÃ IMPORT ROUTES
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeLowStockAlertsWidget extends GetView<HomeController> {
  const HomeLowStockAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.lowStockItems;

      if (items.isEmpty) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.p20,
                top: AppSizes.p20,
                right: AppSizes.p20,
                bottom: items.length > 3 ? 60 : AppSizes.p20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TTexts.homeLowStockAlerts.tr,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.toastErrorBg,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12)),
                        child: Text(
                          '${items.length} ${TTexts.homeItems.tr}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.toastErrorGradientEnd,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),
                  ...items.take(3).map((item) {
                    final pkg = item.productPackage;

                    final name = pkg?.displayName ??
                        pkg?.product?.name ??
                        TTexts.unknownProduct.tr;
                    final barcode = pkg?.barcodeValue ?? '';
                    final String displaySubtitle = barcode.isNotEmpty
                        ? '${TTexts.barcodeLabel.tr}: $barcode'
                        : (pkg?.product?.brand ?? 'Product');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.lowStock),
                        child: _buildAlertItem(
                          name: name,
                          category: displaySubtitle,
                          quantityLeft: item.quantity,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (items.length > 3)
              TCustomFadeOverlayWidget(
                text: TTexts.homeTapToViewAll.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.lowStock); // ĐÃ LINK ROUTE
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAlertItem(
      {required String name,
      required String category,
      required int quantityLeft}) {
    String quantityText = quantityLeft <= 0
        ? TTexts.homeOutOfStock.tr
        : TTexts.homeOnlyLeft.tr
            .replaceAll('@quantity', quantityLeft.toString());

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radius16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radius8)),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.toastErrorGradientEnd),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primaryText)),
                Text(category,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.subText)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.toastErrorGradientEnd,
                      shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(quantityText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.toastErrorGradientEnd,
                      fontWeight: FontWeight.w500,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
