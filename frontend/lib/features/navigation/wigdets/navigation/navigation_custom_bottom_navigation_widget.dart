import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NavigationCustomBottomNavigationWidget
    extends GetView<NavigationController> {
  const NavigationCustomBottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: 120,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: AppSizes.bottomNavHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: AppSizes.radius20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Obx(() {
                final isRestricted = controller.isRestricted;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (!isRestricted)
                      _buildNavItem(index: 0, icon: Iconsax.home_2_copy),

                    _buildNavItem(index: 1, icon: Iconsax.box_copy),

                    const SizedBox(width: 70), // Khoảng trống cho nút +

                    if (!isRestricted)
                      _buildNavItem(index: 3, icon: Iconsax.chart_21_copy),

                    _buildNavItem(index: 4, icon: Iconsax.user_copy),
                  ],
                );
              }),
            ),
            Positioned(
              bottom: 40,
              child: GestureDetector(
                onTap: () {
                  TBottomSheetWidget.show(
                    title: TTexts.createNewTransaction.tr,
                    child: const TransactionBottomSheetWidget(),
                  );
                },
                child: Obx(() {
                  final isSelected = controller.selectedIndex.value == 2;
                  return AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondPrimary],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          TImages.iconImages.plusIcon,
                          width: 26,
                          height: 26,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon}) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;

        return AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryText : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.softGrey,
              size: 24,
            ),
          ),
        );
      }),
    );
  }
}
