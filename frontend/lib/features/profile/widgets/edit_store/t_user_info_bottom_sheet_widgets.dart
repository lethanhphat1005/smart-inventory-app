import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TUserInfoBottomSheetWidgets extends StatelessWidget {
  final StoreMemberModel member;

  const TUserInfoBottomSheetWidgets({
    super.key,
    required this.member,
  });

  static void show(StoreMemberModel member) {
    TBottomSheetWidget.show(
      title: "Member Information",
      child: TUserInfoBottomSheetWidgets(member: member),
    );
  }

  // ===== COLOR =====
  Color get roleColor {
    switch (member.role.toLowerCase()) {
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

  Color get roleBg => roleColor.withOpacity(0.12);

  String get displayName =>
      member.name.trim().isEmpty ? 'Unknown User' : member.name.trim();

  String get displayPhone => member.phone.trim().isEmpty
      ? 'Chưa có số điện thoại'
      : member.phone.trim();

  String get displayAddress =>
      member.address.trim().isEmpty ? 'Chưa có địa chỉ' : member.address.trim();

  String get displayEmail =>
      member.email.trim().isEmpty ? 'Chưa có email' : member.email.trim();

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // avatar
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                roleColor.withOpacity(0.25),
                roleColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            displayName[0].toUpperCase(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: roleColor,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // name
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 6),

        // role chips
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: roleBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            member.role.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: roleColor,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ===== INFO =====
        _infoTile(Iconsax.call_copy, "Số điện thoại", displayPhone),
        const SizedBox(height: 12),

        _infoTile(Iconsax.sms_copy, "Email", displayEmail),
        const SizedBox(height: 12),

        _infoTile(Iconsax.location_copy, "Địa chỉ", displayAddress),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: roleBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: roleColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
