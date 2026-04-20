import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
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
    switch (role.toLowerCase()) {
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

  String get displayName => name.trim().isEmpty ? 'Unknown User' : name.trim();

  String get displayRole {
    final value = role.trim();
    if (value.isEmpty) return 'Staff';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = getRoleColor();

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppSizes.p7,
        horizontal: AppSizes.p16,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          child: Ink(
            padding: const EdgeInsets.all(AppSizes.p14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius24),
              border: Border.all(
                color: roleColor.withOpacity(0.20),
                width: AppSizes.p1_2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: AppSizes.p16,
                  offset: const Offset(0, AppSizes.p6),
                ),
                BoxShadow(
                  color: roleColor.withOpacity(0.08),
                  blurRadius: AppSizes.p10,
                  offset: const Offset(0, AppSizes.p4),
                ),
              ],
            ),
            child: Row(
              children: [
                // AVATAR
                Container(
                  width: AppSizes.p58,
                  height: AppSizes.p58,
                  padding: const EdgeInsets.all(AppSizes.p3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        roleColor.withOpacity(0.18),
                        roleColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: image.trim().isNotEmpty
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                _buildPlaceholder(roleColor),
                          )
                        : _buildPlaceholder(roleColor),
                  ),
                ),

                const SizedBox(width: AppSizes.p14),

                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: AppSizes.p16_5,
                          color: AppColors.primaryText,
                          letterSpacing: AppSizes.p0_3,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getRoleIcon(),
                            size: AppSizes.p14,
                            color: roleColor.withOpacity(0.85),
                          ),
                          const SizedBox(width: AppSizes.p6),
                          Text(
                            displayRole,
                            style: TextStyle(
                              color: roleColor.withOpacity(0.85),
                              fontSize: AppSizes.p13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ICON
                Container(
                  width: AppSizes.p32,
                  height: AppSizes.p32,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.arrow_down,
                    size: AppSizes.p15,
                    color: roleColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      color: color.withOpacity(0.08),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }
}
