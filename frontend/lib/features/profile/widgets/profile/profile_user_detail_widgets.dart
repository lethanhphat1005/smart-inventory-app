import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Column(
      children: [
        const SizedBox(height: AppSizes.p12),

        // Hiển thị Tên
        Obx(() => Text(
              controller.fullName.value.isEmpty
                  ? TTexts.loading.tr
                  : controller.fullName.value,
              style: const TextStyle(
                fontSize: AppSizes.p20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            )),

        const SizedBox(height: AppSizes.p4),

        // Hiển thị Email
        Obx(() => Text(
              controller.email.value,
              style: const TextStyle(
                color: AppColors.subText,
                fontSize: AppSizes.p14,
              ),
            )),
      ],
    );
  }
}
