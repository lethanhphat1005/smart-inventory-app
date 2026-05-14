import 'package:flutter/material.dart';
import 'package:frontend/core/state/controllers/barcode_action_controller.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/state/services/store_service.dart';

class HomeQuickActionsWidget extends StatelessWidget {
  const HomeQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final storeService = Get.find<StoreService>();
    final isManager = storeService.currentRole.value.toLowerCase() != 'staff';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.homeQuickActions.tr,
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSizes.p16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              // 1. THẺ REORDER SUGGESTION

              _buildPremiumCard(
                icon: Icons.lightbulb_outline,
                title: TTexts.reorderThreshold.tr,
                subtitle: TTexts.homeReorderThresholdSub.tr,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5FC8F9), Color(0xFF0189C8)],
                ),
                onTap: () => Get.toNamed(AppRoutes.reorderSuggestion),
              ),
              const SizedBox(width: AppSizes.p16),

              // 2. THẺ SCAN
              _buildPremiumCard(
                icon: Iconsax.scan_barcode_copy,
                title: TTexts.homeScanBarcode.tr,
                subtitle: TTexts.homeScanBarcodeSub.tr,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A4A4A), Color(0xFF1E1E24)],
                ),
                onTap: () {
                  Get.to(() => TBarcodeScannerLayout(
                        // title: TTexts.barCodeScan.tr,
                        onScanned: (code) {
                          // Gọi controller xử lý logic điều hướng/bottom sheet
                          BarcodeActionController.instance
                              .handleScannedBarcode(code);
                        },
                      ));
                },
              ),

              // 3. THẺ ADD PRODUCT
              if (isManager) ...[
                const SizedBox(width: AppSizes.p16),
                _buildPremiumCard(
                  icon: Iconsax.box_1_copy,
                  title: TTexts.homeAddProduct.tr,
                  subtitle: TTexts.homeAddProductSub.tr,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF222222), Color(0xFF000000)],
                  ),
                  onTap: () => Get.toNamed(AppRoutes.productForm),
                ),
              ],

              // 5. THẺ VIEW ADJUSTMENTS (ĐÃ ĐỔI SANG MÀU XANH TEAL TRÁNH TRÙNG MÀU APP)
              const SizedBox(width: AppSizes.p16),
              _buildPremiumCard(
                icon: Iconsax.setting_2_copy,
                title: TTexts.homeViewAdjustments.tr,
                subtitle: TTexts.homeViewAdjustmentsSub.tr,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF11998E),
                    Color(0xFF1F7B6B)
                  ], // Cyan/Teal Gradient
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.adjustmentHistory);
                },
              ),

              // 6. THẺ LOW STOCK ALERTS (MÀU ĐỎ)
              const SizedBox(width: AppSizes.p16),
              _buildPremiumCard(
                icon: Iconsax.warning_2_copy,
                title: TTexts.homeLowStock.tr,
                subtitle: TTexts.homeLowStockSub.tr,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF4B4B), Color(0xFFE52323)],
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.lowStock); // ĐÃ LINK ROUTE
                },
              ),

              const SizedBox(width: AppSizes.p16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 135,
        height: 185,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                color: Colors.white.withOpacity(0.65),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
