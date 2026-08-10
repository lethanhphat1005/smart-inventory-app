import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StoreItemWidget extends StatelessWidget {
  final String name;
  final String role;
  final String image;
  final VoidCallback? onTap;

  const StoreItemWidget({
    super.key,
    required this.name,
    required this.role,
    required this.image,
    this.onTap,
  });

  // Lấy màu sắc dựa trên role
  Color getRoleColor() {
    switch (role.trim().toLowerCase()) {
      case 'owner':
        return AppColors.gradientOrangeStart;
      case 'manager':
        return AppColors.gradientOrangeEnd;
      case 'staff':
        return AppColors.toastSuccessGradientStart;
      default:
        return AppColors.subText;
    }
  }

  IconData getRoleIcon() {
    switch (role.toLowerCase()) {
      case 'owner':
        return Iconsax.crown_copy;
      case 'manager':
        return Iconsax.briefcase_copy;
      case 'staff':
        return Iconsax.user_tag_copy;
      default:
        return Iconsax.user_copy;
    }
  }

  String get displayRole {
    switch (role.trim().toLowerCase()) {
      case 'owner':
        return TTexts.roleOwner.tr;
      case 'manager':
        return TTexts.roleManager.tr;
      case 'staff':
        return TTexts.roleStaff.tr;
      default:
        return role;
    }
  }

  String get displayName =>
      name.trim().isEmpty ? TTexts.unknownUser.tr : name.trim();

  @override
  Widget build(BuildContext context) {
    final roleColor = getRoleColor();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(
          color: roleColor.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p4,
        ),
        // AVATAR
        leading: Container(
          width: AppSizes.p40,
          height: AppSizes.p40,
          padding: const EdgeInsets.all(AppSizes.p2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: roleColor.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: image.trim().isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _buildPlaceholder(roleColor),
                  )
                : _buildPlaceholder(roleColor),
          ),
        ),
        // TEXT (NAME)
        title: Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.p15,
            color: AppColors.primaryText,
          ),
        ),
        // SUBTITLE (ROLE)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSizes.p4),
          child: Row(
            children: [
              Icon(
                getRoleIcon(),
                size: AppSizes.p14,
                color: roleColor.withOpacity(0.85),
              ),
              const SizedBox(width: AppSizes.p4),
              Text(
                displayRole,
                style: TextStyle(
                  color: roleColor.withOpacity(0.85),
                  fontSize: AppSizes.p12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // ICON (TRAILING)
        trailing: Icon(
          Iconsax.arrow_down,
          size: AppSizes.p16,
          color: AppColors.subText.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: AppSizes.p16,
        ),
      ),
    );
  }
}
