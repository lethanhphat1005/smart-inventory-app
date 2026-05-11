// lib/features/workspace/widgets/workspace_ready/workspace_ready_actions_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class WorkspaceReadyActionsWidget extends StatelessWidget {
  const WorkspaceReadyActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.storeSelection),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              side: BorderSide(
                  color: AppColors.softGrey.withOpacity(0.5), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12)),
            ),
            child: Text(
              TTexts.backToWorkspaces.tr,
              style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.main),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12)),
            ),
            child: Text(
              TTexts.goToDashboard.tr,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
