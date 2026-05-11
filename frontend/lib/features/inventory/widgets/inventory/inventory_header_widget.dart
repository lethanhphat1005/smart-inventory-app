import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/services/store_service.dart';

class InventoryHeaderWidget extends StatelessWidget {
  const InventoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  TTexts.inventoryHub.tr,
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  TTexts.manageProductsStock.tr,
                  style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 13,
                      color: AppColors.subText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          Obx(() {
            final storeService = Get.find<StoreService>();
            final role = storeService.currentRole.value.toLowerCase();

            String tooltipMessage;
            List<Color> gradientColors;
            IconData roleIcon;

            // Phân nhánh UI cho 3 Role
            if (role == 'owner') {
              tooltipMessage = TTexts.roleOwner.tr;
              gradientColors = [AppColors.primary, AppColors.secondPrimary];
              roleIcon = Icons.workspace_premium_rounded;
            } else if (role == 'manager') {
              tooltipMessage = TTexts.homeRoleManagerTooltip.tr;
              gradientColors = [
                const Color(0xFFFF9900),
                const Color(0xFFFFCC00)
              ];
              roleIcon = Icons.admin_panel_settings_rounded;
            } else {
              tooltipMessage = TTexts.homeRoleStaffTooltip.tr;
              gradientColors = [
                const Color(0xFF00C853),
                const Color(0xFF69F0AE)
              ];
              roleIcon = Icons.badge_rounded;
            }

            return Tooltip(
              message: tooltipMessage,
              triggerMode: TooltipTriggerMode.tap,
              preferBelow: false,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(roleIcon, color: Colors.white, size: 26),
              ),
            );
          }),
        ],
      ),
    );
  }
}
