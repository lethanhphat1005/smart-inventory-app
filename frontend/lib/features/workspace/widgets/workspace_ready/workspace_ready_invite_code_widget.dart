import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class WorkspaceReadyInviteCodeWidget extends StatelessWidget {
  final String inviteCode;

  const WorkspaceReadyInviteCodeWidget({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          TTexts.inviteCodeTitle.tr,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          TTexts.inviteCodeSubtitle.tr,
          style: const TextStyle(fontSize: 12, color: AppColors.subText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.p12),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p24, vertical: AppSizes.p12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                inviteCode,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  TSnackbarsWidget.success(
                    title: TTexts.inviteCodeCopiedTitle.tr,
                    message: TTexts.inviteCodeCopiedMessage.tr,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                  ),
                  child: const Icon(Iconsax.copy_copy,
                      color: Colors.white, size: 18),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
