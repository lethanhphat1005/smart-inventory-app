import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';

class TransactionBottomSheetWidget extends StatelessWidget {
  const TransactionBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.softGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius16),
          ),
          child: const Center(
            child: Text("📦", style: TextStyle(fontSize: 36)),
          ),
        ),
        const SizedBox(height: AppSizes.p16),
        Text(
          TTexts.manageInventory.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            TTexts.manageInventoryDesc.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.subText,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p24),
        TPrimaryButtonWidget(
          text: TTexts.inbound.tr,
          height: 56,
          customIcon: _buildLayerIcon(isPlus: true),
          fontSize: 14,
          onPressed: () {
            Get.back();
            Get.toNamed(AppRoutes.inboundTransaction);
          },
        ),
        const SizedBox(height: AppSizes.p12),
        TPrimaryButtonWidget(
          text: TTexts.outbound.tr,
          height: 56,
          customIcon: _buildLayerIcon(isMinus: true),
          fontSize: 14,
          onPressed: () {
            Get.back();
            Get.toNamed(AppRoutes.outboundTransaction);
          },
        ),
        const SizedBox(height: AppSizes.p12),
        TPrimaryButtonWidget(
          text: TTexts.stockAdjustment.tr,
          height: 56,
          icon: Iconsax.layer_copy,
          fontSize: 14,
          onPressed: () {
            Get.back(); // 1. Đóng Bottom Sheet hiện tại
            // 2. Mở Hộp thoại xác nhận
            Get.dialog(
              TCustomDialogWidget(
                title: TTexts.confirmAdjustmentTitle.tr,
                description: TTexts.confirmAdjustmentDesc.tr,
                icon: const Text('📋', style: TextStyle(fontSize: 40)),
                primaryButtonText: TTexts.proceedAdjustment.tr,
                onPrimaryPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.stockAdjustment);
                },
                secondaryButtonText: TTexts.cancel.tr,
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.p16),
        TPrimaryButtonWidget(
          text: TTexts.exit.tr,
          height: 56,
          fontSize: 14,
          backgroundColor: AppColors.softGrey.withOpacity(0.15),
          textColor: AppColors.primaryText,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildLayerIcon({bool isPlus = false, bool isMinus = false}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            child: Icon(Iconsax.layer_copy, color: AppColors.white, size: 24),
          ),
          if (isPlus)
            Positioned(
              bottom: -2,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add,
                    color: AppColors.white, size: 14, weight: 800),
              ),
            ),
          if (isMinus)
            Positioned(
              bottom: -2,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove,
                    color: AppColors.white, size: 14, weight: 800),
              ),
            ),
        ],
      ),
    );
  }
}
