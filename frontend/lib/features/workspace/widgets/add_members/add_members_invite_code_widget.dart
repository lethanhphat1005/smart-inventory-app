import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';

class AddMembersInviteCodeWidget extends GetView<AddMembersController> {
  const AddMembersInviteCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasGeneratedCode.value) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.p20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TTexts.activeInviteCodeTitle.tr,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Text Mã mời
                  Expanded(
                    child: Text(
                      controller.activeInviteCode.value,
                      style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: AppColors.primary),
                    ),
                  ),

                  // 2. Dãy nút Action (Không nền trắng)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Copy
                      IconButton(
                        onPressed: controller.copyCode,
                        tooltip: TTexts.copyTooltip.tr, // ĐÃ FIX
                        icon: const Icon(Iconsax.copy_copy,
                            color: AppColors.primary, size: 22),
                      ),
                      // Nút Share
                      IconButton(
                        onPressed: controller.shareCode,
                        tooltip: TTexts.shareTooltip.tr, // ĐÃ FIX
                        icon: const Icon(Icons.share_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                      // Nút Refresh (Tạo mới qua Dialog)
                      IconButton(
                        onPressed: controller.onGenerateCodeTapped,
                        tooltip: TTexts.generateNewCodeTooltip.tr, // ĐÃ FIX
                        icon: const Icon(Iconsax.refresh_copy,
                            color: AppColors.primary, size: 22),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => controller.generatedTimeStr.value.isNotEmpty
                  ? Text(
                      "${TTexts.generatedAt.tr}${controller.generatedTimeStr.value}",
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subText))
                  : const SizedBox.shrink()),
            ],
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.onGenerateCodeTapped,
            icon: const Icon(Iconsax.add_square_copy, color: Colors.white),
            label: Text(
              TTexts.generateInviteCodeBtn.tr,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      }
    });
  }
}
