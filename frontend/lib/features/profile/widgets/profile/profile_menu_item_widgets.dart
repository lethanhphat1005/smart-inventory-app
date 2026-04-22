import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileMenuItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p4,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.4),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: AppColors.primary,
            size: AppSizes.p22,
          ),
          title: Text(
            title.tr,
            style: const TextStyle(
              fontSize: AppSizes.p15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Iconsax.arrow_right_3_copy,
            size: AppSizes.p14,
            color: AppColors.divider,
          ),
        ),
      ),
    );
  }
}
