import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TUserInfoBottomSheetWidgets extends StatelessWidget {
  final StoreMemberModel member;

  const TUserInfoBottomSheetWidgets({
    super.key,
    required this.member,
  });

  static void show(StoreMemberModel member) {
    TBottomSheetWidget.show(
      title: TTexts.profileMemberInfo.tr,
      child: TUserInfoBottomSheetWidgets(member: member),
    );
  }

  // COLOR
  Color get roleColor {
    switch (member.role.trim().toLowerCase()) {
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

  String get roleText {
    switch (member.role.trim().toLowerCase()) {
      case 'owner':
        return TTexts.roleOwner.tr;

      case 'manager':
        return TTexts.roleManager.tr;

      case 'staff':
        return TTexts.roleStaff.tr;

      default:
        return member.role;
    }
  }

  Color get roleBg => roleColor.withOpacity(0.12);

  String get displayName =>
      member.name.trim().isEmpty ? TTexts.unknownUser.tr : member.name.trim();

  String get displayPhone => member.phone.trim().isEmpty
      ? TTexts.profileNoPhoneNumber.tr
      : member.phone.trim();

  String get displayAddress => member.address.trim().isEmpty
      ? TTexts.profileNoAddress.tr
      : member.address.trim();

  String get displayEmail => member.email.trim().isEmpty
      ? TTexts.profileNoEmail.tr
      : member.email.trim();

  // ui
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
              fontSize: AppSizes.p28,
              fontWeight: FontWeight.w900,
              color: roleColor,
            ),
          ),
        ),

        const SizedBox(height: AppSizes.p16),

        // name
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppSizes.p20,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: AppSizes.p6),

        // role chips
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p12,
            vertical: AppSizes.p6,
          ),
          decoration: BoxDecoration(
            color: roleBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            roleText.toUpperCase(),
            style: TextStyle(
              fontSize: AppSizes.p12,
              fontWeight: FontWeight.w700,
              color: roleColor,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: AppSizes.p24),

        // ===== INFO =====
        _infoTile(Iconsax.call_copy, TTexts.profilePhoneNumberBottomSheet.tr,
            displayPhone),
        const SizedBox(height: AppSizes.p12),

        _infoTile(
            Iconsax.sms_copy, TTexts.profileEmailBottomSheet.tr, displayEmail),
        const SizedBox(height: AppSizes.p12),

        _infoTile(Iconsax.location_copy, TTexts.profileAddressBottomSheet.tr,
            displayAddress),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.p20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: AppSizes.p12,
            offset: const Offset(0, AppSizes.p4),
          ),
        ],
      ),
      child: Row(
        children: [
          // icon box
          Container(
            width: AppSizes.p40,
            height: AppSizes.p40,
            decoration: BoxDecoration(
              color: roleBg,
              borderRadius: BorderRadius.circular(AppSizes.p12),
            ),
            child: Icon(
              icon,
              size: AppSizes.p18,
              color: roleColor,
            ),
          ),

          const SizedBox(width: AppSizes.p12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppSizes.p12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: AppSizes.p3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppSizes.p14,
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
